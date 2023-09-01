{{- define "soneta.deployment.web" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "soneta.fullname.web" . }}
  labels:
{{ include "soneta.labels.web" . | indent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
{{ include "soneta.selectors.web" . | indent 6 }}
  template:
    metadata:
      labels:
{{ include "soneta.labels.web" . | indent 8 }}
    spec:
      containers:
        - name: "{{ .Chart.Name }}-web-{{ .Values.image.product}}"
          image: "{{ include "soneta.web.image" . }}"
          imagePullPolicy: IfNotPresent
          command: {{ include "soneta.web.command" . }}
          args:
            {{- include "soneta.args" .Values.args.frontend | indent 12 }}
            {{- include "soneta.args" .Values.args.web | indent 12 }}
          env:
            {{- include "soneta.envs.frontend" . | nindent 12}}
            {{- include "soneta.envs" .Values.envs.all | indent 12 }}
            {{- include "soneta.envs" .Values.envs.frontend | indent 12 }}
            {{- include "soneta.envs" .Values.envs.web | indent 12 }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
          resources:
            {{- toYaml .Values.resources.web | nindent 12 }}
          volumeMounts:
            {{- include "soneta.volumeMounts" .Values.volumes.all | indent 12 }}
            {{- include "soneta.volumeMounts" .Values.volumes.frontend | indent 12 }}
            {{- include "soneta.volumeMounts" .Values.volumes.web | indent 12 }}
      volumes:
        {{- include "soneta.volumes" .Values.volumes.all | indent 8 }}
        {{- include "soneta.volumes" .Values.volumes.frontend | indent 8 }}
        {{- include "soneta.volumes" .Values.volumes.web | indent 8 }}
      nodeSelector:
        kubernetes.io/os: {{ include "soneta.web.nodeselector.os" . }}
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