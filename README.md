# docker-nginx-reloaded
Reverse Proxy Docker container with Nginx, acme.sh, DNS and Autodiscovery ( alternative to jwilder/nginx-proxy )

---

## How to run

```shell
$ docker run \
    --restart=always \
    --name=docker-nginx-reloaded \
    -d \
    -p 172.17.0.1:53:53/udp \
    -p 80:80 \
    -p 443:443 \
    -v /srv/acme:/etc/acme.le \
    -v /srv/certs:/etc/nginx/certs \
    -v /srv/vhost:/etc/nginx/vhost.d:ro \
    -v /srv/htpasswd:/etc/nginx/htpasswd:ro \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    julianxhokaxhiu/docker-nginx-reloaded &>/dev/null
```
