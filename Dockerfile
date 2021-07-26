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
#   - "How do you set a locale non-interactively on Debian/Ubuntu?" (NOTE: OLD: 2012..15!)
#       -> https://serverfault.com/questions/362903/how-do-you-set-a-locale-non-interactively-on-debian-ubuntu/689947#689947
#
FROM debian:buster-slim

ENV HOME /home/user
ENV USER user

RUN apt-get update && apt-get install -y \
  build-essential \
  cmake \
  locales \
  pkg-config \
  && rm -rf /var/lib/apt/lists/*
  #
  # locales: needed to run 'build/bin/solvespace' [https://stackoverflow.com/a/54325765/14455]
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
#
# Note: Having them does not help with the GUI startup issues. ('Unable to create a GL context')
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
# Needed for executing 'build/bin/solvespace'
#
# Adapted from -> https://gist.github.com/shyd/ce8ba7e20d4f825ed3a8e57aa30b892b
#
# Note: Tried to avoid the 'ENV LANG=...' and make the Docker internals set it, instead. But this works.
#
RUN sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen \
  && locale-gen
ENV LANG=en_US.UTF-8

#RUN chown -R ${USER} ${HOME}/src

# Now changing to user (no more root)
USER $USER
   # $ whoami
   # user

# Docker's host is also the X11 host (you can of course override this with '-e' when launching)
ENV DISPLAY=host.docker.internal:0

CMD build/bin/solvespace
