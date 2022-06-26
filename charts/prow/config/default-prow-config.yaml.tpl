# default prow config generated by helm release.
prowjob_namespace: {{ .Release.Namespace }}
pod_namespace: {{ .Values.prow.podsNamespace }}

in_repo_config:
  enabled:
    "*": true

deck:
  spyglass:
    lenses:
    - lens:
        name: metadata
      required_files:
      - started.json|finished.json
    - lens:
        config:
        name: buildlog
      required_files:
      - build-log.txt
    - lens:
        name: junit
      required_files:
      - .*/junit.*\.xml
    - lens:
        name: podinfo
      required_files:
      - podinfo.json

plank:
  job_url_prefix_config:
    "*": https://{{ .Values.prow.domainName }}/view/
  report_templates:
    '*': >-
        [Full PR test history](https://{{ .Values.prow.domainName }}/pr-history?{{`org={{.Spec.Refs.Org}}&repo={{.Spec.Refs.Repo}}&pr={{with index .Spec.Refs.Pulls 0}}{{.Number}}{{end }}`}}).
        [Your PR dashboard](https://{{ .Values.prow.domainName }}/pr?query=is:pr+state:open+author:{{`{{with index .Spec.Refs.Pulls 0}}{{.Author}}{{end }}`}}).
  default_decoration_configs:
    "*":
      gcs_configuration:
        bucket: s3://prow-logs
        path_strategy: explicit
      s3_credentials_secret: {{ include "prow.fullname" . }}-s3-credentials
      utility_images:
        clonerefs: gcr.io/k8s-prow/clonerefs:v20220504-0b3a7e15f4
        entrypoint: gcr.io/k8s-prow/entrypoint:v20220504-0b3a7e15f4
        initupload: gcr.io/k8s-prow/initupload:v20220504-0b3a7e15f4
        sidecar: gcr.io/k8s-prow/sidecar:v20220504-0b3a7e15f4

tide:
  queries:
  - labels:
      - lgtm
      - approved
    missingLabels:
      - needs-rebase
      - do-not-merge/hold
      - do-not-merge/work-in-progress
      - do-not-merge/invalid-owners-file
    {{- if .Values.prow.githubOrg }}
    orgs:
      - {{ .Values.prow.githubOrg }}
    {{- else }}
    orgs: []
    {{- end }}

decorate_all_jobs: true