package configs

import (
	"context"
	"log"
	"os"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"google.golang.org/api/option"
)

func InitDB() *firestore.Client  {
	ctx := context.Background()


	credentialsJSON := os.Getenv("FIREBASE_CREDENTIALS_JSON")
	if credentialsJSON == "" {
		log.Fatal("FIREBASE_CREDENTIALS_JSON environment variable not set")
	}

	sa := option.WithCredentialsJSON([]byte(credentialsJSON))
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