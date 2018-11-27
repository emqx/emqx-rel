FROM debian:8

RUN apt-get update
RUN apt-get install -y wget git zip  build-essential debhelper curl
RUN wget http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_1_general/esl-erlang_21.0.5-1~debian~jessie_amd64.deb -O /tmp/erlang.deb
RUN dpkg -i /tmp/erlang.deb || true
RUN apt-get -f install -y
RUN mkdir -p /root/.ssh/
# cleanup
RUN apt-get clean\
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ~/.ssh/id_rsa /root/.ssh/
ADD ~/.ssh/id_rsa /root/.ssh/
#ADD ./files/id_rsa /root/.ssh/
#ADD ./files/id_rsa.pub /root/.ssh/
ADD ./files/config /root/.ssh/
ADD ./files/emqx_ci.sh /
ADD ./files/emqx_nightly_ci.sh / 
ADD ./files/emqx_release_ci.sh /

CMD ["/emqx_ci.sh"]
