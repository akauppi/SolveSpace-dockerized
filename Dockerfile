#
# Dockerfile for SolveSpace
#
# Provides:
#   - 'build/bin/solvespace' binary
#
# Build on Debian, since the project provides build instructions [1] for it.
#
#   [1]: https://github.com/solvespace/solvespace#building-for-linux
#
# References:
#   - Best practices for writing Dockerfiles
#       -> https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
#   - Docker official images > Ubuntu
#       -> https://hub.docker.com/_/ubuntu
#
#FROM debian:buster-slim    # see Issue #1
#FROM debian:bullseye       # -''-
FROM ubuntu:rolling
  # 21.04 = hirsute (Jul 2021); 30 MB

ENV HOME /home/user
ENV USER user

# Note: 'DEBIAN_FRONTEND="noninteractive"' is needed to not be asking about locale (applies only for the install).
#
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
  build-essential \
  cmake \
  pkg-config \
  && rm -rf /var/lib/apt/lists/*
  #
  # pkg-config: needed by 'cmake' but not mentioned in SolveSpace README

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
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
  # libspnav-dev: needed for SpaceNavigator support

# Note: Having them does not help with the GUI startup issues. (Issue #1)
#
#RUN apt-get update && apt-get install -y \
#  libfontconfig1-dev \
#  libglu-dev \
#  libspnav-dev \
#  && rm -rf /var/lib/apt/lists/*

#--- User ---
# Be eventually a user rather than root
#
RUN useradd -ms /bin/bash --no-log-init $USER

WORKDIR $HOME

#--- Sources ---
COPY solvespace.sub ${HOME}/src

#--- Build ---
#
# Intentionally configuration and build itself (takes longer) separated.

RUN mkdir build \
  && cd build \
  && cmake ../src -DCMAKE_BUILD_TYPE=Release -DENABLE_OPENMP=ON

# Takes 95% of the time...
RUN cd build && make

#--- Locale ---
#
ENV LANG=C.UTF-8

#RUN chown -R ${USER} ${HOME}/src

# Now changing to user (no more root)
USER $USER
   # $ whoami
   # user

# Docker's host is also the X11 host (you can of course override this with '-e' when launching)
ENV DISPLAY=host.docker.internal:0

CMD build/bin/solvespace
