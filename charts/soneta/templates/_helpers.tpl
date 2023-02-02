{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "soneta.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "soneta.name.server" -}}
{{- printf "%s-%s" (include "soneta.name" . ) "server" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "soneta.name.web" -}}
{{- printf "%s-%s" (include "soneta.name" . ) "web" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "soneta.name.webapi" -}}
{{- printf "%s-%s" (include "soneta.name" . ) "webapi" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "soneta.name.webwcf" -}}
{{- printf "%s-%s" (include "soneta.name" . ) "webwcf" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "soneta.name.scheduler" -}}
{{- printf "%s-%s" (include "soneta.name" . ) "scheduler" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "soneta.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{/*- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -*/}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{/*- end -*/}}
{{- end -}}
{{- end -}}

{{- define "soneta.fullname.web" -}}
{{- printf "%s-%s" (include "soneta.fullname" . ) "web" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "soneta.fullname.webapi" -}}
{{- printf "%s-%s" (include "soneta.fullname" . ) "webapi" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "soneta.fullname.webwcf" -}}
{{- printf "%s-%s" (include "soneta.fullname" . ) "webwcf" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "soneta.fullname.server" -}}
{{- printf "%s-%s" (include "soneta.fullname" . ) "server" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "soneta.fullname.scheduler" -}}
{{- printf "%s-%s" (include "soneta.fullname" . ) "scheduler" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "soneta.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "soneta.labels" -}}
helm.sh/chart: {{ include "soneta.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
soneta.product: {{ .Values.image.product }}
{{- end -}}

{{- define "soneta.labels.server" -}}
app.kubernetes.io/name: {{ include "soneta.name.server" . }}
{{ include "soneta.labels" . }}
{{- end -}}

{{- define "soneta.labels.web" -}}
app.kubernetes.io/name: {{ include "soneta.name.web" . }}
{{ include "soneta.labels" . }}
{{- end -}}

{{- define "soneta.labels.webapi" -}}
app.kubernetes.io/name: {{ include "soneta.name.webapi" . }}
{{ include "soneta.labels" . }}
{{- end -}}

{{- define "soneta.labels.webwcf" -}}
app.kubernetes.io/name: {{ include "soneta.name.webwcf" . }}
{{ include "soneta.labels" . }}
{{- end -}}

{{- define "soneta.labels.scheduler" -}}
app.kubernetes.io/name: {{ include "soneta.name.scheduler" . }}
{{ include "soneta.labels" . }}
{{- end -}}

{{/*
Other
*/}}
{{- define "soneta.web.tagPostfix" -}}
{{- if contains "-net" .Values.image.tag -}}
{{ .Values.image.webTagPostfix | default "-nanoserver" }}
{{- else -}}
{{ .Values.image.webTagPostfix | default "" }}
{{- end -}}
{{- end -}}

{{- define "soneta.server.tagPostfix" -}}
{{- if contains "-net" .Values.image.tag -}}
{{ .Values.image.serverTagPostfix | default "-nanoserver" }}
{{- else -}}
{{ .Values.image.serverTagPostfix  | default "" }}
{{- end -}}
{{- end -}}

{{- define "soneta.web.enpointProtocol" -}}
{{- if contains "-net" .Values.image.tag -}}http://{{- else -}}{{- end -}}
{{- end -}}

{{- define "soneta.web.nodeselector.os" -}}
{{ if eq (include "soneta.web.tagPostfix" .) "-alpine" }}linux{{ else }}windows{{ end }}
{{- end -}}

{{- define "soneta.server.nodeselector.os" -}}
{{ if eq (include "soneta.server.tagPostfix" .) "-alpine" }}linux{{ else }}windows{{ end }}
{{- end -}}

{{- define "soneta.server.command" -}}
{{- if contains "-net" .Values.image.tag -}}["dotnet", "server.dll"]
{{- else -}}
    {{- if eq .Values.image.product "standard"  }}[ "SonetaServer.exe" ]
        {{- else -}}[ "SonetaServerPremium.exe" ]
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "soneta.server.args" -}}
{{- if contains "-net" .Values.image.tag -}}["--dbconfig=/config/lista-baz-danych.xml", "--urls=http://+:22000"]
{{- else -}}[ "/console", "/dbconfig=c:\\config\\lista-baz-danych.xml", "/noscheduler"]
{{- end -}}
{{- end -}}

{{- define "soneta.scheduler.command" -}}
{{- if contains "-net" .Values.image.tag -}}["dotnet", "scheduler.dll"]
{{- else -}}
    {{- if eq .Values.image.product "standard"  }}[ "SonetaServer.exe" ]
        {{- else -}}[ "SonetaServerPremium.exe" ]
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "soneta.scheduler.args" -}}
{{- if contains "-net" .Values.image.tag -}}["--mode=Daemon", "--dbconfig=/config/lista-baz-danych.xml"]
{{- else -}}[ "/console", "/dbconfig=c:\\config\\lista-baz-danych.xml"]
{{- end -}}
{{- end -}}

{{- define "soneta.webapi.command_args" -}}
{{- if contains "-net" .Values.image.tag -}}
command: ["dotnet", "webapi.dll"]
{{- end -}}
{{- end -}}

{{- define "soneta.webwcf.command_args" -}}
{{- if contains "-net" .Values.image.tag -}}
command: ["dotnet", "webwcf.dll"]
{{- end -}}
{{- end -}}

{{- define "soneta.frontend.serverendpoint" -}}
{{ include "soneta.web.enpointProtocol" . }}$({{ print ( include "soneta.fullname.server" . ) | upper | replace "-" "_" }}_SERVICE_HOST):$({{ print ( include "soneta.fullname.server" . ) | upper | replace "-" "_" }}_SERVICE_PORT)
{{- end -}}

{{/* Allow KubeVersion to be overridden. */}}
{{- define "soneta.ingress.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version -}}
{{- end -}}