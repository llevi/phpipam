# docker-phpipam

phpIPAM is an open-source web IP address management application. Its goal is to provide light and simple IP address management application.

phpIPAM is developed and maintained by Miha Petkovsek, released under the GPL v3 license, project source is [here](https://github.com/phpipam/phpipam)

Learn more on [phpIPAM homepage](http://phpipam.net)

![phpIPAM logo](http://phpipam.net/wp-content/uploads/2014/12/phpipam_logo_small.png)

## How to use this Docker image

### Phpipam 

```bash
$ docker run -ti -d -p 8080:80 --name ipam \
		-e MYSQL_ENV_MYSQL_HOST=mysql \
		-e MYSQL_ENV_MYSQL_USER=phpipam \
		-e MYSQL_ENV_MYSQL_PASS=phpipam \
		-e MYSQL_ENV_MYSQL_NAME=phpipam \
		-e MYSQL_ENV_MYSQL_PORT=3306 \
		rkojedzinszky/phpipam
```

We are linking the two containers and expose the HTTP port. 

### Specific integration (HTTPS, multi-host containers, etc.)

Regarding your requirements and docker setup, you've to expose resources. 

For HTTPS, run a reverse-proxy in front of your phpipam container and link it to. 

For multi-host containers, expose ports, run etcd or consul to make service discovery works etc. 

### Configuration 

* First you should create the mysql db on the specified mysql server:
```
mysql> create database phpipam;
```
* Then grant permissions to it:
```
mysql> grant all on phpipam.* to phpipam identified by 'phpipam';
```
* Browse to `http://<ip>[:<specific_port>]/`
* Choose 'Automatic database installation'
* Re-Enter connection information
* On advanced settings, uncheck the create db and grant permissions checkboxes.
* Configure the admin user password
* You're done !
