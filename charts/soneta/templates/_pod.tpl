{{- define "soneta.pod" -}}
apiVersion: v1
kind: Pod
metadata:
  name: {{ include "soneta.fullname" . }}
{{- include "soneta.pod.spec" . -}}
{{- end -}}

{{- define "soneta.pod.spec" -}}
{{- $ := index . 0 -}}
{{- $component := index . 1 -}}
{{- $os := include "soneta.nodeselector.os" . -}}
{{- $side := include "soneta.side" $component }}
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
        - name: SONETA_TELEMETRY__SERVICENAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.labels['app.kubernetes.io/instance']
        - name: SONETA_TELEMETRY__SERVICEINSTANCEID
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: SONETA_KUBERNETES__WORKINGUNITID
        {{- if eq $component "server" }}
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        {{- else }}
          value: {{ include "soneta.fullname" . }}
        {{- end }}
        - name: SONETA_KUBERNETES__NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace 
        - name: SONETA_KUBERNETES__HELMRELEASE
          valueFrom:
            fieldRef:
              fieldPath: metadata.labels['app.kubernetes.io/instance']
        - name: SONETA_KUBERNETES__NODE
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName 
        - name: OTEL_RESOURCE_ATTRIBUTES
          value: k8s.node.name=$(SONETA_KUBERNETES__NODE),k8s.namespace.name=$(SONETA_KUBERNETES__NAMESPACE),helm.release.name=$(SONETA_KUBERNETES__HELMRELEASE)
        {{- include (printf "soneta.envs.%s" $side) $ | nindent 8 }}
        {{- include "soneta.envs.component" . |  nindent 8 }}
        - name: SONETA_OrchestratorEndpoint
          value: http://{{ include "soneta.fullname" (list $ "orchestrator" ) }}:80
        - name: SONETA_EventhubEndpoint
          value: http://{{ include "soneta.fullname" (list $ "orchestrator" ) }}:80
      {{- if and (include "soneta.isOrchestrator" $) (eq $side "frontend") }}
        - name: SONETA_RouterEndpoint
          value: {{ include "soneta.routerendpoint" $ }}
      {{- end }}
        - name: SONETA_URLS
          value: http://+:8080
      {{- if eq $component "orchestrator" }}
        - name: SONETA_Orchestrator__Kubernetes__Templates__Name
          value: {{ include "soneta.fullname" (list $ $component ) }}
        {{- if include "soneta.isRouterInProcess" $ }}
        - name: SONETA_{{ "router" | upper }}__URLS
          value: http://+:8081
        {{- end }}  
        {{- if include "soneta.isCommHubInProcess" $ }}
        - name: SONETA_{{ "commhub" | upper }}__URLS
          value: tcp://+:8082
        {{- end }}  
      {{- end }}
      {{- if include "soneta.isCommHub" $ }}
        - name: SONETA_CommHubClient__Enabled
          value: "true"
        - name: SONETA_CommHubClient__Endpoints__0
          value: {{ include "soneta.commhubendpoint" $ }}
      {{- end }}
{{- if eq $component "orchestrator"}}
{{- end }}
{{- if eq $os "linux"}}
        - name: LOCALAPPDATA 
          value: {{ include "soneta.specialfolder" (list $os "localappdata") }}
{{- end }}
      ports:
        - name: http
          containerPort: 8080
          protocol: TCP
      {{- include "soneta.probes" . | nindent 6 }}
      resources:
        {{- toYaml (get $.Values.resources $component) | nindent 8 }}
      volumeMounts:
        {{- include "soneta.volumeMounts.component" . | indent 8 }}
  volumes:
    {{- include "soneta.volumes.component" . | indent 4 }}
  nodeSelector:
    kubernetes.io/os: {{ $os }}
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