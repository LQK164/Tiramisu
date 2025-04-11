# Change Log

This file documents all notable changes to nevisadmin4 Helm Chart.

## v7.2411.0

* Added support for Kubernetes `v1.30` and `v1.31`, and removed support for `v1.25` and `v1.26`

## v7.2405.0

* Updated the used Nevis component versions to the `7.2405.0` release.
* Added configuration values for OpenTelemetry and Product Analytics
* Gitea repositories will now be initialized when using the `bootstrap` option

## v7.2402.1

* Fixed the usage of the Git credentials when using the `git.username` and `git.password` values.

## v7.2402.0

* Updated the used Nevis component versions to the `7.2402.0` release.
* Added values `nevisAdmin4.livenessProbe` and `nevisAdmin4.readinessProbe` to be able to define custom liveness and readiness probes.

## v7.2311.1

* Added value `database.type` to support PostgreSQL database.

## v7.2311.0

* Switched to new version schema.
* Updated the used Nevis component versions to the `7.2311.0` release.
* Added value `nevisOperator.image.tag` to make it possible to specify a separate version for nevisOperator.
* Added value `nevisAdmin4.extraEnvs` to configure additional environment values for nevisAdmin 4.
* Added value `nevisAdmin4.enabled` to make it possible to only deploy the nevisOperator component.
* Added value `nevisAdmin4.ingress.annotations` to configure additional annotations for the ingress of nevisAdmin 4.

## v1.4.2

* Fixed an issue that could cause the installation to fail if https authentication was used for git.

## v1.4.1

* Fixed an issue that could cause the installation to fail if tls was enabled for nevisAdmin 4.

## v1.4.0

* Updated the used Nevis component versions to the `4.20.0` release.
* Added value `nevisOperator.defaultImagePullPolicy` to configure the `imagePullPolicy` of the deployed Nevis components.
* Secret handling was refactored to use the specified secrets directly, this improves compatibility with tools that depends on `helm template`.
  * The following values are now deprecated: `git.httpCredentialSecret`, `git.sshCredentialSecret`, `database.root.credentialSecret`. They are still honored but will be removed in the future.
  * When using the new `database.root.preparedCredentialSecret` property, the `root-creds` secret will no longer be created. Adjust the `Root Credential` and `Root Credential Namespace` in the database patterns of nevisAdmin 4 to use the prepared secret before the migration to this value.

## v1.3.2

* Use standard duration string for the CA certificate

## v1.3.1

* Fixed an issue that could cause the upgrade to fail if `nginx.controller.ingressClassResource` was defined in the provided `values.yaml`.
* Fixed an issue that caused the wrong ingress class to be used in nevisOperator if `nginx.controller.ingressClassResource.enabled` was set to `false`.

## v1.3.0

* Updated the used Nevis component versions to the `4.19.1` release.

## v1.2.0

* Updated the used Nevis component versions to the `4.19` release.
* Added optional mariadb and gitea dependency.
* Added value `repositoryUrlMap` to allow configuring separate git repository url for different component namespaces.
* Added values for cors and ldap.
* Added values for overriding nevisAdmin 4 configuration files.
* Fixed an issue that caused an incorrect passphrase generated for the tls keystore.

## v1.1.1

* Fixed an issue that the initial random password of nevisAdmin 4 was generated with each install. This caused the password in the Kubernetes secret and the actual password to be different.

## v1.1.0

* Updated the used Nevis component versions to the `4.18` release.
* Added separate service account for the nevisAdmin 4 instance.
* Added new label and annotation values.
* Adjusted used `securityContext` for `restricted` Pod Security Standard
* Added multiple new values for credentials that can be used in place of prepared secrets.
* Updated ingress-nginx chart to `4.4.0`
* Added support for Kubernetes `v1.25`, and removed support for `v1.20`

## v1.0.1

* Added cert-manager related values
* Fixed null error when using the `--dry-run` option
