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
  {{- with $.Values.ingress.annotations }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $.Values.ingress.releaseAutoAnnotation }}
    {{ .key }}: {{ printf "%s%s%s" .prefix $.Release.Name .postfix  | upper }}
  {{- end}}
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
        - path: {{ include "soneta.ingress.path" $component }}
          pathType: Prefix
          backend:
            service:
              name: {{ include "soneta.fullname" . }}
              port:
                number: 80
{{- end }}
{{- end -}}