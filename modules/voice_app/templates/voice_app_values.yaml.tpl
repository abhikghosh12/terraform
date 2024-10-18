# templates/voice_app_values.yaml.tpl

webapp:
  image:
    repository:  docker.io/abhikgho/text_to_speech_web_app
    tag: ${webapp_image_tag}
  replicaCount: ${webapp_replica_count}

worker:
  image:
    repository:  docker.io/abhikgho/text_to_speech_web_app
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
      enabled: true                # Enable persistence
      size: 1Gi                    # Size of the volume
      storageClassName: ""
      existingClaim: redis-data-voice-app-redis-master-0        # Specify your storage class here      
  auth:
    enabled: false                # Disable Redis authentication
  replica:
    persistence:
      enabled: true
      existingClaim: redis-data-voice-app-redis-replicas-0  
    kind: StatefulSet             # Use StatefulSet for Redis replicas
    replicaCount: 2

persistence:
  uploads:
    enabled: true
    size: 5Gi
    storageClassName: ""     
  output:
    enabled: true
    size: 5Gi
    storageClassName: ""     