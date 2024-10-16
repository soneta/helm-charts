{{- define "soneta.service" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 -}}
{{- $targetPort := "http" -}}
{{- if gt (len .) 3 -}}
{{- $targetPort = index . 3 -}}
{{- end -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "soneta.fullname" . }}
  labels:
{{ include "soneta.labels" . | indent 4 }}
{{- if and $.Values.service.expireDate (eq $component "web") }}
  annotations:
    expireDate: {{ $.Values.service.expireDate | quote }}
{{- end }}
spec:
  type: {{ $.Values.service.type }}
  {{ if and (eq $component "server") (gt (int64 $.Values.replicaCount) 1) }}sessionAffinity: ClientIP{{ end }}
  ports:
    - port: 80
      targetPort: {{ $targetPort }}
      protocol: TCP
      name: http
  selector:
{{ include "soneta.labels" . | indent 4 }}
{{- end -}}