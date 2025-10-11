FROM ghcr.io/lesscodex/alpine:glibc

ENV JAVA_VERSION="1.6.0_45" \
    JAVA_HOME="/usr/local/jdk1.6.0_45" \
    JRE_HOME="/usr/local/jdk1.6.0_45/jre" \
    PATH="${PATH}:/usr/local/jdk1.6.0_45/bin"
WORKDIR /usr/local
RUN wget -q -O jdk1.6.0_45.bin \
    https://develop.xxy.fyi/archived/jdk-6u45-linux-x64.bin && \
    chmod u+x jdk1.6.0_45.bin && \
    yes | ./jdk1.6.0_45.bin && \
    rm -rf /usr/local/jdk1.6.0_45.bin