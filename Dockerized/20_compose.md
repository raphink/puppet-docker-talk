!SLIDE
## Docker Compose — Volumes


* Code (git + checkout)
* PostgreSQL (when the database is a container)

```yaml
volumes:
  datacode: {}
  datagit: {}
  datar10kcache: {}
  datapostgresql: {}
```


!SLIDE
## Docker Compose — Puppet Master

```yaml
---
version: "2"
services:
  puppetmaster:
    image: 'camptocamp/puppetserver:2.7.2-5'
    environment:
      JAVA_ARGS: '-Xmx2g -Xms2g -XX:MaxPermSize=256m -XX:OnOutOfMemoryError="kill -9 %p" -Djava.security.egd=/dev/urandom'
      AUTOSIGN_PSK: 'HelloGhent'
    hostname: 'master.c2c'
    ports:
      - '8140:8140'
    volumes:
      - './puppetca:/etc/puppetlabs/puppet/ssl'
    volumes_from:
      - 'r10k'
```


!SLIDE
## Docker Compose — R10k
  
```yaml
  r10k:
    image: 'camptocamp/r10k-githook:2.5.2-3'
    ports:
      - '2222:22'
    volumes:
      - 'datacode:/etc/puppetlabs/code/environments/'
      - 'datagit:/srv/puppetmaster.git/'
      - 'datar10kcache:/opt/puppetlabs/r10k/cache/'
      - './authorized_keys:/opt/puppetlabs/r10k/.ssh/authorized_keys:ro'


  # Optional, browse code
  cgit:
    image: 'oems/cgit'
    ports:
      - '8022:80'
    volumes:
      - 'datagit:/mnt/git/puppetmaster.git:ro'
```


!SLIDE
## Docker Compose — PuppetDB
  
```yaml
  postgresql:
    image: 'postgres:9.4'
    environment:
      POSTGRES_USER: 'puppetdb'
      POSTGRES_PASSWORD: 'puppetdb'
    volumes:
      - 'datapostgresql:/var/lib/postgresql/data/'
  
  puppetdb:
    image: 'camptocamp/puppetdb:4.3.2-1'
    environment:
      ENABLE_HTTP: 'true'
      JAVA_ARGS: '-Xmx512m -Xms512m -XX:OnOutOfMemoryError="kill -9 %p" -Djava.security.egd=/dev/urandom'
    links:
      - 'postgresql'
    volumes:
      - './puppetca/certs/ca.pem:/etc/puppetlabs/puppetdb/ssl/ca.pem:ro'
      - './puppetca/private_keys/puppetdb.pem:/etc/puppetlabs/puppetdb/ssl/private.pem'
      - './puppetca/certs/puppetdb.pem:/etc/puppetlabs/puppetdb/ssl/public.pem'
```


!SLIDE
## Docker Compose — Puppetboard
  

```yaml
  puppetboard:
    image: 'camptocamp/puppetboard:0.2.2-gitdf91583-1'
    environment:
      PUPPETBOARD_SETTINGS: "/app/settings.py"
    command: '--mount-point / wsgi.py'
    ports:
      - '80:80'
```
