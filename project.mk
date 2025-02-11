PROJECT_NAME := configuration-dbaas
UPTEST_INPUT_MANIFESTS := examples/postgres-aws-claim.yaml,examples/mariadb-aws-claim.yaml,examples/postgres-azure-claim.yaml,examples/mariadb-azure-claim.yaml,examples/postgres-gcp-claim.yaml,examples/mysql-gcp-claim.yaml
UPTEST_SKIP_UPDATE := true
UPTEST_SKIP_IMPORT := true
