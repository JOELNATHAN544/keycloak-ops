{{/*
Expand the name of the chart.
Returns: The chart name or nameOverride if specified
Usage: Used for labeling and naming conventions
*/}}
{{- define "keycloak.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
Returns: A unique name for resources, typically release-name-chart-name
Usage: Used as the base name for all Kubernetes resources
Note: Truncated to 63 chars due to Kubernetes name length limits
*/}}
{{- define "keycloak.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
Returns: Chart name and version in format "name-version"
Usage: Added to resources for tracking chart version
*/}}
{{- define "keycloak.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
Returns: Standard Kubernetes labels for all resources
Usage: Applied to all Keycloak resources for organization and selection
Includes: chart version, selector labels, app version, and management info
*/}}
{{- define "keycloak.labels" -}}
helm.sh/chart: {{ include "keycloak.chart" . }}
{{ include "keycloak.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
Returns: Minimal labels used for selecting pods (used by Services and Deployments)
Usage: Used in pod selectors and service selectors to match resources
Note: These labels must remain stable - don't add dynamic values here
*/}}
{{- define "keycloak.selectorLabels" -}}
app.kubernetes.io/name: {{ include "keycloak.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
Returns: Name of the ServiceAccount for RBAC
Usage: Used in pod spec and ServiceAccount metadata
Note: Falls back to "default" if serviceAccount.create is false
*/}}
{{- define "keycloak.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "keycloak.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Database host
Returns: PostgreSQL hostname
Usage: Used in KC_DB_URL_HOST environment variable
Note: Automatically uses embedded PostgreSQL service name if enabled
*/}}
{{- define "keycloak.dbHost" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" .Release.Name }}
{{- else }}
{{- .Values.keycloak.database.host }}
{{- end }}
{{- end }}

{{/*
Database port
Returns: PostgreSQL port number
Usage: Used in KC_DB_URL_PORT environment variable
*/}}
{{- define "keycloak.dbPort" -}}
{{- if .Values.postgresql.enabled }}
{{- 5432 }}
{{- else }}
{{- .Values.keycloak.database.port }}
{{- end }}
{{- end }}

{{/*
Database name
Returns: PostgreSQL database name
Usage: Used in KC_DB_URL_DATABASE environment variable
*/}}
{{- define "keycloak.dbName" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database }}
{{- else }}
{{- .Values.keycloak.database.database }}
{{- end }}
{{- end }}

{{/*
Database username
Returns: PostgreSQL username
Usage: Used in KC_DB_USERNAME environment variable
*/}}
{{- define "keycloak.dbUsername" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username }}
{{- else }}
{{- .Values.keycloak.database.username }}
{{- end }}
{{- end }}
