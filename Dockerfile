#
# Dockerfile for dr_py
#

FROM python:3.7-alpine as builder

RUN set -ex \
  && apk add --update --no-cache \
     alpine-sdk \
     libffi-dev \
     libxslt-dev \
  && rm -rf /tmp/* /var/cache/apk/*

WORKDIR /builder
COPY requirements.txt /builder

RUN set -ex \
  && pip install --upgrade pip \
  && mkdir whl \
  && pip wheel -r requirements.txt -w ./whl \
  && ls whl

FROM python:3.7-alpine

COPY --from=builder /builder /builder
COPY docker-entrypoint.sh /entrypoint.sh
COPY supervisord.init /etc/supervisord.init

ENV REPO_URL https://ghproxy.com/https://github.com/hjdhnx/dr_py.git

RUN set -ex \
  && apk add --update --no-cache \
     git \
     libstdc++ \
     libxslt \
  && rm -rf /tmp/* /var/cache/apk/*

WORKDIR /builder

RUN set -ex \
  && ls whl \
  && pip install --upgrade pip \
  && pip install --no-index --find-links ./whl -r requirements.txt \
  && pip list \
  && rm -rf /builder /root/.cache/*

WORKDIR /root/sd/pywork/dr_py
VOLUME /root/sd/pywork/dr_py

ENV PYTHONUNBUFFERED=1
ENV AUTOUPDATE=
ENV INET_USERNAME=user
ENV INET_PASSWORD=123

EXPOSE 5705 9001

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord","-c","/etc/supervisord.conf"]
