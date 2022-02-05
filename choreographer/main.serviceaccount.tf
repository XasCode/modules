resource "google_service_account" "terraform_account" {
  count        = contains(var.envs, var.environment) ? length(var.managed) : 0
  project      = var.managed[count.index].id
  account_id   = "terraform-sa-${var.managed[count.index].name}-${var.environment}"
  display_name = "terraform-sa-${var.managed[count.index].name}-${var.environment}"
}

resource "google_service_account_key" "mykey" {
  count              = contains(var.envs, var.environment) ? length(var.managed) : 0
  service_account_id = google_service_account.terraform_account[count.index].name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_project_iam_binding" "project" {
  count              = contains(var.envs, var.environment) ? length(var.managed) : 0
  project            = var.managed[count.index].id
  
  role    = "roles/owner"
  members = [
    "serviceAccount:${google_service_account.terraform_account[count.index].email}",
  ]
}

resource "google_storage_bucket_iam_binding" "binding" {
  count              = contains(var.envs, var.environment) ? length(var.managed) : 0
  bucket             = google_storage_bucket.bucket[count.index].name
  role               = "roles/storage.admin"
  members = [
    "serviceAccount:${google_service_account.terraform_account[count.index].email}",
  ]
}

resource "google_storage_bucket_iam_binding" "object_binding" {
  count              = contains(var.envs, var.environment) ? length(var.managed) : 0
  bucket             = google_storage_bucket.bucket[count.index].name
  role               = "roles/storage.objectAdmin"
  members = [
    "serviceAccount:${google_service_account.terraform_account[count.index].email}",
  ]
}
