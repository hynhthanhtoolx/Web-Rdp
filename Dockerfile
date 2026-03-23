FROM alpine:latest

# Cài đặt Wine trên Alpine
RUN apk add --no-cache \
    wget curl bash \
    wine xfce4 xfce4-terminal tightvnc \
    xrdp dbus \
    --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community && \
    rm -rf /var/cache/apk/*

# Cấu hình Wine Windows 7
RUN winecfg -v win7

# noVNC
RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz && \
    tar -xzf v1.2.0.tar.gz && rm v1.2.0.tar.gz

# VNC setup
RUN mkdir -p $HOME/.vnc && \
    echo 'xt' | vncpasswd -f > $HOME/.vnc/passwd && \
    chmod 600 $HOME/.vnc/passwd && \
    echo '#!/bin/sh' > $HOME/.vnc/xstartup && \
    echo 'xfce4-session &' >> $HOME/.vnc/xstartup && \
    echo 'wine explorer /desktop=shell,1360x768 &' >> $HOME/.vnc/xstartup && \
    chmod 755 $HOME/.vnc/xstartup

# Script khởi động
RUN echo '#!/bin/sh' > /start.sh && \
    echo '' >> /start.sh && \
    echo '# Start DBus' >> /start.sh && \
    echo 'mkdir -p /var/run/dbus' >> /start.sh && \
    echo 'dbus-daemon --system --fork' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Start XRDP' >> /start.sh && \
    echo 'xrdp --nodaemon &' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Start VNC' >> /start.sh && \
    echo 'vncserver :2000 -geometry 1360x768 -localhost no' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Start noVNC' >> /start.sh && \
    echo 'cd /noVNC-1.2.0 && ./utils/launch.sh --vnc localhost:5900 --listen 8900 &' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'echo "=== Windows 7 Lite ==="' >> /start.sh && \
    echo 'echo "Truy cập: http://localhost:8900"' >> /start.sh && \
    echo 'sleep infinity' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 8900 5900 3389
CMD /start.sh
