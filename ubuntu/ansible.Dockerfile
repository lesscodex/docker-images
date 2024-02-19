FROM ubuntu:latest
LABEL maintainer="xxy1991"
ENV container=docker

ENV pip_packages "ansible"

# Install dependencies.
COPY app/apt-cacher.sh /usr/local/bin/
RUN sh /usr/local/bin/apt-cacher.sh && rm /usr/local/bin/apt-cacher.sh

RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive \
    apt-get -yqq --no-install-recommends install \
            sudo systemd systemd-cron \
            build-essential libffi-dev libssl-dev libyaml-dev \
            wget ca-certificates \
            python3-pip python3-dev python3-setuptools python3-wheel \
            python3-apt python3-yaml \
            iproute2 apt-utils locales \
            software-properties-common rsyslog && \
    rm -rf /var/lib/apt/lists/* && \
    rm -Rf /usr/share/doc && rm -Rf /usr/share/man && \
    rm -f /etc/apt/apt.conf

RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

# Upgrade pip.
# RUN python3 -m pip install --upgrade pip

# Install Ansible via pip.
RUN python3 -m pip install $pip_packages

COPY ansible/initctl_faker .
RUN chmod +x initctl_faker && rm -fr /sbin/initctl && ln -s /initctl_faker /sbin/initctl

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Remove unnecessary getty and udev targets that result in high CPU usage when using
# multiple containers with Molecule (https://github.com/ansible/molecule/issues/1104)
RUN rm -f /lib/systemd/system/systemd*udev* \
  && rm -f /lib/systemd/system/getty.target

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]
