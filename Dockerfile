#
# Dockerfile for dr_py
#

FROM cgr.dev/chainguard/wolfi-base as builder

ARG version=3.10

RUN set -ex \
    && apk add --update --no-cache \
       python-${version} \
       py${version}-pip

RUN set -ex \
    && apk add --update --no-cache \
       python-${version}-dev \
       build-base

RUN python -m venv /venv
ENV PATH="/venv/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /builder
COPY requirements.txt /builder

RUN set -ex \
  && pip install --upgrade pip \
  && pip install -r requirements.txt \
  && pip list

FROM cgr.dev/chainguard/wolfi-base

ARG version=3.10

RUN set -ex \
    && apk add --update --no-cache \
       python-${version} \
       py${version}-pip

COPY --from=builder /venv /venv
ENV PATH="/venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

COPY docker-entrypoint.sh /entrypoint.sh
COPY supervisord.init /etc/supervisord.init

ENV REPO_URL https://github.com/hjdhnx/dr_py.git

RUN set -ex \
  && apk add --update --no-cache \
     git \
  && rm -rf /tmp/* /var/cache/apk/*

WORKDIR /root/sd/pywork/dr_py
VOLUME /root/sd/pywork/dr_py

ENV AUTOUPDATE=
ENV INET_USERNAME=user
ENV INET_PASSWORD=123

EXPOSE 5705 9001

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord","-c","/etc/supervisord.conf"]
