FROM erlang:22.3

RUN curl -L -o /tmp/openjdk-14.0.1_linux-x64_bin.tar.gz  https://download.java.net/java/GA/jdk14.0.1/664493ef4a6946b186ff29eb326336a2/7/GPL/openjdk-14.0.1_linux-x64_bin.tar.gz \
    && tar xvf /tmp/openjdk-14.0.1_linux-x64_bin.tar.gz -C /usr/local

ENV PATH=/usr/local/jdk-14.0.1/bin:$PATH