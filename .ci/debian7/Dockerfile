FROM debian:7

RUN apt-get update
RUN apt-get install -y wget git zip  build-essential debhelper libncurses5-dev unixodbc unixodbc-dev openjdk-7-jdk libssl-dev
RUN wget http://erlang.org/download/otp_src_20.0.tar.gz &&  tar zxvf otp_src_20.0.tar.gz && cd otp_src_20.0 && ./configure && make && make install
RUN mkdir -p /root/.ssh/
# cleanup
RUN apt-get clean\
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /otp_src_20.0/* /otp_src_20.0.tar.gz

ADD ./files/id_rsa /root/.ssh/
ADD ./files/id_rsa.pub /root/.ssh/
ADD ./files/config /root/.ssh/
ADD ./files/emq_ci.sh /

CMD ["/emq_ci.sh"]
