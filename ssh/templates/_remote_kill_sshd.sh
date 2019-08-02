#!/usr/bin/env bash
{{- $host := .Values.ssh.host -}}
{{- $port := .Values.ssh.port -}}
{{- $user := .Values.ssh.user -}}
{{- $ls := .Values.ssh.forwards.local -}}
{{- $rs := .Values.ssh.forwards.remote -}}
{{- $ps := .Values.ssh.extra_params -}}
{{- $tunnel_only := .Values.ssh.tunnel_only -}}
{{- $timeout := .Values.ssh.timeout }}

#forwards="0.0.0.0:2222:10.0.12.60:22 0.0.0.0:80:10.0.12.60:80 0.0.0.0:443:10.0.12.60:443 "
forwards="{{range $rs}}{{.}} {{end}}"
echo $forwards

function get_ports_from_forwards()
{
    for forward in `echo $forwards`; do
        echo $forward | cut -d ':' -f2
    done
}

ports="`echo $forwards| get_ports_from_forwards`"
echo ports: $ports

IP_PATTERN="\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
function get_kills()
{
    ports_re="(`echo $ports|tr ' ' '|'`)"
    netstat -anpt | \
      grep sshd| \
      grep -oP "$IP_PATTERN:$ports_re +$IP_PATTERN.*sshd"| \
      grep -oP "\d+(/sshd)"| \
      grep -oP "\d+"
}

kills="`get_kills`"
echo kills: $kills
kill -9 $kills

exit
