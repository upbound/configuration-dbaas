import models.io.upbound.dbaas.v1alpha1 as dbaasv1alpha1
import models.io.upbound.platform.gcp.v1alpha1 as gcpv1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_items = [
    metav1alpha1.CompositionTest{
        metadata.name: "test-xsqlinstance-gcp"
        spec = {
            compositionPath: "apis/xsqlinstances/composition.yaml"
            xrPath: "examples/postgres-gcp-claim.yaml"
            xrdPath: "apis/xsqlinstances/definition.yaml"
            timeoutSeconds: 60
            validate: False
            assertResources: [
                gcpv1alpha1.XSQLInstance{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "configuration-dbaas-gcp-postgresql"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "sqlinstance"
                        }
                    }
                    spec = {
                        parameters = {
                            engine = "postgres"
                            engineVersion = "15"
                            storageGB = 10
                            region = "us-west2"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            networkRef = {
                                id = "configuration-dbaas-gcp-postgresql"
                            }
                            passwordSecretRef = {
                                namespace = "default"
                                name = "psqlsecretgcp"
                                key = "password"
                            }
                        }
                    }
                }
                gcpv1alpha1.XNetwork{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "configuration-dbaas-gcp-postgresql"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "network"
                        }
                    }
                    spec = {
                        parameters = {
                            id = "configuration-dbaas-gcp-postgresql"
                            region = "us-west2"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                        }
                    }
                }
            ]
        }
    }
]
items = _items
