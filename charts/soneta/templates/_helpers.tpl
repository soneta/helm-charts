{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "soneta.name" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 -}}
{{- printf "%s-%s" (default $.Chart.Name $.Values.nameOverride) $component | trunc 63 | trimSuffix "-" -}}
{{- end -}}

# {{- define "soneta.name.orchestrator" -}}
# {{- printf "%s-%s" (include "soneta.name" . ) "orchestrator" | trunc 63 | trimSuffix "-" -}}
# {{- end -}}

# {{- define "soneta.name.server" -}}
# {{- printf "%s-%s" (include "soneta.name" . ) "server" | trunc 63 | trimSuffix "-" -}}
# {{- end -}}

# {{- define "soneta.name.web" -}}
# {{- printf "%s-%s" (include "soneta.name" . ) "web" | trunc 63 | trimSuffix "-" -}}
# {{- end -}}

# {{- define "soneta.name.webapi" -}}
# {{- printf "%s-%s" (include "soneta.name" . ) "webapi" | trunc 63 | trimSuffix "-" -}}
# {{- end -}}

# {{- define "soneta.name.webwcf" -}}
# {{- printf "%s-%s" (include "soneta.name" . ) "webwcf" | trunc 63 | trimSuffix "-" -}}
# {{- end -}}

# {{- define "soneta.name.scheduler" -}}
# {{- printf "%s-%s" (include "soneta.name" . ) "scheduler" | trunc 63 | trimSuffix "-" -}}
# {{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "soneta.fullname" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 -}}
{{- $fullname := "" -}}
{{- if $.Values.fullnameOverride -}}
{{- $fullname = $.Values.fullnameOverride -}}
{{- else -}}
{{- $fullname = printf "%s-%s" $.Release.Name (default $.Chart.Name $.Values.nameOverride) -}}
{{- end -}}
{{- printf "%s-%s" $fullname $component | trunc 63 | trimSuffix "-" -}}
{{- end -}}

# {{- define "soneta.fullname.orchestrator" -}}
# {{- printf "%s-%s" (include "soneta.fullname" . ) "orchestrator" | trunc 63 | trimSuffix "-" -}}
# {{- end -}}

# {{- define "soneta.fullname.web" -}}
# {{- printf "%s-%s" (include "soneta.fullname" . ) "web" | trunc 63 | trimSuffix "-" -}}
# {{- end -}}

# {{- define "soneta.fullname.webapi" -}}
# {{- printf "%s-%s" (include "soneta.fullname" . ) "webapi" | trunc 63 | trimSuffix "-" -}}
# {{- end -}}

# {{- define "soneta.fullname.webwcf" -}}
# {{- printf "%s-%s" (include "soneta.fullname" . ) "webwcf" | trunc 63 | trimSuffix "-" -}}
# {{- end -}}

# {{- define "soneta.fullname.server" -}}
# {{- printf "%s-%s" (include "soneta.fullname" . ) "server" | trunc 63 | trimSuffix "-" -}}
# {{- end -}}

# {{- define "soneta.fullname.scheduler" -}}
# {{- printf "%s-%s" (include "soneta.fullname" . ) "scheduler" | trunc 63 | trimSuffix "-" -}}
# {{- end -}}

# {{- define "soneta.fullname.pv" -}}
# {{- printf "%s-%s" (include "soneta.fullname" . ) "pv" | trunc 63 | trimSuffix "-" -}}
# {{- end -}}

# {{- define "soneta.fullname.pvc" -}}
# {{- printf "%s-%s" (include "soneta.fullname" . ) "pvc" | trunc 63 | trimSuffix "-" -}}
# {{- end -}}

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
{{- $ := index . 0 -}}
{{- $component := index . 1 -}}
app.kubernetes.io/name: {{ include "soneta.name" . }}
app.kubernetes.io/instance: {{ $.Release.Name }}
app.kubernetes.io/managed-by: {{ $.Release.Service }}
soneta.product: {{ $.Values.image.product }}
{{- end -}}

# {{- define "soneta.selectors.orchestrator" -}}
# app.kubernetes.io/name: {{ include "soneta.name.orchestrator" . }}
# {{ include "soneta.selectors" . }}
# {{- end -}}

