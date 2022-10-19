FROM python:3.7-alpine as builder

RUN set -ex \
  && apk add --update --no-cache \
     alpine-sdk \
     libffi-dev \
     libxml2-dev \
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

RUN set -ex \
  && apk add --update --no-cache \
     git \
  && rm -rf /tmp/* /var/cache/apk/*

WORKDIR /builder

RUN set -ex \
  && ls whl \
  && pip install --upgrade pip \
  && pip install --no-index --find-links ./whl -r requirements.txt

WORKDIR /root/sd/pywork

RUN set -ex \
  && git clone https://gitcode.net/qq_32394351/dr_py.git

WORKDIR /root/sd/pywork/dr_py

COPY supervisord.conf /etc/supervisord.conf 

EXPOSE 5705 9001

CMD ["supervisord","-c","/etc/supervisord.conf"]