{{- define "soneta.pod" -}}
apiVersion: v1
kind: Pod
metadata:
  name: {{ include "soneta.fullname" . }}
{{- include "soneta.pod.spec" . -}}
{{- end -}}

{{- define "soneta.pod.spec" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 }}
  labels:
{{ include "soneta.labels" . | indent 4 }}
spec:
  containers:
    - name: "{{ $.Chart.Name }}-{{ $component }}-{{ $.Values.image.product}}"
      image: "{{ include "soneta.image.component" . }}"
      imagePullPolicy: IfNotPresent
      command: {{ include (printf "soneta.%s.command" $component) $ }}
      args:
        {{- include "soneta.args.component" . | indent 8 }}
      env:
        {{- include (printf "soneta.envs.%s" (include "soneta.side" $component)) $ | nindent 8 }}
        {{- include "soneta.envs.component" . |  nindent 8 }}
{{- if eq $component "orchestrator"}}
        - name: SONETA_Orchestrator__Kubernetes__Templates__Owner__Uid
          valueFrom:
            fieldRef:
              fieldPath: metadata.uid
        - name: SONETA_Orchestrator__Kubernetes__Templates__Owner__Name
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
{{- end }}
      ports:
        - name: http
          containerPort: 80
          protocol: TCP
      resources:
        {{- toYaml (get $.Values.resources $component) | nindent 8 }}
      volumeMounts:
        {{- include "soneta.volumeMounts.component" . | indent 8 }}
  volumes:
    {{- include "soneta.volumes.component" . | indent 4 }}
  nodeSelector:
    kubernetes.io/os: {{ include "soneta.nodeselector.os" . }}
{{- with $.Values.nodeSelector }}
    {{- toYaml $ | nindent 4 }}
{{- end }}
{{- with $.Values.affinity }}
  affinity:
    {{- toYaml . | nindent 4 }}
{{- end }}
{{- with $.Values.tolerations }}
  tolerations:
    {{- toYaml . | nindent 4 }}
{{- end }}
{{- if eq $component "orchestrator"}}
  serviceAccountName: {{ include "soneta.fullname" . }}
{{- end -}}
{{- end -}}