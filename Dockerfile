FROM jakejarvis/hugo-extended:0.124.1 AS hugo-builder
COPY . /app
WORKDIR /app
RUN /usr/bin/hugo --minify --source=src/ --destination /app/build/

FROM nginx:1.27.4-alpine AS web
LABEL maintainer="Phoenix (https://github.com/HotaruBlaze)"
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/web.conf /etc/nginx/conf.d/web.conf

LABEL com.ouroboros.enable="true"
LABEL traefik.http.routers.blog-fluttershub-com.tls=true
LABEL traefik.http.routers.blog-fluttershub-com.rule=Host(`blog.fluttershub.com`)
LABEL traefik.http.routers.blog-fluttershub-com.tls.certresolver=letsencrypt
LABEL traefik.http.services.blog-fluttershub-com.loadbalancer.server.port=80
LABEL traefik.enable=true

EXPOSE 80
RUN rm -Rf /usr/share/nginx/html/ && rm /etc/nginx/conf.d/default.conf
COPY --from=hugo-builder /app/build /usr/share/nginx/html/
CMD [ "nginx", "-g", "daemon off;" ]