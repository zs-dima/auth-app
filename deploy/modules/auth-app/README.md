# auth

Timoni module to deploy the auth app to Kubernetes clusters.

## Build yaml

```shell

timoni -n auth-app build auth-app . oci://docker.io/zsdima/auth-app --values values.yaml

```

## Publish

```shell

timoni mod push deploy/modules/auth-app oci://docker.io/zsdima/auth-app --latest=false  --version=1.0.0-beta.2

```
