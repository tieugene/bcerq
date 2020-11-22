# PostgrSQL

- distro: Fedora 32
- db name: $BTCDB
- db user: $BTCUSER
- db password: $BTCPASS

## 1. Prepare PostgreSQL

### 1.1. install server and client

```
sudo dnf install postgres postgresql-server
sudo postgresql-setup --initdb
```

### 1.2. tune server

- /var/lib/data/pg_hba.conf:

```
-local   all             all                                     peer
+local   all             all                                     trust
-host    all             all             127.0.0.1/32            ident
+host    all             all             127.0.0.1/32            md5
-host    all             all             ::1/128                 ident
```

- data dirs (optionaly):

```
sudo mkdir -m0700 /mnt/shares/pgsql
sudo chown postgres:postgres /mnt/shares/pgsql
sudo mv /var/lib/pgsql/{data,backups} /mnt/shares/pgsql/
sudo ln -s /mnt/shares/pgsql/data /var/lib/pgsql/data
sudo ln -s /mnt/shares/pgsql/backups /var/lib/pgsql/backups
```

### 1.3. go

```
sudo systemctl enable --now postgresql
sudo -i -u postgres psql -c "\password <superpassword>"
```


## 2. Prepare DB

```
psql -U postgres
CREATE USER $BTCUSER;
ALTER USER $BTCUSER WITH ENCRYPTED PASSWORD 'btcpassword';
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

- check:

```
psql $BTCDB $BTCUSER
\q
```

- ~/.pgpass:


```
localhost:5433:*:$BTCUSER:$BTCPASS
```

## Misc

- Check databases and users:

	```
	psql -U postgres [-W]
	SELECT * FROM pg_user;
	SELECT * FROM pg_database;
	```

- drop db:

	```
	sudo -i -u postgres psql
	dropdn $BTCDB
	dropuser $BTCUSER
	```

- reindex PKs etc:

	```
	for t in blocks transactions addresses data; do psql -q -c "REINDEX TABLE $t;" $BTCDB $BTCUSER; done
	```

- updates:

	```
	(echo "BEGIN;"; unpigz -c 0xx.vin.gz; echo "COMMIT;") | psql -q $BTCDB $BTCUSER
	```

## RTFM
* [RTFM #1](https://linux-notes.org/ustanovka-postgresql-centos-red-hat-fedora/)
* [RTFM #2](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-18-04-ru)
* [RTFM #3](http://r00ssyp.blogspot.com/2017/03/postgresql-9.html)
