# gitlab deployments

## pre-requirements
```bash
helm repo add gitlab https://charts.gitlab.io/
```

## install
```bash
helm upgrade --install gitlab gitlab/gitlab \
  --namespace=gitlab
  --set global.hosts.domain=git.happyzh.com \
  --set global.hosts.externalIP=10.10.10.10 \
  --set certmanager-issuer.email=me@example.com
```

