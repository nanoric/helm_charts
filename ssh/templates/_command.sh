#!/usr/bin/env bash
{{- $host := .Values.ssh.host -}}
{{- $port := .Values.ssh.port -}}
{{- $user := .Values.ssh.user -}}
{{- $ls := .Values.ssh.forwards.local -}}
{{- $rs := .Values.ssh.forwards.remote -}}
{{- $ps := .Values.ssh.extra_params -}}
{{- $tunnel_only := .Values.ssh.tunnel_only -}}
{{- $timeout := .Values.ssh.timeout }}

mkdir -p /root/.ssh/
cp /identity/id /id
chmod 600 /id

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

function listens_in_forwards()
{
    for f in `cat`; do
        echo $f | cut -d ':' -f1,2
    done
}

function current_listens()
{
    netstat -anpt | tr -s ' '|cut -d ' ' -f4,7
}

function kill_remote_sshd()
{
    # kill sshd to make sure remote environment is clear
#    echo "kill -9 \`ps -elf|grep -v grep|grep 'sshd: {{$user}}'|tr -s ' '|cut -d ' ' -f4\`" | \
    cat /scripts/remote_kill_sshd.sh | \
        ssh -i /id "{{ $user }}@{{ $host }}" -p {{ $port }} \
            {{- range $key, $val := $ps }}
            -o "{{ $key }}={{ $val }}" \
            {{- end }}
            -tt
}

function run_tunnel()
{

    # start tunnel
    output_keep_alive | \
        ssh -i /id "{{ $user }}@{{ $host }}" -p {{ $port }} \
            -o ExitOnForwardFailure=yes \
            {{- range $ls }}
            -L "{{ . }}" \
            {{- end }}
            {{- range $rs }}
            -R "{{ . }}" \
            {{- end }}
            {{- range $key, $val := $ps }}
            -o "{{ $key }}={{ $val }}" \
            {{- end }}
            -tt >/dev/nul

    echo tunnel > /alive
}

function run_remote_command()
{
    cat /scripts/remote_command.sh | \
        ssh -i /id "{{ $user }}@{{ $host }}" -p {{ $port }} \
            {{- range $key, $val := $ps }}
            -o "{{ $key }}={{ $val }}" \
            {{- end }}
            -tt 'bash -'

    echo remote_command > /alive
}

echo "remote command:"
cat /scripts/remote_command.sh

echo "script to kill sshd:"
cat /scripts/remote_kill_sshd.sh

echo alive > /alive
# tunnel:
{{- if or $ls $rs }}
kill_remote_sshd

run_tunnel &
{{- end }}

# remote command:
{{- if .Values.ssh.remote_command }}
run_remote_command &
{{- end }}

while true; do
    if [[ 'alive' != `cat /alive` ]]; then
        echo -e "\nExited: `cat /alive`\n"
        exit
    fi
done

