package controllers

import (
	"math"
	"net/http"
	"net/url"
	"strconv"

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

func (cs *ComicControllers) GetData(c echo.Context) error {
	pageStr := c.QueryParam("page")
	limitStr := c.QueryParam("limit")
	searchQuery := c.QueryParam("q")
	genreQuery := c.QueryParam("genre")
	statusQuery := c.QueryParam("status")

	if searchQuery != "" {
		decodedQuery, err := url.QueryUnescape(searchQuery)
		if err == nil {
			searchQuery = decodedQuery
		}
	}

	page, err := strconv.Atoi(pageStr)
	if err != nil || page < 1 {
		page = 1
	}

	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit < 1 {
		limit = 20 
	}

	data, totalItems, err := cs.ComicStruct.GetData(page, limit, searchQuery, genreQuery, statusQuery)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"status":   "Failed",
			"messages": "Failed to get data",
			"error":    err.Error(),
		})
	}

	totalPages := int(math.Ceil(float64(totalItems) / float64(limit)))

	return c.JSON(http.StatusOK, echo.Map{
		"status": "Success",
		"pagination": echo.Map{
			"current_page": page,
			"total_items":  totalItems,
			"total_pages":  totalPages,
		},
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