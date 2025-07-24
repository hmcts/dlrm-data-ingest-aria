removed {
  from = databricks_dbfs_file.config_file_sbox02

  lifecycle {
    destroy = true
  }
}

removed {
  from = databricks_secret_scope.kv-scope-sbox02

  lifecycle {
    destroy = true
  }
}

