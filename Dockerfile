FROM openjdk:8-jdk

RUN apt-get update && apt-get -y install cmake g++ libgomp1

ADD . /root
WORKDIR /root

RUN sed -i -e 's/    \${JAVA_JVM_LIBRARY}//' ./xgboost/CMakeLists.txt

ENV CFLAGS -fvisibility=hidden -static-libgcc
ENV CXXFLAGS -fvisibility=hidden -fvisibility-inlines-hidden -static-libgcc -static-libstdc++
