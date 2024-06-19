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

{{- define "soneta.fullname.pv" -}}
{{- printf "%s-%s" (include "soneta.fullname" . ) "pv" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "soneta.fullname.pvc" -}}
{{- printf "%s-%s" (include "soneta.fullname" . ) "pvc" | trunc 63 | trimSuffix "-" -}}
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
{{- define "soneta.selectors" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
soneta.product: {{ .Values.image.product }}
{{- end -}}

{{- define "soneta.selectors.server" -}}
app.kubernetes.io/name: {{ include "soneta.name.server" . }}
{{ include "soneta.selectors" . }}
{{- end -}}

{{- define "soneta.selectors.web" -}}
app.kubernetes.io/name: {{ include "soneta.name.web" . }}
{{ include "soneta.selectors" . }}
{{- end -}}

{{- define "soneta.selectors.webapi" -}}
app.kubernetes.io/name: {{ include "soneta.name.webapi" . }}
{{ include "soneta.selectors" . }}
{{- end -}}

{{- define "soneta.selectors.webwcf" -}}
app.kubernetes.io/name: {{ include "soneta.name.webwcf" . }}
{{ include "soneta.selectors" . }}
{{- end -}}

{{- define "soneta.selectors.scheduler" -}}
app.kubernetes.io/name: {{ include "soneta.name.scheduler" . }}
{{ include "soneta.selectors" . }}
{{- end -}}

{{- define "soneta.labels" -}}
{{ include "soneta.selectors" . }}
helm.sh/chart: {{ include "soneta.chart" . }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
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
{{- if include "soneta.isNet" . -}}
{{ .Values.image.webTagPostfix | default "-windowsservercore" }}
{{- else -}}
{{ .Values.image.webTagPostfix | default "" }}
{{- end -}}
{{- end -}}

{{- define "soneta.server.tagPostfix" -}}
{{- if include "soneta.isNet" . -}}
{{ .Values.image.serverTagPostfix | default "-windowsservercore" }}
{{- else -}}
{{ .Values.image.serverTagPostfix  | default "" }}
{{- end -}}
{{- end -}}

{{- define "soneta.web.enpointProtocol" -}}
{{- if include "soneta.isNet" . -}}http://{{- else -}}{{- end -}}
{{- end -}}

{{- define "soneta.web.nodeselector.os" -}}
{{ if eq (include "soneta.web.tagPostfix" .) "-alpine" }}linux{{ else }}windows{{ end }}
{{- end -}}

{{- define "soneta.server.nodeselector.os" -}}
{{ if eq (include "soneta.server.tagPostfix" .) "-alpine" }}linux{{ else }}windows{{ end }}
{{- end -}}

{{- define "soneta.server.command" -}}
{{- if include "soneta.isNet" . -}}["dotnet", "server.dll"]
{{- else -}}
    {{- if eq .Values.image.product "standard"  }}[ "SonetaServer.exe" ]
        {{- else -}}[ "SonetaServerPremium.exe" ]
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "soneta.args" -}}
  {{- if . }}
{{ toYaml . }}
  {{- end }}
{{- end -}}

{{- define "soneta.envs" -}}
  {{- if . }}
{{ toYaml . }}
  {{- end }}
{{- end -}}

{{- define "soneta.dbconfig" -}}
{{- if include "soneta.isNet" . -}}
/config/lista-baz-danych.xml
{{- else -}}
c:\\config\\lista-baz-danych.xml
{{- end -}}
{{- end -}}

{{- define "soneta.envs.dbconfig" -}}
{{- if include "soneta.isNet" . -}}
- name: SONETA_DBCONFIG
  value: {{ include "soneta.dbconfig" . }}
{{- end -}}
{{- end -}}

{{- define "soneta.args.dbconfig" -}}
{{- if not (include "soneta.isNet" .) }}
- /dbconfig={{ include "soneta.dbconfig" . }}
{{- end -}}
{{- end -}}

{{- define "soneta.server.args" -}}
  {{- if not (include "soneta.isNet" .) }}
- /console
- /noscheduler
  {{- end -}} 
  {{ include "soneta.args.dbconfig" . }}
  {{- include "soneta.args" .Values.args.backend -}}
  {{- include "soneta.args" .Values.args.server -}}
{{- end -}}

{{- define "soneta.scheduler.command" -}}
{{- if include "soneta.isNet" . -}}["dotnet", "scheduler.dll"]
{{- else -}}
    {{- if eq .Values.image.product "standard"  }}[ "SonetaServer.exe" ]
        {{- else -}}[ "SonetaServerPremium.exe" ]
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "soneta.scheduler.args" -}}
  {{- if include "soneta.isNet" . -}}
