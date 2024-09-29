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
  port: 80

redis:
  master:
    persistence:
      enabled: false

configMap:
  REDIS_URL: "redis://{{ .Release.Name }}-redis-master:6379"
