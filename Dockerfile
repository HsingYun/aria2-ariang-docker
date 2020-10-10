FROM alpine:3

LABEL maintainer="hsingyun iakext@gmail.com"

ENV HTTP_PORT=80
ENV EXTERNAL_PORT=80
ENV USER_NAME=admin
ENV PASSWORD=admin
ENV PUID=1000
ENV PGID=1000
ENV TRACKER_URL=https://cdn.jsdelivr.net/gh/ngosang/trackerslist/trackers_all.txt
ENV ENABLE_UPDATE_TRACKER=true
ENV ENABLE_AUTO_RANDOM_ARIA=false
ENV ENABLE_AUTO_CLEAR_ARIANG=true
ENV ENABLE_PASSWORD=true
ENV TZ=

VOLUME /data
VOLUME /conf

EXPOSE 80

WORKDIR /app
ADD app /app
RUN chmod +x /app/*.sh
ADD conf /app/conf
RUN echo '*/15 * * * * /app/updatebttracker.sh' > /etc/crontabs/root
CMD /app/run.sh
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 CMD /app/healthcheck.sh
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk add --no-cache \
    aria2 \
    wget \
    apache2-utils \
    sudo \
    nginx \
    curl \
    tzdata \
    shadow
    
RUN groupadd -o -g 1000 aria2 \
    && useradd -o -g 1000 -u 1000 aria2

ADD AriaNg.zip /app/AriaNg.zip

RUN mkdir -p /run/nginx \
    && mkdir -p /usr/share/nginx/html \
    && rm -rf /usr/share/nginx/html/* \
    && unzip AriaNg.zip -d /usr/share/nginx/html \
    && rm -rf AriaNg.zip \
    && echo Set disable_coredump false >> /etc/sudo.conf

RUN apk del \
    wget
