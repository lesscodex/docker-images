FROM eclipse-temurin:11-alpine

ENV ARTHAS_HOME /usr/local/arthas
RUN mkdir -p "$ARTHAS_HOME"
WORKDIR $ARTHAS_HOME

RUN wget -q -O arthas-tunnel-server.jar \
        https://arthas.aliyun.com/download/arthas-tunnel-server/latest_version?mirror=aliyun

EXPOSE 8080
EXPOSE 7777
CMD ["java", "-jar", "arthas-tunnel-server.jar"]