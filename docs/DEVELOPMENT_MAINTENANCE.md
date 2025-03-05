# Development Maintenance

Don't forget to look at the [bitnami common chart](https://github.com/bitnami/charts/tree/main/bitnami/common/templates) for examples of how to do things.

You need to:

- [work the intro to backstage](https://backstage.io/docs/getting-started/)
- [enable buildkit](https://docs.docker.com/build/buildkit/#getting-started)
- [install buildx](https://github.com/docker/buildx?tab=readme-ov-file#installing)

To build and run:

```bash
# For local development
make
# For docker development
make docker
```

More options

```bash
# Build the code
make build
# Run the code
make run

# Build the docker image locally
make docker-build
# Build the docker image in a multi-stage build (doesn't require any local dependencies)
make docker-build-multi
# Run the latest image
make docker-run
```

## TODO: all of this

- [ ] Finish these docs
- [ ] Add a `make test` command
- [ ] Add a `make lint` command
- [ ] Add a `make format` command
- [ ] Add a `make clean` command
- [ ] [Harden the docker images](https://github.com/backstage/backstage/blob/master/contrib/docker/minimal-hardened-image/Dockerfile)
- [ ] [Upgrading backstage](https://backstage.io/docs/getting-started/keeping-backstage-updated/)

## Changes BB Values

### chart/values.yaml

- All big bang values at the bottom of the chart

### chart/templates/bigbang/**

- Everything in the bigbang folder
=======

# Work In Progress

Please see `TEMP_DEV.md` for getting started.

# Files that require bigbang integration testing

### See [bb MR testing](./docs/test-package-against-bb.md) for details regarding testing changes against bigbang umbrella chart

There are certain integrations within the bigbang ecosystem and this package that require additional testing outside of the specific package tests ran during CI.  This is a requirement when files within those integrations are changed, as to avoid causing breaks up through the bigbang umbrella.  Currently, these include changes to the istio implementation within argocd (see: [istio templates](./chart/templates/bigbang/istio/), [network policy templates](./chart/templates/bigbang/networkpolicies/), [service entry templates](./chart/templates/bigbang/serviceentries/)).

Be aware that any changes to files listed in the [Big Bang Chart Additions](#big-bang-chart-additions) section will also require a codeowner to validate the changes using above method, to ensure that they do not affect the package or its integrations adversely.

Be sure to also test against monitoring locally as it is integrated by default with these high-impact service control packages, and needs to be validated using the necessary chart values beneath `istio.hardened` block with `monitoring.enabled` set to true as part of your dev-overrides.yaml

# Upgrading to a new version

WIP

# Testing for updates

> NOTE: For these testing steps it is good to do them on both a clean install and an upgrade. For clean install, point backstage to your branch. For an upgrade do an install with backstage pointing to the latest tag, then perform a helm upgrade with backstage pointing to your branch.

WIP

# Big Bang Chart Additions

This package has a number of additions to the [upstream helm chart](https://upstream) to integrate with other Big Bang capabilities such as:

- Monitoring tools (Prometheus/Grafana)
- Service Mesh (Istio)
- Network Policies
- Helm hook jobs for automating upgrade tasks

Here's the section of the `chart/values.yaml` file where these additions are configured:

These values are required to be at the top of values.yaml as they are anchoring values and are consumed later in the values fileas extraEnvVars for the containers to utilize in config.
```yaml
grafana:
  # The following is the endpoint at which grafana API calls will be accessed through
  url: &grafanaUrl "monitoring-grafana.monitoring.svc.cluster.local"
  http: &grafanaHttp "http"

  # The following is the rewritten URL at which backstage grafana iframe will hyperlink to
  externalUrl: &grafanaExternalUrl "https://grafana.dev.bigbang.mil"
...

    extraEnvVars:
      - name: GRAFANA_HTTP
        value: *grafanaHttp
      - name: GRAFANA_URL
        value: *grafanaUrl
      - name: GRAFANA_DOMAIN
        value: *grafanaExternalUrl
```

The following is added as an initContainer to generate the api token for backstage to query grafana API.

```yaml
initContainers:
      - name: backstage-grafana-token
        image: registry1.dso.mil/ironbank/big-bang/base:2.1.0
        command: ["/bin/sh"]
        args: ["-c", "export SVCACCT_ID=$(curl -X POST -H 'Content-Type: application/json' -d '{\"name\": \"backstage-viewer-{{ (randAlphaNum 5) }}\", \"role\": \"Viewer\"}' ${GRAFANA_HTTP}://${GRAFANA_ADMIN}:${GRAFANA_PASS}@${GRAFANA_URL}/api/serviceaccounts | jq -r '.id') && kubectl create secret -n backstage generic grafana-api-token --from-literal=GRAFANA_TOKEN=$(curl -X POST -H 'Content-Type: application/json' -d '{\"name\": \"backstage-grafana-{{ (randAlphaNum 5) }}\"}' ${GRAFANA_HTTP}://${GRAFANA_ADMIN}:${GRAFANA_PASS}@${GRAFANA_URL}/api/serviceaccounts/${SVCACCT_ID}/tokens | jq -r '.key') --dry-run=client -o yaml | kubectl apply -f -"]
        env:
          - name: GRAFANA_URL
            value: *grafanaUrl
          - name: GRAFANA_HTTP
            value: *grafanaHttp
          - name: GRAFANA_ADMIN
            valueFrom:
              secretKeyRef:
                name: monitoring-grafana
                key: admin-user  
          - name: GRAFANA_PASS
            valueFrom:
              secretKeyRef:
                name: monitoring-grafana
                key: admin-password
        securityContext:
          runAsNonRoot: true
          runAsUser: 1001
          runAsGroup: 1001
          capabilities:
            drop:
              - ALL
```

## chart/templates/bigbang/kyverno/*
Added to utilize grafana API generation via a clusterpolicy that syncs the default grafana credentials at "monitoring-grafana" to backstage namespace on first create



## Monitoring

WIP

## automountServiceAccountToken

WIP

## AWS Credentials Secret

WIP

## Chart.yaml

The `Chart.yaml` file has a number of changes to support Big Bang needs:

- `-bb.x` version appended
- Annotations added for images and app versions
- Dependencies added for Gluon and BB Redis
