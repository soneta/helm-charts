{{- define "soneta.service" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 }}
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
  ports:
    - port: 80
      targetPort: http
      protocol: TCP
      name: http
  selector:
{{ include "soneta.labels" . | indent 4 }}
{{- end -}}