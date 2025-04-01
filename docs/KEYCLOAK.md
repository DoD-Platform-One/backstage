## Deploying Backstage with a Dev Instance of Keycloak

### Prerequisites

Backstage should be configured to work with P1 SSO/`login.dso.mil` for keycloak integration. To learn about deploying Backstage with a dev version of Keycloak, see [keycloak-dev.md](./keycloak-dev.md)

1. You will need a K8s development environment with two `Gateway` resources configured. One for `passthrough` and the other for `public`. Use the `k3d-dev.sh` script without any flag to deploy a dev cluster with MetalLB. Keycloak is configured with the `passthrough` gateway.

2. You will need the following values file saved locally: `keycloak-dev-values.yaml` ([link](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/docs/assets/configs/example/keycloak-dev-values.yaml?ref_type=heads)).


### Deploying

Before deploying Backstage you must ensure keycloak dev instance has been deployed and configured with client for backstage. Use the overrides file below.

1. Reference ([link](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/docs/assets/configs/example/keycloak-dev-values.yaml?ref_type=heads))
  `keycloak_overrides.yaml` see sample override below:

  ```yaml
  comments: |
  This values override file is provided FOR DEVELOPMENT/DEMO/TEST PURPOSES ONLY
  For production configuration reference the Big Bang repo docs at docs/assets/configs/example/keycloak-prod-values.yaml

domain: dev.bigbang.mil

flux:
  interval: 1m
  rollback:
    cleanupOnFail: false

istioOperator:
  enabled: true

istio:
  enabled: true
  ingressGateways:
    passthrough-ingressgateway:
      type: "LoadBalancer"
  gateways:
    public:
      ingressGateway: "public-ingressgateway"
      hosts:
      - "*.{{ .Values.domain }}"
    passthrough:
      ingressGateway: "passthrough-ingressgateway"
      hosts:
      - "*.{{ .Values.domain }}"
      tls:
        mode: "PASSTHROUGH"

addons:

  keycloak:
    enabled: true
    git:
      tag: null
      branch: "main"

    ingress:
      gateway: "passthrough"
    values:
      replicas: 1
      command:
        - "/opt/keycloak/bin/kc.sh"
      args:
        - "start"
        # - "start-dev"
        - "--import-realm"

      # https://www.keycloak.org/server/all-config
      # Deploy KC_HTTPS_TRUST_STORE (https truststore) envs or KC_TRUSTSTORE_PATHS (system truststore) but not both
      # Conversion will require changes in extraEnv, extraVolumeMounts, and secrets
      #- name: KC_HTTPS_TRUST_STORE_FILE
      #    value: /opt/keycloak/conf/truststore.jks
      #  - name: KC_HTTPS_TRUST_STORE_PASSWORD
      #    value: password
      #  - name: KC_TRUSTSTORE_PATHS
      #    value: /opt/keycloak/conf/truststore.pfx
      extraEnv: |-
        - name: KC_HTTPS_CERTIFICATE_FILE
          value: /opt/keycloak/conf/tls.crt
        - name: KC_HTTPS_CERTIFICATE_KEY_FILE
          value: /opt/keycloak/conf/tls.key
        - name: KC_HTTPS_CLIENT_AUTH
          value: request
        - name: KC_TRUSTSTORE_PATHS
          value: /opt/keycloak/conf/truststore.pfx
        - name: KC_HOSTNAME
          value: keycloak.dev.bigbang.mil
        - name: KC_HOSTNAME_STRICT
          value: "true"
        - name: KC_LOG_LEVEL
          value: "org.keycloak.events:DEBUG,org.infinispan:INFO,org.jgroups:INFO"

      secrets:
        env:
          stringData:
            CUSTOM_REGISTRATION_CONFIG: /opt/keycloak/conf/customreg.yaml
        customreg:
          stringData:
            customreg.yaml: '{{ .Files.Get "resources/dev/baby-yoda.yaml" }}'
        realm:
          stringData:
            realm.json: '{{ .Files.Get "resources/dev/baby-yoda.json" }}'
        truststore:
          data:
            #truststore.jks: |-
            #  {{ .Files.Get "resources/dev/truststore.jks" | b64enc }}
            # '{{ .Files.Get "resources/dev/truststore.pfx" | b64enc }}'
            truststore.pfx: |-
              {{ .Files.Get "resources/dev/truststore.pfx" | b64enc }}
        quarkusproperties:
          stringData:
            quarkus.properties: '{{ .Files.Get "resources/dev/quarkus.properties" }}'
      # Modify the image key below to deploy a custom image
      # i.e image: registry.dso.mil/big-bang/apps/product-tools/keycloak-p1-auth-plugin/init-container:test-X.X.X
      extraInitContainers: |-
        - name: plugin
          image: registry1.dso.mil/ironbank/big-bang/p1-keycloak-plugin:3.5.0
          imagePullPolicy: Always
          command:
          - sh
          - -c
          - | 
            cp /app/p1-keycloak-plugin.jar /init
            ls -l /init
          volumeMounts:
          - name: plugin
            mountPath: "/init"
          securityContext:
            capabilities:
              drop:
                - ALL
      extraVolumes: |-
        - name: customreg
          secret:
            secretName: {{ include "keycloak.fullname" . }}-customreg
        - name: realm
          secret:
            secretName: {{ include "keycloak.fullname" . }}-realm
        - name: plugin
          emptyDir: {}
        - name: truststore
          secret:
            secretName: {{ include "keycloak.fullname" . }}-truststore
        - name: quarkusproperties
          secret:
            secretName: {{ include "keycloak.fullname" . }}-quarkusproperties
            defaultMode: 0777

      #- name: truststore
      #    mountPath: /opt/keycloak/conf/truststore.jks
      #    subPath: truststore.jks
      # OR
      #- name: truststore
      #    mountPath: /opt/keycloak/conf/truststore.pfx
      #    subPath: truststore.pfx
      extraVolumeMounts: |-
        - name: customreg
          mountPath: /opt/keycloak/conf/customreg.yaml
          subPath: customreg.yaml
          readOnly: true
        - name: realm
          mountPath: /opt/keycloak/data/import/realm.json
          subPath: realm.json
        - name: plugin
          mountPath: /opt/keycloak/providers/p1-keycloak-plugin.jar
          subPath: p1-keycloak-plugin.jar
        - name: truststore
          mountPath: /opt/keycloak/conf/truststore.pfx
          subPath: truststore.pfx
        - name: quarkusproperties
          mountPath: /opt/keycloak/conf/quarkus.properties
          subPath: quarkus.properties
    istio:
      keycloak:
        enabled: true
      hardened:
        customServiceEntries:
          - name: "keycloak-http"
            enabled: true
            spec:
              hosts:
                - 'keycloak.dev.bigbang.mil'
              location: MESH_EXTERNAL
              ports:
                - number: 443
                  protocol: TLS
                  name: https
              resolution: DNS
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


2. For backstage override file see sample below:  Please replace all keycloak variable with real values.
     `backstage_override.yaml`
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

  neuvector:
    enabled: false

  twistlock:
    enabled: false

packages:
  backstage:
    enabled: true
    wrapper:
      enabled: true
    ##########################################
    ### disable the below if disabling grafana
    ##########################################
    dependsOn:
      - name: grafana
        namespace: bigbang
    ##########################################
    git:
      repo: "https://repo1.dso.mil/big-bang/product/packages/backstage"
      tag: null
      branch: "your-test-branch"
      path: "./chart"
    values:
      ########################################################
      ### Change http and Urls to reflect deployment if needed
      ########################################################
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
            registry: "registry1.dso.mil"
            repository: "bigbang-staging/backstage"
            tag: "your-test-image-tag"
          #######################################################
          ### Disable to following block if not utilizing grafana
          ### in bigbang.  See The following link for details:
          ### [Bigbang Grafana](./Grafana.md)
          #######################################################
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
          #######################################################

          resources:
            requests:
              cpu: 2
              memory: 2Gi
            limits:
              cpu: 2
              memory: 2Gi
          podSecurityContext: 
            runAsUser: 473
            runAsGroup: 473
            fsGroup: 473
            runAsNonRoot: true
            seccompProfile:
              type: RuntimeDefault

          containerSecurityContext: 
            capabilities:
                drop:
                  - ALL
          appConfig:
            app:
            #################################################
            ### Replace ${DOMAIN} with your working domain
            #################################################
              baseUrl: https://backstage.${DOMAIN}
            backend:
              baseUrl: https://backstage.${DOMAIN}
              listen:
                port: 7007
              ##########################################################################################################
              ### For use with catalog yaml URLs. See catalog.locations values for example config.
              ### Info: https://backstage.io/docs/features/software-catalog/configuration/#static-location-configuration
              ##########################################################################################################
              reading:
                allow:
                  - host: 'repo1.dso.mil'
            auth:
            ### Providing an auth.session.secret will enable session support in the auth-backend. you can use "openssl rand -hex 64" to generate a random secret from cli or use the value provided below.
              session:
                secret: "XxNl2b+/hGH7w7RJk8c5LXNOBh6+kzysxgYXlMK5Pgo="
            # see https://backstage.io/docs/auth/ to learn about auth providers
              environment: development
              providers:
                guest: {}
                  #########################################################################
                  ### The below is for use only for development.  Enables full access to
                  ### your development backstage instance through guest login.
                  ### Remove '{}' from previous providers.guest line if using this setting.
                  #########################################################################
                  #dangerouslyAllowOutsideDevelopment: true
                keycloak:
                  development:
                  # please replace variables below with real value
                    metadataUrl: "https://${KEYCLOAK_BASE_URL}/auth/realms/backstage/.well-known/openid-configuration"
                    clientId: "${KEYCLOAK_CLIENT_ID}"
                    clientSecret: "${KEYCLOAK_CLIENT_SECRET}"
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
                serviceLocatorMethod:
                type: 'multiTenant'
              clusterLocatorMethods:
                - type: 'config'
                  clusters:
                    ######################################################################################################
                    ### k8s plugin utilizes k8s api, however the url field is required to be set to avoid
                    ### a bug in the k8s plugin. See bottom of anchor link for details on how backstage omits url field:
                    ### https://backstage.io/docs/features/kubernetes/configuration/#clustersserviceaccounttoken-optional 
                    ######################################################################################################
                    - url: http://127.0.0.1:9999
                      name: bigbang-dev
                      authProvider: 'serviceAccount'
                      skipTLSVerify: false
                      skipMetricsLookup: true 

            catalog:
              providers:
                keycloakOrg:
                  default:
                    ########################################################################################
                    ### replace the following variables with the necessary values from the created keycloak.
                    ########################################################################################
                    baseUrl: "${KEYCLOAK_BASE_URL}/auth"    
                    loginRealm: "${KEYCLOAK_LOGIN_REALM}"
                    realm: "${KEYCLOAK_REALM}"
                    clientId: "${KEYCLOAK_CLIENT_ID}"
                    clientSecret: "${KEYCLOAK_CLIENT_SECRET}"
              rules:
                - allow: [Component, API, System, Location, Template, User, Group]
              locations:
                - type: file
                  target: ./catalog/*.yaml
                - type: file
                  target: ./template/*.yaml
              ######################
              ### Example url 'type'
              ######################
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
          - name: "keycloak-http.keycloak.svc.cluster.local"
            enabled: true
            spec:
              hosts:
                - 'keycloak.dev.bigbang.mil'
              location: MESH_EXTERNAL
              ports:
                - number: 443
                  protocol: TLS
                  name: https
              resolution: DNS
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
