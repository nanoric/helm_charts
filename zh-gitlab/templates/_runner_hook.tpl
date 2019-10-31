{{- define "gitlab-runner.image" }}
{{- $image := printf "registry.cn-shanghai.aliyuncs.com/zh-mirror/gitlab_gitlab-runner:alpine-v%s" .Chart.AppVersion -}}
{{- default $image .Values.image}}
{{- end -}}
