#
# Dockerfile for SolveSpace
#
# Provides:
#   - ...
#
# Build on Debian, since the project provides build instructions [1] for it.
#
#   [1]: https://github.com/solvespace/solvespace#building-for-linux
#
# References:
#   - Best practices for writing Dockerfiles
#       -> https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
#
FROM debian:buster-slim

ENV HOME /home/user
ENV USER user

RUN apt-get update && apt-get install -y \
  build-essential \
  cmake \
  git \
  pkg-config \
  && rm -rf /var/lib/apt/lists/*
  #
  # git: Needed not only for priming the 'extlib/{libdxfrw|mimalloc}', but also during the 'cmake' build.
  # pkg-config: needed by 'cmake' but not mentioned in SolveSpace README

RUN apt-get update && apt-get install -y \
  libcairo2-dev \
  libfreetype6-dev \
  libgl-dev \
  libgtkmm-3.0-dev \
  libjson-c-dev \
  libpangomm-1.4-dev \
  libpng-dev \
  zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

# Mentioned in README, but managed to build without these (are they important??):
#
#  libfontconfig1-dev \
#  libglu-dev \
#  libspnav-dev

# Locales needed when trying to run 'build/bin/solvespace'. [https://stackoverflow.com/a/54325765/14455]
#
RUN apt-get update && apt-get install -y \
  locales \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen "en_US.UTF-8"

#  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
#ENV LANG=en_US.UTF-8 \
#  LANGUAGE=en_US \
#  LC_ALL=en_US.UTF-8

#--- User ---
# Be eventually a user rather than root
#
RUN useradd -ms /bin/bash --no-log-init $USER

WORKDIR $HOME

#--- Sources ---
COPY solvespace.sub ${HOME}/src
RUN chown -R ${USER} ${HOME}/src

# Now changing to user (no more root)
USER $USER
   # $ whoami
   # user

#--- Build ---
#
# Intentionally configuration and build itself (takes longer) separated.

RUN mkdir build \
  && cd build \
  && cmake ../src -DCMAKE_BUILD_TYPE=Release -DENABLE_OPENMP=ON

RUN cd build \
  && make

CMD build/bin/solvespace
