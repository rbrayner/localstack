package main

import (
    "fmt"
    "github.com/aws/aws-lambda-go/lambda"
)

// MyEvent is a thing
type MyEvent struct {
    Name string `json:"name"`
}

// HandleRequest for an event
func HandleRequest(name MyEvent) (string, error) {
    return fmt.Sprintf("hi %s", name.Name), nil
}

func main() {
    lambda.Start(HandleRequest)
}