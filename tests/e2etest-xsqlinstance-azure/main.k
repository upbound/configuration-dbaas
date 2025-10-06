import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.dbaas.v1alpha1 as dbaasv1alpha1
import models.io.k8s.api.core.v1 as k8sv1
import models.io.upbound.azure.v1beta1 as azurev1beta1

_postgres_secret = k8sv1.Secret{
    metadata = {
        name = "e2e-postgres-secret-azure"
        namespace = "default"
    }
    type = "Opaque"
    data = {
        password = "dXBiMHVuZHIwY2s1ITMxMzM3"  # base64 encoded password
    }
}

_mysql_secret = k8sv1.Secret{
    metadata = {
        name = "e2e-mysql-secret-azure"
        namespace = "default"
    }
    type = "Opaque"
    data = {
        password = "dXBiMHVuZHIwY2s1ITMxMzM3"  # base64 encoded password
    }
}

_postgres_xr = dbaasv1alpha1.XSQLInstance{
    metadata = {
        name = "e2e-postgres-azure"
    }
    spec = {
        parameters = {
            provider = "azure"
            region = "eastus"
            engine = "postgres"
            engineVersion = "16"
            storageGB = 32
            passwordSecretRef = {
                namespace = "default"
                name = "e2e-postgres-secret-azure"
                key = "password"
            }
            deletionPolicy = "Delete"
            providerConfigName = "default"
        }
        writeConnectionSecretToRef = {
            name = "e2e-postgres-azure-conn"
            namespace = "default"
        }
    }
}

_mysql_xr = dbaasv1alpha1.XSQLInstance{
    metadata = {
        name = "e2e-mysql-azure"
    }
    spec = {
        parameters = {
            provider = "azure"
            region = "eastus"
            engine = "mysql"
            engineVersion = "8.0.21"
            storageGB = 32
            passwordSecretRef = {
                namespace = "default"
                name = "e2e-mysql-secret-azure"
                key = "password"
            }
            deletionPolicy = "Delete"
            providerConfigName = "default"
        }
        writeConnectionSecretToRef = {
            name = "e2e-mysql-azure-conn"
            namespace = "default"
        }
    }
}

_items = [
    metav1alpha1.E2ETest{
        metadata.name: "e2e-xsqlinstance-azure"
        spec = {
            crossplane.autoUpgrade.channel: "Rapid"
            defaultConditions: ["Ready"]
            manifests: [
                _postgres_secret,
                _mysql_secret,
                _postgres_xr,
                _mysql_xr
            ]
            extraResources: [
                # Azure ProviderConfig for Azure resources
                azurev1beta1.ProviderConfig{
                    metadata.name = "default"
                    spec = {
                        credentials = {
                            source = "Upbound"
                        }
                        clientID = "bcf40abd-283c-494b-b186-03d6c864be51"
                        tenantID = "b9925bc4-8383-4c37-b9d2-fa456d1bb1c7"
                        subscriptionID = "038f2b7c-3265-43b8-8624-c9ad5da610a8"
                    }
                }
            ]
            skipDelete: False
            timeoutSeconds: 4500
        }
    }
]
items = _items
