# DBS
DataBase Server installation.

- [PosgreSQL](#postgresql)
- [MariaDB](#mariadb)
- [SQLite](#sqlite)

Prerequisitions:

- distro: Fedora 33
- [DBA](https://en.wikipedia.org/wiki/Database_administrator) password: _$DBAPASSWORD_
- DB name: _$BTCDB_
- DB user: _$BTCUSER_
- DB password: _$BTCPASS_
- DB location: /mnt/shares/_dbsname_/

**TODO**: [read-only account](https://habr.com/ru/post/531090/)

## 1. PostgrSQL

### 1.1. Install (client and server)

```sudo dnf install postgresql-server```

_Note: `postgresql` installing by dependencies_.

### 1.2. Config server

- Init data:

```sudo -u postgres postgresql-setup --initdb```

- /var/lib/data/pg_hba.conf:

```diff
 # "local" is for Unix domain socket connections only
-local all all                peer
+local all all                trust
 # IPv4 local connections:
-host  all all 127.0.0.1/32   ident
+host  all all 127.0.0.1/32   md5
+# IPv4 LAN connections:
+host  all all 192.168.0.0/24 md5
+# or IPv4 LAN/WAN connections:
+# host  all all 0.0.0.0/0 md5
 # IPv6 local connections:
-host  all all ::1/128        ident
```

- /var/lib/data/postresql.conf:

```diff
-#listen_addresses = 'localhost'
+listen_addresses = '*'
-shared_buffers = 128MB
+shared_buffers = 8192MB #(1/4 RAM)
```


- Move data to external storage (option):

```bash
sudo mkdir /mnt/shares/pgsql
sudo chown postgres:postgres /mnt/shares/pgsql
sudo mv /var/lib/pgsql/{data,backups} /mnt/shares/pgsql/
sudo ln -s /mnt/shares/pgsql/data /var/lib/pgsql/data
sudo ln -s /mnt/shares/pgsql/backups /var/lib/pgsql/backups
```

### 1.3. Start server

```sudo systemctl enable --now postgresql```

#### _check:_

```telnet localhost 5432```

### 1.4. Create user and DB

```
sudo -u postgres createuser -U postgres -w $BTCUSER -P $BTCPASS
sudo -u postgres createdb -O "$BTCUSER" $BTCDB
```

or (long version):

```
psql -U postgres
CREATE USER $BTCUSER;
ALTER USER $BTCUSER WITH ENCRYPTED PASSWORD '$BTCPASS';
CREATE DATABASE $BTCDB;
GRANT ALL PRIVILEGES ON DATABASE $BTCDB TO $BTCUSER;
ALTER DATABASE $BTCDB OWNER TO $BTCUSER;
\q
```

### 1.5 Config client

- ~/.pgpass:

```localhost:5433:$BTCDB:$BTCUSER:$BTCPASS```

#### _check:_

```bash
pg_isready -d $BTCDB -U $BTCUSER
psql $BTCDB $BTCUSER
\q
```

### 1.x. Misc

- Check databases and users:

```psql -U postgres -c "SELECT * FROM pg_user;SELECT * FROM pg_database;"```

- RTFM:
[1](https://linux-notes.org/ustanovka-postgresql-centos-red-hat-fedora/)
[2](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-18-04-ru)
[3](http://r00ssyp.blogspot.com/2017/03/postgresql-9.html)

## 2. MariaDB

### 2.1. Install

```sudo dnf install mariadb-server```

_Note: `mariadb ` installing by dependencies_.

### 2.2. Config

- Create extra data dir:

```
mkdir /mnt/shares/mysql
chown mysql:mysql /mnt/shares/mysql
```

/etc/my.cnf.d/mariadb-server.cnf:

```diff
 [mysqld]
-datadir=/var/lib/mysql
+datadir=/mnt/shares/mysql
+default_storage_engine=MyISAM
+# do 'SELECT @@sql_mode;' before next set
+sql_mode="STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION,NO_AUTO_VALUE_ON_ZERO"
```

TODO: default-storage-engine = MyISAM
TODO: enable LAN/WAN access

### 2.3. Start server

```sudo systemctl enable --now mariadb```

#### _check_:

````telnet localhost 3306```

### 2.4. Create user and DB

```
sudo mysql -u <root> -p
# or 'sudo -u mysql mysql`
CREATE USER $BTCUSER IDENTIFIED BY '$BTCPASS';
CREATE USER $BTCUSER@localhost IDENTIFIED BY '$BTCPASS';
CREATE DATABASE $BTCDB CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON $BTCDB.* TO $BTCUSER;
GRANT ALL PRIVILEGES ON $BTCDB.* TO $BTCUSER@localhost;
FLUSH PRIVILEGES;
```

#### _check_:

```mysql [-h <ext_ip> -u $BTCUSER -p$BTCPASS $BTCDB```

### 2.5 Config client

- ~/.my.cnf:

```
[client]
host = $BTCHOST
user = $BTCUSER
password = $BTCPASS
```

#### _check:_

```bash
mariadb-check $BTCDB
mysql $BTCDB
^D
```

### 2.x. misc

```
-- show all databases;
SHOW DATABASES;
-- show registered users
SELECT User,Host,Password FROM mysql.user;
-- show tables[ of current db]
SHOW TABLES [FROM <db>];
-- show privileges in db

```

[Example](https://computingforgeeks.com/how-to-install-glpi-on-centos-fedora/):

```
$ mysql -u root -p

CREATE USER 'glpi'@'%' IDENTIFIED BY 'glpiDBSecret';
GRANT USAGE ON *.* TO 'glpi'@'%' IDENTIFIED BY 'glpiDBSecret';
CREATE DATABASE IF NOT EXISTS `glpi` ;
GRANT ALL PRIVILEGES ON `glpi`.* TO 'glpi'@'%';
FLUSH PRIVILEGES;
EXIT
```

- mariadb-access
- mariadb-check
- mariadb-admin


## SQLite

Nothing to do.
