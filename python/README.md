# Python program

## Preparation

Go into directory with python files.
Execute following commands there:
```
python3 -m venv acra_env
source acra_env/bin/activate
pip install -U pip
pip install -r ./requirements.txt
apt install libpq-dev
```
!!!! BE SURE THAT WHEN YOU ARE TRYING TO RUN PYTHON COMMAND, YOU ARE RUNNING ACTIVE `acra_env` !!!!
OR
!!!! INSTALL EVERY DEPENDENCY WITHOUT `acra_env` AND TOUCH IT !!!!

`acra_env` is a different python environment with only new packets installed. If you will try run the same command in and out of this envionment you will have missing dependency errors!

### If there is a problem with Themis/Pythemis
Look into `./install_themis_ubuntu.sh` file.
Here is a listing of commands to run to install pythemis/themis correctly:
```
wget -qO - https://pkgs-ce.cossacklabs.com/gpg | sudo apt-key add -
sudo apt install apt-transport-https
echo "deb https://pkgs-ce.cossacklabs.com/stable/ubuntu noble main" | \
  sudo tee /etc/apt/sources.list.d/cossacklabs.list
sudo apt update
sudo apt install libthemis-dev
pip install pythemis
```

# Obligatory params to run program with
Please, notice that you need to give path to `acra-client` certificates and one root (CA) certificate:
`--tls_root_cert /YOUR_PATH/acra-engineering-demo/_common/ssl/ca/ca.crt --tls_key /YOUR_PATH/acra-engineering-demo/_common/ssl/acra-client/acra-client.key --tls_cert /YOUR_PATH/acra-engineering-demo/_common/ssl/acra-client/acra-client.crt`
Please, notice that you need to set the domain name of the service and not the IP address:
`--host localhost` OR `--host acra-server` OR `--host mysql`

# Run Mysql Reader With Acra
```
python3 ./extended_example.py --db_name test --db_user test --db_password test --port 9393 --host localhost --mysql --tls_root_cert /YOUR_PATH/acra-engineering-demo/_common/ssl/ca/ca.crt --tls_key /YOUR_PATH/acra-engineering-demo/_common/ssl/acra-client/acra-client.key --tls_cert /YOUR_PATH/acra-engineering-demo/_common/ssl/acra-client/acra-client.crt --print
```

# Run Mysql Reader Plain MySQL
```
python3 ./extended_example.py --db_name test --db_user test --db_password test --port 3306 --host localhost --mysql --tls_root_cert /YOUR_PATH/acra-engineering-demo/_common/ssl/ca/ca.crt --tls_key /YOUR_PATH/acra-engineering-demo/_common/ssl/acra-client/acra-client.key --tls_cert /YOUR_PATH/acra-engineering-demo/_common/ssl/acra-client/acra-client.crt --print
```

# Run Mysql Writer With Acra
```
python3 ./extended_example.py --db_name test --db_user test --db_password test --port 9393 --host localhost --mysql --tls_root_cert /YOUR_PATH/acra-engineering-demo/_common/ssl/ca/ca.crt --tls_key /YOUR_PATH/acra-engineering-demo/_common/ssl/acra-client/acra-client.key --tls_cert /YOUR_PATH/acra-engineering-demo/_common/ssl/acra-client/acra-client.crt --data=./extended_example_data.json
```

# How to switch Acra to work with Postgresql
To switch the demo to use PostgreSQL change `mysql_enable` to `false`, `db_host` to `postgresql` and `db_port` to `5432` in `/YOUR_PATH/acra-engineering-demo/python-mysql-postgresql/acra-server-config/acra-server.yaml`

Restart `acra-server` to use updated config:

`docker restart python-mysql-postgresql-acra-server-1`

Link to [Acra's demo repo](https://github.com/cossacklabs/acra-engineering-demo/tree/master/python-mysql-postgresql#readme)

# How to change Acra's Encryption settings?
Write your own `encryptor_config.yaml` and place it there: `/YOUR_PATH/acra-engineering-demo/acra/examples/python/extended_example_encryptor_config.yaml` OR change the config filename in `/YOUR_PATH/acra-engineering-demo/python-mysql-postgresql/docker-compose.python-mysql-postgresql.yml` or `short_deploy.yaml` 

## The easiest suggestion
In `encryptor_config.yaml` add another table. Enumerate all column names under `columns` parameter. Enumerate those columns under `encrypted` field:
```
- table: new_table
  columns:
    - id
    - text1
    - text2
    - num1
    - num2
    - total_data
  encrypted:
    - column: text1
    - column: num1
    - column: total_data
```
In that example we decided to encrypt `text1`, `num1` and `total_data` fields. All other fields will remain untouched. [You can read more about different encryption methods in Acra here](https://docs.cossacklabs.com/acra/security-controls/encryption/)