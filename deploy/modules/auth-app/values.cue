@if(!debug)

package main

values: {
	image: {
		repository: "docker.io/zsdima/auth-app"
		digest:     "" // sha256:f1bcaa9faace13d2fd8a56c668f8f2e8f32b6777a8a74de4e55aee8fe5527e33
		tag:        "stable"
	}
	ingress: {
		className: "traefik"
		host:      "app.${DOMAIN}"
		// tls: {
		// 	secretName: "app-tls"
		// 	hosts: ["app.${DOMAIN}"]
		// }
	}
	autoscaling: enabled: false
	db: {
		enabled:  false
		provider: "google-official"
	}
	test: image: {
		repository: "cgr.dev/chainguard/curl"
		digest:     ""
		tag:        "latest"
	}
}
