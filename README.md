# Disconnected OCP Install Helper

## Overview
This project follows the [Red Hat documentation](https://docs.openshift.com/container-platform/3.5/install_config/install/disconnected_install.html) for creating a disconnected controller/repository to use in the installation of the OpenShift Container Platform.

## Docker images to build the tar ball
I created on my local machine a directory /exports on which I will have at the end the tar ball
```
    git clone https://github.com/dwojciec/ocp-disconnected-1.git
    cd ocp-disconnected-1/docker
    docker build -t rhel/ocp-disconnected .
    docker run -it --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /exports:/data/ocp-disconnected/build rhel/ocp-disconnected
```
At the end the /export directory will contents all files (here it's just a simple test - the size of the file ocp-disconnected-3.5.tar.gz doesn't reflect the full size of a real tar ball ) :
```
[root@ip-172 exports]# ls -ltr
total 1709664
drwxr-xr-x. 3 root root         34 Jun 26 13:34 content
-rw-r--r--. 1 root root        953 Jun 26 13:34 yum.conf
-rw-r--r--. 1 root root 1750691840 Jun 26 13:36 ocp-disconnected-3.5.tar.gz
[root@ip-172- exports]#
```


## Prerequisites
* Git
* Ansible >= 2.2.0.0
* Red Hat >= 7.3
* A Red Hat ISO
* Active OCP subscription
* Access to these repositories:
    - rhel-7-server-rpms
    - rhel-7-server-extras-rpms
    - rhel-7-server-ose-3.5-rpms
    - rhel-7-fast-datapath-rpms

## Warning
This is not intended to create a full set of releases or patches. It is simply designed to create a minimal set of packages that can be used to install OCP. A large number of packages are filtered out of the repostiories that are created by the installer in order to reduce the on-disk size. This means that critical packages and updates *not required by OpenShift* may be missing. Similarly this is not a reliable way to update OCP offline for that same reason.

## Create Release
Before starting the build host must have an active subcription and must have the repositories that are listed in the [prerequisites](#prerequisites) enabled. (You will need to determine your own pool id.)

```bash
subscription-manager register
subscription-manager attach --pool=<poolid>
subscription-manager repos --disable=\* --enable=rhel-7-server-rpms --enable rhel-7-server-extras-rpms --enable rhel-7-server-ose-3.5-rpms --enable rhel-7-fast-datapath-rpms
```

You must also log into the Red Hat docker repository with your RHN account details. (As well as any other required/private repositories.)

```bash
docker login registry.access.redhat.com
```

Copy the conf.default.yml file to conf.yml. Edit the contents of conf.yml (if required). You can add extra repositories and docker images as needed. 

To execute the installation run the ansible-playbook command. The output will be an an Archive that contains all of the materials required to install OCP on a target system.

```bash
ansible-playbook -i hosts build.yml
```

The output will be a TAR archive in the build folder with the prefix "ocp-disconnected" and the version configured in the configuration file.

## Using the Release
Once the release has been copied to the target host in the offline environment you can extract it. (The target system must have `tar` installed.)

```bash
tar xvf ocp-disconnected-<version>.tar.gz
cd ocp-disconnected-<version>.tar.gz
```

Then you can bootstrap the installation to install Ansible by using the available bootstrap script. This command should be run as root or with `sudo`. This step is only required if the host does not have Ansible installed.

```bash
sudo bootstrap.sh
```

You can then execute the controller playbook to turn the current system into a controller. (You can omit `--ask-sudo-pass` if you set up passwordless sudo.)

```bash
ansible-playbook -i hosts playbooks/controller.yml --ask-sudo-pass
```

At the end of this playboook the system will be configured to provide yum repositories over HTTP (port 80) and a docker registry on port 5000.

## Connecting Other Hosts
Before continuing with this step you should make sure the system has a valid hostname and is resolvable from your other hosts. These other hosts should also be configured for Ansible connections from this host. This setup makes no special provisions for remote installation.

This installation uses the same inventory that will be used by the OCP install.

To attach other hosts:
```bash
ansible-playbook -i /path/to/ocp/host/inventory playbooks/attach.yml
```

After this command is complete these systems will be set up with their yum repositories pointing at the hostname of the controller host. They will also have all Red Hat repositories disabled and will use the repositories provided by the controller.

To override the hostname pass in the `-e CLI_HOSTNAME=somehostname.company.com` to the `ansible-playbook` command. This will override the hostname from the local system with the one that you specify.

**Note**: this step does not add this registry to your inventory. In order to install OCP you will need to add this system's registry to your inventory file and blacklist the other registries.

## In Place Install
In some cases it may make more sense to use an already created target system as the controller. In those cases this playbook can perform an 'in place' installation. This would be the case in situations where the controller has network access (but the rest of the system does not) or where the VM could be snapshotted or imaged and transfered from an environment with connectivity to another environment without.

In that case the `[inplace.yml](/inplace.yml)` playbook will turn the current system into a system running containerized instances of the applications for hosting the images and rpms as well as having Ansible and all of the Ansible content for OCP present.

```bash
ansible-playbooks -i hosts inplace.yml
```



