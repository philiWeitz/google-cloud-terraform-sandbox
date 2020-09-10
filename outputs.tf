output "hello_world_url" {
  value = google_cloudfunctions_function.hello_world_function.https_trigger_url
}

output "db_password" {
  value = google_secret_manager_secret_version.db_secret_password_version.secret_data
}

output "db_user" {
  value = google_secret_manager_secret_version.db_secret_user_version.secret_data
}