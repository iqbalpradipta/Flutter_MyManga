package models

type Comic struct {
	ID          string      `firestore:"id" json:"id"`
	Title       string   `firestore:"title" json:"title"`
	Genre       []string `firestore:"genre" json:"genre"`
	Status      string   `firestore:"status" json:"status"`
	Author      string   `firestore:"author" json:"author"`
	Release     string   `firestore:"release" json:"release"`
	Type        string   `firestore:"type" json:"type"`
	Update_on   string   `firestore:"update_on" json:"update_on"`
	Comic_image string   `firestore:"comic_image" json:"comic_image"`
	Comic_url   string   `firestore:"comic_url" json:"comic_url"`
	Rating      string   `firestore:"rating" json:"rating"`

	Chapters []Chapter `firestore:"chapters" json:"chapters"`
}