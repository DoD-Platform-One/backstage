<!-- Warning: Do not manually edit this file. See notes on gluon + helm-docs at the end of this file for more information. -->
# backstage

![Version: 1.9.6-bb.3](https://img.shields.io/badge/Version-1.9.6--bb.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.31.1](https://img.shields.io/badge/AppVersion-v1.31.1-informational?style=flat-square) ![Maintenance Track: unknown](https://img.shields.io/badge/Maintenance_Track-unknown-red?style=flat-square)

A Helm chart for deploying a Backstage application

## Upstream References

- <https://backstage.io>
- <https://github.com/backstage/charts>
- <https://github.com/backstage/backstage>

## Upstream Release Notes

This package has no upstream release note links on file. Please add some to [chart/Chart.yaml](chart/Chart.yaml) under `annotations.bigbang.dev/upstreamReleaseNotesMarkdown`.
Example:
```yaml
annotations:
  bigbang.dev/upstreamReleaseNotesMarkdown: |
    - [Find our upstream chart's CHANGELOG here](https://link-goes-here/CHANGELOG.md)
    - [and our upstream application release notes here](https://another-link-here/RELEASE_NOTES.md)
```

## Learn More

- [Application Overview](docs/overview.md)
- [Other Documentation](docs/)

## Pre-Requisites

- Kubernetes Cluster deployed
- Kubernetes config installed in `~/.kube/config`
- Helm installed

Kubernetes: `>= 1.19.0-0`

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

- Clone down the repository
- cd into directory

```bash
helm install backstage chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global | object | See below | Global parameters Global Docker image parameters Please, note that this will override the image parameters, including dependencies, configured to use the global value Current available global Docker image parameters: imageRegistry, imagePullSecrets and storageClass |
| global.imageRegistry | string | `""` | Global Docker image registry |
| global.imagePullSecrets | list | `[]` | Global Docker registry secret names as an array </br> E.g. `imagePullSecrets: [myRegistryKeySecretName]` |
| grafana.url | string | `""` |  |
| grafana.http | string | `"http"` |  |
| grafana.externalUrl | string | `""` |  |
| kubeVersion | string | `""` | Override Kubernetes version |
| nameOverride | string | `""` | String to partially override common.names.fullname |
| fullnameOverride | string | `""` | String to fully override common.names.fullname |
| clusterDomain | string | `"cluster.local"` | Default Kubernetes cluster domain |
| commonLabels | object | `{}` | Labels to add to all deployed objects |
| commonAnnotations | object | `{}` | Annotations to add to all deployed objects |
| extraDeploy | list | `[]` | Array of extra objects to deploy with the release |
| diagnosticMode | object | `{"args":["infinity"],"command":["sleep"],"enabled":false}` | Enable diagnostic mode in the Deployment |
| diagnosticMode.enabled | bool | `false` | Enable diagnostic mode (all probes will be disabled and the command will be overridden) |
| diagnosticMode.command | list | `["sleep"]` | Command to override all containers in the Deployment |
| diagnosticMode.args | list | `["infinity"]` | Args to override all containers in the Deployment |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"host":"","path":"/","tls":{"enabled":false,"secretName":""}}` | Ingress parameters |
| ingress.enabled | bool | `false` | Enable the creation of the ingress resource |
| ingress.className | string | `""` | Name of the IngressClass cluster resource which defines which controller will implement the resource (e.g nginx) |
| ingress.annotations | object | `{}` | Additional annotations for the Ingress resource |
| ingress.host | string | `""` | Hostname to be used to expose the route to access the backstage application (e.g: backstage.IP.nip.io) |
| ingress.path | string | `"/"` | Path to be used to expose the full route to access the backstage application (e.g: IP.nip.io/backstage) |
| ingress.tls | object | `{"enabled":false,"secretName":""}` | Ingress TLS parameters |
| ingress.tls.enabled | bool | `false` | Enable TLS configuration for the host defined at `ingress.host` parameter |
| ingress.tls.secretName | string | `""` | The name to which the TLS Secret will be called |
| backstage | object | See below | Backstage parameters |
| backstage.backstage.replicas | int | `1` | Number of deployment replicas |
| backstage.backstage.revisionHistoryLimit | int | `10` | Define the [count of deployment revisions](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy) to be kept. May be set to 0 in case of GitOps deployment approach. |
| backstage.backstage.image.registry | string | `"registry1.dso.mil"` | Backstage image registry |
| backstage.backstage.image.repository | string | `"bigbang-staging/backstage"` | Backstage image repository |
| backstage.backstage.image.tag | string | `"initial-start"` | Backstage image tag (immutable tags are recommended) |
| backstage.backstage.image.pullPolicy | string | `"Always"` | Specify a imagePullPolicy. Defaults to 'Always' if image tag is 'latest', else set to 'IfNotPresent' <br /> Ref: https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy |
| backstage.backstage.image.pullSecrets | list | `["private-registry"]` | Optionally specify an array of imagePullSecrets.  Secrets must be manually created in the namespace. <br /> Ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ <br /> E.g: `pullSecrets: [myRegistryKeySecretName]` |
| backstage.backstage.containerPorts | object | `{"backend":7007}` | Container ports on the Deployment |
| backstage.backstage.command | list | `["node","packages/backend"]` | Backstage container command |
| backstage.backstage.args | list | `[]` | Backstage container command arguments |
| backstage.backstage.extraAppConfig | list | `[]` | Extra app configuration files to inline into command arguments |
| backstage.backstage.extraContainers | list | `[]` | Deployment sidecars |
| backstage.backstage.extraEnvVarsCM | list | `[]` | Backstage container environment variables from existing ConfigMaps |
| backstage.backstage.extraVolumeMounts | list | `[]` | Backstage container additional volume mounts |
| backstage.backstage.extraVolumes | list | `[]` | Backstage container additional volumes |
| backstage.backstage.extraEnvVars | list | `[]` | Backstage container environment variables |
| backstage.backstage.extraEnvVarsSecrets | list | `[]` | Backstage container environment variables from existing Secrets |
| backstage.backstage.initContainers | list | `[]` | Backstage container init containers |
| backstage.backstage.installDir | string | `"/app"` | Directory containing the backstage installation |
| backstage.backstage.resources | object | `{"limits":{"cpu":2,"memory":"2Gi"},"requests":{"cpu":0.6,"memory":"500Mi"}}` | Resource requests/limits <br /> Ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-requests-and-limits-of-pod-and-container <!-- E.g. resources:   limits:     memory: 1Gi     cpu: 1000m   requests:     memory: 250Mi     cpu: 100m --> |
| backstage.backstage.readinessProbe | object | `{}` | Readiness Probe Backstage doesn't provide any health endpoints by default. A simple one can be added like this: https://backstage.io/docs/plugins/observability/#health-checks <br /> Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes <!-- E.g. readinessProbe:   failureThreshold: 3   httpGet:     path: /healthcheck     port: 7007     scheme: HTTP   initialDelaySeconds: 30   periodSeconds: 10   successThreshold: 2   timeoutSeconds: 2 |
| backstage.backstage.livenessProbe | object | `{}` | Liveness Probe Backstage doesn't provide any health endpoints by default. A simple one can be added like this: https://backstage.io/docs/plugins/observability/#health-checks <br /> Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes <!-- E.g. livenessProbe:   failureThreshold: 3   httpGet:     path: /healthcheck     port: 7007     scheme: HTTP   initialDelaySeconds: 60   periodSeconds: 10   successThreshold: 1   timeoutSeconds: 2 |
| backstage.backstage.startupProbe | object | `{}` | Startup Probe Backstage doesn't provide any health endpoints by default. A simple one can be added like this: https://backstage.io/docs/plugins/observability/#health-checks <br /> Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes <!-- E.g. startupProbe:   failureThreshold: 3   httpGet:     path: /healthcheck     port: 7007     scheme: HTTP   initialDelaySeconds: 60   periodSeconds: 10   successThreshold: 1   timeoutSeconds: 2 |
| backstage.backstage.podSecurityContext | object | `{"fsGroup":473,"runAsGroup":473,"runAsNonRoot":true,"runAsUser":473,"seccompProfile":{"type":"RuntimeDefault"}}` | Security settings for a Pod.  The security settings that you specify for a Pod apply to all Containers in the Pod. <br /> Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod |
| backstage.backstage.containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}` | Security settings for a Container. <br /> Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container |
| backstage.backstage.appConfig | object | `{}` | Generates ConfigMap and configures it in the Backstage pods |
| backstage.backstage.affinity | object | `{}` | Affinity for pod assignment <br /> Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| backstage.backstage.nodeSelector | object | `{}` | Node labels for pod assignment <br /> Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector |
| backstage.backstage.tolerations | list | `[]` | Node tolerations for server scheduling to nodes with taints <br /> Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ |
| backstage.backstage.podAnnotations | object | `{}` | Annotations to add to the backend deployment pods |
| backstage.backstage.podLabels | object | `{}` | Labels to add to the backend deployment pods |
| backstage.backstage.annotations | object | `{}` | Additional custom annotations for the `Deployment` resource |
| service | object | See below | Service parameters |
| service.type | string | `"ClusterIP"` | Kubernetes Service type |
| service.ports | object | `{"backend":7007,"name":"http-backend","targetPort":"backend"}` | Backstage svc port for client connections |
| service.ports.name | string | `"http-backend"` | Backstage svc port name |
| service.ports.targetPort | string | `"backend"` | Backstage svc target port referencing receiving pod container port |
| service.nodePorts | object | `{"backend":""}` | Node port for the Backstage client connections Choose port between `30000-32767` |
| service.sessionAffinity | string | `"None"` | Control where client requests go, to the same pod or round-robin (values: `ClientIP` or `None`) <br /> Ref: https://kubernetes.io/docs/concepts/services-networking/service/#session-stickiness |
| service.clusterIP | string | `""` | Backstage service Cluster IP  <br /> E.g `clusterIP: None` |
| service.loadBalancerIP | string | `""` | Backstage service Load Balancer IP  <br /> Ref: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer |
| service.loadBalancerSourceRanges | list | `[]` | Load Balancer sources  <br /> Ref: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer <br /> E.g `loadBalancerSourceRanges: [10.10.10.0/24]` |
| service.externalTrafficPolicy | string | `"Cluster"` | Backstage service external traffic policy  Ref: https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip |
| service.annotations | object | `{}` | Additional custom annotations for Backstage service |
| service.extraPorts | list | `[]` | Extra ports to expose in the Backstage service (normally used with the `sidecar` value) |
| networkPolicy.enabled | bool | `false` | Specifies whether a NetworkPolicy should be created |
| networkPolicy.ingressRules.namespaceSelector | object | `{}` | Namespace selector label allowed to access the Backstage instance |
| networkPolicy.ingressRules.podSelector | object | `{}` | Pod selector label allowed to access the Backstage instance |
| networkPolicy.ingressRules.customRules | list | `[]` | Additional custom ingress rules |
| networkPolicy.egressRules.denyConnectionsToExternal | bool | `false` | Deny external connections. Should not be enabled when working with an external database. |
| networkPolicy.egressRules.customRules | list | `[]` | Additional custom egress rules |
| postgresql | object | See below | PostgreSQL [chart configuration](https://github.com/bitnami/charts/blob/master/bitnami/postgresql/values.yaml) |
| postgresql.enabled | bool | `false` | Switch to enable or disable the PostgreSQL helm chart |
| postgresql.auth | object | `{"existingSecret":"","password":"","secretKeys":{"adminPasswordKey":"admin-password","replicationPasswordKey":"replication-password","userPasswordKey":"user-password"},"username":"bn_backstage"}` | The authentication details of the Postgres database |
| postgresql.auth.username | string | `"bn_backstage"` | Name for a custom user to create |
| postgresql.auth.password | string | `""` | Password for the custom user to create |
| postgresql.auth.existingSecret | string | `""` | Name of existing secret to use for PostgreSQL credentials |
| postgresql.auth.secretKeys | object | `{"adminPasswordKey":"admin-password","replicationPasswordKey":"replication-password","userPasswordKey":"user-password"}` | The secret keys Postgres will look for to retrieve the relevant password |
| postgresql.auth.secretKeys.adminPasswordKey | string | `"admin-password"` | The key in which Postgres will look for, for the admin password, in the existing Secret |
| postgresql.auth.secretKeys.userPasswordKey | string | `"user-password"` | The key in which Postgres will look for, for the user password, in the existing Secret |
| postgresql.auth.secretKeys.replicationPasswordKey | string | `"replication-password"` | The key in which Postgres will look for, for the replication password, in the existing Secret |
| postgresql.architecture | string | `"standalone"` | PostgreSQL architecture (`standalone` or `replication`) |
| serviceAccount | object | See below | Service Account Configuration |
| serviceAccount.create | bool | `false` | Enable the creation of a ServiceAccount for Backstage pods |
| serviceAccount.name | string | `""` | Name of the ServiceAccount to use If not set and `serviceAccount.create` is true, a name is generated |
| serviceAccount.labels | object | `{}` | Additional custom labels to the service ServiceAccount. |
| serviceAccount.annotations | object | `{}` | Additional custom annotations for the ServiceAccount. |
| serviceAccount.automountServiceAccountToken | bool | `true` | Auto-mount the service account token in the pod |
| metrics | object | `{"serviceMonitor":{"annotations":{},"enabled":false,"interval":null,"labels":{},"path":"/metrics"}}` | Metrics configuration |
| metrics.serviceMonitor | object | `{"annotations":{},"enabled":false,"interval":null,"labels":{},"path":"/metrics"}` | ServiceMonitor configuration <br /> Allows configuring your backstage instance as a scrape target for [Prometheus](https://github.com/prometheus/prometheus) using a ServiceMonitor custom resource that [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator) can understand. |
| metrics.serviceMonitor.enabled | bool | `false` | If enabled, a ServiceMonitor resource for Prometheus Operator is created <br /> Prometheus Operator must be installed in your cluster prior to enabling. |
| metrics.serviceMonitor.annotations | object | `{}` | ServiceMonitor annotations |
| metrics.serviceMonitor.labels | object | `{}` | Additional ServiceMonitor labels |
| metrics.serviceMonitor.interval | string | `nil` | ServiceMonitor scrape interval |
| metrics.serviceMonitor.path | string | `"/metrics"` | ServiceMonitor endpoint path <br /> Note that the /metrics endpoint is NOT present in a freshly scaffolded Backstage app. To setup, follow the [Prometheus metrics tutorial](https://github.com/backstage/backstage/blob/master/contrib/docs/tutorials/prometheus-metrics.md). |
| domain | string | `"dev.bigbang.mil"` |  |
| networkPolicies.enabled | bool | `false` | Toggle networkPolicies |
| networkPolicies.controlPlaneCidr | string | `"0.0.0.0/0"` | Control Plane CIDR, defaults to 0.0.0.0/0, use `kubectl get endpoints -n default kubernetes` to get the CIDR range needed for your cluster Must be an IP CIDR range (x.x.x.x/x - ideally with /32 for the specific IP of a single endpoint, broader range for multiple masters/endpoints) Used by package NetworkPolicies to allow Kube API access |
| networkPolicies.additionalPolicies | list | `[]` |  |
| networkPolicies.egress | object | `{}` | NetworkPolicy selectors and ports for egress to downstream telemetry ingestion services. These should be uncommented and overridden if any of these values deviate from the Big Bang defaults. |
| networkPolicies.ingressLabels.app | string | `"istio-ingressgateway"` |  |
| networkPolicies.ingressLabels.istio | string | `"ingressgateway"` |  |
| istio | object | `{"backstage":{"gateways":["istio-system/public"],"hosts":["backstage.{{ .Values.domain }}"]},"enabled":false,"hardened":{"customAuthorizationPolicies":[],"customServiceEntries":[],"enabled":false,"outboundTrafficPolicyMode":"REGISTRY_ONLY"},"mtls":{"mode":"STRICT"},"namespace":"istio-system"}` | Istio configuration |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.

---

_This file is programatically generated using `helm-docs` and some BigBang-specific templates. The `gluon` repository has [instructions for regenerating package READMEs](https://repo1.dso.mil/big-bang/product/packages/gluon/-/blob/master/docs/bb-package-readme.md)._

