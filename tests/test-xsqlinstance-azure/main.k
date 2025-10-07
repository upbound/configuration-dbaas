import models.io.upbound.dbaas.v1alpha1 as dbaasv1alpha1
import models.io.upbound.platform.azure.v1alpha1 as azurev1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_items = [
    metav1alpha1.CompositionTest{
        metadata.name: "test-xsqlinstance-azure"
        spec = {
            compositionPath: "apis/xsqlinstances/composition.yaml"
            xrPath: "examples/mysql-azure.yaml"
            xrdPath: "apis/xsqlinstances/definition.yaml"
            timeoutSeconds: 60
            validate: False
            assertResources: [
                azurev1alpha1.XSQLInstance{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "configuration-dbaas-azure-mysql"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "sqlinstance"
                        }
                    }
                    spec = {
                        compositionSelector = {
                            matchLabels = {
                                dbengine = "mysql"
                            }
                        }
                        parameters = {
                            version = "10.3"
                            storageGB = 32
                            region = "westus2"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            networkRef = {
                                id = "configuration-dbaas-azure-mysql"
                            }
                            passwordSecretRef = {
                                namespace = "default"
                                name = "mysqlsecretazure"
                                key = "password"
                            }
                        }
                        writeConnectionSecretToRef = {
                            namespace = "crossplane-system"
                            name = "configuration-dbaas-azure-mysql"
                        }
                    }
                }
                azurev1alpha1.XNetwork{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "configuration-dbaas-azure-mysql"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "network"
                        }
                    }
                    spec = {
                        parameters = {
                            id = "configuration-dbaas-azure-mysql"
                            region = "westus2"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            addressRange = "10.0.0.0/16"
                            generalSubnetRange = "10.0.1.0/24"
                            databaseSubnets = [
                                {
                                    addressRange = "10.0.2.0/24"
                                    serviceType = "mysql"
                                }
                            ]
                        }
                    }
                }
            ]
        }
    }
]
items = _items
