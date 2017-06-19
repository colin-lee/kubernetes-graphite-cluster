FROM    ubuntu:14.04
RUN     sed -i 's/archive.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list 

# Install required packages
RUN     apt-get -y update &&\ 
        apt-get -y install software-properties-common python-django-tagging python-simplejson \
        python-memcache python-ldap python-cairo python-pysqlite2 python-support python-pip \
        gunicorn supervisor nginx-light git wget curl build-essential python-dev libffi-dev jq && \
        apt-get -y autoclean
RUN     pip install Twisted==13.2.0 &&\
        pip install pytz
RUN     git clone https://github.com/graphite-project/whisper.git /src/whisper            &&\
        cd /src/whisper                                                                   &&\
        git checkout 1.0.x                                                                &&\
        python setup.py install                                                           &&\
        rm -rf /src/whisper

RUN     git clone https://github.com/graphite-project/carbon.git /src/carbon              &&\
        cd /src/carbon                                                                    &&\
        git checkout 1.0.x                                                                &&\
        python setup.py install                                                           &&\
        rm -rf /src/carbon


ADD conf/carbon.conf /opt/graphite/conf/carbon.conf
ADD conf/storage-schemas.conf /opt/graphite/conf/storage-schemas.conf
ADD set-cluster-nodes.sh /set-cluster-nodes.sh
ADD entrypoint.sh /entrypoint.sh

EXPOSE 2003

CMD ["/entrypoint.sh"]
