#!/bin/bash
set -eu -o pipefail

#
# build.sh
#
# Builds the SolveSpace Docker image
#
# Requires:
#   - git
#   - docker
#

#--- Preparation
#
# If the needed subpackages within the 'solvespace.sub' subpackage are empty, populate them.
#
for X in libdxfrw mimalloc
do
  [[ "$(ls -A solvespace.sub/extlib/$X)" ]] || (cd solvespace.sub && git submodule update --init extlib/$X)
done

# Modify 'CMakeLists.txt' as instructed within it:
#   <<
#     # NOTE TO PACKAGERS: The embedded git commit hash is critical for rapid bug triage when the builds
#     # can come from a variety of sources. If you are mirroring the sources or otherwise build when
#     #the .git directory is not present, please comment the following line:
#     include(GetGitCommitHash)
#     #and instead uncomment the following, adding the complete git hash of the checkout you are using:
#     set(GIT_COMMIT_HASH 0000000000000000000000000000000000000000)
#   <<
#

HASH=$(cd solvespace.sub && git rev-parse HEAD)

# Note: '-i.~' should make this work both on macOS and GNU.
#
(cd solvespace.sub &&
  sed -i.~ 's/^include(GetGitCommitHash)$/# include(GetGitCommitHash)/' CMakeLists.txt &&
  sed -i.~ "s/^# set(GIT_COMMIT_HASH 0000000000000000000000000000000000000000)$/set(GIT_COMMIT_HASH ${HASH})/" CMakeLists.txt &&
  rm CMakeLists.txt.~
)

docker build . --tag solvespace
