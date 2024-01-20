#
# Dockerfile for dr_py
#

FROM esme518/wolfi-base-python:3.10 as builder

RUN set -ex \
  && apk add --update --no-cache \
     build-base \
     python-3.10-dev \
  && rm -rf /tmp/* /var/cache/apk/*

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

FROM esme518/wolfi-base-python:3.10

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
