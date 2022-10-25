
# PostgreSQL


## centos8
https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-centos-8

```bash
# installation
cpm postgresql:setup --version=13


# Setup the database
cpm postgresql:setup

# Create user
cpm postgresql:createuser --db-user=gitlab --db-password=gitlab123
cpm postgresql:createdb --db-name=gitlab --db-user=gitlab

```