{{- define "soneta.templates" -}}
orchestrator:
  kubernetes:
    templates:
{{- $router := (list . "router") }}          
      router:
        service: {{ include "soneta.service" $router | toYaml }}
        pod: {{ include "soneta.pod" $router | toYaml }}
{{- $web := (list . "web") }}          
      web:
        service: {{ include "soneta.service" $web | toYaml }}
        pod: {{ include "soneta.pod" $web | toYaml }}
        ingress: {{ include "soneta.ingress.httppath" $web | toYaml }}
{{- $webapi := (list . "webapi") }}          
      webapi:
        service: {{ include "soneta.service" $webapi | toYaml }}
        pod: {{ include "soneta.pod" $webapi | toYaml }}
        ingress: {{ include "soneta.ingress.httppath" $webapi | toYaml }}
{{- $webwcf := (list . "webwcf") }}          
      webwcf:
        service: {{ include "soneta.service" $webwcf | toYaml }}
        pod: {{ include "soneta.pod" $webwcf | toYaml }}
        ingress: {{ include "soneta.ingress.httppath" $webwcf | toYaml }}
{{- $server := (list . "server") }}          
      server:
        service: {{ include "soneta.service" $server | toYaml }}
        pod: {{ include "soneta.pod" $server | toYaml }}
{{- $scheduler := (list . "scheduler") }}          
      scheduler:
        pod: {{ include "soneta.pod" $scheduler | toYaml }}
{{- $commhub := (list . "commhub") }}          
      commhub:
        service: {{ include "soneta.service" $commhub | toYaml }}
        pod: {{ include "soneta.pod" $commhub | toYaml }}
{{- end -}}