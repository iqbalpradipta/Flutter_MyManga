package services

import (
	"context"
	"errors"

	"cloud.google.com/go/firestore"
	"github.com/iqbalpradipta/Flutter_MyManga/tree/main/server/src/models"
)

type ComicStruct interface {
	Create(data *models.Comic) error
	GetData() ([]models.Comic, error)
	GetDataByid(id string) (models.Comic, error)
	UpdateData(id string, data *models.Comic) error
	Delete(id string) error
}

type comicService struct {
	db *firestore.Client
}

func NewComicService(db *firestore.Client) ComicStruct {
	return &comicService{db}
}

func (c *comicService) Create(data *models.Comic) error {
	ctx := context.Background()

	_, err := c.db.Collection("comic").Doc(data.ID).Set(ctx, data)
	return err
}

func (c *comicService) GetData() ([]models.Comic, error) {
	ctx := context.Background()
	var comics []models.Comic

	data := c.db.Collection("comic").Documents(ctx)
	docs, err := data.GetAll(); if err != nil {
		return nil, err
	}

	for _, doc := range docs {
		var comic models.Comic
		if err := doc.DataTo(&comic); err != nil {
			return nil, err
		}
		comics = append(comics, comic)
	}
	return comics, nil
}

func (c *comicService) GetDataByid(id string) (models.Comic, error) {
	ctx := context.Background()
	var comic models.Comic

	data := c.db.Collection("comic").Where("id", "==", id).Limit(1).Documents(ctx)
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

	docRef := c.db.Collection("comic").Doc(id)

	_, err := docRef.Update(ctx, []firestore.Update{
		{Path: "title", Value: data.Title},
		{Path: "type", Value: data.Type},
		{Path: "genre", Value: data.Genre},
		{Path: "status", Value: data.Status},
		{Path: "author", Value: data.Author},
		{Path: "release", Value: data.Release},
		{Path: "update_on", Value: data.Update_on},
		{Path: "comic_image", Value: data.Comic_image},
		{Path: "comic_url", Value: data.Comic_url},
		{Path: "rating", Value: data.Rating},
	})
	return err
}

func (c *comicService) Delete(id string) error {
	ctx := context.Background()

    _, err := c.db.Collection("comics").Doc(id).Delete(ctx)

    return err
}

