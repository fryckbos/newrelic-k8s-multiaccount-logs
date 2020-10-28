# newrelic-k8s-multiaccount-logs

This project enables sending Kubernetes logs per namespace to different New Relic accounts. Each namespace needs to have a secret that contains the New Relic license key.

## How

The repo contains a Docker container (with kubectl, fluentbit and the new-relic-fluentbit-output plugin) that does the following:

 * Retrieve all Kubernetes namespaces and the New Relic license key per namespace from the Kubernetes API
 * Configure a FluentBit outputs accordingly
 * Whenever a namespace is created or the secret has changed, the configuration is updated and fluentbit is restarted in the containers

## Deployment

Fill in the following environment varialbes in `new-relic-logging.yml`:

 * CLUSTER_NAME: the name of the cluster
 * SECRET: the name of the secret in each namespace
 * SECRET_KEY: the key of the field in the secret
 
Deploy the components:

```
kubectl apply -f *.yml
```
