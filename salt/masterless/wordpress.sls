install_pkgs:
  pkg.installed:
    - pkgs:
      - httpd
      - mariadb
      - php
      - php-gd
      - php-mysql
      - at
      - epel-release
      - wget
      - vim-enhanced
      - telnet
      - unzip

aws-cli:
  cmd.run:
    - name: wget --quiet https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -O /tmp/awscli-bundle.zip && unzip -qo /tmp/awscli-bundle.zip -d /tmp/ && /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/bin/aws
    - unless: stat /usr/bin/aws
    - require:
      - pkg: install-pkgs

setenforce 0:
  cmd.run:
    - require:
      - cmd: aws-cli

disable-selinux:
  file.replace:
    - names:
      - /etc/sysconfig/selinux
      - /etc/selinux/config
    - pattern: 'SELINUX=.*'
    - repl: SELINUX=permissive
    - require:
      - cmd: aws-cli

create-database:
  cmd.run:
    - name: mysql -h {{ pillar['rds_endpoint'] }} -u {{ pillar['rds_user'] }} -p{{ pillar['rds_passwd'] }} -e "CREATE DATABASE wordpress"
    - require:
      - pkg: install_pkgs

copy-dumpbase:
  file.managed:
    - name: /tmp/wordpress.sql
    - source: salt://masterless/files/wordpress.sql
    - require:
      - cmd: create-database

import-dump:
  cmd.run:
    - name: mysql -h {{ pillar['rds_endpoint'] }} -u {{ pillar['rds_user'] }} -p{{ pillar['rds_passwd'] }} wordpress < /tmp/wordpress.sql
    - require:
      - file: copy-dumpbase

copy-wordpress-app:
  archive.extracted:
    - name: /var/www/html/
    - source: salt://masterless/files/wordpress.tar.gz
    - source_hash: md5=15e30b829854ad21e5436836ab00ef00
    - archive_format: tar
    - if_missing: /tmp/data
    - require:
      - pkg: install_pkgs

grant-html-permissions:
  file.directory:
    - name: /var/www/html
    - makedirs: True
    - user: apache
    - group: apache
    - recurse:
      - user
      - group
    - require:
      - archive: copy-wordpress-app

create-wp-config:
  file.managed:
    - name: /var/www/html/wp-config.php
    - source: salt://masterless/files/wp-config.php
    - template: jinja
    - user: apache
    - group: apache
    - require:
      - archive: copy-wordpress-app

attach-instance-asg:
  cmd.run:
    - name: at -f /srv/salt/masterless/files/attach_instance-asg.sh now + 10 min
    - require:
      - file: create-wp-config

httpd:
  service.running:
    - enable: True
    - order: last
