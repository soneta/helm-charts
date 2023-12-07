{{- define "soneta.deployment.server" -}}
{{- $component := (list . "server") -}}
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
      labels:
{{ include "soneta.labels" $component | indent 8 }}
    spec:
      containers:
        - name: "{{ .Chart.Name }}-server-{{ .Values.image.product}}"
          image: "{{ include "soneta.server.image" . }}"
          imagePullPolicy: IfNotPresent
          command: {{ include "soneta.server.command" . }}
          args: 
            {{- include "soneta.args.component" $component | indent 12 }}
          env:
            {{- include "soneta.envs.dbconfig" . | nindent 12 }}
            {{- if contains "-net" .Values.image.tag }}
            - name: SONETA_URLS
              value: http://+:22000
            {{- end }}
            {{- include "soneta.envs.component" $component | indent 12 }}
          ports:
            - name: {{ .Values.service.server.port0Name }}
              containerPort: {{ .Values.service.server.port0 }}
              protocol: TCP
          resources:
            {{- toYaml .Values.resources.server | nindent 12 }}
          volumeMounts:
            {{- include "soneta.volumeMounts.listaBazDanych" . | nindent 12 }}
            {{- include "soneta.volumeMounts.component" $component | indent 12 }}
      volumes:
        {{- include "soneta.volumes.listaBazDanych" . | nindent 8 }}
        {{- include "soneta.volumes.component" $component | indent 8 }}
      nodeSelector:
        kubernetes.io/os: {{ include "soneta.server.nodeselector.os" . }}
      {{- with .Values.nodeSelector }}
          {{- toYaml . | nindent 8 }}
      {{- end }}
    {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
    {{- end }}
    {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
    {{- end }}
{{- end -}}