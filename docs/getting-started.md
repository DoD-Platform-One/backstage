# Backstage Bigbang

## TODO: change these for bigbang umbrella

## Base values

Utilize the following yaml overrides to get a base development deployment of backstage going in a bigbang environment.  Note that these values enable guest access, which is unrestricted full access for anyone with the URL to your backstage deployment. This does not deploy an ingress by default, so be sure to add that alongside these values, the app port to use for the service and pod is 7007.

```yaml
packages:
  backstage:
    enabled: true
    wrapper:
      enabled: true
    git:
      repo: "https://repo1.dso.mil/big-bang/product/packages/backstage"
      tag: null
      branch: "main"
      path: "./chart"
    values:
      networkPolicies:
        enabled: true
      backstage:
        serviceAccount:
          name: "backstage"
        backstage:
          args: ["--config", "app-config.yaml"]
          image:
            repository: "bigbang-staging/backstage"
            tag: "1.0.1"
          appConfig:
            auth:
              environment: development
              providers:
                guest:
                #  # because we use NODE_ENV: production, we must set this to allow guest development login
                  dangerouslyAllowOutsideDevelopment: true
```
