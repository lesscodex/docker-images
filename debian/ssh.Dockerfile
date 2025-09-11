FROM debian:latest
LABEL maintainer="xxy1991"
ENV container=docker

ARG APT_HTTP_PROXY
ARG APT_HTTPS_PROXY

ENV APT_HTTP_PROXY=$APT_HTTP_PROXY \
    APT_HTTPS_PROXY=$APT_HTTPS_PROXY

COPY files/proxy.sh /usr/local/share/proxy.sh
RUN chmod +x /usr/local/share/proxy.sh

RUN /usr/local/share/proxy.sh && \
    apt-get -qq update && DEBIAN_FRONTEND=noninteractive \
    apt-get -yqq --no-install-recommends install \
            openssh-server \
    && rm -f /etc/apt/apt.conf.d/proxy.conf

RUN echo 'root:Test123!' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE="in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
