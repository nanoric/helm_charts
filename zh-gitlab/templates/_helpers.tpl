{{ define "zh-gitlab.labels" }}
app: "zh-gitlab"
{{ end }}

{{ define "zh-gitlab.ingress.name" -}}
{{ printf "%s-%s" .Release.Name "ingress" }}
{{- end }}


{{ define "zh-gitlab.ingress.labels" }}
{{ include "zh-gitlab.labels" . }}
role: ingress
{{ end }}

{{ define "zh-gitlab.busybox.name" -}}
{{ printf "%s-%s" .Release.Name "busybox" }}
{{- end }}

{{ define "zh-gitlab.busybox.labels" }}
{{ include "zh-gitlab.labels" . }}
role: busybox
{{ end }}

{{- define "gitlab-runner.image" }}
{{- $image := printf "registry.cn-shanghai.aliyuncs.com/zh-mirror/gitlab_gitlab-runner:alpine-v%s" .Chart.AppVersion -}}
{{- default $image .Values.image}}
{{- end -}}
