---
layout: post
title: Running an MPI Cluster within a LAN
author: Dwaraka Nath
categories: Beginner MPI
tags: MPI, Cluster, LAN
redirect_from: '/running-an-mpi-cluster-within-a-lan'
---

Earlier, we looked at running MPI programs in a [single machine]({{ site.baseurl }}/tutorials/mpi-hello-world/) to parallel process the code, taking advantage of having more than a single core in CPU. Now, let's widen our scope a bit, taking the same from more than just one computer to a network of nodes connected together in a Local Area Network. To keep things simple, let's just consider two computers for now. It is fairly straight to implement the same with many more nodes.

As with other tutorials, I am assuming you run Linux machines. The following tutorial was tested with Ubuntu, but it should be the same with any other distribution. And also, let's consider your machine to be **master** and the other one as **client**

## Pre-requisite

If you have not installed MPICH2 in each of the machines, follow the steps [here]({{ site.baseurl }}/tutorials/installing-mpich2/).

## Step 1: Configure your ```hosts``` file

You are gonna need to communicate between the computers and you don't want to type in the IP addresses every so often. Instead, you can give a name to the various nodes in the network that you wish to communicate with. ```hosts``` file is used by your device operating system to map hostnames to IP addresses.

```bash

$ cat /etc/hosts

127.0.0.1       localhost
172.50.88.34    client
```
The ```client``` here is the machine you'd like to do your computation with. Likewise, do the same about ```master``` in the client.

## Step 2: Create a new user

Though you can operate your cluster with your existing user account, I'd recommend you to create a new one to keep our configurations simple. Let us create a new user ```mpiuser```. Create new user accounts with the same username in all the machines to keep things simple.

```bash
$ sudo adduser mpiuser
```
Follow prompts and you will be good. Please don't use ```useradd``` command to create a new user as that doesn't create a separate home for new users.

## Step 3: Setting up SSH

