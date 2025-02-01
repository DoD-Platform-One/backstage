# Backstage Temporary Development Guid

The Dev and Ops team is actively working on bringing backstage to the BB suite of apps. At this time these are the
steps required to get the `stage` version of backstage up and running on your dev cluster.

> NOTE: You will need access to the bigbang-staging  projecet in Iron Bank

## Overrides

This makes use of the wrapper project to be able to pull in this chart before its officially part of the big bang echo 
system. Anything in the `packages.backstage.values` key will be passed down directly to the chart. You can read more 
about the wrapper system [here](https://docs-bigbang.dso.mil/latest/docs/guides/deployment-scenarios/extra-package-deployment/#wrapper-deployment).

Using the following overide you will be able to access the Backstage app at https://backstage.dev.bigbang.mil. As of
this writing, the guest login will allow you admin level access. 

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
  enabled: false

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
    git:
      repo: "https://repo1.dso.mil/big-bang/apps/sandbox/backstage"
      tag: null
      branch: "your-branch-here"
      path: "./chart"
    values:
      backstage:
        image:
          repository: "bigbang-staging/backstage"
          tag: "initial-start"
        resources:
          requests:
            cpu: 2
            memory: 2Gi
          limits:
            cpu: 2
            memory: 2Gi
    istio:
      hosts:
        - names:
            - backstage
          gateways:
            - public
          destination:
            port: 7007
```