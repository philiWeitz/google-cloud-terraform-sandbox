# google-cloud-terraform-sandbox

## install dependencies
- install google cloud sdk ```brew cask install google-cloud-sdk```
- install terraform ```brew install terraform```

## prepare your environment
- create a new terraform service account
- add the following permissions: 
    - App Engine Creator
    - Cloud Functions Admin
    - Cloud Scheduler Admin
    - Cloud SQL Admin
    - Pub/Sub Admin
    - Project IAM Admin
    - Storage Admin
    - Service Account User
    - Secret Manager
- create and download a key for the created service account (.json key file)
- copy the key to the project root folder and rename it to "google_cloud_key_develop.json"
- enable the following APIs (https://console.cloud.google.com/apis/library):
    - Cloud Pub/Sub API
    - Cloud Scheduler API
    - Cloud Functions API
    - Cloud SQL Admin API
    - App Engine Admin API
    - Cloud Build API
    - Secret Manager API

## run terraform 
- terraform apply -var project_id=[your project id] -var-file=environments/develop/variables.tfvars