import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.dbaas.v1alpha1 as dbaasv1alpha1
import models.io.k8s.api.core.v1 as k8sv1
import models.io.upbound.gcp.v1beta1 as gcpv1beta1

_postgres_secret = k8sv1.Secret{
    metadata = {
        name = "e2e-postgres-secret-gcp"
        namespace = "default"
    }
    type = "Opaque"
    data = {
        password = "dXBiMHVuZHIwY2s1ITMxMzM3"  # base64 encoded password
    }
}

_mysql_secret = k8sv1.Secret{
    metadata = {
        name = "e2e-mysql-secret-gcp"
        namespace = "default"
    }
    type = "Opaque"
    data = {
        password = "dXBiMHVuZHIwY2s1ITMxMzM3"  # base64 encoded password
    }
}

_postgres_xr = dbaasv1alpha1.XSQLInstance{
    metadata = {
        name = "e2e-postgres-gcp"
    }
    spec = {
        parameters = {
            provider = "gcp"
            region = "us-west2"
            engine = "postgres"
            engineVersion = "15"
            storageGB = 10
            passwordSecretRef = {
                namespace = "default"
                name = "e2e-postgres-secret-gcp"
                key = "password"
            }
            deletionPolicy = "Delete"
            providerConfigName = "default"
        }
        writeConnectionSecretToRef = {
            name = "e2e-postgres-gcp-conn"
            namespace = "default"
        }
    }
}

_mysql_xr = dbaasv1alpha1.XSQLInstance{
    metadata = {
        name = "e2e-mysql-gcp"
    }
    spec = {
        parameters = {
            provider = "gcp"
            region = "us-west2"
            engine = "mysql"
            engineVersion = "8_0"
            storageGB = 10
            passwordSecretRef = {
                namespace = "default"
                name = "e2e-mysql-secret-gcp"
                key = "password"
            }
            deletionPolicy = "Delete"
            providerConfigName = "default"
        }
        writeConnectionSecretToRef = {
            name = "e2e-mysql-gcp-conn"
            namespace = "default"
        }
    }
}

_items = [
    metav1alpha1.E2ETest{
        metadata.name: "e2e-xsqlinstance-gcp"
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
                # GCP ProviderConfig for GCP resources
                gcpv1beta1.ProviderConfig{
                    metadata.name: "default"
                    spec: {
                        projectID: "crossplane-playground"
                        credentials: {
                            source: "Upbound"
                            upbound: {
                                federation: {
                                    providerID: "projects/283222062215/locations/global/workloadIdentityPools/solutions-upbound-oidc-pool/providers/solutions-u5d-oidc-pool"
                                    serviceAccount: "solutions-u5d-service-account@crossplane-playground.iam.gserviceaccount.com"
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
