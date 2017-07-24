FROM centos:7

RUN yum update -y
RUN yum install -y wget git zip
RUN yum groupinstall -y "Development Tools"
RUN wget https://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm -P /tmp
RUN rpm -Uvh /tmp/erlang-solutions-1.0-1.noarch.rpm
RUN yum install -y epel-release
RUN yum install -y esl-erlang-20.0
RUN mkdir -p /root/.ssh/

# cleanup
RUN yum clean packages \
 && rm -rf /tmp/* /var/tmp/*

ADD ./files/id_rsa /root/.ssh/
ADD ./files/id_rsa.pub /root/.ssh/
ADD ./files/config /root/.ssh/
ADD ./files/emq_ci.sh /

CMD ["/emq_ci.sh"]
