#!/usr/bin/env bash
{{- $host := .Values.ssh.host -}}
{{- $port := .Values.ssh.port -}}
{{- $user := .Values.ssh.user -}}
{{- $ls := .Values.ssh.forwards.local -}}
{{- $rs := .Values.ssh.forwards.remote -}}
{{- $ps := .Values.ssh.forwards.extra_params -}}
{{- $tunnel_only := .Values.ssh.tunnel_only -}}
{{- $timeout := .Values.ssh.timeout -}}

function output_keep_alive()
{
    reconnect_interval={{ $timeout }}
    keep_alive_interval=5

    elapsed=0
    while true; do
        sleep ${keep_alive_interval}
        ((elapsed+=$keep_alive_interval))
        echo "echo ${elapsed}"
        {{- if $timeout }}
        if ((elapsed >= $reconnect_interval)); then
            return # exit then docker will restart this instance.
        fi
        {{- end }}
     done
}

function tunnel()
{
    output_keep_alive | \
        ssh -i /id "{{ $user }}@{{ $host }}" -p {{ $port }} \
        {{- range $ls }}
            -L "{{ . }}" \
        {{- end }}
        {{- range $rs }}
            -R "{{ . }}" \
        {{- end }}
            -o \
        {{- range $key, $val := $ps }}
            "{{ $key }}={{$val}}" \
        {{- end }}
    echo dead > /alive
}

function remote_command()
{
    cat /scripts/remote_command | \
        ssh -i /id "{{ $user }}@{{ $host }}" -p {{ $port }} \
            -o \
        {{- range $key, $val := $ps }}
            "{{ $key }}={{$val}}" \
        {{- end }}

    echo dead > /alive
}

echo alive > /alive
tunnel &
remote_command &

while true; do
    if [[ 'alive' != `cat /alive` ]]; then
        exit
    fi
done

