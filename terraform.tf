provider "vault" {
    address = "http://localhost:8200"
    token = "test_token"
}

resource "vault_mount" "db" {
  path = "postgres"
  type = "database"
}

resource "vault_database_secret_backend_connection" "postgres" {
  backend       = "${vault_mount.db.path}"
  name          = "postgres"

  postgresql {
    connection_url = "postgres://postgres:postgres@postgres:5432/postgres?sslmode=disable"
  }
}