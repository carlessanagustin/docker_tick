FROM ubuntu:16.04

COPY install_telegraf_Ubuntu.sh /install_telegraf_Ubuntu.sh
RUN /bin/bash /install_telegraf_Ubuntu.sh
ENV TELEGRAF_VERSION 1.4
EXPOSE 8125/udp 8092/udp 8094
CMD ["telegraf"]
