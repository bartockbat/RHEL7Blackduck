FROM registry.access.redhat.com/rhel7:latest

MAINTAINER Ton Schoots <ton@maiastra.com>

#Lables for the following - keep in mind I just made most of these up.

LABEL Name Blackduck Scanner 
LABEL Release Lite/OSS Release 
LABEL Vendor Blackduck Software
LABEL Version 1.01 

#Added to pass certification
RUN  yum clean all && yum -y update openldap

RUN  yum install -y wget unzip passwd tar \
     && cd /opt \
     && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u60-b27/jre-8u60-linux-x64.tar.gz" \
     && tar -xvf jre-8u60-linux-x64.tar.gz \
     && rm -rf jre-8u60-linux-x64.tar.gz \
     && cd /opt/jre1.8.0_60/  \
     && alternatives --install /usr/bin/java java /opt/jre1.8.0_60/bin/java 2 \
     && alternatives --set java /opt/jre1.8.0_60/bin/java  \
     && alternatives --install /usr/bin/jar jar /opt/jre1.8.0_60/bin/jar 2 \
     #&& alternatives --install /usr/bin/javac javac /opt/jre1.8.0_60/bin/javac 2 \
     && alternatives --set jar /opt/jre1.8.0_60/bin/jar \
     #&& alternatives --set javac /opt/jre1.8.0_60/bin/javac

# set root password for debugging purposes.
RUN echo blackduck | passwd --stdin root

# create user and groups
RUN groupadd blckdck
RUN useradd -ou 0 -g 0  blckdck
#RUN useradd -g blckdck blckdck
RUN echo blackduck | passwd --stdin blckdck

RUN mkdir -p /home/blackduck/scanner && mkdir -p /home/blackduck/j_scanner \
     && chown -R blckdck:blckdck /home/blackduck \
     && mkdir /log && chown -R blckdck:blckdck /log

# make a temporarily copy
RUN mkdir -p /tmp/scanner
COPY . /tmp/scanner
RUN find /tmp/scanner/ -name "scan*\.zip" -exec unzip {} -d /tmp/scanner \; \
     && find /tmp/scanner -type d -name "bin" -exec cp -r  {} /home/blackduck/j_scanner/ \; \
     && find /tmp/scanner -type d -name "lib" -exec cp -r  {} /home/blackduck/j_scanner/ \; \
     && cp /tmp/scanner/scanner /scanner \
     && chown -R blckdck:blckdck /home/blackduck \
     && rm -rf /tmp/scanner

ENV JAVA_HOME /opt/jre1.8.0_60
ENV JRE_HOME /opt/jre1.8.0_60/jre

USER blckdck

CMD ["/scanner"]

#Atomic labels - added for the Atomic Run parameter
LABEL RUN /usr/bin/docker run -d IMAGE
