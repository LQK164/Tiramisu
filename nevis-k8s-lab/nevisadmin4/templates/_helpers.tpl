{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nevisadmin4.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nevisadmin4.labels" -}}
helm.sh/chart: {{ include "nevisadmin4.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Create the name of the service account to use
*/}}
{{- define "nevisadmin4.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default "nevisadmin4" .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nevisoperator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default "nevisoperator" .Values.serviceAccount.nevisOperatorName }}
{{- else }}
{{- default "default" .Values.serviceAccount.nevisOperatorName }}
{{- end }}
{{- end }}

{{/*
Create repository url.
*/}}
{{- define "nevisadmin4.repository" -}}
{{ .Values.image.repository }}/{{ .Values.image.imagePrefix }}
{{- end }}

{{/*
Create nevisadmin4 port
*/}}
{{- define "nevisadmin4.port" -}}
{{- if .Values.nevisAdmin4.tls.enabled }}
{{- .Values.nevisAdmin4.tls.port | default 8443 }}
{{- else }}
{{- .Values.nevisAdmin4.port | default 9080 }}
{{- end }}
{{- end }}

{{/*
Create git username.
*/}}
{{- define "nevisadmin4.gitUsername" -}}
{{- if .Values.git.username }}
    {{- .Values.git.username }}
{{- else if .Values.git.httpCredentialSecret }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.git.httpCredentialSecret) }}
    {{- index $secret.data "username" | b64dec }}
{{- end -}}
{{- end -}}

{{/*
Create git password.
*/}}
{{- define "nevisadmin4.gitPassword" -}}
{{- if .Values.git.password }}
    {{- .Values.git.password }}
{{- else if .Values.git.httpCredentialSecret }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.git.httpCredentialSecret) }}
    {{- index $secret.data "password" | b64dec }}
{{- end -}}
{{- end -}}

{{/*
Create git private key.
*/}}
{{- define "nevisadmin4.gitPrivateKey" -}}
{{- if .Values.git.privateKey64 }}
    {{- .Values.git.privateKey64 }}
{{- else if .Files.Get "key" }}
    {{- .Files.Get "key" | b64enc }}
{{- else if .Values.git.sshCredentialSecret }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.git.sshCredentialSecret) }}
    {{- if and $secret (index $secret.data "key") }}
        {{- index $secret.data "key" }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create git public key.
*/}}
{{- define "nevisadmin4.gitPublicKey" -}}
{{- if .Values.git.publicKey64 }}
    {{- .Values.git.publicKey64 }}
{{- else if .Files.Get "key.pub" }}
    {{- .Files.Get "key.pub" | b64enc }}
{{- else if .Values.git.sshCredentialSecret }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.git.sshCredentialSecret) }}
    {{- if and $secret (index $secret.data "key.pub") }}
        {{- index $secret.data "key.pub" }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create git known_hosts.
*/}}
{{- define "nevisadmin4.gitKnownHosts" -}}
{{- if .Values.git.knownHosts64 }}
    {{- .Values.git.knownHosts64 }}
{{- else if .Files.Get "known_hosts" }}
    {{- .Files.Get "known_hosts" | b64enc }}
{{- else if .Values.git.sshCredentialSecret }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.git.sshCredentialSecret) }}
    {{- if and  $secret (index $secret.data "known_hosts")  }}
        {{- index $secret.data "known_hosts" }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create nevisadmin4 keystore
*/}}
{{- define "nevisadmin4.keystore" -}}
{{- if .Values.nevisAdmin4.tls.keystore64 }}
    {{- .Values.nevisAdmin4.tls.keystore64 }}
{{- else if .Files.Get .Values.nevisAdmin4.tls.keystore }}
    {{- .Files.Get .Values.nevisAdmin4.tls.keystore | b64enc }}
{{- end -}}
{{- end -}}

{{/*
Create nevisadmin4 keystore passphrase
*/}}
{{- define "nevisadmin4.keystorePassphrase" -}}
{{- if .Values.nevisAdmin4.tls.passphrase }}
    {{- .Values.nevisAdmin4.tls.passphrase | b64enc }}
{{- end -}}
{{- end -}}

{{/*
Create nevisadmin4 saml key
*/}}
{{- define "nevisadmin4.samlKey" -}}
{{- if .Values.nevisAdmin4.saml.privateKey64 }}
    {{- .Values.nevisAdmin4.saml.privateKey64 }}
{{- else if .Files.Get "saml.key" }}
    {{- .Files.Get "saml.key" | b64enc }}
{{- end -}}
{{- end -}}

{{/*
Create nevisadmin4 saml certificate
*/}}
{{- define "nevisadmin4.samlCertificate" -}}
{{- if .Values.nevisAdmin4.saml.certificate64 }}
    {{- .Values.nevisAdmin4.saml.certificate64 }}
{{- else if .Files.Get "saml.crt" }}
    {{- .Files.Get "saml.crt" | b64enc }}
{{- end -}}
{{- end -}}

