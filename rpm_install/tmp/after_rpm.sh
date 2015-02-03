#!/bin/bash

chkconfig --level 2345 httpd on
chkconfig --level 2345 memcached on
chkconfig --level 2345 crond on
chkconfig --level 2345 redis on
chkconfig --level 2345 tomcat6 on
chkconfig --level 2345 postgresql-9.1 on

setsebool -P httpd_can_network_connect 1
semanage port -a -t http_port_t -p tcp 8800
setsebool -P httpd_tmp_exec on
setsebool -P httpd_execmem=on

initctl reload-configuration
rm -f /etc/httpd/conf.d/welcome.conf


if [ ! -d /var/lib/ckan ];
then
  mkdir /var/lib/ckan
  chown -R apache:apache /var/lib/ckan
fi


if [ ! -f /usr/lib64/libxmlsec1-openssl.so ];
then
     ln -s /usr/lib64/libxmlsec1-openssl.so.1.2.16 /usr/lib64/libxmlsec1-openssl.so
fi


# install geoserver
if [ ! -f /usr/share/tomcat6/webapps/geoserver.war ]; then
  service tomcat6 start
  cd /tmp
  echo "Downloading geoserver 2.5.3 ..."
  curl -LfsOS http://downloads.sourceforge.net/project/geoserver/GeoServer/2.5.3/geoserver-2.5.3-war.zip
  if [ ! -f /tmp/geoserver-2.5.3-war.zip ]; then
    echo "Error: coud not fetch geoserver package."
    echo "geoserver needs to be install manually."
  else
    unzip -o geoserver-2.5.3-war.zip
    cp geoserver.war /usr/share/tomcat6/webapps/

    # wait 2+ min for war file to be deployed
    echo "Deploying geoserver 2.5.3 ..."
    n=0
    ret=0
    until [ $n -ge 30 ]
    do
      sleep 5
      if [ -f /var/lib/tomcat6/webapps/geoserver/data/global.xml ]; then
        ret=1
        break
      fi
      n=$[$n+1]
    done

    if [ $ret -eq 0 ]; then
      echo "ERROR: geoserver deployment failed. It needs to be fixed manually."
      # exit out of geoserver
    else
      service tomcat6 stop
      chown tomcat:tomcat /var/tmp/geoserver.global.xml
      cp -f /var/tmp/geoserver.global.xml /var/lib/tomcat6/webapps/geoserver/data/global.xml
    fi
  fi
fi


# install solr
if [ ! -f /usr/share/tomcat6/webapps/solr.war ]; then
  rm -rf /var/solr
  mkdir -p /var/solr
  cd /var/solr
  tar zxf /var/tmp/ngds.solr.tgz
  cp -f /var/tmp/schema.xml /var/solr/ngds/conf/schema.xml
  chown -R tomcat:tomcat /var/solr/

  service tomcat6 start
  cd /tmp
  echo "Downloading solr 4.2.1 ..."
  curl -LfsOS http://archive.apache.org/dist/lucene/solr/4.2.1/solr-4.2.1.tgz
  if [ ! -f /tmp/solr-4.2.1.tgz ]; then
    echo "Error: coud not download solr package."
    echo "Solr needs to be install manually."
    # exit out of solr
  else
    tar zxf solr-4.2.1.tgz
    cp solr-4.2.1/dist/solr-4.2.1.war /usr/share/tomcat6/webapps/solr.war

    # wait 2+ min for war file to be deployed
    echo "Deploying solr 4.2.1 ..."
    n=0
    ret=0
    until [ $n -ge 30 ]
    do
      sleep 5
      if [ -f /usr/share/tomcat6/webapps/solr/WEB-INF/web.xml ]; then
        ret=1
        break
      fi
      n=$[$n+1]
    done

    if [ $ret -eq 0 ]; then
      echo "ERROR: solr deployment failed. It needs to be fixed manually."
      # exit out of solr
    else
      chown tomcat:tomcat /var/tmp/solr.web.xml
      cp -f /var/tmp/solr.web.xml /usr/share/tomcat6/webapps/solr/WEB-INF/web.xml
      service tomcat6 restart

      echo "Preparing solr core for ngds..."
      solr_url="http://127.0.0.1:8080/solr/"

      # wait 2+ min for war file to be deployed
      n=0
      until [ $n -ge 30 ]; do
        sleep 5
        reponse_code=$(curl --write-out "%{http_code}\n" --silent --output /dev/null "$solr_url")
        if [ "$reponse_code" = "200" ]; then
          core_url="{$solr_url}admin/cores?wt=json&indexInfo=false&action=CREATE&name=ngds&instanceDir=ngds&dataDir=data&config=solrconfig.xml&schema=schema.xml"
          reponse_code=$(curl --write-out "%{http_code}\n" --silent --output /dev/null "$core_url")
          break
        fi
        n=$[$n+1]
      done

      if [ "$reponse_code" = "200" ]; then
        echo "Solr core done."
      else
        echo "ERROR: solr core creation failed. It need to be fixed manually."
      fi
    fi
  fi