# {{- define "soneta.selectors.server" -}}
# app.kubernetes.io/name: {{ include "soneta.name.server" . }}
# {{ include "soneta.selectors" . }}
# {{- end -}}

# {{- define "soneta.selectors.web" -}}
# app.kubernetes.io/name: {{ include "soneta.name.web" . }}
# {{ include "soneta.selectors" . }}
# {{- end -}}

# {{- define "soneta.selectors.webapi" -}}
# app.kubernetes.io/name: {{ include "soneta.name.webapi" . }}
# {{ include "soneta.selectors" . }}
# {{- end -}}

# {{- define "soneta.selectors.webwcf" -}}
# app.kubernetes.io/name: {{ include "soneta.name.webwcf" . }}
# {{ include "soneta.selectors" . }}
# {{- end -}}

# {{- define "soneta.selectors.scheduler" -}}
# app.kubernetes.io/name: {{ include "soneta.name.scheduler" . }}
# {{ include "soneta.selectors" . }}
# {{- end -}}

{{- define "soneta.labels" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 -}}
{{ include "soneta.selectors" . }}
helm.sh/chart: {{ include "soneta.chart" $ }}
app.kubernetes.io/version: {{ $.Values.image.tag | quote }}
{{- end -}}

# {{- define "soneta.labels.orchestrator" -}}
# app.kubernetes.io/name: {{ include "soneta.name.orchestrator" . }}
# {{ include "soneta.labels" . }}
# {{- end -}}

# {{- define "soneta.labels.server" -}}
# app.kubernetes.io/name: {{ include "soneta.name.server" . }}
# {{ include "soneta.labels" . }}
# {{- end -}}

# {{- define "soneta.labels.web" -}}
# app.kubernetes.io/name: {{ include "soneta.name.web" . }}
# {{ include "soneta.labels" . }}
# {{- end -}}

# {{- define "soneta.labels.webapi" -}}
# app.kubernetes.io/name: {{ include "soneta.name.webapi" . }}
# {{ include "soneta.labels" . }}
# {{- end -}}

# {{- define "soneta.labels.webwcf" -}}
# app.kubernetes.io/name: {{ include "soneta.name.webwcf" . }}
# {{ include "soneta.labels" . }}
# {{- end -}}

# {{- define "soneta.labels.scheduler" -}}
# app.kubernetes.io/name: {{ include "soneta.name.scheduler" . }}
# {{ include "soneta.labels" . }}
# {{- end -}}

{{/*
Other
*/}}

{{- define "soneta.image.postfix" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 -}}
{{- $side := ternary "web" "server" (eq (include "soneta.side" $component) "frontend") -}}
{{- if eq (include "soneta.side" $component) "backend" -}}{{- $side := "server" -}}{{- end -}}
{{- $postfix := get $.Values.image (printf "%sTagPostfix" $side) -}}
{{- if include "soneta.isNet" $ -}}
{{ $postfix | default "-windowsservercore" }}
{{- else -}}
{{ $postfix | default "" }}
{{- end -}}
{{- end -}}

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

{{- define "soneta.image.name" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 -}}
{{- $side := include "soneta.side" $component -}}
{{- if eq $side "frontend" -}}web{{- else -}}server{{- end -}}
{{- end -}}

{{- define "soneta.image.component" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 -}}
{{- $image := include "soneta.image.name" . -}}
{{- $postfix := include "soneta.image.postfix" . -}}
{{ $.Values.image.repository }}soneta/{{ $image }}.{{ $.Values.image.product}}:{{ $.Values.image.tag }}{{ $postfix }}
{{- end -}}

{{- define "soneta.web.enpointProtocol" -}}
{{- if include "soneta.isNet" . -}}http://{{- else -}}{{- end -}}
{{- end -}}

{{- define "soneta.nodeselector.os" -}}
{{ if eq (include "soneta.image.postfix" .) "-alpine" }}linux{{ else }}windows{{ end }}
{{- end -}}

{{- define "soneta.orchestrator.command" -}}
["dotnet", "orchestrator.dll", "kubernetes", "start"]
{{- end -}}

