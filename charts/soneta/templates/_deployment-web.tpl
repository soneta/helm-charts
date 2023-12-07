{{- define "soneta.deployment.web" -}}
{{- $component := (list . "web") -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "soneta.fullname" $component }}
  labels:
{{ include "soneta.labels" $component | indent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
{{ include "soneta.selectors" $component | indent 6 }}
  template:
    metadata:
{{- include "soneta.pod.spec" $component | indent 4 }}
{{- end -}}