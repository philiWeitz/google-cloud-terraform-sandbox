# google-cloud-terraform-sandbox

## install dependencies
- install google cloud sdk ```brew cask install google-cloud-sdk```
- install terraform ```brew install terraform```

## prepare your environment
- create a new terraform service account
- add the following permissions (needs cleanup): 
    - App Engine Admin
    - App Engine Creator
    - Cloud Functions Admin
    - Cloud Scheduler Admin
    - Cloud SQL Admin
    - Service Account Admin
    - Create Service Accounts
    - Service Account User
    - Pub/Sub Admin
    - Project IAM Admin
    - Storage Admin
- create and download a key for the created service account (.json key file)
- copy the key to the project root folder

## run terraform 
- terraform apply -var google_key_file=<your key json file>  -var project_id=<your project id>