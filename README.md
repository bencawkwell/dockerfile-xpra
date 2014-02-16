dockerfile-xpra
===============

Simple example of using xpra inside a docker container. This example uses Xdummy with xpra which is required to use opengl. See the branch no-gl for an example that uses the standard Xvfb with xpra.

Usage
-----

Make sure you are in the same directory as the Dockerfile

    cd dockerfile-xpra

Build the image and tag it xpra. The -rm options cleans the cache after the final image ha been created.

    docker build -t xpra -rm .

Run it, mapping the 22 port in the container to 1022 on the host.

    docker run -i -t -p 1022:22 xpra

In a separate terminal connect to xpra running in the container. The password is changeme.

    xpra attach --ssh="ssh -p 1022" ssh:xpra@localhost:100

If you return to the first terminal and hit any key then glxgears will launch on the host. If you already hit any key then glxgears will open on the host as soon as you attached to xpra. I only added the extra need to press a key before launching glxgears because I intend to use this example to run applications that may contain intros (eg. Dwarf Fortress).

Todo
----

* The line that prints start.sh is too long, it would be good to extract common functionality into separate utilities that can be fetched from gitub. I do not include it as a separate file since I want the Dockerfile to be as self contained as possible.