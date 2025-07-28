package services

import (
	"context"
	"errors"
	"log"

	"cloud.google.com/go/firestore"
	"cloud.google.com/go/firestore/apiv1/firestorepb"
	"github.com/iqbalpradipta/Flutter_MyManga/tree/main/server/src/models"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type ComicStruct interface {
	CreateData(data *models.Comic) error
	GetData(page, limit int) ([]models.Comic, int, error)
	GetDataById(id string) (models.Comic, error)
	UpdateData(id string, data *models.Comic) error
	DeleteData(id string) error
	ImportFromJSON(data []models.Comic) (int, error)
}

type comicService struct {
	db *firestore.Client
}

func NewComicService(db *firestore.Client) ComicStruct {
	return &comicService{db}
}

func (c *comicService) ImportFromJSON(data []models.Comic) (int, error) {
	ctx := context.Background()
	importedCount := 0

	for _, comic := range data {
		docRef := c.db.Collection("comics").Doc(comic.ID)

		_, err := docRef.Get(ctx)

		if err == nil {
			log.Printf("Skipping comic ID %s, data sudah ada.", comic.ID)
			continue 
		}

		if status.Code(err) != codes.NotFound {
			log.Printf("Error saat memeriksa comic ID %s: %v", comic.ID, err)
			continue
		}

		if _, err := docRef.Set(ctx, comic); err != nil {
			log.Printf("Gagal impor comic %s: %v", comic.ID, err)
		} else {
			importedCount++
		}
	}

	return importedCount, nil
}

func (c *comicService) CreateData(data *models.Comic) error {
	ctx := context.Background()

	_, err := c.db.Collection("comics").Doc(data.ID).Set(ctx, data)
	return err
}

func (c *comicService) GetData(page, limit int) ([]models.Comic, int, error) {
	ctx := context.Background()
	var comics []models.Comic
	comicsCollection := c.db.Collection("comics")

	// --- PERBAIKAN FINAL UNTUK MENGHITUNG TOTAL ITEM ---

	aggQuery := comicsCollection.NewAggregationQuery().WithCount("all")
	results, err := aggQuery.Get(ctx)
	if err != nil {
		return nil, 0, err
	}

	countValue, ok := results["all"]
	if !ok {
		return []models.Comic{}, 0, nil // Koleksi kosong, kembalikan nilai nol
	}

	// 1. Assert tipe data ke *firestorepb.Value
	valueProto, ok := countValue.(*firestorepb.Value)
	if !ok {
		return nil, 0, errors.New("gagal mengonversi hasil agregasi ke tipe proto")
	}

	// 2. Ambil nilai integer dari dalam objek proto tersebut
	totalItems := valueProto.GetIntegerValue()

	// --- AKHIR PERBAIKAN ---

	// Jika tidak ada item, tidak perlu query lagi
	if totalItems == 0 {
		return []models.Comic{}, 0, nil
	}
	
	offset := (page - 1) * limit
	iter := comicsCollection.
		OrderBy("id", firestore.Asc).
		Limit(limit).
		Offset(offset).
		Documents(ctx)

	docs, err := iter.GetAll()
	if err != nil {
		return nil, 0, err
	}

	for _, doc := range docs {
		var comic models.Comic
		if err := doc.DataTo(&comic); err != nil {
			return nil, 0, err
		}
		comics = append(comics, comic)
	}

	return comics, int(totalItems), nil
}

func (c *comicService) GetDataById(id string) (models.Comic, error) {
	ctx := context.Background()
	var comic models.Comic

	data := c.db.Collection("comics").Where("id", "==", id).Limit(1).Documents(ctx)
	docs, err := data.GetAll()
	if err != nil {
		return comic, err
	}

	if len(docs) == 0 {
		return comic, errors.New("comic not found")
	}

	if err := docs[0].DataTo(&comic); err != nil {
		return comic, err
	}

	return comic, nil
}

func (c *comicService) UpdateData(id string, data *models.Comic) error {
	ctx := context.Background()

	docRef := c.db.Collection("comics").Doc(id)

	_, err := docRef.Update(ctx, []firestore.Update{
		{Path: "title", Value: data.Title},
		{Path: "type", Value: data.Type},
		{Path: "genre", Value: data.Genres},
		{Path: "status", Value: data.Status},
		{Path: "author", Value: data.Author},
		{Path: "release", Value: data.Released},
		{Path: "update_on", Value: data.UpdateOn},
		{Path: "comic_image", Value: data.ComicImage},
		{Path: "comic_url", Value: data.ComicUrl},
		{Path: "rating", Value: data.Rating},
	})
	return err
}

func (c *comicService) DeleteData(id string) error {
	ctx := context.Background()

	_, err := c.db.Collection("comics").Doc(id).Delete(ctx)

	return err
}
