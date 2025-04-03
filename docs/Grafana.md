# Grafana plugin enabled

<https://github.com/backstage/community-plugins/blob/main/workspaces/grafana/plugins/grafana/docs/index.md>

## With new grafana deployment

To utilize grafana, users will need to enable the necessary block near the bottom of [values.yaml](../chart/values.yaml#L466) by uncommenting them, as well as
defining the three necessary components anchored at the top of values.yaml:

- `grafana.grafanaHttp`: http or https for communication to grafana API
- `grafana.grafanaUrl`: grafana API URL (in a k8s service approach, utilize service-name.namespace.svc.cluster.local)
- `grafana.externalurl`: URL to external grafana.  This is the URL used when generating links to dashboards on the component page.
This method will automatically generate the grafana API token for backstage to consume for purposes of grabbing dashboards and alert data if it is configured in the app config.

## With existing grafana deployment

If you have an existing grafana deployment, you may create a Service Account and subsequent Service Account Token under grafana, with the role "Viewer".
This value will need to be created as a secret with the name `grafana-api-token`, and key `GRAFANA_TOKEN` with value equal to the service account token generated in the previous step in the backstage namespace (as base64).  Create the namespace and secret prior to deploying backstage. Be sure to add the following to [values.yaml](../chart/values.yaml) to add this secret as the necessary environment var to your backstage pod, and attach the grafana endpoints vars for use in backstage:

```yaml
backstage:
  backstage:
    extraEnvVars:
      - name: GRAFANA_HTTP
        value: *grafanaHttp
      - name: GRAFANA_URL
        value: *grafanaUrl
      - name: GRAFANA_DOMAIN
        value: *grafanaExternalUrl
    extraEnvVarsSecrets:
      - grafana-api-token
```

Also be sure to define the following components near the top of [values.yaml](../chart/values.yaml), as they are anchored:

- `grafana.grafanaHttp`: http or https for communication to grafana API
- `grafana.grafanaUrl`: grafana API URL (in a k8s service approach, utilize service-name.namespace.svc.cluster.local)
- `grafana.externalurl`: URL to external grafana.  This is the URL used when generating links to dashboards on the component page.

### WIP

- configuring grafana at runtime as an option versus static frontend/backend in build
