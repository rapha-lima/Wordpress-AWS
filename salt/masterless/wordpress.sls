include:
  - masterless.core

### instalacao dos pacotes necessarios
install_pkgs:
  pkg.installed:
    - pkgs:
      - httpd
      - mariadb
      - php
      - php-gd

create-database:
  cmd.run:
    - name: mysql -h {{ pillar['rds_endpoint'] }} -u {{ pillar['rds_user'] }} -p{{ pillar['rds_passwd'] }} -e "CREATE DATABASE wordpress"

download-wordpress:
  cmd.run:
    - name: wget http://wordpress.org/latest.tar.gz

extract-wordpress:
  cmd.run:
    - name: tar xzf latest.tar.gz
    - require:
      - cmd: download-wordpress

cp-wordpress-content:
  cmd.run:
    - name: rsync -a wordpress/ /var/www/html/
    - require:
      - cmd: extract-wordpress

/var/www/html/wp-content/uploads:
  file.directory:
    - makedirs: True
    - require:
      - cmd: cp-wordpress-content

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
      - cmd: cp-wordpress-content

create-wp-config:
  file.managed:
    - name: wp-config.php
    - source: salt://masterless/files/wp-config.php
    - template: jinja
    - user: apache
    - group: apache
    - cwd: /var/www/html
    - require:
      - cmd: cp-wordpress-content

httpd:
  service.running:
    - enable: True
    - order: last
