terraform {
  backend "gcs" {
    # Configure with backend config file or -backend-config flags
    # terraform init -backend-config=dev.gcs.tfbackend
  }
}
