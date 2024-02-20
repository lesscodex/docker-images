FROM xxy1991/alpine:glibc

ENV JAVA_VERSION="1.6.0_45" \
    JAVA_HOME="/usr/local/jre1.6.0_45" \
    JRE_HOME="/usr/local/jre1.6.0_45" \
    PATH="${PATH}:/usr/local/jre1.6.0_45/bin"
WORKDIR /usr/local
RUN wget -q -O jre1.6.0_45.bin \
    https://develop.xxy.fyi/archived/jre-6u45-linux-x64.bin && \
    chmod u+x jre1.6.0_45.bin && \
    yes | ./jre1.6.0_45.bin && \
    rm -rf /usr/local/jre1.6.0_45.bin