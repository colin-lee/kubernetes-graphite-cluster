FROM    ubuntu:14.04
RUN     sed -i 's/archive.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list 

# Install required packages
RUN     apt-get -y update &&\ 
        apt-get -y install software-properties-common python-django-tagging python-simplejson \
        python-memcache python-ldap python-cairo python-pysqlite2 python-support python-pip \
        gunicorn supervisor nginx-light git wget curl build-essential python-dev libffi-dev jq &&\
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


RUN     git clone https://github.com/graphite-project/graphite-web.git /src/graphite-web  &&\
        cd /src/graphite-web                                                              &&\
        git checkout 1.0.x     			                                                  &&\
        python setup.py install                                                           &&\
        pip install -r requirements.txt                                                   &&\
        python check-dependencies.py

# Add system service config
ADD    ./nginx/nginx.conf /etc/nginx/nginx.conf
ADD    ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add graphite config
ADD    ./webapp/initial_data.json /opt/graphite/webapp/graphite/initial_data.json
ADD    ./webapp/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
ADD    ./conf/carbon.conf /opt/graphite/conf/carbon.conf
ADD    ./conf/storage-schemas.conf /opt/graphite/conf/storage-schemas.conf
ADD    ./conf/storage-aggregation.conf /opt/graphite/conf/storage-aggregation.conf
ADD    set-cluster-nodes.sh /set-cluster-nodes.sh
ADD    entrypoint.sh /entrypoint.sh
RUN    mkdir -p /opt/graphite/storage/whisper
RUN    touch /opt/graphite/storage/graphite.db /opt/graphite/storage/index
RUN    chmod 0775 /opt/graphite/storage /opt/graphite/storage/whisper
RUN    chmod 0664 /opt/graphite/storage/graphite.db
RUN    cp /src/graphite-web/webapp/manage.py /opt/graphite/webapp

# Nginx
expose    80
# Carbon line receiver port
# expose    2003
# Carbon UDP receiver port
# expose    2003/udp
# Carbon pickle receiver port
# expose    2004
# Carbon cache query port
# expose    7002

cmd    ["/entrypoint.sh"]
