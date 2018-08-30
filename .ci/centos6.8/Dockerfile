FROM centos:6.8

RUN yum update -y
RUN yum install -y wget git zip
RUN yum groupinstall -y "Development Tools"
RUN wget https://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm -P /tmp
RUN yum install -y epel-release
RUN rpm -Uvh /tmp/erlang-solutions-1.0-1.noarch.rpm
RUN yum install -y esl-erlang
RUN mkdir -p /root/.ssh/

# cleanup
RUN yum clean packages \
 && rm -rf /tmp/* /var/tmp/*

ADD ./files/id_rsa /root/.ssh/
ADD ./files/id_rsa.pub /root/.ssh/
ADD ./files/config /root/.ssh/
ADD ./files/emqx_ci.sh /

CMD ["/emqx_ci.sh"]
