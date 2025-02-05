{{/*
Bigbang labels
*/}}
{{- define "bigbang.labels" -}}
app: {{ include "backstage.name" . }}
{{- if .Chart.AppVersion }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}
