package controllers

import (
	"net/http"

	"github.com/iqbalpradipta/Flutter_MyManga/tree/main/server/src/models"
	"github.com/iqbalpradipta/Flutter_MyManga/tree/main/server/src/services"
	"github.com/labstack/echo/v4"
)

type ComicControllers struct {
	services.ComicStruct
}

func NewComicController(cs services.ComicStruct) *ComicControllers  {
	return &ComicControllers{cs}
}

func (cs *ComicControllers) ImportFromJSON(c echo.Context) error {
	var comics []models.Comic

	if err := c.Bind(&comics); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"status": "Failed",
			"messages": "Invalid JSON format",
			"err": err,
		})
	}

	if len(comics) == 0 {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"status": "Failed",
			"messages": "JSON array cannot be empty",
		})
	}

	importedCount, err := cs.ComicStruct.ImportFromJSON(comics)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"status": "Failed",
			"messages": "Failed during import process",
		})
	}

	return c.JSON(http.StatusCreated, echo.Map{
		"status": "Success",
		"message": "Import successful",
		"imported_count": importedCount,
	})
}

func(cs *ComicControllers) CreateData(c echo.Context) error  {
	var data models.Comic

	if err := c.Bind(&data); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"status": "Failed",
			"messages": "Bind data failed",
		})
	}

	if err := cs.ComicStruct.CreateData(&data); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"status": "Failed",
			"messages": "Failed to create new comic!",
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"status": "Success",
		"messages": "Create comic success",
	})
}

func(cs *ComicControllers) GetData(c echo.Context) error {
	data, err := cs.ComicStruct.GetData(); if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"status": "Failed",
			"messages": "Failed to get data",
			"error": err,
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"status": "Success",
		"messages": "Get Data Success",
		"data": data,
	})
}

func(cs *ComicControllers) GetDataById(c echo.Context) error {
	id := c.Param("id")

	data, err := cs.ComicStruct.GetDataById(id); if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"status": "Failed",
			"messages": "Failed to get data by ID",
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"status": "Success",
		"messages": "Get Data By ID Success",
		"data": data,
	})
}

func(cs *ComicControllers) UpdateData(c echo.Context) error {
	var data models.Comic
	id := c.Param("id")

	comicData, err := cs.ComicStruct.GetDataById(id); if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"status": "Failed",
			"messages": "Failed to find data for update.",
		})
	}

	err = c.Bind(&data); if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"status": "Failed",
			"messages": "Bind data failed",
		})
	} 

	err = cs.ComicStruct.UpdateData(id, &data); if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"status": "Failed",
			"messages": "Failed to Update data",
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"status": "Success",
		"messages": "Success Update data",
		"data": comicData,
	})
}

func(cs *ComicControllers) DeleteData(c echo.Context) error {
	id := c.Param("id")

	data, err := cs.ComicStruct.GetDataById(id); if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"status": "Failed",
			"messages": "Failed find data to delete",
		})
	}

	err = cs.ComicStruct.DeleteData(id); if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"status": "Failed",
			"messages": "Failed to delete data.",
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"status": "Success",
		"messages": "Get Data By ID Success",
		"data": data,
	})
}



