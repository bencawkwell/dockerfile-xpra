FROM ubuntu:16.04
MAINTAINER Ali Sadat <sadatakhavi.ali@gmail.com>

# Update the system
RUN apt-get update
#RUN apt-get upgrade -y

# Install supervisord.
RUN apt-get install -y supervisor

# Setup sshd
RUN apt-get install -y ssh
RUN mkdir /var/run/sshd
RUN echo 'root:changeme' |chpasswd
RUN /bin/echo -e "[program:sshd] \ncommand=/usr/sbin/sshd -D \n" > /etc/supervisor/conf.d/sshd.conf

#RUN apt-get install -y apt-utils

# Install Xpra
#RUN apt-get install -y curl
#RUN curl https://winswitch.org/gpg.asc | apt-key add -
#RUN wget -qO - http://winswitch.org/gpg.asc | apt-key add -
#RUN echo "deb http://winswitch.org/ xenial main" > /etc/apt/sources.list.d/winswitch.list
#RUN apt-get install -y software-properties-common >& /dev/null
#RUN add-apt-repository universe >& /dev/null
RUN apt-get update
RUN apt-get install -y xpra xserver-xorg-video-dummy
RUN useradd -m xpra
RUN echo 'xpra:xpra' |chpasswd
RUN chsh -s /bin/bash xpra
ADD http://xpra.org/xorg.conf /home/xpra/xorg.conf
RUN /bin/echo -e "export DISPLAY=:100" > /home/xpra/.profile && chown xpra:xpra /home/xpra/xorg.conf
RUN /bin/echo -e "[program:xpra] \ncommand=xpra --no-daemon --xvfb=\"Xorg -dpi 96 -noreset -nolisten tcp +extension GLX +extension RANDR +extension RENDER -logfile /home/xpra/.xpra/Xvfb-10.log -config /home/xpra/xorg.conf\" start :100 \nuser=xpra \nenvironment=HOME=\"/home/xpra\" \n" > /etc/supervisor/conf.d/xpra.conf

# Fetch a utility for pausing bash scripts until supervisord has finished starting programs
ADD https://github.com/bencawkwell/supervisor-tools/raw/master/wait-for-daemons.sh /wait-for-daemons.sh
RUN chmod +x wait-for-daemons.sh

# Use glxgears as the example application
RUN apt-get install -y --no-install-recommends mesa-utils

RUN /bin/echo -e "#!/bin/bash \n/usr/bin/supervisord \n./wait-for-daemons.sh xpra sshd\necho 'use the following command to connect: xpra attach --ssh=\"ssh -p PORT\" ssh:xpra@HOST:100' \nread -p 'Press any key to continue...' \nsu -l xpra -c 'DISPLAY=:100 glxgears'" > /start.sh
RUN chmod +x start.sh

EXPOSE 22

ENTRYPOINT ["/start.sh"]
