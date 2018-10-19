Minimal reproduction for https://github.com/terraform-providers/terraform-provider-vault/issues/115

## Steps to reproduce:

1. Start Postgres and Vault via docker-compose: `docker-compose up`, wait for it to finish starting.
2. Apply Terraform `terraform apply --auto-approve`
3. Apply Terraform again `terraform apply --auto-approve`

## Notes:

First run of Terraform works as expected and creates the mount and the database connection.  After the first run `terraform plan` shows the plugin wants to update the connection string of the resource:

```
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

vault_mount.db: Refreshing state... (ID: postgres)
vault_database_secret_backend_connection.postgres: Refreshing state... (ID: postgres/config/postgres)

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  ~ vault_database_secret_backend_connection.postgres
      postgresql.0.connection_url: "*****://*****:*****@*****:5432/*****?sslmode=disable" => "postgres://postgres:postgres@postgres:5432/postgres?sslmode=disable"


Plan: 0 to add, 1 to change, 0 to destroy.
```

This appears to be due to the fact that Vault masks the connection string on the read configuration call:

```
$ curl -s http://localhost:8200/v1/postgres/config/postgres -H "X-Vault-Token: test_token" | jq
{
  "request_id": "e78cd79d-ff1f-f214-bd38-acd2452dc403",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": {
    "allowed_roles": [],
    "connection_details": {
      "connection_url": "*****://*****:*****@*****:5432/*****?sslmode=disable",
      "max_open_connections": 2
    },
    "plugin_name": "postgresql-database-plugin",
    "root_credentials_rotate_statements": []
  },
  "wrap_info": null,
  "warnings": null,
  "auth": null
}
```