{{/*
Create db username.
*/}}
{{- define "nevisadmin4.dbRootUsername" -}}
{{- if .Values.database.root.username}}
    {{- .Values.database.root.username }}
{{- else if .Values.database.root.credentialSecret -}}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.database.root.credentialSecret) }}
    {{- if and $secret (index $secret.data "username") }}
        {{- index $secret.data "username" | b64dec }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create db username with host
*/}}
{{- define "nevisadmin4.dbRootUsernameWithHost" -}}
{{- include "nevisadmin4.dbRootUsername" . }}{{- if contains "mariadb.database.azure.com" .Values.database.host }}@{{- .Values.database.host }}{{- end }}
{{- end -}}

{{/*
Create db password.
*/}}
{{- define "nevisadmin4.dbPassword" -}}
{{- if .Values.database.root.password }}
    {{- .Values.database.root.password }}
{{- else if .Values.database.root.credentialSecret -}}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.database.root.credentialSecret) }}
    {{- if and $secret (index $secret.data "password") }}
        {{- index $secret.data "password" | b64dec }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create operator version.
*/}}
{{- define "nevisadmin4.operatorVersion" -}}
{{- if .Values.nevisOperator.image.tag -}}
    {{- .Values.nevisOperator.image.tag -}}
{{- else if .Values.nevisAdmin4.image.tag -}}
    {{- .Values.nevisAdmin4.image.tag -}}
{{- else -}}
    {{- .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "nevisadmin4.validateValues" -}}
{{- $messages := list -}}
{{- $messages = append $messages (include "nevisadmin4.validateValues.repository" .) -}}
{{- $messages = append $messages (include "nevisadmin4.validateValues.imagePrefix" .) -}}
{{- $messages = append $messages (include "nevisadmin4.validateValues.databaseHost" .) -}}
{{- $messages = append $messages (include "nevisadmin4.validateValues.databasePort" .) -}}
{{- $messages = append $messages (include "nevisadmin4.validateValues.applicationUser" .) -}}
{{- $messages = append $messages (include "nevisadmin4.validateValues.rootUsername" .) -}}
{{- $messages = append $messages (include "nevisadmin4.validateValues.rootPassword" .) -}}
{{- $messages = append $messages (include "nevisadmin4.validateValues.schemaUser" .) -}}
{{- $messages = append $messages (include "nevisadmin4.validateValues.domain" .) -}}
{{- $messages = append $messages (include "nevisadmin4.validateValues.gitUrl" .) -}}
{{- $messages = append $messages (include "nevisadmin4.validateValues.keystore" .) -}}
{{- $messages = append $messages (include "nevisadmin4.validateValues.publicKey" .) -}}
{{- $messages = append $messages (include "nevisadmin4.validateValues.privatekey" .) -}}
{{- $messages = append $messages (include "nevisadmin4.validateValues.knownHosts" .) -}}
{{- $messages = append $messages (include "nevisadmin4.validateValues.idp" .) -}}
{{- $messages = append $messages (include "nevisadmin4.validateValues.samlKey" .) -}}
{{- $messages = without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{- printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{- define "nevisadmin4.validateValues.repository" -}}
{{- if not .Values.image.repository }}
Please configure the image repository.
image:
  repository: <repository>
{{- end }}
{{- end }}

{{- define "nevisadmin4.validateValues.imagePrefix" -}}
{{- if not .Values.image.imagePrefix }}
Please configure the image prefix. <repository>/<imagePrefix>/<image>:<tag>
image:
  imagePrefix: <imagePrefix>
{{- end }}
{{- end }}

{{- define "nevisadmin4.validateValues.databaseHost" -}}
{{- if not .Values.database.host }}
Please configure the database host.
database:
  host: <host>
{{- end }}
{{- end }}

{{- define "nevisadmin4.validateValues.databasePort" -}}
{{- if not .Values.database.port }}
Please configure the database port.
database:
  port: <port>
{{- end }}
{{- end }}

{{- define "nevisadmin4.validateValues.applicationUser" -}}
{{- if not .Values.nevisAdmin4.database.applicationUser }}
Please configure the nevisAdmin4 database application user.
nevisAdmin4:
  database:
    applicationUser: <applicationUser>
{{- end }}
{{- end }}

{{- define "nevisadmin4.validateValues.schemaUser" -}}
{{- if not .Values.nevisAdmin4.database.schemaUser }}
Please configure the nevisAdmin4 database schemaUser user.
nevisAdmin4:
  database:
    schemaUser: <schemaUser>
{{- end }}
{{- end }}

{{- define "nevisadmin4.validateValues.rootUsername" -}}
{{- if and (not .Values.database.root.password) (not .Values.database.root.credentialSecret) (not .Values.database.root.preparedCredentialSecret)  }}
Please configure the username of the database root user. It's recommended to prepare a secret with the credentials and use the database.root.preparedCredentialSecret value:
kubectl create secret generic helm-database-credential -n <namespace> \
  --from-literal=username=<root-username> \
  --from-literal=password=<root-password>
{{- end }}
{{- end }}

{{- define "nevisadmin4.validateValues.rootPassword" -}}
{{- if and (not .Values.database.root.username) (not .Values.database.root.credentialSecret) (not .Values.database.root.preparedCredentialSecret)  }}
Please configure the password of the database root user. It's recommended to prepare a secret with the credentials and use the database.root.preparedCredentialSecret value:
kubectl create secret generic helm-database-credential -n <namespace> \
  --from-literal=username=<root-username> \
  --from-literal=password=<root-password>
{{- end }}
{{- end }}

{{- define "nevisadmin4.validateValues.domain" -}}
{{- if and (not .Values.nevisAdmin4.domain) (list nil true "true" | has .Values.nevisAdmin4.enabled) }}
Please configure the domain to be used for nevisAdmin4
nevisAdmin4:
  domain: <domain>
{{- end }}
{{- end }}

{{- define "nevisadmin4.validateValues.gitUrl" -}}
{{- if not .Values.git.repositoryUrl }}
Please configure the git url to be used.
git:
  repositoryUrl: <url>
{{- end }}
{{- end }}

{{- define "nevisadmin4.validateValues.publicKey" -}}
{{- $globPublicKey := .Files.Glob "key.pub" }}
{{- if and (not .Values.git.publicKey64) (not $globPublicKey) (not .Values.git.sshCredentialSecret) (not .Values.git.credentialSecret) }}
Public key file  "key.pub" not found. Please create the key files using the following command:
ssh-keygen -t ecdsa -C "kubernetes" -m PEM -P "" -f key
And use the git.publicKey64 value.
{{- end }}
{{- end }}

{{- define "nevisadmin4.validateValues.privatekey" -}}
{{- $globPrivateKey := .Files.Glob "key" }}
{{- if and (not .Values.git.privateKey64) (not $globPrivateKey) (not .Values.git.sshCredentialSecret) (not .Values.git.credentialSecret) }}
Key file "key" not found. Please create the key files using the following command:
ssh-keygen -t ecdsa -C "kubernetes" -m PEM -P "" -f key
And use the git.privateKey64 value.
{{- end }}
{{- end }}

{{- define "nevisadmin4.validateValues.knownHosts" -}}
{{- $globknown:= .Files.Glob "known_hosts" }}
{{- if and (not .Values.git.knownHosts64) (not $globknown) (not .Values.git.sshCredentialSecret) (not .Values.git.credentialSecret) }}
Known hosts not found. Generate the known_hosts for the used git domain by running:
ssh-keyscan <domain> > known_hosts
And use the git.knownHosts64 value.
{{- end }}
{{- end }}

{{- define "nevisadmin4.validateValues.keystore" -}}
{{- $globTlsKeystore := .Files.Glob .Values.nevisAdmin4.tls.keystore }}
{{- if and .Values.nevisAdmin4.tls.enabled (not .Values.nevisAdmin4.tls.keystore64) (not $globTlsKeystore) (not .Values.nevisAdmin4.tls.keystoreSecret) }}
Keystore file {{ .Values.nevisAdmin4.tls.keystore | quote }} not found. Please create a keystore file for the tls connection:
openssl req -x509 -newkey rsa:4096 -keyout myKey.pem -out cert.pem -days 3650
openssl pkcs12 -export -out {{ .Values.nevisAdmin4.tls.keystore }} -inkey myKey.pem -in cert.pem -name nevisadmin
And use the nevisAdmin4.tls.keystore64 value.
{{- end }}
{{- end }}

{{- define "nevisadmin4.validateValues.samlKey" -}}
{{- $globsamlKey := .Files.Glob "saml.key" }}
{{- $globsamlCrt := .Files.Glob "saml.crt" }}
{{- if and .Values.nevisAdmin4.saml.enabled (or (not .Values.nevisAdmin4.saml.privateKey64) (not .Values.nevisAdmin4.saml.certificate64)) (or (and (not $globsamlKey) (not .Values.nevisAdmin4.saml.keySecret)) (and (not $globsamlCrt) (not .Values.nevisAdmin4.saml.keySecret))) }}
SAML service provider key material no found, run the following command to generare the key material:
openssl req -nodes -x509 -newkey rsa:4096 -keyout saml.key -out saml.crt -sha256 -days 3650
And use the nevisAdmin4.saml.privateKey64 and nevisAdmin4.saml.certificate64 values.
{{- end }}
{{- end }}

{{- define "nevisadmin4.validateValues.idp" -}}
{{- if and (not .Values.nevisAdmin4.saml.idp.metadataUri) .Values.nevisAdmin4.saml.enabled }}
Please configure the idp meatadata uri to be used for nevisAdmin4
nevisAdmin4:
  saml:
    idp:
     metadataUri: <metadataUri>
{{- end }}
{{- end }}
