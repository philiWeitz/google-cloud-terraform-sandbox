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
    default = "infrastructure-sandbox-289010"
}

variable "cron_schedule_every_ten_minutes" {
    type = string
    default = "*/10 * * * *"
}
