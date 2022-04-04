FROM amd64/openjdk:17-jdk-alpine AS build

ARG PAPER_DOWNLOAD_URL=https://download.getbukkit.org/spigot/spigot-1.18.2.jar

ADD ${PAPER_DOWNLOAD_URL} /opt/minecraft/paper.jar
ENV MINECRAFT_BUILD_PATH=/opt/minecraft

WORKDIR /opt/minecraft
ADD ${PAPER_DOWNLOAD_URL} paper.jar

# RUN mv ${MINECRAFT_BUILD_PATH}/cache/patched*.jar ${MINECRAFT_BUILD_PATH}/paper.jar

FROM amd64/openjdk:17-jdk-alpine AS production

ENV MINECRAFT_PATH=/opt/minecraft
ENV SERVER_PATH=${MINECRAFT_PATH}/server

ENV JAVA_HEAP_SIZE=4G
ENV JAVA_ARGS="-server -Dcom.mojang.eula.agree=true"

RUN apk add py3-pip
RUN pip3 install mcstatus

HEALTHCHECK --interval=10s --timeout=5s --start-period=120s \
  CMD mcstatus localhost:$( cat $SERVER_PATH/server.properties | grep "server-port" | cut -d'=' -f2 ) ping

WORKDIR ${SERVER_PATH}
COPY --from=build /opt/minecraft/paper.jar ${SERVER_PATH}/
ADD scripts/run_server.sh run_server.sh
RUN chmod +x run_server.sh

ADD mc-data/* ${SERVER_PATH}/

EXPOSE 25565

ENTRYPOINT [ "./run_server.sh" ]

CMD [ "serve" ]