Your machines are gonna be talking over the network via SSH and share data via [NFS](#step-4-setting-up-nfs), about which we'll talk a little later.

```bash
$ sudo apt­-get install openssh-server
```

And right after that, login with your newly created account

```bash
$ su - mpiuser
```
Since the ```ssh``` server is already installed, you must be able to login to other machines by ```ssh username@hostname```, at which you will be prompted to enter the password of the ```username```. To enable more easier login, we generate keys and copy them to other machines' list of ```authorized_keys```.

```bash
$ ssh-keygen -t dsa
```

You can as well generate RSA keys. But again, it is totally up to you. If you want more security, go with RSA. Else, DSA should do just fine. Now, add the generated key to each of the other computers. In our case, the client machine.

```bash
$ ssh-copy-id client #ip-address may also be used
```

Do the above step for each of the client machines and your own user (localhost).

This will setup ```openssh-server``` for you to securely communicate with the client machines. ```ssh``` all machines once, so they get added to your list of ```known_hosts```. This is a very simple but essential step failing which passwordless ```ssh``` will be a trouble.

Now, to enable passwordless ssh,

```bash
$ eval `ssh-agent`
$ ssh-add ~/.ssh/id_dsa
```
Now, assuming you've properly added your keys to other machines, you must be able to login to other machines without any password prompt.

```bash
$ ssh client
```

> **Note** - Since I've assumed that you've created ```mpiuser``` as the common user account in all of the client machines, this should just work fine. If you've created user accounts with different names in master and client machines, you'll need to work around that.

## Step 4: Setting up NFS

You share a directory via NFS in **master** which the **client** mounts to exchange data.

### NFS-Server

Install the required packages by

```bash
$ sudo apt-get install nfs-kernel-server
```

Now, (assuming you are still logged into ```mpiuser```), let's create a folder by the name ```cloud``` that we will share across in the network.

```bash
$ mkdir cloud
```

To export the ```cloud``` directory, you create an entry in ```/etc/exports```

```bash
$  cat /etc/exports
/home/mpiuser/cloud *(rw,sync,no_root_squash,no_subtree_check)
```
Here, instead of ```*``` you can specifically give out the IP address to which you want to share this folder to. But, this will just make our job easier.

* **rw**: This is to enable both read and write option. **ro** is for read-only.
* **sync**: This applies changes to the shared directory only after changes are committed.
* **no_subtree_check**: This option prevents the subtree checking. When a shared directory is the subdirectory of a larger filesystem, nfs performs scans of every directory above it, in order to verify its permissions and details. Disabling the subtree check may increase the reliability of NFS, but reduce security.
* **no_root_squash**: This allows root account to connect to the folder.

> Thanks to [Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-ubuntu-12-04) for help with tutorial and explanations. Content re-used on account of Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. For information, read [here](https://creativecommons.org/licenses/by-nc-sa/4.0/).

After you have made the entry, run the following.

```bash
$ exportfs -a
```

Run the above command, every time you make a change to ```/etc/exports```.

If required, restart the ```nfs``` server

```bash
$ sudo service nfs-kernel-server restart
```

### NFS-Client

Install the required packages

```bash
$ sudo apt-get install nfs-common
```

Create a directory in the client's machine with the samename ```cloud```

```bash
$ mkdir cloud
```

And now, mount the shared directory like

```bash
$ sudo mount -t nfs master:/home/mpiuser/cloud ~/cloud
```

To check the mounted directories,

```bash
$ df -h
Filesystem      		    Size  Used Avail Use% Mounted on
master:/home/mpiuser/cloud  49G   15G   32G  32% /home/mpiuser/cloud
```

To make the mount permanent so you don't have to manually mount the shared directory everytime you do a system reboot, you can create an entry in your file systems table - i.e., ```/etc/fstab``` file like this:

```bash
$ cat /etc/fstab
#MPI CLUSTER SETUP
master:/home/mpiuser/cloud /home/mpiuser/cloud nfs
```

## Step 5: Running MPI programs

For consideration sake, let's just take a sample program, that comes along with MPICH2 installation package ```mpich2/examples/cpi```. We shall take this executable and try to run it parallely.

Or if you want to compile your own code, the name of which let's say is ```mpi_sample.c```, you will compile it the way given below, to generate an executable ```mpi_sample```.

```bash
$ mpicc -o mpi_sample mpi_sample.c
```

First copy your executable into the shared directory ```cloud``` or better yet, compile your code within the NFS shared directory.

```bash
$ cd cloud/
$ pwd
/home/mpiuser/cloud
```

To run it only in your machine, you do

```bash
$ mpirun -np 2 ./cpi # No. of processes = 2
```

Now, to run it within a cluster,

```bash
$ mpirun -np 5 -hosts client,localhost ./cpi
#hostnames can also be substituted with ip addresses.
```

Or specify the same in a hostfile and

```bash
$ mpirun -np 5 --hostfile mpi_file ./cpi
```

This should spin up your program in all of the machines that your **master** is connected to.

## Common errors and tips

* Make sure all the machines you are trying to run the executable on, has the same version of MPI. Recommended is [MPICH2](http://www.mpich.org/downloads/).
* The ```hosts``` file of ```master``` should contain the local network IP address entries of ```master``` and all of the slave nodes. For each of the slave, you need to have the IP address entry of ```master``` and the corresponding slave node.

For e.g. a sample hostfile entry of a ```master``` node can be,

```bash
$ cat /etc/hosts
127.0.0.1	localhost
#127.0.1.1	1944

#MPI CLUSTER SETUP
172.50.88.22	master
172.50.88.56 	slave1
172.50.88.34 	slave2
172.50.88.54	slave3
172.50.88.60 	slave4
172.50.88.46	slave5
```
A sample hostfile entry of ```slave3``` node can be,

```bash
$ cat /etc/hosts
127.0.0.1	localhost
#127.0.1.1	1947

#MPI CLUSTER SETUP
172.50.88.22	master
172.50.88.54	slave3
```
* Whenever you try to run a process parallely using MPI, you can either run the process locally or run it as a combination of local and remote nodes. You **cannot** invoke a process **only on other nodes**.

To make this more clear, from ```master``` node, this script can be invoked.

```bash
$ mpirun -np 10 --hosts master ./cpi
# To run the program only on the same master node
```

So can this be. The following will also run perfectly.

```bash
$ mpirun -np 10 --hosts master,slave1,slave2 ./cpi
# To run the program on master and slave nodes.
```

But, the following is **not correct** and will result in an error if invoked from ```master```.

```bash
$ mpirun -np 10 --hosts slave1 ./cpi
# Trying to run the program only on remote slave
```

## So, what's next?

Exciting isn't it, for having built a cluster to run your code? You now need to know the specifics of writing a program that can run parallely. Best place to start off would be the lesson [MPI hello world lesson]({{ site.baseurl }}/tutorials/mpi-hello-world/). Or if you want to replicate the same using Amazon EC2 instances, I suggest you have a look at [building and running your own cluster on Amazon EC2]({{ site.baseurl }}/tutorials/launching-an-amazon-ec2-mpi-cluster/). For all the other lessons, you may go to the [MPI tutorials]({{ site.baseurl }}/tutorials/) page.

Should you have any issues in setting up your local cluster, please don't hesitate to comment below so we can try to sort it out.