- --mode=Daemon
  {{- else -}}
- /console
  {{- end -}}
  {{ include "soneta.args.dbconfig" . }}
  {{- include "soneta.args" .Values.args.backend -}}
  {{- include "soneta.args" .Values.args.scheduler -}}
{{- end -}}

{{- define "soneta.web.commands" -}}
{{- if include "soneta.isNet" . -}}
command: ["dotnet", "web.dll"]
{{- end -}}
{{- end -}}

{{- define "soneta.webapi.commands" -}}
{{- if include "soneta.isNet" . -}}
command: ["dotnet", "webapi.dll"]
{{- end -}}
{{- end -}}

{{- define "soneta.webwcf.commands" -}}
{{- if include "soneta.isNet" . -}}
command: ["dotnet", "webwcf.dll"]
{{- end -}}
{{- end -}}

{{- define "soneta.frontend.serverendpoint" -}}
{{ include "soneta.web.enpointProtocol" . }}$({{ print ( include "soneta.fullname.server" . ) | upper | replace "-" "_" }}_SERVICE_HOST):$({{ print ( include "soneta.fullname.server" . ) | upper | replace "-" "_" }}_SERVICE_PORT)
{{- end -}}

{{- define "soneta.envs.frontend" -}}
- name: SONETA_SERVER_ENDPOINTS
  value: {{ include "soneta.frontend.serverendpoint" . }}
- name: SONETA_FRONTEND__SERVERENDPOINT
  value: {{ include "soneta.frontend.serverendpoint" . }}
- name: SONETA_URLS
  value: http://+:8080
{{- end -}}

{{- define "soneta.volumes" -}}
{{- if . }}
{{- range $i, $val := . }}
- name: {{ $val.name }}
{{- toYaml $val.spec | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "soneta.volumes.listaBazDanych" -}}
- name: lista-baz-danych-volume
  configMap:
    name: {{ include "soneta.fullname.server" . }}
    items:
    - key: lista-baz-danych
      path: "lista-baz-danych.xml"
{{- end -}}

{{- define "soneta.volumeMounts" -}}
{{- if . }}
{{- range $i, $val := . }}
{{- if $val.mountPath }}
- name: {{ $val.name }}
  mountPath: {{ $val.mountPath | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "soneta.volumeMounts.listaBazDanych" -}}
- name: lista-baz-danych-volume
  mountPath: "/config"
{{- end -}}

{{- define "soneta.ingress.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version -}}
{{- end -}}

{{- define "soneta.resources.pvc.storageClassName" -}}
  {{- if .Values.resources.pvc.storageClassName -}}
    {{- default .Values.resources.pvc.storageClassName -}}
  {{- else -}}
    azurefile
  {{- end -}}
{{- end -}}

{{- define "soneta.isNet" -}}
  {{- if lt .Values.image.tag "2404.0.0" -}}
    {{- if contains "-net" .Values.image.tag -}}
      true
    {{- else -}}
    {{- end -}}
  {{- else -}}
    {{- if contains "-framework" .Values.image.tag -}}
    {{- else -}}
      true
    {{- end -}}
  {{- end -}}
{{- end -}}