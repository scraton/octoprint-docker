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
      gphoto2 \
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

RUN useradd -m --home-dir /data/octoprint octoprint \
 && usermod -aG tty octoprint \
 && usermod -aG dialout octoprint \
 && mkdir -p /data/plugins \
 && chown -R octoprint:octoprint /data

ARG MJPG_STREAMER_VERSION
ENV MJPG_STREAMER_VERSION="${MJPG_STREAMER_VERSION:-master}"

WORKDIR /opt/mjpg-streamer
RUN curl -fsSLO --compressed https://github.com/jacksonliam/mjpg-streamer/archive/${MJPG_STREAMER_VERSION}.tar.gz \
 && tar -zxvf ${MJPG_STREAMER_VERSION}.tar.gz -C /opt/mjpg-streamer \
 && cd /opt/mjpg-streamer/mjpg-streamer-master/mjpg-streamer-experimental \
 && make \
 && make install \
 && rm -rf /opt/mjpg-streamer

ARG OCTOPRINT_VERSION
ENV OCTOPRINT_VERSION="${OCTOPRINT_VERSION:-master}"

WORKDIR /opt/octoprint
RUN curl -fsSLO --compressed https://github.com/OctoPrint/OctoPrint/archive/${OCTOPRINT_VERSION}.tar.gz \
 && tar -zxvf ${OCTOPRINT_VERSION}.tar.gz --strip-components 1 -C /opt/octoprint --no-same-owner \
 && pip install . \
 && rm ${OCTOPRINT_VERSION}.tar.gz

COPY bin/ /usr/local/bin

USER octoprint
ENV PIP_USER="true"
ENV PYTHONUSERBASE="/data/plugins"
ENV PATH="${PYTHONUSERBASE}/bin:${PATH}"

WORKDIR /data
EXPOSE 5000
VOLUME /data

CMD ["start_octoprint"]
