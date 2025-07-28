package routes

import (
	"cloud.google.com/go/firestore"
	"github.com/iqbalpradipta/Flutter_MyManga/tree/main/server/src/controllers"
	"github.com/iqbalpradipta/Flutter_MyManga/tree/main/server/src/services"
	"github.com/labstack/echo/v4"
)

func Routes(e *echo.Echo, client *firestore.Client) {
	api := e.Group("/api/v1")

	comicService := services.NewComicService(client)
	comicControllers := controllers.NewComicController(comicService)
	ComicRoutes(api, comicControllers)
}