package routes

import (
	"github.com/iqbalpradipta/Flutter_MyManga/tree/main/server/src/controllers"
	"github.com/labstack/echo/v4"
)

func ComicRoutes(e *echo.Group, c *controllers.ComicControllers) {
	e.GET("/comic", c.GetData)
	e.GET("/comic/:id", c.GetDataById)
	e.POST("/comic", c.CreateData)
	e.POST("/comic/imports", c.ImportFromJSON)
	e.PUT("/comic", c.UpdateData)
	e.DELETE("/comic", c.DeleteData)
}