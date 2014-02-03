FROM ubuntu:precise
MAINTAINER Ben Cawkwell <bencawkwell@gmail.com>

# Update the system
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y

# Install supervisord.
RUN apt-get install -y supervisor

# Setup sshd
RUN apt-get install -y ssh
RUN mkdir /var/run/sshd
RUN echo 'root:changeme' |chpasswd
RUN /bin/echo -e "[program:sshd] \ncommand=/usr/sbin/sshd -D \n" > /etc/supervisor/conf.d/sshd.conf

# Install Xpra
RUN wget -qO - http://winswitch.org/gpg.asc | apt-key add -
RUN echo "deb http://winswitch.org/ precise main" > /etc/apt/sources.list.d/winswitch.list
RUN apt-get update
RUN apt-get install -y --no-install-recommends xpra
RUN useradd -m xpra
RUN echo 'xpra:changeme' |chpasswd
RUN chsh -s /bin/bash xpra
RUN /bin/echo -e "export DISPLAY=:100" > /home/xpra/.profile
RUN /bin/echo -e "[program:xpra] \ncommand=xpra start --no-daemon :100 \nuser=xpra \nenvironment=HOME=\"/home/xpra\" \n" > /etc/supervisor/conf.d/xpra.conf

# Fetch a utility for pausing bash scripts until supervisord has finished starting programs
ADD https://github.com/bencawkwell/supervisor-tools/raw/master/wait-for-daemons.sh /wait-for-daemons.sh
RUN chmod +x wait-for-daemons.sh

# Use xterm as the example application
RUN apt-get install -y --no-install-recommends xterm

RUN /bin/echo -e "#!/bin/bash \n/usr/bin/supervisord \n./wait-for-daemons.sh xpra sshd\necho 'use the following command to connect: xpra attach --ssh=\"ssh -p PORT\" ssh:xpra@HOST:100' \nread -p 'Press any key to continue...' \nsu -l xpra -c 'DISPLAY=:100 xterm'" > /start.sh
RUN chmod +x start.sh

EXPOSE 22

ENTRYPOINT ["/start.sh"]