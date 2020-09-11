provider "google" {
 credentials = file(var.google_key_file)
 project     = var.project_id
 region      = var.region
}

# generate a random DB password
resource "random_password" "db" {
  length = 24
  special = true
  override_special = "_%@"
}

# create a secret entry
resource "google_secret_manager_secret" "db_secret_password" {
  secret_id = "db_password"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "db_secret_password_version" {
  secret = google_secret_manager_secret.db_secret_password.id
  secret_data = random_password.db.result
}

resource "google_secret_manager_secret" "db_secret_user" {
  secret_id = "db_user"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "db_secret_user_version" {
  secret = google_secret_manager_secret.db_secret_user.id
  secret_data = "postgres"
}


# create SQL server
resource "google_sql_database_instance" "master" {
 name             = "master-instance"
 database_version = "POSTGRES_12"
 region           = var.region

 settings {
    tier = var.sql_db_instance_type

    ip_configuration {
      authorized_networks {
        # should be removed for production
        name  = "Allow all"
        value = "0.0.0.0/0"
      }
    }
  }
}

# create postgres user
resource "google_sql_user" "postgres_user" {
  instance = google_sql_database_instance.master.name
  name     = google_secret_manager_secret_version.db_secret_user_version.secret_data
  password = google_secret_manager_secret_version.db_secret_password_version.secret_data
}

# create a database
provider "postgresql" {
  host            = google_sql_database_instance.master.first_ip_address
  port            = 5432
  username        = google_secret_manager_secret_version.db_secret_user_version.secret_data
  password        = google_secret_manager_secret_version.db_secret_password_version.secret_data
  connect_timeout = 15
}

resource "postgresql_database" "my_db" {
  name              = "my_db"
  owner             = google_secret_manager_secret_version.db_secret_user_version.secret_data
  template          = "template0"
  lc_collate        = "en_US.UTF8"
  connection_limit  = -1
  allow_connections = true
}

# create a bucket
resource "google_storage_bucket" "file_storage" {
  name          = "${var.project_id}_file_storage_bucket"
  location      = var.region
  force_destroy = true
  versioning {
    enabled = true
  }
}


# create a zip file out of a cloud function folder
data "archive_file" "hello_world_zip" {
  type        = "zip"
  source_dir  = "${path.root}/hello_world/"
  output_path = "${path.root}/hello_world.zip"
}

# create a bucket for storing our cloud function zip file
resource "google_storage_bucket" "deploy_bucket" {
  name    = "${var.project_id}_deploy_bucket"
}

# upload the zip file to the deploy bucket
resource "google_storage_bucket_object" "hello_world_zip" {
  name   = "hello_world.zip"
  bucket = google_storage_bucket.deploy_bucket.name
  source = "${path.root}/hello_world.zip"
}

# create a cloud function
resource "google_cloudfunctions_function" "hello_world_function" {
  name                  = "hello_world_function"
  description           = "Scheduled Hello World Function"
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.deploy_bucket.name
  source_archive_object = google_storage_bucket_object.hello_world_zip.name
  timeout               = 60
  entry_point           = "hello_world"
  trigger_http          = true
  runtime               = "python37"
}

# all users to invoke the cloud function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.hello_world_function.project
  region         = google_cloudfunctions_function.hello_world_function.region
  cloud_function = google_cloudfunctions_function.hello_world_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

# create a cloud function
resource "google_cloudfunctions_function" "hello_bucket_function" {
  name                  = "hello_bucket_function"
  description           = "On File Upload Function"
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.deploy_bucket.name
  source_archive_object = google_storage_bucket_object.hello_world_zip.name
  timeout               = 60
  entry_point           = "hello_bucket"
  runtime               = "python37"

  event_trigger {
    event_type  = "google.storage.object.finalize"
    resource = google_storage_bucket.file_storage.name
  }
}

# all users to invoke the cloud function
resource "google_cloudfunctions_function_iam_member" "bucket-invoker" {
  project        = google_cloudfunctions_function.hello_bucket_function.project
  region         = google_cloudfunctions_function.hello_bucket_function.region
  cloud_function = google_cloudfunctions_function.hello_bucket_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

# create an app engine instance to run a cron job on
# resource "google_app_engine_application" "hello_world_scheduler_app" {
#   project     = var.project_id
#   location_id = var.region_app_engine
# }

# create a scheduler which invokes the cloud function ever x minutes
resource "google_cloud_scheduler_job" "job" {
  name             = "test-job"
  description      = "test http job"
  schedule         = var.cron_schedule_every_ten_minutes
  attempt_deadline = "60s"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "GET"
    uri         = google_cloudfunctions_function.hello_world_function.https_trigger_url
  }
}

# create a pub/sub topic and subscription
resource "google_pubsub_topic" "example_topic" {
  name = "example_topic"
}

resource "google_pubsub_subscription" "example_subscription" {
  name  = "example_subscription"
  topic = google_pubsub_topic.example_topic.name

  ack_deadline_seconds = 20

  push_config {
    push_endpoint = google_cloudfunctions_function.hello_world_function.https_trigger_url
  }
}