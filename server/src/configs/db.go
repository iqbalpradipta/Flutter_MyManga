package configs

import (
	"context"
	"log"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"google.golang.org/api/option"
)

func InitDB() *firestore.Client  {
	ctx := context.Background()

	sa := option.WithCredentialsFile("./mangabal-d5010-firebase-adminsdk-fbsvc-4e2e6da1d4.json")
	app, err := firebase.NewApp(ctx, nil, sa)

	if err != nil {
		log.Fatalf("Error when initializing app: %v\n", err)
	}

	client, err := app.Firestore(ctx);
	if err != nil {
		log.Fatalf("Error when firestore client: %v\n", err)
	}

	return client
}