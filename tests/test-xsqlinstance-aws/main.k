import models.io.upbound.dbaas.v1alpha1 as dbaasv1alpha1
import models.io.upbound.platform.aws.v1alpha1 as platformawsv1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_items = [
    metav1alpha1.CompositionTest{
        metadata.name: "test-xsqlinstance-aws"
        spec = {
            compositionPath: "apis/xsqlinstances/composition.yaml"
            xrPath: "examples/postgres-aws.yaml"
            xrdPath: "apis/xsqlinstances/definition.yaml"
            timeoutSeconds: 60
            validate: False
            assertResources: [
                platformawsv1alpha1.XSQLInstance{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "configuration-dbaas-aws-postgresql"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "sqlinstance"
                        }
                    }
                    spec = {
                        parameters = {
                            engine = "postgres"
                            engineVersion = "16.3"
                            storageGB = 5
                            region = "us-west-2"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            networkRef = {
                                id = "configuration-dbaas-aws-postgresql"
                            }
                            passwordSecretRef = {
                                namespace = "default"
                                name = "psqlsecretaws"
                                key = "password"
                            }
                        }
                    }
                }
                platformawsv1alpha1.XNetwork{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "configuration-dbaas-aws-postgresql"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "network"
                        }
                    }
                    spec = {
                        parameters = {
                            id = "configuration-dbaas-aws-postgresql"
                            region = "us-west-2"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            vpcCidrBlock = "192.168.0.0/16"
                            subnets = [
                                {
                                    availabilityZone = "us-west-2a"
                                    type = "public"
                                    cidrBlock = "192.168.0.0/18"
                                }
                                {
                                    availabilityZone = "us-west-2b"
                                    type = "public"
                                    cidrBlock = "192.168.64.0/18"
                                }
                                {
                                    availabilityZone = "us-west-2a"
                                    type = "private"
                                    cidrBlock = "192.168.128.0/18"
                                }
                                {
                                    availabilityZone = "us-west-2b"
                                    type = "private"
                                    cidrBlock = "192.168.192.0/18"
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
