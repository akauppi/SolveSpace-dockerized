# Docker SolveSpace

This repo provides a way to run [SolveSpace](http://solvespace.com/) without installing it natively on one's machine.

## Requirements

- Docker

### For running on macOS as a GUI

To run SolveSpace from within Docker, on macOS, you need an X11 host.

<details style="border: 1px solid lightblue; padding: 0.4em;"><summary>Installing XQuartz on macOS...</summary>

- Download and install from [xquartz.org](https://www.xquartz.org/index.html) (version 2.8.1 or later)
- Launch `XQuartz` 
- `Preferences` > `Security` > enable `Allow connections from network clients`

   >Now your Mac will be listening on port 6000 for X11 connections.

   >Note: You can close the `xterm` window that opens. Don't need it.

- Quit and restart XQuartz (needed for the setting to take effect)
- In a macOS terminal: 

   ```
   $ xhost + localhost
   localhost being added to access control list
   ```

These instructions were based on:

- [To forward X11 from inside a docker container to a host running macOS](https://gist.github.com/cschiewek/246a244ba23da8b9f0e7b11a68bf3285) (gist, 2017)

<!--
[release notes](https://www.xquartz.org/releases)
-->

</details>


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

You now have a `solvespace` Docker image (~780MB) that can run the SolveSpace GUI application.

### Launching

#### Windows + WSL2 + WSLg

Once [WSLg](https://github.com/microsoft/wslg) (GitHub) is out, by the end of 2021, you can run Linux GUI programs in Windows 10, seamlessly.

<!--
tbd. Instructions on how to run it off the Docker image - once we have access to WSLg.
-->

>**PENDING...** for WSLg public release.

#### macOS

```
$ docker run --rm -v`pwd`:/work solvespace
```

<!-- tbd. 
- directory mappings so it can edit files in some folder (`/work`)
-->


## Alternatives

The author is not aware of other SolveSpace Docker images.


## References

- [How to show X11 windows with Docker on Mac](https://medium.com/@mreichelt/how-to-show-x11-windows-within-docker-on-mac-50759f4b65cb) (blog, Oct 2017)

<!--
https://gist.github.com/cschiewek/246a244ba23da8b9f0e7b11a68bf3285
-->