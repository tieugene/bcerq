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

## 1. PostgrSQL

### 1.1. Install

```
sudo dnf install postgresql postgresql-server
sudo postgresql-setup --initdb
```

### 1.2. Config

/var/lib/data/pg_hba.conf:

```diff
-local all all                peer
+local all all                trust
-host  all all 127.0.0.1/32   ident
+host  all all 127.0.0.1/32   md5
-host  all all ::1/128        ident
+# if you want LAN access
+host  all all 192.168.0.0/24 md5
```

Data dirs (optionaly):

```
sudo mkdir -m0700 /mnt/shares/pgsql
sudo chown postgres:postgres /mnt/shares/pgsql
sudo mv /var/lib/pgsql/{data,backups} /mnt/shares/pgsql/
sudo ln -s /mnt/shares/pgsql/data /var/lib/pgsql/data
sudo ln -s /mnt/shares/pgsql/backups /var/lib/pgsql/backups
```

### 1.3. Start

```
sudo systemctl enable --now postgresql
sudo -i -u postgres psql -c "\password <adminpassword>"
```

#### _check:_

```telnet localhost 5432```

### 1.4. Create DB

```
psql -U postgres
CREATE USER $BTCUSER;
ALTER USER $BTCUSER WITH ENCRYPTED PASSWORD '$BTCPASS';
CREATE DATABASE $BTCDB;
GRANT ALL PRIVILEGES ON DATABASE $BTCDB TO $BTCUSER;
ALTER DATABASE $BTCDB OWNER TO $BTCUSER;
\q
```

or (not tested)

```
sudo createuser -U postgres -w $BTCUSER
sudo -u postgres createdb -O "$BTCUSER" $BTCDB
```

#### _check:_

```
psql $BTCDB $BTCUSER
\q
```

~/.pgpass:

```localhost:5433:$BTCDB:$BTCUSER:$BTCPASS```

### 1.5. Misc

Check databases and users:

```
psql -U postgres [-W]
SELECT * FROM pg_user;
SELECT * FROM pg_database;
```

drop db:

```
sudo -i -u postgres psql
dropdn $BTCDB
dropuser $BTCUSER
```

RTFM:
[1](https://linux-notes.org/ustanovka-postgresql-centos-red-hat-fedora/)
[2](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-18-04-ru)
[3](http://r00ssyp.blogspot.com/2017/03/postgresql-9.html)

## 2. MariaDB

### 2.1. Install

### 2.2. Config

### 2.3. Start

### 2.4. Create DB

## SQLite

Nothing to do.