# Setting Up Your NGDS Node

1. NGDS Node Deployment Options
  1. Amazon EC2 Virtual Server *(easiest method)*
  2. Set Up Your Own Server
2. NGDS for Development
3. Post Deployment

## Deployment on an Amazon EC2 Virtual Server

1. Set up an account at [Amazon Web Services](http://aws.amazon.com/ec2/) if you don't already have one. 
  - For pricing see [Amazon EC2 Pricing](http://aws.amazon.com/ec2/pricing/), and if using the recommended settings look under On-Demand Instance Prices for US East (N. Virginia) and the t2.medium instance. Also see Amazon EBS Magnetic volumes under Amazon Elastic Block Store, US East (N. Virginia) for pricing for the recommended 50GB storage.
1. After logging in, navigate to the EC2 page.
1. In the top right corner make sure **US East (N. Virginia)** is selected as the region.
1. Click on **Launch Instance**.
1. Select **AWS Marketplace**.
1. Search for **CentOS 6.4 (x86_64) - Release Media** and the click **Select**.
1. Choose **m3.medium (or higher)** as the Instance Type in Step 2.
1. Click the button at the bottom **Next: Configure Instance Details**.
1. Don't make any changes and click the **Next: Add Storage** button.
1. Modify the **Size** of the Root to at least **50GB**.
1. Change the **Volume Type** to **Magnetic**.
1. Click the **Next: Tag Instance** button.
1. No changes are needed here so click the **Next: Configure Security Group** button.
1. Select Create a new security group and name it **ngds**.
1. Click the **Add Rule** button and select **HTTP** as the type.
1. There should now be 2 security rules. The default SSH with port 22 open and HTTP with port 80 open. Click the **Review and Launch** button.
1. In the pop-up message select **Continue with Magnetic as the boot volume for this instance**.
1. Ignore the warnings about the instance's security and being ineligible for the free usage tier. Click the **Launch** button.
1. Create a new key pair and name it **ngds**. **Download** the key pair. Do not lose this downloaded file, called **ngds.pem**. This is needed if you ever want to ssh into your instance.
1. Click the **Launch Instances** button.
1. On the Launch Status page click the **View Instances** button to see a list of your instances.
1. Note the IP address in the **Public IP** column for this new instance. Once the launch has completed (it will take several minutes) you will be able to see your node at this IP address in any web browser.
1. Extending a Linux File System
  - In Linux, you use a file system-specific command to resize the file system to the larger size of the new volume. This command works even if the volume you wish to extend is the root volume. For ext2, ext3, and ext4 file systems, this command is resize2fs. For XFS file systems, this command is xfs_growfs. For other file systems, refer to the specific documentation for those file systems for instructions on extending them.
  - If you are unsure of which file system you are using, you can use the file -s command to list the file system data for a device.
  - The following example shows a Linux ext4 file system and an SGI XFS file system:
  
    [ec2-user ~]$ sudo file -s /dev/xvd*  
    /dev/xvda1: Linux rev 1.0 ext4 filesystem data ...  
    /dev/xvdf:  SGI XFS filesystem data ... 

1. **Important!** Make sure these steps are completed immediately after launch.
  - At the NGDS landing page click **Sign In**.
  - Login with the default sysadmin account. The user is `admin` and the password is `admin`.
  - In the user settings change the password to something more secure.

## Deployment on Your Own Server

### Prerequisites:
1. CentOS 6.6 x86_64 minimal install. 50 GB disk space and 4GM RAM are recommended. Keep everything as original as you can. Other versions of CentOS have not been tested. 
  - **Important!** During the installation process, on the page where you give your computer a Hostname, be sure to click the **Configure Network** button in the bottom left corner. Edit the **System eth0** connection and be sure to check **Connect automatically**. Click Apply then close the Network Connections box. This will give you Internet access and allow you to ssh in.
2. Internet access is ready. You should be able to `ping www.yahoo.com` from your CentOS box.
3. Root ssh login is enabled. You should be able to ssh into your CentOS box from your workstation and execute installation commands.
4. Know the IP address of your CentOS box. Issue the command `ip addr`.

### Installation:

To install the NGDS ckan on a CentOS box, run the following commands. For now, use packages.reisys.com for NGDS-RPM-SERVER:

    yum update -y ca-certificates

    cd /etc/yum.repos.d/
    curl -fsLOS http://packages.reisys.com/ckan/ngds/libxml2.repo
    curl -fsLOS http://packages.reisys.com/ckan/ngds/ngds.repo

    rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
    rpm -Uvh http://yum.postgresql.org/9.1/redhat/rhel-6.3-x86_64/pgdg-centos91-9.1-4.noarch.rpm
    rpm -Uvh http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm

    yum install -y libxml2-2.9.0 gdal-1.9.2 gdal-python-1.9.2 gdal-devel-1.9.2 yum-utils
    yum-config-manager --disable pgdg93
    yum install ngds.ckan

After all steps completed, you should be able to access the NGDS ckan application via http://CENTOS-IP-ADDRESS/.

After all the steps please update two config files. Update "ckan.hostname" & "ngds.aggregator_url" (no trailing slash) variables with correct URLs in file /etc/ckan/production.ini, and update proxyBaseUrl in file /var/lib/tomcat6/webapps/geoserver/data/global.xml, replacing 127.0.0.1 with correct URL. Restart server after update.

**Important!** The default sysadmin password must be changed immediately. Upon the completion of setup login to the web interface with the default user `admin`. The password is `admin`. In the user settings change the password to something more secure.

## [ For developer to build rpm via ansible script ]

For NGDS developers, when new code changes are ready on github repository, you can integrate the changes from git into rpm package and release a new rpm version to end users. The rpm building process can be done directly on officical NGDS-RPM-SERVER server, or done on a local CentOS 6.6 x86_64 box as rpm build server, then transfer the rpm files to NGDS-RPM-SERVER. To prepare the CentOS box ready for the rpm building, here are the steps:

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

## Post Deployment

### Access server via SSH

If you're on Windows you can follow the directions below to set up the PuTTY SSH client.

1. Download putty.exe from here. Also download puttygen.exe.
1. The ngds.pem key pair that was downloaded previously needs to be converted to a Putty key. To do this:
1. Run puttygen.exe.
1. Click Load.
1. In the dropdown menu on the bottom right select All Files (*.*), select the ngds.pem key, and press Open.
1. Click the button Save private key and yes in the popup menu.
1. Name your key ngds.ppk and Save.
1. Close the PuTTY Key Generator.
1. Run putty.exe.
1. For Host Name (or IP address) enter the the Public IP of your Amazon instance.
1. In the window on the left, under Connection - SSH - Auth and Private key file for authentication add the ngds.ppk key you created.
1. Click Open and click yes for the PuTTY Security Alert.
1. Login as root 

### Updating NGDS

When NGDS releases new rpm, you can upgrade exisitng NGDS ckan application with the following command:

    yum update ngds.ckan

Go to folder /etc/ckan, and check for file `production.ini.rpmnew`. If the file is present, you will need to replace file `production.ini` with this rpmnew file, and make appropriate config changes that you have previouly done. After done, delete `production.ini.rpmnew`. Restart server.

**Notice for updating from rpm versions prior to version 300:**
The installation steps have changed. Follow the instruction and update the two config files (`/etc/ckan/production.ini` and `/var/lib/tomcat6/webapps/geoserver/data/global.xml`) as mentioned above. If there is no `<proxyBaseUrl>` tag at the top of the file global.xml, you will need to get the new file from /var/tmp/geoserver.global.xml and move it to /var/lib/tomcat6/webapps/geoserver/data/global.xml. Also make sure file permission is right by doing `chown tomcat:tomcat /var/lib/tomcat6/webapps/geoserver/data/global.xml`. Some manual database changes need to done if you come from rpm 300 and before:

    cd /tmp
    sudo -u postgres createdb -O ckan_default pycsw -E utf-8

    sudo -u postgres psql -d datastore_default -f /usr/pgsql-9.1/share/contrib/postgis-1.5/postgis.sql > /dev/null
    sudo -u postgres psql -d datastore_default -f /usr/pgsql-9.1/share/contrib/postgis-1.5/spatial_ref_sys.sql > /dev/null
    sudo -u postgres psql -d datastore_default -c 'GRANT SELECT, UPDATE, INSERT, DELETE ON spatial_ref_sys TO ckan_default' > /dev/null
    sudo -u postgres psql -d datastore_default -c 'GRANT SELECT, UPDATE, INSERT, DELETE ON geometry_columns TO ckan_default' > /dev/null
    sudo -u postgres psql -d pycsw -f /usr/pgsql-9.1/share/contrib/postgis-1.5/postgis.sql > /dev/null
    sudo -u postgres psql -d pycsw -f /usr/pgsql-9.1/share/contrib/postgis-1.5/spatial_ref_sys.sql > /dev/null
    sudo -u postgres psql -d pycsw -c 'GRANT SELECT, UPDATE, INSERT, DELETE ON spatial_ref_sys TO ckan_default' > /dev/null
    sudo -u postgres psql -d pycsw -c 'GRANT SELECT, UPDATE, INSERT, DELETE ON geometry_columns TO ckan_default' > /dev/null


    cd /usr/lib/ckan/src/ckanext-spatial
    ../../bin/paster --plugin=ckanext-spatial ckan-pycsw setup -p /etc/ckan/pycsw.cfg

Restart server after done.

### Sysadmin

  A sysadmin will be created automatically but the manual way to do it would have been:

    ckan sysadmin add <username>
    
### Restarting Apache

    /etc/init.d/httpd restart
### Troubleshooting
####Datapusher fails to push data to the datastore
#####Possible Error messages:
  
  1. `ConnectionError(ProtocolError('Connection aborted.', error(110, 'Connection timed out')))`
  1. `could not post to result_url`
  
#####Possible resolutions:

  1. Make sure that the datapusher service is on and apache is listening on port 8800
  i.e. `curl 0.0.0.0:8800`
  1. Make sure that datapusher can push data to the datastore.
  i.e. `curl {public_ip_address or hostname}`

#####More information on how datapusher & datastore work together can be found here: 

https://github.com/ckan/datapusher/issues/18

####Can't install RPM
#####Possible Error message:

`Cannot retrieve metalink for repository: epel. Please verify its path and try again`

#####Possible resolutions: 

Run `yum upgrade ca-certificates --disablerepo=epel`  
  
####After CentOS server is moved, the server stops responding  
   
If you have a Centos virtual machine installed in Hyper-V and think that you might clone or move the virtual machine in the future, you should set a static MAC address on the virtual network card.  Otherwise the Centos OS will add a new network  card if the virtual machine is cloned or moved to another Hyper-V server and the network will stop functioning. 

