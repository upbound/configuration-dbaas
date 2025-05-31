import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1
import models.io.upbound.dbaas.v1alpha1 as dbaasv1alpha1
import models.io.upbound.platform.aws.v1alpha1 as platformawsv1alpha1
import models.io.upbound.platform.azure.v1alpha1 as platformazurev1alpha1
import base64

oxr = dbaasv1alpha1.XSQLInstance{**option("params").oxr}
_ocds = option("params").ocds

_metadata = lambda name: str -> any {
    { annotations = { "krm.kcl.dev/composition-resource-name" = name }}
}


_items = []

if oxr.spec.parameters.provider == "aws":

    # we want to forward all parameters except for "provider"
    _instanceParameters = {k: v for k, v in oxr.spec.parameters if k != "provider"} | {
        networkRef.id = oxr.metadata.name
    }

    _items += [
            platformawsv1alpha1.XSQLInstance{
                metadata = _metadata("sqlinstance")
                spec = {
                    parameters = {
                        **_instanceParameters
                    }
                }
            }
            platformawsv1alpha1.XNetwork{
                metadata = _metadata("network")
                spec = {
                    parameters = {
                        deletionPolicy = oxr.spec.parameters.deletionPolicy
                        id = oxr.metadata.name
                        providerConfigName = oxr.spec.parameters.providerConfigName
                        region = oxr.spec.parameters.region
                    }
                }
            }
    ]

elif oxr.spec.parameters.provider == "azure":

    # we want to forward all parameters except for "provider"
    _instanceParameters = {k: v for k, v in oxr.spec.parameters if k not in [
        "provider"
        "engine"
        "engineVersion"
    ]} | {
        networkRef.id = oxr.metadata.name
    }

    _subnetServiceType = Undefined
    if oxr.spec.parameters.engine == "mysql":
        _subnetServiceType = "mysql"
    elif oxr.spec.parameters.engine == "postgres":
        _subnetServiceType = "postgresql"
    else:
        assert False, "Unsupported engine: {}".format(oxr.spec.parameters.engine)

    _items += [
            platformazurev1alpha1.XSQLInstance{
                metadata = _metadata("sqlinstance")
                spec = {
                    compositionSelector = {
                        matchLabels = {
                            dbengine = oxr.spec.parameters.engine
                        }
                    }
                    parameters = {
                        **_instanceParameters
                        version = oxr.spec.parameters.engineVersion
                    }
                    writeConnectionSecretToRef = {
                        namespace = "crossplane-system"
                        name = oxr.metadata.name
                    }
                }
            }
            platformazurev1alpha1.XNetwork{
                metadata = _metadata("network")
                spec = {
                    parameters = {
                        addressRange = "10.0.0.0/16"
                        databaseSubnets = [
                            {
                                addressRange = "10.0.2.0/24"
                                serviceType = _subnetServiceType
                            }
                        ]
                        deletionPolicy = oxr.spec.parameters.deletionPolicy
                        generalSubnetRange = "10.0.1.0/24"
                        id = oxr.metadata.name
                        providerConfigName = oxr.spec.parameters.providerConfigName
                        region = oxr.spec.parameters.region
                    }
                }
            }
    ]


_items += [
        {
            apiVersion: "meta.krm.kcl.dev/v1alpha1"
            kind: "CompositeConnectionDetails"
            data: {
                "host" = base64.encode(_ocds["sqlinstance"]?.Resource?.status?.atProvider?.host)
            }
        }
]
items = _items
