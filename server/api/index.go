package handler

import (
	"log"
	"net/http"

	"github.com/iqbalpradipta/Flutter_MyManga/tree/main/server/src/configs"
	"github.com/iqbalpradipta/Flutter_MyManga/tree/main/server/src/routes"
	"github.com/joho/godotenv"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func Handler(w http.ResponseWriter, r *http.Request) {
	err := godotenv.Load()
	if err != nil {
		log.Printf("Error loading .env file")
	}

	db := configs.InitDB()

	e := echo.New()
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"*"},
		AllowMethods: []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete},
	}))

	routes.Routes(e, db)

	e.ServeHTTP(w, r)
}