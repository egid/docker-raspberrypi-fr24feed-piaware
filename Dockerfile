FROM arm32v7/debian:jessie
 
RUN apt-get update && \
    apt-get install -y wget libusb-1.0-0-dev pkg-config ca-certificates git-core cmake build-essential --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget http://flightaware.com/adsb/piaware/files/packages/pool/piaware/p/piaware-support/piaware-repository_3.8.0~bpo8+1_all.deb 
RUN dpkg -i piaware-repository_3.8.0~bpo8+1_all.deb

# WORKDIR /tmp
# RUN mkdir /etc/modprobe.d
# RUN echo 'blacklist dvb_usb_rtl28xxu' > /etc/modprobe.d/raspi-blacklist.conf && \
#     git clone git://git.osmocom.org/rtl-sdr.git && \
#     mkdir rtl-sdr/build && \
#     cd rtl-sdr/build && \
#     cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON && \
#     make && \
#     make install && \
#     ldconfig && \
#     rm -rf /tmp/rtl-sdr

# dump1090 + Piaware + supervisor

WORKDIR /tmp
RUN apt-get update && \
    apt-get install -y dump1090-fa piaware supervisor
COPY piaware.conf /etc/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf


EXPOSE 8754 8080 30001 30002 30003 30004 30005 30104 

CMD ["/usr/bin/supervisord"]
