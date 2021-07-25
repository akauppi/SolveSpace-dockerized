# Docker SolveSpace

This repo provides a way to run [SolveSpace](http://solvespace.com/) without installing it natively on one's machine.

## Requirements

- Docker

## Getting started

```
$ git submodule update
```

That populates the `solvespace.sub` subpackage, holding the sources.

```
$ ./build.sh
...
 => => naming to docker.io/library/solvespace
```

### Launching the thing

>WIP: Instructions on how to run the image, graphically.

<!-- #later...
```
$ docker run -it --rm solvespace /bin/bash
```

<_!-- tbd. 
- directory mappings so it can edit files in some folder (`/work`)
-->


## Alternatives

The author is not aware of other SolveSpace Docker images.
