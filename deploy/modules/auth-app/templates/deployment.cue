package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

#Deployment: appsv1.#Deployment & {
	_config:    #Config
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata:   _config.metadata
	spec: appsv1.#DeploymentSpec & {
		if !_config.autoscaling.enabled {
			replicas: _config.replicas
		}
		selector: matchLabels: _config.selector.labels
		template: {
			metadata: {
				labels: _config.selector.labels
				if _config.podAnnotations != _|_ {
					annotations: _config.podAnnotations
				}
			}
			spec: corev1.#PodSpec & {
				serviceAccountName: _config.metadata.name
				containers: [
					{
						name:            _config.metadata.name
						image:           _config.image.reference
						imagePullPolicy: _config.image.pullPolicy
						ports: [
							{
								// name:          "http"
								// containerPort: 8080
								// protocol:      "TCP"
								containerPort: _config.service.targetPort
							},
						]
						// livenessProbe: {
						// 	httpGet: {
						// 		path: "/"                        // TODO "/healthz"
						// 		port: _config.service.targetPort // TODO "http"
						// 	}
						// }
						// readinessProbe: {
						// 	httpGet: {
						// 		path: "/"                        // TODO "/healthz"
						// 		port: _config.service.targetPort // TODO "http"
						// 	}
						// }
						if _config.resources != _|_ {
							resources: _config.resources
						}
						securityContext: _config.securityContext
						if _config.db.enabled == true {
							env: [
								{
									name: "DB_ENDPOINT"
									valueFrom: {
										secretKeyRef: {
											name: _config.metadata.name
											key:  "endpoint"
										}
									}
								}, {
									name: "DB_PORT"
									valueFrom: {
										secretKeyRef: {
											name: _config.metadata.name
											key:  "port"
										}
									}
								}, {
									name: "DB_USER"
									valueFrom: {
										secretKeyRef: {
											name: _config.metadata.name
											key:  "username"
										}
									}
								}, {
									name: "DB_PASS"
									valueFrom: {
										secretKeyRef: {
											name: _config.metadata.name
											key:  "password"
										}
									}
								}, {
									name:  "DB_NAME"
									value: _config.metadata.name
								},
							]
						}

					},
				]
				if _config.podSecurityContext != _|_ {
					securityContext: _config.podSecurityContext
				}
				if _config.topologySpreadConstraints != _|_ {
					topologySpreadConstraints: _config.topologySpreadConstraints
				}
				if _config.affinity != _|_ {
					affinity: _config.affinity
				}
				if _config.tolerations != _|_ {
					tolerations: _config.tolerations
				}
				if _config.imagePullSecrets != _|_ {
					imagePullSecrets: _config.imagePullSecrets
				}
			}
		}
	}
}
