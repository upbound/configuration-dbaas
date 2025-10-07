import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.dbaas.v1alpha1 as dbaasv1alpha1
import models.io.k8s.api.core.v1 as k8sv1
import models.io.upbound.aws.v1beta1 as awsv1beta1

_postgres_secret = k8sv1.Secret{
    metadata = {
        name = "e2e-postgres-secret-aws"
        namespace = "default"
    }
    type = "Opaque"
    data = {
        password = "dXBiMHVuZHIwY2s1ITMxMzM3"  # base64 encoded password
    }
}

_mariadb_secret = k8sv1.Secret{
    metadata = {
        name = "e2e-mariadb-secret-aws"
        namespace = "default"
    }
    type = "Opaque"
    data = {
        password = "dXBiMHVuZHIwY2s1ITMxMzM3"  # base64 encoded password
    }
}

_postgres_xr = dbaasv1alpha1.XSQLInstance{
    metadata = {
        name = "e2e-postgres-aws"
    }
    spec = {
        parameters = {
            provider = "aws"
            region = "us-west-2"
            engine = "postgres"
            engineVersion = "16.3"
            storageGB = 5
            passwordSecretRef = {
                namespace = "default"
                name = "e2e-postgres-secret-aws"
                key = "password"
            }
            deletionPolicy = "Delete"
            providerConfigName = "default"
        }
        writeConnectionSecretToRef = {
            name = "e2e-postgres-aws-conn"
            namespace = "default"
        }
    }
}

_mariadb_xr = dbaasv1alpha1.XSQLInstance{
    metadata = {
        name = "e2e-mariadb-aws"
    }
    spec = {
        parameters = {
            provider = "aws"
            region = "us-west-2"
            engine = "mariadb"
            engineVersion = "10.11"
            storageGB = 5
            passwordSecretRef = {
                namespace = "default"
                name = "e2e-mariadb-secret-aws"
                key = "password"
            }
            deletionPolicy = "Delete"
            providerConfigName = "default"
        }
        writeConnectionSecretToRef = {
            name = "e2e-mariadb-aws-conn"
            namespace = "default"
        }
    }
}

_items = [
    metav1alpha1.E2ETest{
        metadata.name: "e2e-xsqlinstance-aws"
        spec = {
            crossplane.autoUpgrade.channel: "Rapid"
            defaultConditions: ["Ready"]
            manifests: [
                _postgres_secret,
                _mariadb_secret,
                _postgres_xr,
                _mariadb_xr
            ]
            extraResources: [
                # AWS ProviderConfig for AWS resources
                awsv1beta1.ProviderConfig{
                    metadata.name = "default"
                    spec = {
                        credentials = {
                            source = "Upbound"
                            upbound = {
                                webIdentity = {
                                    roleARN = "arn:aws:iam::609897127049:role/solutions-e2e-provider-aws"
                                }
                            }
                        }
                    }
                }
            ]
            skipDelete: False
            timeoutSeconds: 4500
        }
    }
]
items = _items
