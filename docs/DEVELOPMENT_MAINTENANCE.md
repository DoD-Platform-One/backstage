# Development approach for Developer
 We build and maintain our own images of backstage at [repo1 developer tool](https://repo1.dso.mil/big-bang/apps/developer-tools/backstage?), so for future develpment works this  should be the source of reference for image base when we trigger our own renovates. The flow of the development process is summarized in the steps below:

 1. New backstage upstream image version comes out, this will trigger a renovate at [developer-tools/backstage](https://repo1.dso.mil/big-bang/apps/developer-tools/backstage)
 2. We kick off the renovate process using the upgrade-helper and build image, tag and push to registry.dso.mil/bigbang-staging/backstage like we do currently, test that image against the current main branch of this chart
 3. once testing there passes, approve/merge MR for developer-tools/backstage, which will trigger a release
 4. once release finishes, we update [ironbank container template for backstage image](https://repo1.dso.mil/dsop/big-bang/backstage) to the new release tag / sha / any accompanying hardening information
 5. pipeline builds/passes, and ironbank handles the MR approval
 6. once approved, ironbank consumes and publishes an image in registry1.dso.mil/ironbank/backstage
 7. our renovate in this chart will be pointed at this, triggering a renovate issue/MR
 8. Renovate chart to new version, then application testing follows as usual.


# Files that require bigbang integration testing

### See [bb MR testing](./docs/test-package-against-bb.md) for details regarding testing changes against bigbang umbrella chart

There are certain integrations within the bigbang ecosystem and this package that require additional testing outside of the specific package tests ran during CI.  This is a requirement when files within those integrations are changed, as to avoid causing breaks up through the bigbang umbrella.  Currently, these include changes to the istio implementation within backstage (see: [istio templates](./chart/templates/bigbang/istio/), [network policy templates](./chart/templates/bigbang/networkpolicies/), [serviceaccount templates](./chart/templates/bigbang/serviceaccount/), [catalog-builder templates](./chart/templates/bigbang/catalog-builder/), [kyverno templates](./chart/templates/bigbang/kyverno/)).

Be aware that any changes to files listed in the [Big Bang Chart Additions](#big-bang-chart-additions) section will also require a codeowner to validate the changes using above method, to ensure that they do not affect the package or its integrations adversely.

Be sure to also test against monitoring locally as it is integrated by default with these high-impact service control packages, and needs to be validated using the necessary chart values beneath `istio.hardened` block with `monitoring.enabled` set to true as part of your dev-overrides.yaml

# Upgrading to a new version

The below details the steps required to update to a new version of the backstage package.

# Note, Backstage is not upgraded/updated by the kpt approach. We maintain this chart as a subchart which is then updated via a wrapper

1. Create a development branch and merge request from the Gitlab issue.
2. In `chart/Chart.yaml` update backstage, gluon, common and postgresql to the latest version and run `helm dependency update chart` from the top level of the repo to package it up.
3. Modify the `image.tag` value in `chart/values.yaml` to point to the newest version of backstage.
4. Update `chart/Chart.yaml` to the appropriate versions. The annotation version should match the ```appVersion```.

    ```yaml
    version: X.X.X-bb.X
    appVersion: X.X.X

    ```

5. Update `CHANGELOG.md` adding an entry for the new version and noting all changes (at minimum should include `Updated backstage to x.x.x`).
6. Generate the `README.md` updates by following the [guide in gluon](https://repo1.dso.mil/platform-one/big-bang/apps/library-charts/gluon/-/blob/master/docs/bb-package-readme.md).
7. Open an MR in "Draft" status and validate that CI passes. This will perform a number of smoke tests against the package, but it is good to manually deploy to test some things that CI doesn't.
8. Once all manual testing is complete take your MR out of "Draft" status and add the review label.


# Testing for updates

> NOTE: For these testing steps it is good to do them on both a clean install and an upgrade. For clean install, point backstage to your branch. For an upgrade do an install with backstage pointing to the latest tag, then perform a helm upgrade with backstage pointing to your branch.

  ***Test Basic Functionality with Keycloak and Monitoring***

Deploy with the following Big Bang override values, in addition to (from the BB repo) ./docs/assets/configs/examples/policy-overrides-k3d.yaml, to backstage, monitoring and keycloak interaction:
Reference dev-overrides.yaml for the full list of overrides with an assumption you are deploying with P1 keycloak: [dev-overrides.md](https://repo1.dso.mil/big-bang/product/packages/backstage/-/blob/main/docs/dev-overrides.md)

When deploying with a dev instance of keycloak please reference the [keycloak-dev.md](https://repo1.dso.mil/big-bang/product/packages/backstage/-/blob/main/docs/keycloak-dev.md?ref_type=heads) and [KEYCLOAK.md](https://repo1.dso.mil/big-bang/product/packages/backstage/-/blob/main/docs/KEYCLOAK.md?ref_type=heads) documentation.

1. Log in to the [backstage UI](https://backstage.dev.bigbang.mil) with your keycloak credentials.
2. Verify that the backstage UI is working by navigating to the "components" page.
3. Navigate through each of the components in the backstage UI and verify that they are working. 
4. Navigate to the "dashboard" page of each component and verify that the "dashboards" are connecting to grafana and shwoing the correct information.
5. Navigate to the Kubernetes page and verify that the kubernetes cluster is reporting correct information for deployed resources.

# Big Bang Chart Additions

This package has a number of additions to the [upstream helm chart](https://github.com/backstage/charts) to integrate with other Big Bang capabilities such as:

- Monitoring tools (Prometheus/Grafana)
- Keycloak integration
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

The following is added to the backstage deployment to enable keycloak integration.

```yaml

appConfig:
  app:
    baseUrl: "https://${BACKSTAGE_BASE_URL}"
  backend:
    baseUrl: "https://${BACKSTAGE_BASE_URL}"
    listen:
      port: 7007
  auth:
    session:
    ### Providing an auth.session.secret will enable session support in the auth-backend. you can use "openssl rand -hex 64" to generate a random secret from cli or use the value provided below.
      secret: "XxNl2b+/hGH7w7RJk8c5LXNOBh6+kzysxgYXlMK5Pgo="
    environment: development
    providers:
      keycloak:
        development:
          metadataUrl: "https://${KEYCLOAK_BASE_URL}/auth/realms/${KEYCLOAK_REALM}/.well-known/openid-configuration"
          clientId: "${KEYCLOAK_CLIENT_ID}"
          clientSecret: "${KEYCLOAK_CLIENT_SECRET}"
          #prompt can be set to 'auto' or 'login'
          prompt: auto
  catalog:
    providers:
      keycloakOrg:
        default:
          baseUrl: "https://${KEYCLOAK_BASE_URL}/auth"
          loginRealm: "${KEYCLOAK_REALM}"
          realm: "${KEYCLOAK_REALM}"
          clientId: "${KEYCLOAK_CLIENT_ID}"
          clientSecret: "${KEYCLOAK_CLIENT_SECRET}"
```


## chart/templates/bigbang/kyverno/*

Added to utilize grafana API generation via a clusterpolicy that syncs the default grafana credentials at "monitoring-grafana" to backstage namespace on first create


## automountServiceAccountToken

The mutating Kyverno policy named `update-automountserviceaccounttokens` is leveraged to harden all ServiceAccounts in this package with `automountServiceAccountToken: false`. This policy is configured by namespace in the Big Bang umbrella chart repository at [chart/templates/kyverno-policies/values.yaml](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/chart/templates/kyverno-policies/values.yaml?ref_type=heads).

This policy revokes access to the K8s API for Pods utilizing said ServiceAccounts. If a Pod truly requires access to the K8s API (for app functionality), the Pod is added to the `pods:` array of the same mutating policy. This grants the Pod access to the API, and creates a Kyverno PolicyException to prevent an alert.


## Chart.yaml

The `Chart.yaml` file has a number of changes to support Big Bang needs:

- `-bb.x` version appended
- Annotations added for images and app versions
- Dependencies added for Backstage, Gluon, Common and Postgresql 
