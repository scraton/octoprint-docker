FROM python:3.9-slim

RUN apt-get update \
 && apt-get install -y \
      avrdude \
      build-essential \
      cmake \
      curl \
      imagemagick \
      ffmpeg \
      fontconfig \
      g++ \
      git \
      libjpeg-dev \
      libjpeg62-turbo \
      libprotobuf-dev \
      libudev-dev \
      libusb-1.0-0-dev \
      libv4l-dev \
      v4l-utils \
      xz-utils \
      zlib1g-dev \
      x265 \
 && python -m pip install --upgrade pip \
 && rm -rf /var/lib/apt/lists/*

RUN useradd -m --home-dir /opt/octoprint octoprint \
 && mkdir -p /data/octoprint /data/plugins \
 && chown -R octoprint:octoprint /data

WORKDIR /opt/octoprint
USER octoprint

ARG OCTOPRINT_VERSION
ENV OCTOPRINT_VERSION="${OCTOPRINT_VERSION:-master}"

ENV PIP_USER="true"
ENV PYTHONUSERBASE="/data/plugins"
ENV PATH="${PYTHONUSERBASE}/bin:/opt/octoprint/.local/bin:${PATH}"

RUN curl -fsSLO --compressed https://github.com/OctoPrint/OctoPrint/archive/${OCTOPRINT_VERSION}.tar.gz \
 && tar -zxvf ${OCTOPRINT_VERSION}.tar.gz --strip-components 1 -C /opt/octoprint --no-same-owner \
 && rm ${OCTOPRINT_VERSION}.tar.gz \
 && pip install --user .

WORKDIR /data
EXPOSE 5000
VOLUME /data

CMD ["octoprint", "serve", "--iknowwhatimdoing", "--host", "0.0.0.0", "--port", "5000", "--basedir", "/data/octoprint"]
