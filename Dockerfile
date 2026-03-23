FROM fedora:latest

RUN dnf install -y \
    wget curl git xz dbus-x11 \
    @xfce xfce4-terminal tigervnc-server \
    firefox gnome-system-monitor mate-system-monitor \
    wine qemu-kvm wqy-zenhei-fonts && \
    dnf clean all

RUN dnf install -y wine.i686 && \
    dnf clean all

RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz && \
    tar -xvf v1.2.0.tar.gz && \
    rm v1.2.0.tar.gz

RUN mkdir -p $HOME/.vnc && \
    echo 'xt' | vncpasswd -f > $HOME/.vnc/passwd && \
    chmod 600 $HOME/.vnc/passwd

RUN echo '#!/bin/sh' > $HOME/.vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> $HOME/.vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> $HOME/.vnc/xstartup && \
    echo 'exec startxfce4' >> $HOME/.vnc/xstartup && \
    chmod 755 $HOME/.vnc/xstartup

RUN echo '#!/bin/bash' > /luo.sh && \
    echo 'whoami' >> /luo.sh && \
    echo 'cd' >> /luo.sh && \
    echo 'su -l -c "vncserver :1 -geometry 1360x768 -localhost no"' >> /luo.sh && \
    echo 'cd /noVNC-1.2.0' >> /luo.sh && \
    echo './utils/launch.sh --vnc localhost:5901 --listen 8900' >> /luo.sh && \
    chmod 755 /luo.sh

EXPOSE 8900
CMD ["/bin/bash", "/luo.sh"]