{{- define "soneta.router.command" -}}
["dotnet", "router.dll"]
{{- end -}}

{{- define "soneta.webapi.command" -}}
["dotnet", "webapi.dll"]
{{- end -}}

{{- define "soneta.webwcf.command" -}}
["dotnet", "webwcf.dll"]
{{- end -}}

{{- define "soneta.server.command" -}}
{{- if include "soneta.isNet" . -}}["dotnet", "server.dll"]
{{- else -}}
    {{- if eq .Values.image.product "standard"  }}[ "SonetaServer.exe" ]
        {{- else -}}[ "SonetaServerPremium.exe" ]
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "soneta.web.command" -}}
{{- if include "soneta.isNet" . -}}["dotnet", "web.dll"]
{{- else -}}
    {{- if eq .Values.image.product "standard"  }}[ "Soneta.Web.Standard.exe" ]
        {{- else -}}[ "Soneta.Web.Premium.exe" ]
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "soneta.side" -}}
{{- if has . (list "web" "webapi" "webwcf") -}}frontend{{- else -}}backend{{- end -}}
{{- end -}}

{{- define "soneta.ingress.path" -}}
{{- $paths := dict "web" "/(.*)" "webapi" "/(api/.*)" "webwcf" "/(Business/.*)" -}}
{{- get $paths . -}}
{{- end -}}

{{- define "soneta.ingress-traefik.path" -}}
{{- $paths := dict "web" "/" "webapi" "/api" "webwcf" "/Business" -}}
{{- get $paths . -}}
{{- end -}}

{{- define "soneta.toYaml" -}}
  {{- if . }}
{{ toYaml . }}
  {{- end }}
{{- end -}}

{{- define "soneta.toYaml.component" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 -}}
{{- include "soneta.toYaml" (get $ "all" ) }}
{{- include "soneta.toYaml" (get $ (include "soneta.side" $component)) }}
{{- include "soneta.toYaml" (get $ $component) }}
{{- end -}}

{{- define "soneta.args.component" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 -}}
{{- with $.Values.args -}}
{{- include "soneta.toYaml.component" (list . $component) -}}
{{- end -}}
{{- end -}}

{{- define "soneta.args" -}}
  {{- if . }}
{{ toYaml . }}
  {{- end }}
{{- end -}}

{{- define "soneta.envs.component" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 -}}
{{- if or (eq $component "server") (eq $component "scheduler") -}}
{{- include "soneta.envs.dbconfig" $ -}}
{{- end -}}
{{- with $.Values.envs -}}
{{- include "soneta.toYaml.component" (list . $component) -}}
{{- end -}}
{{- end -}}

{{- define "soneta.envs" -}}
  {{- if . }}
{{ toYaml . }}
  {{- end }}
{{- end -}}

{{- define "soneta.dbconfig" -}}
{{- if include "soneta.isNet" . -}}
/config/dblist.xml
{{- else -}}
c:\\config\\dblist.xml
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
{{- $server := include "soneta.fullname" (list . "server") | upper | replace "-" "_" -}}
{{ include "soneta.web.enpointProtocol" . }}$({{ print $server }}_SERVICE_HOST):$({{ print $server }}_SERVICE_PORT)
{{- end -}}

{{- define "soneta.envs.frontend" -}}
- name: SONETA_SERVER_ENDPOINTS
  value: {{ include "soneta.frontend.serverendpoint" . }}
- name: SONETA_FRONTEND__SERVERENDPOINT
  value: {{ include "soneta.frontend.serverendpoint" . }}
- name: SONETA_URLS
  value: http://+:8080
{{- end -}}

{{- define "soneta.envs.backend" -}}
- name: SONETA_URLS
  value: http://+:8080
{{- end -}}

{{- define "soneta.volumes.abstract" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 -}}
{{- $type := index . 2 -}}
{{- $template := printf "soneta.%s" $type -}}
{{- include $template (get $.Values.volumes "all" ) }}
{{- include $template (get $.Values.volumes (include "soneta.side" $component)) }}
{{- include $template (get $.Values.volumes $component) }}
{{- end -}}

