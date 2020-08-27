FROM fedora:32

RUN dnf update -y && \
    dnf install findutils -y && \
    dnf clean all && \
    dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    dnf install -y dovecot dovecot-pgsql dovecot-pigeonhole openssl telnet net-tools iputils

ADD Configuration /etc/dovecot
ADD Utils /usr/local/bin
ADD Scripts/start.sh /start.sh
ADD Scripts/logrotate.sh /logrotate.sh

RUN mkdir /etc/dovecot/sieve

ADD Sieve/.dovecot.sieve /etc/dovecot/sieve/.dovecot.sieve
ADD Sieve/report-ham.sieve /etc/dovecot/sieve/report-ham.sieve
ADD Sieve/report-spam.sieve /etc/dovecot/sieve/report-spam.sieve
ADD Sieve/spam-global.sieve /etc/dovecot/sieve/spam-global.sieve

RUN sievec /etc/dovecot/sieve/.dovecot.sieve
RUN sievec /etc/dovecot/sieve/report-ham.sieve
RUN sievec /etc/dovecot/sieve/report-spam.sieve
RUN sievec /etc/dovecot/sieve/spam-global.sieve

RUN groupadd -g 5000 vmail && useradd -g vmail -u 5000 vmail -d /home/vmail -m
RUN chgrp vmail /etc/dovecot/dovecot.conf && chmod g+r /etc/dovecot/dovecot.conf
RUN chgrp -R vmail /etc/dovecot/sieve && chmod -R 750 /etc/dovecot/sieve

EXPOSE {{SERVICE.MAIL_RECEIVE.PORTS.PORT_EXPOSED_IMAPS}}

CMD sh start.sh