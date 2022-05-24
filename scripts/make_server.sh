#!/bin/sh
cd /tmp
curl https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar --output BuildTools.jar
java -Xmx6G -Xms6G -XX:MaxDirectMemorySize=256M -jar BuildTools.jar --rev 1.18.2
mv spigot-*.jar straw-serv.jar
