## [ For end-user to deploy NGDS ckan application via rpm ]

To install the NGDS ckan on a CentOS box, start with a CentOS 6.4 x86_64 minimal download. Keep everything as original as you can, then run the following commands:

    yum update -y ca-certificates

    cd /etc/yum.repos.d/
    curl -fsLOS http://NGDS-RPM-SERVER/libxml2.repo
    curl -fsLOS http://NGDS-RPM-SERVER/ngds.repo

    rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
    rpm -Uvh http://yum.postgresql.org/9.1/redhat/rhel-6.3-x86_64/pgdg-centos91-9.1-4.noarch.rpm
    rpm -Uvh http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm

    yum install -y libxml2-2.9.0 gdal-1.9.2 gdal-python-1.9.2 gdal-devel-1.9.2 yum-utils
    yum-config-manager --disable pgdg93
    yum install ngds.ckan

After all steps completed, you should be able to access the NGDS ckan application via http://CENTOS-IP-ADDRESS/.

### Optional post installation:

To add a sysadmin user, register an account on the web gui, then run the following commands to promote it to sysadmin.

    ckan sysadmin add <username>

To enable harvester, uncomment the cron job at `/etc/cron.d/ckan-harvest`

### Updating existing NGDS application:

When NGDS releases new rpm, you can upgrade exisitng NGDS ckan application with the following command:

    yum install ngds.ckan

## [ For developer to build rpm via ansible script ]

For NGDS developers, when new code changes are ready on github repository, you can integrate the changes from git into rpm package and release a new rpm version to end users. The rpm building process can be done directly on officical NGDS-RPM-SERVER server, or done on a local CentOS 6.4 x86_64 box as rpm build server, then transfer the rpm files to NGDS-RPM-SERVER. To prepare the CentOS box ready for the rpm building, here are the steps:

    yum update -y ca-certificates

    cd /etc/yum.repos.d/
    curl -fsLOS http://NGDS-RPM-SERVER/libxml2.repo

    rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
    rpm -Uvh http://yum.postgresql.org/9.1/redhat/rhel-6.3-x86_64/pgdg-centos91-9.1-4.noarch.rpm
    rpm -Uvh http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm

    yum install -y libxml2-2.9.0 libxml2-devel-2.9.0 libxml2-python-2.9.0 gdal-1.9.2 gdal-python-1.9.2 gdal-devel-1.9.2 yum-utils
    yum-config-manager --disable pgdg93

To build rpm, you need to install ansible client on your workstation, add a ansible hosts file pointing to the ip address of the CentOS rpm build server, then run the ansible script:

    ansible-playbook -i hosts ngds-buildserver.yml

When done, the new rpm package will at http://CENTOS-RPM-SERVER/ngds-repo/.