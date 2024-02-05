

# Database-as-a-service Configuration


This repository contains a [Crossplane configuration](https://docs.crossplane.io/v1.11/concepts/packages/#configuration-packages), tailored for users establishing their initial control plane with [Upbound](https://cloud.upbound.io). This configuration deploys fully managed database instances in any cloud.

## Overview

The core components of a custom API in [Crossplane](https://docs.crossplane.io/v1.11/getting-started/introduction/) include:

- **CompositeResourceDefinition (XRD):** Defines the API's structure.
- **Composition(s):** Implements the API by orchestrating a set of Crossplane managed resources.

In this specific configuration, the database API contains:

- **an database (/apis/definition.yaml) custom resource type.**
- **Compositions of the database resources:** Configured in the [/apis/](/apis/) directory, it can provision Azure or AWS database-as-a-service resources in the `upbound-system` namespace.

This repository contains an Composite Resource (XR) file.

## Deployment

```shell
apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: configuration-dbaas
spec:
  package: xpkg.upbound.io/upbound/configuration-dbaas:v0.2.0
```

## Next steps

Upbound will automatically detect the commits you make in your repo and build the configuration package for you. To learn more about how to build APIs for your managed control planes in Upbound, read the guide on Upbound's docs.
