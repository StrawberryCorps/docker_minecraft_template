FROM openjdk:17-jdk-slim-buster AS build

RUN apt update
RUN apt install git curl -y

WORKDIR /tmp
ADD scripts/make_server.sh make_server.sh
RUN chmod +x make_server.sh

RUN ./make_server.sh

# ----------

FROM openjdk:17-jdk-slim-buster AS production

ENV MINECRAFT_PATH=/opt/minecraft
ENV SERVER_PATH=${MINECRAFT_PATH}/server

ENV JAVA_HEAP_SIZE=4G
ENV JAVA_ARGS="-server -Dcom.mojang.eula.agree=true"

RUN apt update
RUN apt install python3-pip -y
RUN pip3 install mcstatus

HEALTHCHECK --interval=5s --timeout=5s --start-period=120s \
  CMD mcstatus localhost:$( cat $SERVER_PATH/server.properties | grep "server-port" | cut -d'=' -f2 ) ping

WORKDIR ${SERVER_PATH}
COPY --from=build /tmp/straw-serv.jar ${SERVER_PATH}/

ADD scripts/run_server.sh run_server.sh
RUN chmod +x run_server.sh

ADD mc-data/* ${SERVER_PATH}/

EXPOSE 25565

ENTRYPOINT [ "./run_server.sh" ]

CMD [ "serve" ]