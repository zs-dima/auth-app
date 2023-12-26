package templates

import (
	netv1 "k8s.io/api/networking/v1"
)

#Ingress: netv1.#Ingress & {
	_config:    #Config
	apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
	metadata:   _config.metadata
	if _config.ingress.annotations != _|_ {
		metadata: annotations: _config.ingress.annotations
	}
	spec: netv1.#IngressSpec & {
		rules: [{
			host: _config.ingress.host
			http: {
				paths: [{
					pathType: "ImplementationSpecific"
					path:     "/"
					backend: service: {
						name: _config.metadata.name
						port: number: _config.service.targetPort
					}
				}]
			}
		}]
		if _config.ingress.className != _|_ {
			ingressClassName: _config.ingress.className
		}
		if _config.ingress.tls != _|_ {
			tls: _config.ingress.tls
		}
	}
}
