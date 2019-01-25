FROM centos:7

RUN yum update -y
RUN yum install -y wget git zip which curl unzip
RUN yum groupinstall -y "Development Tools"
RUN wget https://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm -P /tmp
RUN yum install -y epel-release
RUN rpm -Uvh /tmp/erlang-solutions-1.0-1.noarch.rpm
RUN yum install -y esl-erlang
RUN yum install -y openssl-devel bzip2-devel expat-devel gdbm-devel readline-devel sqlite-devel gcc gcc-c++  openssl-devel \
    && wget https://www.python.org/ftp/python/3.6.7/Python-3.6.7.tgz \
    && tar xvf Python-3.6.7.tgz \
    && cd Python-3.6.7 \
    && echo "_socket socketmodule.c" >> Modules/Setup.dist \ 
    && echo "_ssl _ssl.c -DUSE_SSL -I/usr/local/ssl/include -I/usr/local/ssl/include/openssl -L/usr/local/ssl/lib -lssl -lcrypto" >> Modules/Setup.dist \
    && ./configure --prefix=/usr/local/python3.6.7 \
    && make \
    && make install \
    && rm -rf /usr/bin/python3 && ln -s /usr/local/python3.6.7/bin/python3.6 /usr/bin/python3
RUN mkdir -p /root/.ssh/

# cleanup
RUN yum clean packages \
 && rm -rf /tmp/* /var/tmp/*

ADD ./files/id_rsa /root/.ssh/
ADD ./files/id_rsa.pub /root/.ssh/
ADD ./files/config /root/.ssh/
ADD ./files/emqx_ci.sh /

RUN chmod +x /emqx_ci.sh 

CMD ["/bin/bash", "-c", "source /emqx_ci.sh"]



