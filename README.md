# Database-as-a-service Configuration

This repository contains an Upbound project, tailored for users establishing their initial control plane with [Upbound](https://cloud.upbound.io). This configuration deploys fully managed database instances across AWS, Azure, and GCP.

## Overview

The core components of a custom API in [Upbound Project](https://docs.upbound.io/learn/control-plane-project/) include:

- **CompositeResourceDefinition (XRD):** Defines the API's structure.
- **Composition(s):** Configures the Functions Pipeline
- **Embedded Function(s):** Encapsulates the Composition logic and implementation within a self-contained, reusable unit

In this specific configuration, the Database API contains:

- **a [SQL Instance](/apis/definition.yaml) custom resource type.**
- **Composition:** Configured in [/apis/xsqlinstances/composition.yaml](/apis/xsqlinstances/composition.yaml),
- **Embedded Function:** The Composition logic is encapsulated within [embedded function](/functions/xsqlinstances/main.k)

## Testing

The configuration can be tested using:

- `up composition render --xrd=apis/definition.yaml apis/xsqlinstances/composition.yaml examples/postgres-aws-claim.yaml` to render the composition
- `up test run tests/*` to run composition tests
- `up test run tests/* --e2e` to run end-to-end tests

## Deployment

- Execute `up project run`
- Alternatively, install the Configuration from the [Upbound Marketplace](https://marketplace.upbound.io/configurations/upbound/configuration-dbaas)
- Check [examples](/examples/) for example claims and XR(Composite Resource)

## Next steps

This repository serves as a foundational step. To enhance the configuration, consider:

1. create new API definitions in this same repo
2. editing the existing API definition to your needs

To learn more about how to build APIs for your managed control planes in Upbound, read the guide on [Upbound's docs](https://docs.upbound.io/).
