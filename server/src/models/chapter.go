package models

type Chapter struct {
	ChapterTitle string   `firestore:"chapter_title" json:"chapter_title"`
	ChapterURL   string   `firestore:"chapter_url" json:"chapter_url"`
	UploadTime   string   `firestore:"upload_time" json:"upload_time"`
	Images       []string `firestore:"images" json:"images"`
}