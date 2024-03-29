FROM jakejarvis/hugo-extended:0.105.0 as Builder
COPY . /app
WORKDIR /app
RUN /usr/bin/hugo --minify --source=src/ --destination build/

FROM nginx:1.19.6-alpine as web
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
COPY --from=Builder /app/build /usr/share/nginx/html/
CMD [ "nginx", "-g", "daemon off;" ]