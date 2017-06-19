FROM node:8-alpine
RUN echo "http://mirrors.aliyun.com/alpine/v3.6/main/" > /etc/apk/repositories
RUN apk add --update git
RUN mkdir -p /app
WORKDIR /app
RUN git clone https://github.com/etsy/statsd.git
WORKDIR /app/statsd
COPY config.js .

EXPOSE 8125/udp 8126

CMD ["node", "stats.js", "config.js"]
