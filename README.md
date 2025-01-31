# goit-pnc-hw-09
Cryptographic protection of databases on the example of MySQL and Acra

## How to deploy
Clone repo and go inside
```
git clone git@github.com:yevhenmazur/goit-pnc-hw-09.git
cd ./goit-pnc-hw-09
```

Use the script to generate SSL certificates and Acra master-key
```
./auxiliary/ssl_gen.sh
```

Bulid an run the project
```
docker compose up --build
```

## How to use
Deploy TestDB1
```
mysql -hlocalhost -u test-user -p -P3306 --ssl --database=TestDB1 < ./test-data/TetsDB1.sql
```

Deploy TestDB2
```
docker exec goit-pnc-hw-09-python-1 python /app/main.py --db_name TestDB2 --port 9393 --import_dump /app.test-data/TestDB2.sql
```

Get decrypted data from TestDB2
```
docker exec goit-pnc-hw-09-python-1 python /app/main.py --db_name TestDB2 --port 9393 --print
```

