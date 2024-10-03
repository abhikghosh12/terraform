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
      enabled: true
      size: 5Gi
      existingClaim: voice-app-redis-data
  auth:
    enabled: false

persistence:
  uploads:
    enabled: true
    existingClaim: voice-app-uploads
  output:
    enabled: true
    existingClaim: voice-app-output