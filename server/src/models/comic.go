package models

type Comic struct {
	ID         string   `firestore:"id" json:"id"`
	Title      string   `firestore:"title" json:"title"`
	Type       string   `firestore:"type" json:"type"`
	ComicImage string   `firestore:"comic_image" json:"comic_image"`
	ComicUrl   string   `firestore:"comic_url" json:"comic_url"`
	Rating     string   `firestore:"rating" json:"rating"`
	Status     string   `firestore:"status" json:"status"`
	Author     string   `firestore:"author" json:"author"`
	Released   string   `firestore:"released" json:"released"`
	UpdateOn   string   `firestore:"updated_on" json:"updated_on"`
	Genres     []string `firestore:"genres" json:"genres"`
	Chapters []Chapter `firestore:"chapters" json:"chapters"`
}