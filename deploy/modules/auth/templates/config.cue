package templates

import (
	corev1 "k8s.io/api/core/v1"
	netv1 "k8s.io/api/networking/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

dbProvider: "local-k8s" | "aws-official" | "azure-official"

#Config: {
	kubeVersion!: string
	clusterVersion: timoniv1.#SemVer & {
		#Version: kubeVersion, #Minimum: "1.20.0"
	}
	moduleVersion!: string
	metadata: timoniv1.#Metadata & {
		#Version: moduleVersion
	}
	metadata: labels:       timoniv1.#Labels
	metadata: annotations?: timoniv1.#Annotations
	metadata: annotations: {
		"description": "Simple auth client"
		"owner":       "Dmitrii ZS (belojar@gmail.com)"
		"team":        "dot"
		"language":    "Dart, Flutter"
	}

	selector: timoniv1.#Selector & {#Name: metadata.name}

	image!: timoniv1.#Image

	resources: timoniv1.#ResourceRequirements & {
		limits: {
			cpu:    *"500m" | timoniv1.#CPUQuantity
			memory: *"512Mi" | timoniv1.#MemoryQuantity
		}
		requests: {
			cpu:    *"250m" | timoniv1.#CPUQuantity
			memory: *"256Mi" | timoniv1.#MemoryQuantity
		}
	}

	replicas: *1 | int & >0

	securityContext: corev1.#SecurityContext & {
		allowPrivilegeEscalation: *false | true
		privileged:               *false | true
		capabilities:
		{
			drop: *["ALL"] | [string]
			add: *["CHOWN", "NET_BIND_SERVICE", "SETGID", "SETUID"] | [string]
		}
	}

	service: {
		annotations?: timoniv1.#Annotations

		port:       *80 | int & >0 & <=65535
		targetPort: *port | int & >0 & <=65535
	}
	autoscaling: {
		enabled:     *false | bool
		cpu:         *80 | int & >0 & <=100
		memory:      *80 | int & >0 & <=100
		minReplicas: *replicas | int
		maxReplicas: *6 | int & >=minReplicas
	}
	ingress: {
		className?:   string
		annotations?: timoniv1.#Annotations
		host:         metadata.name | string
		tls?: [...netv1.#IngressTLS]
	}
	db: {
		enabled:  *false | bool
		provider: *"google-official" | dbProvider
		type:     *"postgres" | string
	}

	// Pod optional settings.
	podAnnotations?: {[string]: string}
	podSecurityContext?: corev1.#PodSecurityContext
	imagePullSecrets?: [...timoniv1.ObjectReference]
	tolerations?: [...corev1.#Toleration]
	affinity?: corev1.#Affinity
	topologySpreadConstraints?: [...corev1.#TopologySpreadConstraint]

	// Test Job disabled by default.
	test: {
		enabled: *false | bool
		image!:  timoniv1.#Image
	}
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		// sa: #ServiceAccount & {_config: config}
		svc: #Service & {_config: config}

		deploy: #Deployment & {_config: config}

		if config.autoscaling.enabled {
			hpa: #HorizontalPodAutoscaler & {_config: config}
		}
		ingress: #Ingress & {_config: config}
		if config.db.enabled {
			db_secret: #DBSecret & {_config: config}
			db_claim: #DBClaim & {_config: config}
		}
	}

	// tests: {
	// 	"test-svc": #TestJob & {_config: config}
	// }
}