{{- define "soneta.volumeMounts.component" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 }}
{{- $os := include "soneta.nodeselector.os" . -}}
{{- if and $.Values.appsettings }}
- name: appsettings-yaml
  mountPath: {{ include "soneta.specialfolder" (list $os "appdata" ) }}{{ include "soneta.path.combine" (list $os "Soneta" "config") }}
{{- end -}}
{{- if or (eq $component "server") (eq $component "web") (eq $component "webapi") }}
- mountPath: {{ include "soneta.specialfolder" (list $os "appdata" ) }}{{ include "soneta.path.combine" (list $os "Soneta" "Authentication") }}
  subPath: Authentication
  name: default-pvc
{{- end -}}
{{- if eq $component "web" }}
- mountPath: {{ include "soneta.specialfolder" (list $os "localappdata" ) }}{{ include "soneta.path.combine" (list $os "ASP.NET" "DataProtection-Keys") }}
  subPath: DataProtection-Keys
  name: default-pvc
{{- end -}}
{{- if or (eq $component "server") (eq $component "scheduler") }}
{{ include "soneta.volumeMounts.dblist" $ -}}
{{- end -}}
{{- include "soneta.volumes.abstract" (list $ $component "volumeMounts") }}
{{- end -}}

{{- define "soneta.volumes.component" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 }}
- name: default-pvc
  persistentVolumeClaim:
    claimName: {{ include "soneta.fullname" (list $ "pvc") }}
{{- if and $.Values.appsettings }}
- name: appsettings-yaml
  configMap:
    name: {{ include "soneta.fullname" (list $ "appsettings") }}
    items: 
    - key: appsettings.yaml
      path: appsettings.yaml
{{- end -}}
{{- if or (eq $component "server") (eq $component "scheduler") }}
{{ include "soneta.volumes.dblist" $ -}}
{{- end -}}
{{- include "soneta.volumes.abstract" (list $ $component "volumes") }}
{{- end -}}

{{- define "soneta.volumes" -}}
{{- if . }}
{{- range $i, $val := . }}
{{- if $val.name }}
- name: {{ $val.name }}
{{- toYaml $val.spec | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "soneta.volumeMounts" -}}
{{- if . }}
{{- range $i, $val := . }}
{{- if $val.mountPath }}
- name: {{ $val.name | default "default-pvc" }}
  mountPath: {{ $val.mountPath | quote }}
{{- if $val.subPath }}
  subPath: {{ $val.subPath | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "soneta.volumes.dblist" -}}
- name: dblist-volume
  configMap:
    name: {{ include "soneta.fullname" (list . "dblist") }}
    items:
    - key: dblist
      path: "dblist.xml"
{{- end -}}

{{- define "soneta.volumeMounts.dblist" -}}
- name: dblist-volume
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

{{- define "soneta.isOrchestrator" -}}
  {{- if .Values.appsettings.orchestrator -}}
    {{- if .Values.appsettings.orchestrator.kubernetes -}}
      true
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "soneta.isLinux" -}}
  {{- if eq (include "soneta.nodeselector.os" .) "linux" -}}
    true
  {{- end -}}
{{- end -}}


{{- define "soneta.specialfolder"  -}}
{{- $os := index . 0 -}}
{{- $special := index . 1 -}}
{{- if eq $os "windows" -}}
{{-   if eq $special "home" -}}
        c:\\Users\\ContainerUser\\
{{-   else if eq $special "localappdata" -}}
        c:\\Users\\ContainerUser\\AppData\\Local\\
{{-   else if eq $special "appdata" -}}
        c:\\Users\\ContainerUser\\AppData\\Roaming\\
{{-   end -}}
{{- else -}}
{{-   if eq $special "home" -}}
        /home/app/
{{-   else if eq $special "localappdata" -}}
        /home/app/.local/share/
{{-   else if eq $special "appdata" -}}
        /home/app/.config/
{{-   end -}}
{{- end -}}
{{- end -}}

{{- define "soneta.path.combine" }}
{{- $separator := ternary "\\\\" "/" (eq (index . 0) "windows") -}}
{{ join $separator (slice . 1) }}
{{- end -}}