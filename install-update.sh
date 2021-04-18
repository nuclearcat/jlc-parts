#!/bin/sh
#wget -c https://bitbucket.org/phpliteadmin/public/downloads/phpLiteAdmin_v1-9-8-2.zip
#unzip phpLiteAdmin_v1-9-8-2.zip
#apt install dos2unix
#dos2unix phpliteadmin.config.sample.php
#sed -i "s/'admin'/'admin2'/g" phpliteadmin.config.sample.php
#apt install gnumeric

if ! [ -x "$(command -v ssconvert)" ];
then
    echo "ssconvert from gnumeric not found, you can install in Debian/Ubuntu by:"
    echo "sudo apt-get install gnumeric"
    exit
fi

# Check if file older than 24h
# Cache it for 24h to not make load on JLC servers
if [ ! -f jlc.xls ] || [ "`find jlc.xls -mmin +1440`" ]; then
  echo Updating jlc.xls
  rm jlc.xls
  wget -O jlc.xls https://jlcpcb.com/componentSearch/uploadComponentInfo
fi

if [ ! -d "db" ]; then
    mkdir db
else
    echo Delete old db
    rm db/.jlc.sqlite
fi


echo Convert it to CSV
ssconvert jlc.xls jlc.csv

echo Import CSV
sqlite3 db/.jlc.sqlite < import.sql

echo Convert stock and solder_joint fields to integer for proper sorting
echo ".schema jlc" | sqlite3 db/.jlc.sqlite > .tmp.schema
echo "alter table jlc rename to jlctmp" | sqlite3 db/.jlc.sqlite
sed -i 's/"Stock" TEXT/"Stock" INTEGER/g' .tmp.schema
sed -i 's/"Solder Joint" TEXT/"Solder Joint" INTEGER/g' .tmp.schema
cat .tmp.schema | sqlite3 db/.jlc.sqlite
rm .tmp.schema
echo "INSERT INTO jlc SELECT * FROM jlctmp" | sqlite3 db/.jlc.sqlite
echo "drop table jlctmp" | sqlite3 db/.jlc.sqlite

echo "Optional: delete 0 stock items"
echo "DELETE FROM jlc WHERE Stock=0" | sqlite3 db/.jlc.sqlite

#echo "Ownership (ubuntu specific stuff) if you want to use it on web-server"
#chown -R www-data db