fi

# update schema.xml if needed
if [ $(diff /var/tmp/schema.xml /var/solr/ngds/conf/schema.xml | wc -l) -gt 0 ]; then
  service tomcat6 stop
  cp -f /var/tmp/schema.xml /var/solr/ngds/conf/schema.xml
fi

# prepare ckan DB
if [ ! -f /var/lib/pgsql/9.1/data/PG_VERSION ]; then
  service postgresql-9.1 initdb
  service postgresql-9.1 start
  # stop harvester so it does not get in the way of ckan db init.
  supervisorctl stop all

  # allow ckan user to access db
  sed -i '1i host all all 127.0.0.1/32 md5' /var/lib/pgsql/9.1/data/pg_hba.conf

  cd /tmp
  sudo -u postgres psql -c "CREATE USER ckan_default WITH PASSWORD 'pass';"
  sudo -u postgres psql -c "CREATE USER datastore_default WITH PASSWORD 'pass';"

  sudo -u postgres createdb -O ckan_default ckan_default -E utf-8
  sudo -u postgres createdb -O ckan_default datastore_default  -E utf-8
  sudo -u postgres createdb -O ckan_default pycsw -E utf-8
  sudo -u postgres psql datastore_default -f /var/tmp/datastore_permissions.sql

  # install postgis on both ckan_default and datastore_default and pycsw
  sudo -u postgres psql -d ckan_default -f /usr/pgsql-9.1/share/contrib/postgis-1.5/postgis.sql > /dev/null
  sudo -u postgres psql -d ckan_default -f /usr/pgsql-9.1/share/contrib/postgis-1.5/spatial_ref_sys.sql > /dev/null
  sudo -u postgres psql -d ckan_default -c 'GRANT SELECT, UPDATE, INSERT, DELETE ON spatial_ref_sys TO ckan_default' > /dev/null
  sudo -u postgres psql -d ckan_default -c 'GRANT SELECT, UPDATE, INSERT, DELETE ON geometry_columns TO ckan_default' > /dev/null
  sudo -u postgres psql -d datastore_default -f /usr/pgsql-9.1/share/contrib/postgis-1.5/postgis.sql > /dev/null
  sudo -u postgres psql -d datastore_default -f /usr/pgsql-9.1/share/contrib/postgis-1.5/spatial_ref_sys.sql > /dev/null
  sudo -u postgres psql -d datastore_default -c 'GRANT SELECT, UPDATE, INSERT, DELETE ON spatial_ref_sys TO ckan_default' > /dev/null
  sudo -u postgres psql -d datastore_default -c 'GRANT SELECT, UPDATE, INSERT, DELETE ON geometry_columns TO ckan_default' > /dev/null
  sudo -u postgres psql -d pycsw -f /usr/pgsql-9.1/share/contrib/postgis-1.5/postgis.sql > /dev/null
  sudo -u postgres psql -d pycsw -f /usr/pgsql-9.1/share/contrib/postgis-1.5/spatial_ref_sys.sql > /dev/null
  sudo -u postgres psql -d pycsw -c 'GRANT SELECT, UPDATE, INSERT, DELETE ON spatial_ref_sys TO ckan_default' > /dev/null
  sudo -u postgres psql -d pycsw -c 'GRANT SELECT, UPDATE, INSERT, DELETE ON geometry_columns TO ckan_default' > /dev/null


  sudo -u postgres psql postgres postgres -c "select pg_reload_conf();" > /dev/null

  ckan db init
  ckan --plugin=ckanext-spatial spatial initdb

  cd /usr/lib/ckan/src/ckanext-spatial
  ../../bin/paster --plugin=ckanext-spatial ckan-pycsw setup -p /etc/ckan/pycsw.cfg
  cd /tmp

  ckan user add admin password=admin email=admin@domain.local
  ckan sysadmin add admin
fi


# open port 80
if [ $(iptables -L -n | grep :80 | wc -l )  -eq 0 ]; then
  service iptables start
  iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
  service iptables save
fi


service tomcat6 start
service memcached start
service httpd restart
initctl start supervisor
service redis restart
service crond restart
supervisorctl restart all