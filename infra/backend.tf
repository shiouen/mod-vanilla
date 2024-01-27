terraform {
  backend "gcs" {
    bucket = "rt-terraform-backends"
    prefix = "github.com/shiouen/mod-vanilla"
  }
}
