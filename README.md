install-and-run
===============

Use this repository's issue tracker to post comments, bug reports, and help questions on installing and running NGDS CKAN.

### Low Level Installer Script Documentation

### Introduction

This documentation is written for seasoned linux users.

[Here's the installer script you'll be running](https://github.com/ngds/ckanext-ngds/blob/master/installation/install-ngds.sh)

As of 2/6/2014, [ckanext-ngds](https://github.com/ngds/ckanext-ngds) is in a beta production mode.  We're shooting for releasing v1.0 in April 2014.  The installer script will install the latest stable version of ckanext-ngds along with core CKAN and every other software dependency it needs to run in production except for a Java SDK.  Currently, the stable version of ckanext-ngds is written to run with core CKAN v2.0.1.  We have development branches in the ckanext-ngds Github repository which we use to keep this software up-to-date with the latest stable releases of core CKAN and these branches follow this naming convention:
`upgrade-ckanvX.X.X` where `X.X.X` refers to a core CKAN release version.  These development branches do not contain stable code and will usually be merged into the master branch once they are stable.

### Installation

Installation with the installer script has only been tested in Ubuntu v12.04 LTS, Xubuntu v12.04, Ubuntu v12.10 and Xubuntu v12.10.  All of this software has been tested on MacOSX as well, but we don't have an installation script for that -- so you'll have to install all of the components manually.  

Setup your environment (assumes starting as user `root`. If you created your system with `ngds` as your main user, you may skip the first 3 steps below.):

    $ adduser ngds
    $ adduser ngds sudo
    $ su -l ngds

Download NGDS:

    $ cd ~
    $ mkdir tmp
    $ cd tmp
    $ git clone https://github.com/ngds/ckanext-ngds.git
    $ cd ckanext-ngds/installation

Set custom parameters in the installer script:

    site_url
    SERVER_NAME
    SMTP_SERVER
    SMTP_STARTTLS
    SMTP_USER
    SMTP_PASSWORD
    GEOSERVER_REST_URL

Run the installer script:

    $ sudo ./install-ngds.sh (this will take a long time) 

NGDS should be being served at http://127.0.0.1/
Login: {username: admin, password: admin}

If you find that upon visiting http://127.0.0.1/ (or http://<SERVER_NAME>) instead of NGDS you get the generic Apache "It's working page", run this command: `sudo a2dissite default`.

Go to http://127.0.0.1/organization and add a new organization named 'public'.

The log file for CKAN is in: /var/log/apache2/
Source code is installed in: /opt/ngds/bin/default