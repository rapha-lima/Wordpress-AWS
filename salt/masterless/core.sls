install-pkgs:
  pkg.installed:
    - names:
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
  cmd.run
disable-selinux:
  file.replace:
    - names:
      - /etc/sysconfig/selinux
      - /etc/selinux/config
    - pattern: 'SELINUX=.*'
    - repl: SELINUX=permissive

time_zone_7:
  cmd.run:
    - name:  timedatectl set-timezone America/Sao_Paulo
