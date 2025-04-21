# Backstage Development overrides

## make sure to replace git branch and image tag with your development branch and tag values

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

kyverno:
  enabled: true

kyvernoPolicies:
  enabled: true

grafana:
  enabled: true

monitoring:
  enabled: true

neuvector:
  enabled: false

twistlock:
  enabled: false

addons:
  backstage:
    enabled: true
    git:
      tag: null
      branch: "your-branch-here"
    values:
      networkPolicies:
        enabled: true
        backstage:
          image:
            repository: "bigbang-staging/backstage"
            tag: "your-dev-image-tag-here"
          appConfig:
            organization:
              name: "P1"
```
