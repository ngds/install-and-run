# Setting Up Your NGDS Node

1. NGDS Node Deployment Options
  1. Amazon EC2 Virtual Server *(easiest method)*
  2. Set Up Your Own Server
2. NGDS for Development

## Deployment on an Amazon EC2 Virtual Server

1. Set up an account at [Amazon Web Services](http://aws.amazon.com/ec2/) if you don't already have one. 
  - For pricing see [Amazon EC2 Pricing](http://aws.amazon.com/ec2/pricing/), and if using the recommended settings look under On-Demand Instance Prices for US East (N. Virginia) and the t2.medium instance. Also see Amazon EBS Magnetic volumes under Amazon Elastic Block Store, US East (N. Virginia) for pricing for the recommended 50GB storage.
1. After logging in, navigate to the EC2 page.
1. In the top right corner make sure **US East (N. Virginia)** is selected as the region.
1. In the EC2 Dashboard (on the left), under Images click **AMIs**.
1. Change the Filter to **Public Images**.
1. Search for **NGDS**.
1. Select the AMI found, NGDS CKAN, and then click the **Launch** button.
1. Choose **t2.medium** as the Instance Type in Step 2.
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
1. **Important!** Make sure these steps are completed immediately after launch.
  - At the NGDS landing page click **Sign In**.
  - Login with the default sysadmin account. The user is `admin` and the password is `admin`.
  - In the user settings change the password to something more secure.

## Deployment on Your Own Server

### Prerequisites:
1. CentOS 6.4 x86_64 minimal install. Available [here](http://mirrors.usc.edu/pub/linux/distributions/centos/6.4/isos/x86_64/CentOS-6.4-x86_64-minimal.iso). 50 GB disk space and 4GM RAM are recommended. Keep everything as original as you can. Other versions of CentOS have not been tested. 
  - **Important!** During the installation process, on the page where you give your computer a Hostname, be sure to click the **Configure Network** button in the bottom left corner. Edit the **System eth0** connection and be sure to check **Connect automatically**. Click Apply then close the Network Connections box. This will give you Internet access and allow you to ssh in.
2. Internet access is ready. You should be able to `ping www.yahoo.com` from your CentOS box.
3. Root ssh login is enabled. You should be able to ssh into your CentOS box from your workstation and execute installation commands.
4. Know the IP address of your CentOS box. Issue the command `ip addr`.

### Installation:

To install the NGDS ckan on a CentOS box, run the following commands. For now, use yum.tigbox.com for NGDS-RPM-SERVER::

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

After all the steps please update /etc/ckan/production.ini file. Update "ckan.site_url" variable with correct URL.

**Important!** The default sysadmin password must be changed immediately. Upon the completion of setup login to the web interface with the default user `admin`. The password is `admin`. In the user settings change the password to something more secure.

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
