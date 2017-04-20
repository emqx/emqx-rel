FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y wget git zip
RUN apt-get update
RUN apt-get install -y build-essential debhelper
RUN wget http://packages.erlang-solutions.com/erlang/esl-erlang/FLAVOUR_1_general/esl-erlang_19.1.3-1~ubuntu~precise_amd64.deb -O /tmp/erlang.deb
RUN dpkg -i /tmp/erlang.deb || true
RUN apt-get -f install -y
RUN mkdir -p /rebar && git clone https://github.com/rebar/rebar && cd /rebar && ./bootstrap && cp /rebar/rebar /usr/local/bin/ && rm -rf /rebar
RUN mkdir -p /root/.ssh/
# cleanup
RUN apt-get clean\
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./files/id_rsa /root/.ssh/
ADD ./files/id_rsa.pub /root/.ssh/
ADD ./files/config /root/.ssh/
ADD ./files/emq_ci.sh /

CMD ["/emq_ci.sh"]
