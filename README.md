dockerfile-xpra
===============

Simple example of using xpra inside a docker container

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

If you return to the first terminal and hit any key then xterm will launch on the host. If you already hit any key then xterm will open on the host as soon as you attached to xpra. I only added the extra need to press a key before launching xterm because I intend to use this example to run applications that may contain intros (eg. Dwarf Fortress).

Todo
----

* Poll supervisorctl and make sure sshd and xpra are running before prompting the user.