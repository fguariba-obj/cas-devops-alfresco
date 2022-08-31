FROM nginx:1.19.1-alpine
ENV TZ=Europe/Zurich
ARG NGINX_HOME=/etc/nginx

# Set timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
# Remove default conf
RUN rm "$NGINX_HOME/conf.d/default.conf"

# Copy overlay files:
COPY overlay "$NGINX_HOME"