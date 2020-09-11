variable "region" {
    type = string
    default = "europe-west1"
}

variable "region_app_engine" {
    type = string
    default = "europe-west"
}

variable "project_id" {
    type = string
}

variable "cron_schedule_every_ten_minutes" {
    type = string
    default = "*/10 * * * *"
}

variable "google_key_file" {
    type = string
}

variable "sql_db_instance_type" {
    type = string
}
