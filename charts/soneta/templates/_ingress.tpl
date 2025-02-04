{{- define "soneta.ingress" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 }}
{{- if $.Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "soneta.fullname" . }}
  labels:
{{ include "soneta.labels" . | indent 4 }}
  annotations:
{{- if eq $.Values.ingress.class "nginx" }}
    nginx.ingress.kubernetes.io/rewrite-target: /$1
    nginx.ingress.kubernetes.io/use-regex: "true"
{{- end }}
  # {{- with $.Values.ingress.annotations }}
  #   {{- toYaml . | nindent 4 }}
  # {{- end }}
  # {{- with $.Values.ingress.releaseAutoAnnotation }}
  #   {{ .key }}: {{ printf "%s%s%s" .prefix $.Release.Name .postfix  | upper }}
  # {{- end}}
spec:
  ingressClassName: {{ $.Values.ingress.class }}
{{- if $.Values.ingress.tlsSecretName }}
  tls:
    - hosts:
      - {{ $.Release.Name }}.{{ $.Values.ingress.host }}
      secretName: {{ $.Values.ingress.tlsSecretName }}
{{- end }}
  rules:
    - host: {{ $.Release.Name }}.{{ $.Values.ingress.host }}
      http:
        paths:
        {{- include "soneta.ingress.httppath" (list $ "web") | nindent 8 }}
        {{- include "soneta.ingress.httppath" (list $ "webapi") | nindent 8 }}
        {{- include "soneta.ingress.httppath" (list $ "webwcf") | nindent 8 }}
{{- end }}
{{- end -}}


{{- define "soneta.ingress.httppath" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 }}
{{- if eq $.Values.ingress.class "traefik" -}}
{{- /* https://doc.traefik.io/traefik/routing/routers/#path-pathprefix-and-pathregexp */ -}}
- path: {{ include "soneta.ingress-traefik.path" $component }}
  pathType: Prefix
{{- else -}}
- path: {{ include "soneta.ingress.path" $component }}
  pathType: ImplementationSpecific
{{- end }}
  backend:
    service:
      name: {{ include "soneta.fullname" . }}
      port:
        number: 80
{{- end -}}