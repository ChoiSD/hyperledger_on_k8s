{{/* vim: set filetype=mustache: */}}
{{/*
Define namespace
*/}}
{{- define "hlf-org.namespace" -}}
{{- default .Chart.Name .Values.namespace -}}
{{- end -}}

{{/*
Define domain name
*/}}
{{- define "hlf-org.domain" -}}
{{- default "org1.com" .Values.org.domain -}}
{{- end -}}

{{/*
Define Hyperledger Fabric version
*/}}
{{- define "hlf-org.version" -}}
{{- default "1.4.1" .Chart.AppVersion -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hlf-org.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Define default labels
*/}}
{{- define "hlf-org.labels" -}}
heritage: {{ .Release.Service | quote }}
release: {{ .Release.Name | quote }}
chart: {{ include "hlf-org.chart" . }}
version: {{ include "hlf-org.version" . }}
{{- end -}}