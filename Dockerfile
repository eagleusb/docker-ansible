# syntax=docker/dockerfile:latest
FROM debian:buster as build

ENV DEBIAN_FRONTEND="noninteractive"
ENV ANSIBLE_VERS="2.9"

RUN apt update -qq && apt install -qqy --no-install-recommends \
  build-essential wget libffi-dev libssl-dev \
  python3-pip python3-dev python3-setuptools python3-wheel

RUN pip3 install \
  --no-cache-dir \
  --disable-pip-version-check \
  --no-compile \
  --root "/opt/ansible" \
  ansible>=${ANSIBLE_VERS}

FROM debian:buster as run

LABEL org.label-schema.name="docker-ansible" \
  org.label-schema.description="ansible with systemd on debian" \
  org.label-schema.vcs-ref="latest" \
  org.label-schema.vcs-url="https://github.com/eagleusb/docker-ansible" \
  org.label-schema.schema-version="1.0"

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt update -qq && \
  apt install -qqy --no-install-recommends \
  python3-minimal python3-cryptography python3-netaddr sudo systemd && \
  apt upgrade -qqy && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /usr/share/doc && \
  rm -rf /usr/share/man && \
  apt clean

RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts
RUN rm -f /lib/systemd/system/multi-user.target.wants/getty.target

COPY --from=build /opt/ansible/usr/ /usr/

VOLUME ["/sys/fs/cgroup"]
CMD ["/lib/systemd/systemd"]
HEALTHCHECK NONE
