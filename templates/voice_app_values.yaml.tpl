# templates/voice_app_values.yaml.tpl

webapp:
  image:
    repository: abhikgho/text_to_speech_web_app
    tag: ${webapp_image_tag}
  replicaCount: ${webapp_replica_count}

worker:
  image:
    repository: abhikgho/text_to_speech_web_app
    tag: ${worker_image_tag}
  replicaCount: ${worker_replica_count}

ingress:
  enabled: ${ingress_enabled}
  host: ${ingress_host}

service:
  type: ClusterIP
  port: 5000

redis:
  enabled: true
  master:
    persistence:
      enabled: false
      size: 5Gi
      storageClassName: "efs-sc"
      existingClaim: voice-app-redis-data
  auth:
    enabled: false

persistence:
  uploads:
    enabled: true
    existingClaim: voice-app-uploads
    storageClassName: "efs-sc"
  output:
    enabled: true
    existingClaim: voice-app-output
    storageClassName: "efs-sc"