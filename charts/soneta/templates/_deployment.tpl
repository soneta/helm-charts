{{- define "soneta.deployment" -}}
{{- $ := index . 0 -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "soneta.fullname" . }}
  labels:
{{ include "soneta.labels" . | indent 4 }}
spec:
  replicas: {{ $.Values.replicaCount }}
{{- if eq (index . 1) "orchestrator" }}
  strategy:
    type: Recreate
{{- end }}
  selector:
    matchLabels:
{{ include "soneta.selectors" . | indent 6 }}
  template:
    metadata:
{{- include "soneta.pod.spec" . | indent 4 }}
{{- end -}}