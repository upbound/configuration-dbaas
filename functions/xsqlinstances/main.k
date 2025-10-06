import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1
import models.io.upbound.dbaas.v1alpha1 as dbaasv1alpha1
import models.io.upbound.platform.aws.v1alpha1 as platformawsv1alpha1
import models.io.upbound.platform.azure.v1alpha1 as platformazurev1alpha1
import models.io.upbound.platform.gcp.v1alpha1 as platformgcpv1alpha1
import base64

oxr = dbaasv1alpha1.XSQLInstance{**option("params").oxr}
_ocds = option("params").ocds

_metadata = lambda name: str -> any {
    { annotations = { "krm.kcl.dev/composition-resource-name" = name }}
}


_items = []

if oxr.spec.parameters.provider == "aws":

    # Generate region-specific availability zones for subnets
    _regionAzMap = {
        "us-east-1": ["us-east-1a", "us-east-1b"]
        "us-east-2": ["us-east-2a", "us-east-2b"]
        "us-west-1": ["us-west-1a", "us-west-1c"]
        "us-west-2": ["us-west-2a", "us-west-2b"]
        "eu-west-1": ["eu-west-1a", "eu-west-1b"]
        "eu-west-2": ["eu-west-2a", "eu-west-2b"]
        "eu-central-1": ["eu-central-1a", "eu-central-1b"]
        "ap-southeast-1": ["ap-southeast-1a", "ap-southeast-1b"]
        "ap-southeast-2": ["ap-southeast-2a", "ap-southeast-2b"]
        "ap-northeast-1": ["ap-northeast-1a", "ap-northeast-1c"]
        "ca-central-1": ["ca-central-1a", "ca-central-1b"]
    }

    _region = oxr.spec.parameters.region
    _availabilityZones = _regionAzMap[_region] if _region in _regionAzMap else ["us-west-2a", "us-west-2b"]

    # Generate subnets configuration based on the region's availability zones
    _regionSpecificSubnets = [
        {
            availabilityZone = _availabilityZones[0]
            type = "public"
            cidrBlock = "192.168.0.0/18"
        }
        {
            availabilityZone = _availabilityZones[1]
            type = "public"
            cidrBlock = "192.168.64.0/18"
        }
        {
            availabilityZone = _availabilityZones[0]
            type = "private"
            cidrBlock = "192.168.128.0/18"
        }
        {
            availabilityZone = _availabilityZones[1]
            type = "private"
            cidrBlock = "192.168.192.0/18"
        }
    ]

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
                        region = _region
                        vpcCidrBlock = "192.168.0.0/16"
                        subnets = _regionSpecificSubnets
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

elif oxr.spec.parameters.provider == "gcp":

    # we want to forward all parameters except for "provider"
    _instanceParameters = {k: v for k, v in oxr.spec.parameters if k != "provider"} | {
        networkRef.id = oxr.metadata.name
    }

    _items += [
            platformgcpv1alpha1.XSQLInstance{
                metadata = _metadata("sqlinstance")
                spec = {
                    parameters = {
                        **_instanceParameters
                    }
                }
            }
            platformgcpv1alpha1.XNetwork{
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


# Propagate connection details from provider-specific XSQLInstance
_items += [
        {
            apiVersion: "meta.krm.kcl.dev/v1alpha1"
            kind: "CompositeConnectionDetails"
            if "sqlinstance" in _ocds:
                data: {
                    # Common connection details available from all providers
                    username = _ocds["sqlinstance"].ConnectionDetails.username if "username" in _ocds["sqlinstance"].ConnectionDetails else None
                    password = _ocds["sqlinstance"].ConnectionDetails.password if "password" in _ocds["sqlinstance"].ConnectionDetails else None
                    host = _ocds["sqlinstance"].ConnectionDetails.host if "host" in _ocds["sqlinstance"].ConnectionDetails else None
                    # AWS-specific: endpoint
                    **({endpoint = _ocds["sqlinstance"].ConnectionDetails.endpoint} if "endpoint" in _ocds["sqlinstance"].ConnectionDetails else {})
                    # Azure-specific: port
                    **({port = _ocds["sqlinstance"].ConnectionDetails.port} if "port" in _ocds["sqlinstance"].ConnectionDetails else {})
                    # GCP-specific: serverCACertificateCert
                    **({serverCACertificateCert = _ocds["sqlinstance"].ConnectionDetails.serverCACertificateCert} if "serverCACertificateCert" in _ocds["sqlinstance"].ConnectionDetails else {})
                }
            else:
                data: {}
        }
]
items = _items
