FROM ubuntu:12.04

RUN apt-get update && apt-get install -y \
    wget \
    make \
    g++ \
    zip \
    libncurses5-dev \
    unixodbc \
    unixodbc-dev \
    openjdk-7-jdk \
    libssl-dev \
    build-essential \
    curl \
    debhelper \
    python-software-properties \
    unzip
RUN add-apt-repository -y ppa:git-core/ppa && apt-get update && apt-get install -y git
RUN echo >> deb http://security.ubuntu.com/ubuntu precise-security main /etc/apt/sources.list
RUN wget http://erlang.org/download/otp_src_21.2.tar.gz &&  tar zxvf otp_src_21.2.tar.gz && cd otp_src_21.2 && ./configure && make && make install
RUN wget https://www.python.org/ftp/python/3.6.7/Python-3.6.7.tgz \
    && tar xvf Python-3.6.7.tgz \
    && cd Python-3.6.7 \
    && echo "_socket socketmodule.c" >> Modules/Setup.dist \ 
    && echo "_ssl _ssl.c -DUSE_SSL -I/usr/local/ssl/include -I/usr/local/ssl/include/openssl -L/usr/local/ssl/lib -lssl -lcrypto" >> Modules/Setup.dist \
    && ./configure --prefix=/usr/local/python3.6.7 \
    && make \
    && make install \
    && rm -rf /usr/bin/python3 \
    && ln -s /usr/local/python3.6.7/bin/python3.6 /usr/bin/python3
RUN mkdir -p /root/.ssh/
# cleanup
RUN apt-get clean\
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /otp_src_21.2/* /otp_src_21.2.tar.gz

ADD ./files/id_rsa /root/.ssh/
ADD ./files/id_rsa.pub /root/.ssh/
ADD ./files/config /root/.ssh/
ADD ./files/emqx_ci.sh /

RUN chmod +x /emqx_ci.sh 

CMD ["/bin/bash", "-c", "source /emqx_ci.sh"]
