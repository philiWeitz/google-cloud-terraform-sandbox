output "hello_world_url" {
  value = google_cloudfunctions_function.hello_world_function.https_trigger_url
}