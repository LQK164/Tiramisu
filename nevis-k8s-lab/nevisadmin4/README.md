# nevisadmin4

![Version: 7.2411.0](https://img.shields.io/badge/Version-7.2411.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 7.2411.0](https://img.shields.io/badge/AppVersion-7.2411.0-informational?style=flat-square)

A Helm chart for installing nevisAdmin4.

## Prerequisites

- Existing cert-manager installation
    - Follow: https://cert-manager.io/docs/installation/
- Existing MariaDB database
    - The following values has to be configured for the database:
    ```console
    autocommit=0
    transaction-isolation = READ-COMMITTED
    log_bin_trust_function_creators = 1
    lower_case_table_names = 1
    character-set-server = utf8mb4
    ```
- Existing Git system
- Nevis docker images already pushed to the container repository

## Requirements

Kubernetes: `>= 1.27.0 < 1.32.0`

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | maria(mariadb) | 11.5.1 |
| https://dl.gitea.io/charts | gitea | 7.0.4 |
| https://kubernetes.github.io/ingress-nginx | nginx(ingress-nginx) | 4.7.2 |

## Install Chart

### Prepare secrets for installation
First we prepare the required secrets to be used by the helm chart. This is done to avoid having plain secret values in the values.yaml.
#### Generate key material
```console
ssh-keyscan [GIT_DOMAIN] > known_hosts
ssh-keygen -t ecdsa -C "kubernetes" -m PEM -P "" -f key
```
#### Create ssh secret
```console
kubectl create namespace [RELEASE_NAMESPACE]
kubectl create secret generic helm-git-ssh \
--from-file=key=key \
--from-file=key.pub=key.pub \
--from-file=known_hosts=known_hosts\
-n [RELEASE_NAMESPACE]
```
#### Create database credential secret
```console
kubectl create secret generic helm-database-credential \
--from-literal=username=[DB_ROOT_USER] \
--from-literal=password=[DB_ROOT_PASSWORD] \
-n [RELEASE_NAMESPACE]
```

### Fill in the following required values in the `values.yaml`:
   - `image.repository`: Container repository url
   - `database.host`: Database host of the MariaDB database.
   - `nevisAdmin4.domain`: Domain where nevisAdmin4 will be available. Make sure to point the domain to the IP of the nginx LoadBalancer after the installation is done.
   - `git.repositoryUrl`: URL of the Git repository to be used by nevisAdmin4.

For more configuration options see the values table below.

### Install
```console
helm install [RELEASE_NAME] -n [RELEASE_NAMESPACE]
```

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME] -n [RELEASE_NAMESPACE]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalComponentNamespaces | list | `[]` | Listing additional ones here, will make it so that nevisAdmin4 can deploy to these namespaces. The namespace itself has to exist already. |
| bootstrap | object | `{"annotations":{},"gitea":{"enabled":false},"image":{"version":"1.3.0"},"labels":{},"nevisAdmin4":{"enabled":false},"podAnnotations":{},"podLabels":{}}` | Supports importing initial projects and inventories into nevisAdmin 4 and creating a repository in gitea. |
| bootstrap.annotations | object | `{}` | Annotations to put onto the Job. |
| bootstrap.labels | object | `{}` | Labels to put onto the bootstrap job. |
| bootstrap.podAnnotations | object | `{}` | Annotations to put onto the pods. |
| bootstrap.podLabels | object | `{}` | Labels to put onto the bootstrap job pod. |
| certManager.createCAIssuer | bool | `true` | Create a CA Issuer to the main release namespace, it also creates a self-signed issuer to prepare the root CA |
| certManager.createLetsEncryptIssuer | bool | `true` | Creates a Let's encrypt issuer to every component namespace |
| database.host | string | `""` | Database host, example: mariadb29a7439e.mariadb.database.azure.com |
| database.port | string | `"3306"` | Database port |
| database.root.credentialSecret | string | `"helm-database-credential"` | DEPRECATED: Use `preparedCredentialSecret` instead. Secret containing the username and password for the root user. Must have the "username" and "password" key. |
| database.root.password | string | `""` | Root password in plain value. It's recommended to prepare a secret instead. |
| database.root.preparedCredentialSecret | string | `""` | When using this value, root-creds secret will only be created in the namespace where nevisAdmin4 resides. Adjust the `Root Credential Namespace` in the Database patterns of nevisAdmin 4 before the migration to this value. |
| database.root.username | string | `""` | Root username in plain value. It's recommended to prepare a secret instead. |
| database.type | string | `"mariadb"` | Type of the database, supported values: mariadb, postgresql |
| git.credentialSecret | string | `""` | Secret containing the git credentials, to avoid having plain values in the values file. Must have "key", "key.pub", "known_hosts", "passphrase", "username", "password" secret keys. In case only http or ssh is used, the corresponding keys can be empty, but still has to exist in the secret. |
| git.httpCredentialSecret | string | `""` | DEPRECATED: Use `credentialSecret` instead. Secret containing the username and password for http authentication. Must have the "username" and "password" key. |
| git.knownHosts64 | string | `""` | Base64 known_hosts. |
| git.passphrase | string | `""` | Private key passphrase |
| git.password | string | `""` | Password used for http authentication. It's recommended to prepare a secret instead. |
| git.privateKey64 | string | `""` | Base64 git private key. |
| git.publicKey64 | string | `""` | Base64 git public key. |
| git.repositoryUrl | string | `""` | Git repository, can be either ssh or http |
| git.repositoryUrlMap | object | `{}` | Makes it possible to use a different repository for each component namespace |
| git.sshCredentialSecret | string | `"helm-git-ssh"` | DEPRECATED: Use `credentialSecret` instead. Secret containing the git credentials, to avoid having plain values in the values file. Must have "key", "key.pub", "known_hosts" key. |
| git.username | string | `""` | Username used for http authentication. It's recommended to prepare a secret instead. |
| gitea.enabled | bool | `false` |  |
| gitea.fullnameOverride | string | `"gitea"` | Name of the gitea deployment |
| gitea.gitea.admin.email | string | `"gitea@local.domain"` |  |
| gitea.gitea.admin.password | string | `""` | Gitea admin password |
| gitea.gitea.admin.username | string | `""` | Gitea admin username |
| gitea.gitea.config.cache.ADAPTER | string | `"memory"` |  |
| gitea.gitea.config.cache.ENABLED | bool | `true` |  |
| gitea.gitea.config.cache.HOST | string | `"127.0.0.1:9090"` |  |
| gitea.gitea.config.cache.INTERVAL | int | `60` |  |
| gitea.gitea.config.database.DB_TYPE | string | `"mysql"` |  |
| gitea.gitea.config.database.HOST | string | `"mariadb:3306"` |  |
| gitea.gitea.config.database.NAME | string | `"gitea"` |  |
| gitea.gitea.config.database.PASSWD | string | `""` | Database user password |
| gitea.gitea.config.database.SCHEMA | string | `"gitea"` |  |
| gitea.gitea.config.database.USER | string | `""` | Database user for gitea |
| gitea.gitea.config.server.ROOT_URL | string | `""` | Root url of gitea |
| gitea.image.rootless | bool | `true` | Use rootless image |
| gitea.ingress.annotations."cert-manager.io/cluster-issuer" | string | `"letsencrypt-prod"` |  |
| gitea.ingress.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/$2"` |  |
| gitea.ingress.apiVersion | string | `"networking.k8s.io/v1"` |  |
| gitea.ingress.enabled | bool | `true` |  |
| gitea.ingress.hosts[0].host | string | `""` |  |
| gitea.ingress.hosts[0].paths[0].path | string | `"/gitea(/|$)(.*)"` |  |
| gitea.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| gitea.ingress.tls[0].hosts[0] | string | `""` |  |
| gitea.ingress.tls[0].secretName | string | `"gitea-tls"` |  |
| gitea.job.annotations | object | `{}` | Annotations to put onto the Job. |
| gitea.job.labels | object | `{}` |  |
| gitea.job.podAnnotations | object | `{}` | Annotations to put onto the pods. |
| gitea.job.podLabels | object | `{}` | Labels to put onto the bootstrap job pod. |
| gitea.memcached.enabled | bool | `false` |  |
| gitea.mysql.enabled | bool | `false` |  |
| gitea.postgresql.enabled | bool | `false` |  |
| gitea.statefulset.env[0].name | string | `"HOME"` |  |
| gitea.statefulset.env[0].value | string | `"/data/git"` |  |
| image.imagePrefix | string | `"nevis"` | Image prefix, nevis images will be pulled from [repository]/[imagePrefix] |
| image.imagePullSecretName | string | `""` | Name of the secret containing the credentials, only necessary if a private repository is used. |
| image.repository | string | `""` | Repository where the images will be pulled from |
| maria.auth.password | string | `"nevis"` | Name of the additional user created for mariadb |
| maria.auth.rootPassword | string | `""` | Root password of mariadb |
| maria.auth.username | string | `""` | Password of the additional user |
| maria.enabled | bool | `false` |  |
| maria.fullnameOverride | string | `"mariadb"` | Name of the mariadb deployment |
| maria.primary.configuration | string | `"[mysqld]\nskip-name-resolve\nexplicit_defaults_for_timestamp\nbasedir=/opt/bitnami/mariadb\nplugin_dir=/opt/bitnami/mariadb/plugin\nport=3306\nsocket=/opt/bitnami/mariadb/tmp/mysql.sock\ntmpdir=/opt/bitnami/mariadb/tmp\nmax_allowed_packet=16M\nbind-address=*\npid-file=/opt/bitnami/mariadb/tmp/mysqld.pid\nlog-error=/opt/bitnami/mariadb/logs/mysqld.log\ncharacter-set-server=utf8mb4\nslow_query_log=0\nslow_query_log_file=/opt/bitnami/mariadb/logs/mysqld.log\nlong_query_time=10.0\nmax_connections=1200\nconnect_timeout=5\nwait_timeout=600\ntransaction-isolation=READ-COMMITTED\nlower_case_table_names=1\nlog_bin_trust_function_creators=1\n\n[client]\nport=3306\nsocket=/opt/bitnami/mariadb/tmp/mysql.sock\ndefault-character-set=UTF8\nplugin_dir=/opt/bitnami/mariadb/plugin\n\n[manager]\nport=3306\nsocket=/opt/bitnami/mariadb/tmp/mysql.sock\npid-file=/opt/bitnami/mariadb/tmp/mysqld.pid"` | Primary node configuration |
| nevisAdmin4.affinity | object | `{}` |  |
| nevisAdmin4.annotations | object | `{}` | Additional annotations to be put on the nevisAdmin4 StatefulSet. |
| nevisAdmin4.certManagerIssuer | string | `"letsencrypt-prod"` | Specify the cert-manager issuer for the nevisAdmin4 ingress |
| nevisAdmin4.config | object | `{"env":"","logback":"","nevisadmin4":{}}` | low level configuration options |
| nevisAdmin4.config.env | string | `""` | Content of env.conf configuration file as multiline string |
| nevisAdmin4.config.logback | string | `""` | Content of logback.xml configuration file as multiline string |
| nevisAdmin4.config.nevisadmin4 | object | `{}` | Content of nevisadmin4.yml configuration file |
| nevisAdmin4.configOverrideEnabled | bool | `false` | The env.conf, nevisadmin4.yml and logback.xml can be overriden by placing tha file with the same name besides the values.yaml |
| nevisAdmin4.containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}` | Security context for the nevisAdmin4 pod containers. |
| nevisAdmin4.cors | object | `{}` | cors attributes |
| nevisAdmin4.credentialSecret | string | `""` | Secret containing the initial password of nevisAdmin4 to avoid plain values in the values file. Must have the "password" key. If credentialSecret and password is not given it will be autogenerated. Must be prepared id advance. |
| nevisAdmin4.database.applicationUser | string | `"admin4appuser"` | Database user by nevisAdmin4 |
| nevisAdmin4.database.applicationUserPassword | string | `""` | Database app user password. |
| nevisAdmin4.database.credentialSecret | string | `""` | Secret containing schema and application user credentials to avoid plain values in the values file. Must have the "applicationUser", "applicationUserPassword", "schemaUser", "schemaUserPassword" key. Must be prepared is advance. |
| nevisAdmin4.database.enableSSL | bool | `true` | Disable ssl if it's not supported by the database |
| nevisAdmin4.database.job | object | `{"annotations":{},"cleanupEnabled":true,"labels":{},"podAnnotations":{},"podLabels":{},"ttlSecondsAfterFinished":1200}` | Values for the dbschema job |
| nevisAdmin4.database.job.annotations | object | `{}` | Annotations to put onto the migration job. |
| nevisAdmin4.database.job.cleanupEnabled | bool | `true` | dbschema job will be deleted automatically |
| nevisAdmin4.database.job.labels | object | `{}` | Labels to put onto the migration job. |
| nevisAdmin4.database.job.podAnnotations | object | `{}` | Annotations to put onto the migration job pod. |
| nevisAdmin4.database.job.podLabels | object | `{}` | Labels to put onto the migration job pod. |
| nevisAdmin4.database.name | string | `"nevisadmin4"` | Name of the database |
| nevisAdmin4.database.schemaUser | string | `"admin4schemauser"` | Database user used for the migration of the database for nevisAdmin4. |
| nevisAdmin4.database.schemaUserPassword | string | `""` | Database schema user password. |
| nevisAdmin4.domain | string | `""` | Domain where nevisAdmin4 will be reachable |
| nevisAdmin4.enabled | bool | `true` |  |
| nevisAdmin4.extraEnvs | list | `[]` | Additional environment variables that will be added to the nevisAdmin4 container |
| nevisAdmin4.image.migrationTag | string | `""` | Overrides the dbschema image tag whose default is the chart appVersion. |
| nevisAdmin4.image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| nevisAdmin4.ingress.annotations | object | `{"nginx.ingress.kubernetes.io/proxy-body-size":"100m"}` | Annotations to be put on the nevisAdmin4 Ingress. |
| nevisAdmin4.ingress.enabled | bool | `true` |  |
| nevisAdmin4.ingressIssuerAnnotation | string | `"cert-manager.io/issuer"` | cert-manager annotation to put on the ingress |
| nevisAdmin4.labels | object | `{}` | Additional labels to be put on the nevisAdmin4 StatefulSet. |
| nevisAdmin4.ldap | object | `{"context":{},"enabled":false,"search":{},"truststore64":"","truststorePassphrase":"","user":{}}` | ldap attributes for the nevisadmin4.yml |
| nevisAdmin4.ldap.context | object | `{}` | ldap context block |
| nevisAdmin4.ldap.enabled | bool | `false` | Enable ldap |
| nevisAdmin4.ldap.search | object | `{}` | ldap search block |
| nevisAdmin4.ldap.truststore64 | string | `""` | pkcs12 truststore in base64 format |
| nevisAdmin4.ldap.truststorePassphrase | string | `""` | truststore passphrase |
| nevisAdmin4.ldap.user | object | `{}` | ldap user block |
| nevisAdmin4.livenessProbe | object | `{}` | Specify a custom livenessProbe. |
| nevisAdmin4.managementPort | int | `9889` | Management port, this is where the health checks will be available |
| nevisAdmin4.migrationResources.limits.cpu | string | `"1000m"` |  |
| nevisAdmin4.migrationResources.limits.memory | string | `"1000Mi"` |  |
| nevisAdmin4.migrationResources.requests.cpu | string | `"20m"` |  |
| nevisAdmin4.migrationResources.requests.memory | string | `"200Mi"` |  |
| nevisAdmin4.nodeSelector | object | `{}` |  |
| nevisAdmin4.otel.enabled | bool | `false` | Enable OpenTelemetry forwarding |
| nevisAdmin4.otel.protocol | string | `"http/protobuf"` | OpenTelemetry protocol |
| nevisAdmin4.otel.url | string | `""` | OpenTelemetry url |
| nevisAdmin4.password | string | `""` | Initial password of nevisAdmin4. If credentialSecret and password is not given it will be autogenerated. |
| nevisAdmin4.podAnnotations | object | `{}` | Additional annotations to be put on the nevisAdmin4 pods. |
| nevisAdmin4.podLabels | object | `{}` | Additional labels to be put on the nevisAdmin4 pods. |
| nevisAdmin4.podSecurityContext | object | `{"fsGroup":2000,"runAsNonRoot":true}` | Security context for the nevisAdmin4 pods. |
| nevisAdmin4.port | int | `9080` | Default port of nevisAdmin4 |
| nevisAdmin4.productAnalytics.enabled | bool | `false` | Enable product analytics |
| nevisAdmin4.productAnalytics.prometheus.credentialSecret | string | `""` | Credential secret for Prometheus in case basic authentication is enabled. Has to have "password" and "username" keys. |
| nevisAdmin4.productAnalytics.prometheus.password | string | `""` | Password for Prometheus in case basic authentication is enabled |
| nevisAdmin4.productAnalytics.prometheus.url | string | `""` | base url of the Prometheus instance |
| nevisAdmin4.productAnalytics.prometheus.username | string | `""` | Username for Prometheus in case basic authentication is enabled |
| nevisAdmin4.readinessProbe | object | `{}` | Specify a custom readinessProbe. |
| nevisAdmin4.resources.limits.cpu | string | `"4000m"` |  |
| nevisAdmin4.resources.limits.memory | string | `"4500Mi"` |  |
| nevisAdmin4.resources.requests.cpu | string | `"1000m"` |  |
| nevisAdmin4.resources.requests.memory | string | `"1500Mi"` |  |
| nevisAdmin4.saml.attribute | object | `{"email":"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress","first-name":"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname","group-keys":"http://schemas.microsoft.com/ws/2008/06/identity/claims/role","last-name":"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname","user-key":"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"}` | SAML attributes, by default it is set up for azure AD |
| nevisAdmin4.saml.certificate64 | string | `""` | Base64 saml.crt. |
| nevisAdmin4.saml.enabled | bool | `false` | Enable SAML login |
| nevisAdmin4.saml.idp.metadataUri | string | `nil` |  |
| nevisAdmin4.saml.keySecret | string | `""` | Secret containing the sam key and certificate to avoid using local files. Must be prepared advance. Must have saml.key and saml.crt key. |
| nevisAdmin4.saml.privateKey64 | string | `""` | Base64 saml.key. |
| nevisAdmin4.springProfiles | string | `""` | Commma seperated list of spring profiles to use, overrides all defaults |
| nevisAdmin4.storageClass | string | `""` | Specify the storage class for the nevisAdmin4 persistent volume |
| nevisAdmin4.tls.enabled | bool | `false` | Enable https for nevisadmin4, it will only affect the traffic between nginc and nevisadmin4 |
| nevisAdmin4.tls.keyAlias | string | `"nevisadmin"` | The key alias |
| nevisAdmin4.tls.keystore | string | `"keystore.p12"` | Keystore file to use, will be used instead of the prepared secret or base64 if the file is available in the chart folder. |
| nevisAdmin4.tls.keystore64 | string | `""` | Base64 keystore file. |
| nevisAdmin4.tls.keystoreSecret | string | `""` | Secret containing the tls keystore, to avoid plain values and using a local files. Must be prepared in advance. Must have the "passphrase" and the value for `tls.keystore` as a secret key. |
| nevisAdmin4.tls.keystoreType | string | `"pkcs12"` | Keystore type |
| nevisAdmin4.tls.passphrase | string | `""` | Keystore passphrase |
| nevisAdmin4.tls.port | int | `8443` | what port to use if https is enabled |
| nevisAdmin4.tolerations | list | `[]` |  |
| nevisOperator.affinity | object | `{}` |  |
| nevisOperator.annotations | object | `{}` | Annotations to put onto the Deployment. |
| nevisOperator.certificateDuration | string | `"8760h"` | Certificate duration of the internal certificates created with cert-manager |
| nevisOperator.containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}` | Security context for the nevisOperator pod containers. |
| nevisOperator.csr | object | `{"country":"CH","email-address":"noreply@local.domain","locality":"K8S","organization":"K8S","organizational-unit":"K8S","province":"K8S"}` | These values will be used for creating the internal certicates with cert-manager |
| nevisOperator.defaultImagePullPolicy | string | `""` | Sets the default imagePullPolicy for the deployed components by nevisAdmin 4 |
| nevisOperator.enableLeaderElection | bool | `true` | Enable leader election for nevisOperator, this make it possible to run with multiple replicas |
| nevisOperator.image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| nevisOperator.ingressIssuer | string | `"letsencrypt-prod"` | Name of the issuer that will be used for the generated ingresses |
| nevisOperator.ingressIssuerAnnotation | string | `"cert-manager.io/issuer"` | cert-manager annotation to put on the ingress |
| nevisOperator.internalIssuer | string | `"ca-issuer"` | Name of the internal issuer used to create the certificate for internal communication between the components |
| nevisOperator.internalIssuerCASecret | string | `"ca-root-secret"` | Name of the CA secret of the internal issuer |
| nevisOperator.internalIssuerCASecretNamespace | string | `""` | Namespace of the CA secret, defaults to the release namespace |
| nevisOperator.internalIssuerNamespace | string | `""` | Namespace of the internal issuer used to create the certificate for internal communication between the components |
| nevisOperator.labels | object | `{}` | Labels to put onto the Deployment. |
| nevisOperator.nodeSelector | object | `{}` |  |
| nevisOperator.podAnnotations | object | `{}` | Annotations to put onto the pods. |
| nevisOperator.podLabels | object | `{}` | Labels to put onto the pods. |
| nevisOperator.podSecurityContext | object | `{"runAsNonRoot":true}` | Security context for the nevisOperator pods. |
| nevisOperator.replicas | int | `1` |  |
| nevisOperator.resources.limits.cpu | string | `"200m"` |  |
| nevisOperator.resources.limits.memory | string | `"256Mi"` |  |
| nevisOperator.resources.requests.cpu | string | `"100m"` |  |
| nevisOperator.resources.requests.memory | string | `"96Mi"` |  |
| nevisOperator.restrictNamespaces.additionalNamespaces | list | `[]` | If the goal is to deploy to these namespace use the additionalComponentNamespaces value instead |
| nevisOperator.restrictNamespaces.enabled | bool | `true` | By default, nevisOperator only has access to the namespace where it resides, and the namespaces from the additionalComponentNamespaces |
| nevisOperator.tolerations | list | `[]` |  |
| nginx | object | `{"controller":{"admissionWebhooks":{"enabled":false},"config":{"annotation-value-word-blocklist":"load_module,lua_package,_by_lua,location,root,proxy_pass,serviceaccount"},"ingressClassResource":{"enabled":true,"name":"nginx"},"service":{"externalTrafficPolicy":"Local"}},"enabled":true}` | nginx settings, disable if nginx is already installed, the generated ingress will use the ingress class specified here |
| podLabels | object | `{}` | Labels that will put onto every pod created by the chart |
| serviceAccount.create | bool | `true` | Enable service account creation, if disabled the default service account will be used |
| serviceAccount.name | string | `""` | Override the name of the created service account for nevisadmin4 |
| serviceAccount.nevisOperatorName | string | `""` | Override the name of the created service account for nevisoperator |
