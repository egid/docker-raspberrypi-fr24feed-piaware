FROM raspbian/jessie
 
RUN apt-get update && \
    apt-get install -y wget libusb-1.0-0-dev pkg-config ca-certificates git-core cmake build-essential --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
 
WORKDIR /tmp
RUN echo 'blacklist dvb_usb_rtl28xxu' > /etc/modprobe.d/raspi-blacklist.conf && \
    git clone git://git.osmocom.org/rtl-sdr.git && \
    mkdir rtl-sdr/build && \
    cd rtl-sdr/build && \
    cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON && \
    make && \
    make install && \
    ldconfig && \
    rm -rf /tmp/rtl-sdr

# dump1090 + Piaware + supervisor
COPY piaware.conf /etc/

WORKDIR /tmp
RUN apt-get update && \
    apt-get install -y dump1090-fa piaware supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf


EXPOSE 8754 8080 30001 30002 30003 30004 30005 30104 

CMD ["/usr/bin/supervisord"]
