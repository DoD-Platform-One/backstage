# Backstage Development overrides

### make sure to replace git branch and image tag with your development branch and tag values!

```yaml
clusterAuditor:
  enabled: false

gatekeeper:
  enabled: false

istioOperator:
  enabled: true

istio:
  enabled: true

jaeger:
  enabled: false

kiali:
  enabled: true

eckOperator:
  enabled: false

fluentbit:
  enabled: false

monitoring:
  enabled: true
  git:
    tag: null
    branch: "grafana-netpol"

neuvector:
  enabled: false

twistlock:
  enabled: false

packages:
  backstage:
    enabled: true
    wrapper:
      enabled: true
    dependsOn:
      - name: grafana
        namespace: bigbang
    git:
      repo: "https://repo1.dso.mil/big-bang/product/packages/backstage"
      tag: null
      branch: "your-branch-here"
      path: "./chart"
    values:
      grafana:
        # The following is the endpoint at which grafana API calls will be accessed through
        url: &grafanaUrl "monitoring-grafana.monitoring.svc.cluster.local"
        http: &grafanaHttp "http"
        # The following is the rewritten URL at which backstage grafana iframe will hyperlink to
        externalUrl: &grafanaExternalUrl "https://grafana.dev.bigbang.mil"
      networkPolicies:
        enabled: true
      backstage:
        serviceAccount:
          name: "backstage"
        backstage:
          args: ["--config", "app-config.yaml", "--config", "app-config-from-configmap.yaml"]
          image:
            repository: "bigbang-staging/backstage"
            tag: "your-image-here"
          extraEnvVars:
            - name: GRAFANA_HTTP
              value: *grafanaHttp
            - name: GRAFANA_URL
              value: *grafanaUrl
            - name: GRAFANA_DOMAIN
              value: *grafanaExternalUrl

          extraEnvVarsSecrets:
            - grafana-api-token

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
          appConfig:
            organization:
              name: "P1"
            app:
              baseUrl: "https://backstage.dev.bigbang.mil"
            backend:
              baseUrl: "https://backstage.dev.bigbang.mil"
              listen:
                port: 7007
              reading:
                allow:
                  - host: 'repo1.dso.mil'
            auth:
              session:
                secret: "XxNl2b+/hGH7w7RJk8c5LXNOBh6+kzysxgYXlMK5Pgo="
              environment: development
              providers:
                guest: {}
                #  # because we use NODE_ENV: production, we must set this to allow guest development login
                #  dangerouslyAllowOutsideDevelopment: true
                keycloak:
                  development:
                    metadataUrl: "https://login.dso.mil/auth/realms/baby-yoda/.well-known/openid-configuration"
                    clientId: "platform1_a8604cc9-f5e9-4656-802d-d05624370245_bb8-backstage"
                    clientSecret: "public"
                    #prompt can be set to 'auto' or 'login'
                    prompt: auto
            proxy:
              '/grafana/api':
                # May be a public or an internal DNS
                target: ${GRAFANA_HTTP}://${GRAFANA_URL}
                headers:
                  Authorization: Bearer ${GRAFANA_TOKEN}

            grafana:
              # Publicly accessible domain
              domain: ${GRAFANA_DOMAIN}

              # Is unified alerting enabled in Grafana?
              # See: https://grafana.com/blog/2021/06/14/the-new-unified-alerting-system-for-grafana-everything-you-need-to-know/
              # Optional. Default: false
              unifiedAlerting: false

            kubernetes:
              customResources:
                - group: 'networking.istio.io'
                  apiVersion: 'v1'
                  plural: 'virtualservices'
                - group: 'networking.k8s.io'
                  apiVersion: 'v1'
                  plural: 'networkpolicies'
                - group: 'security.istio.io'
                  apiVersion: 'v1'
                  plural: 'authorizationpolicies'
                - group: 'security.istio.io'
                  apiVersion: 'v1'
                  plural: 'peerauthentications'
                - group: 'source.toolkit.fluxcd.io'
                  apiVersion: 'v1'
                  plural: 'helmcharts'
                - group: 'helm.toolkit.fluxcd.io'
                  apiVersion: 'v2'
                  plural: 'helmreleases'
                - group: 'source.toolkit.fluxcd.io'
                  apiVersion: 'v1'
                  plural: 'gitrepositories'
                - group: 'wgpolicyk8s.io'
                  apiVersion: 'v1alpha2'
                  plural: 'clusterpolicyreports'
                - group: 'wgpolicyk8s.io'
                  apiVersion: 'v1alpha2'
                  plural: 'policyreports'
                - group: 'kyverno.io'
                  apiVersion: 'v1'
                  plural: 'clusterpolicies'
              frontend:
                podDelete:
                  enabled: true
              serviceLocatorMethod:
                type: 'multiTenant'
              clusterLocatorMethods:
                - type: 'config'
                  clusters:
                    - url: http://127.0.0.1:9999
                      name: bigbang-dev
                      authProvider: 'serviceAccount'
                      skipTLSVerify: false
                      skipMetricsLookup: true
            catalog:
              providers:
                keycloakOrg:
                  default:
                    baseUrl: "https://login.dso.mil/auth"
                    loginRealm: "baby-yoda"
                    realm: "baby-yoda"
                    clientId: "platform1_a8604cc9-f5e9-4656-802d-d05624370245_bb8-backstage"
                    clientSecret: "public"
              rules:
                - allow: [Component, API, System, Location, Template, User, Group]
              locations:
                - type: file
                  target: ./catalog/*.yaml
                - type: file
                  target: ./template/*.yaml
              #  - type: url
              #    target: https://repo1.dso.mil/big-bang/apps/sandbox/backstage/-/raw/main/backstage/examples/org.yaml
    istio:
      hosts:
        - names:
            - backstage
          gateways:
            - public
          destination:
            port: 7007
      enabled: true
      hardened:
        customServiceEntries:
          - name: "backstage.backstage.svc.cluster.local"
            enabled: true
            spec:
              hosts:
                - 'backstage.dev.bigbang.mil'
              location: MESH_EXTERNAL
              ports:
                - number: 443
                  protocol: TLS
                  name: https
              resolution: DNS
```
