# DevOps

Este código irá subir toda uma infraestrutura na Amazon AWS contemplando uma Instancia AMI Linux com RDS e ASG, e fará o deploy de uma aplicação em Wordpress na instancia criada.

O código utiliza um script inicial em bash para criar as key-pairs e subir um template do CloudFormation via CLI que irá subir toda a infraestrutura.

No bootstrap da instância, o código irá clonar este repositório, que contém também uma receita SaltStack via masterless que fará o deploy e toda a configuração do sistema.

Para iniciar o processo basta clonar o repositório e executar o script setup-formation.sh.

$ git clone https://github.com/rapha-lima/Wordpress-AWS.git ~/Wordpress-AWS/

$ cd ~/Wordpress-AWS

$ ./setup-formation.sh
