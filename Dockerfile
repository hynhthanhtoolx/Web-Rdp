FROM fedora:latest

# Cập nhật hệ thống trước
RUN dnf update -y && \
    dnf install -y \
    wget curl git xz dbus-x11 \
    xfce4-session xfce4-terminal xfce4-panel xfdesktop xfwm4 \
    tigervnc-server \
    firefox \
    gnome-system-monitor \
    mate-system-monitor \
    wine wine.i686 \
    qemu-kvm \
    google-noto-sans-cjk-ttc-fonts && \
    dnf clean all

# Tải noVNC
RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz && \
    tar -xvf v1.2.0.tar.gz && \
    rm v1.2.0.tar.gz

# Cấu hình VNC
RUN mkdir -p $HOME/.vnc && \
    echo 'xt' | vncpasswd -f > $HOME/.vnc/passwd && \
    chmod 600 $HOME/.vnc/passwd

# Tạo xstartup cho XFCE
RUN echo '#!/bin/sh' > $HOME/.vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> $HOME/.vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> $HOME/.vnc/xstartup && \
    echo 'exec startxfce4' >> $HOME/.vnc/xstartup && \
    chmod 755 $HOME/.vnc/xstartup

# Tạo script khởi động
RUN echo '#!/bin/bash' > /luo.sh && \
    echo 'whoami' >> /luo.sh && \
    echo 'cd' >> /luo.sh && \
    echo 'vncserver :1 -geometry 1360x768 -localhost no -fg' >> /luo.sh && \
    echo 'cd /noVNC-1.2.0' >> /luo.sh && \
    echo './utils/launch.sh --vnc localhost:5901 --listen 8900' >> /luo.sh && \
    chmod 755 /luo.sh

EXPOSE 8900
CMD ["/bin/bash", "/luo.sh"]
