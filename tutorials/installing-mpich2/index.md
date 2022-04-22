---
layout: post
title: Installing MPICH2 on a Single Machine
author: Wes Kendall
categories: Beginner MPI
tags:
translations: zh_cn
redirect_from: '/installing-mpich2/'
---

MPI is simply a standard which others follow in their implementation. Because of this, there are a wide variety of MPI implementations out there. One of the most popular implementations, MPICH, will be used for all of the examples provided through this site. Users are free to use any implementation they wish, but only instructions for installing MPICH will be provided. Furthermore, the scripts and code provided for the lessons are only guaranteed to execute and run with the lastest version of MPICH.

MPICH is a widely-used implementation of MPI that is developed primarily by Argonne National Laboratory in the United States. The main reason for choosing MPICH over other implementations is simply because of my familiarity with the interface and because of my close relationship with Argonne National Laboratory. I also encourage others to check out [OpenMPI](https://www.open-mpi.org/), which is also a widely-used implementation.

## Installing MPICH
The latest version of MPICH is available [here](https://www.mpich.org/). The version that I will be using for all of the examples on the site is 3.3-2, which was released 13 November 2019. Go ahead and download the source code, uncompress the folder, and change into the MPICH directory.

```
>>> tar -xzf mpich-3-3.2.tar.gz
>>> cd mpich-3-3.2
```

Once doing this, you should be able to configure your installation by performing `./configure`. If you need to install MPICH to a local directory (for example, if you don't have root access to your machine), type `./configure --prefix=/installation/directory/path`. It is possible to avoid building the MPI Fortran library by using `./configure --disable-fortran` if you do not have Fortran compilers. For more information about possible configuration parameters, type `./configure --help`

```
>>> ./configure
Configuring MPICH version 3.3.2
Running on system: Linux localhost.localdomain 5.8.18-100.fc31.x86_64 #1 SMP Mon Nov 2 20:32:55 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
checking build system type... x86_64-unknown-linux-gnu
```

When configuration is done, it should say *"Configuration completed."* Once this is through, it is time to build and install MPICH2 with `make; sudo make install`.

```
>>> make; sudo make install
make
make  all-recursive

```

If your build was successful, you should be able to type `mpiexec --version` and see something similar to this.

```
>>> mpiexec --version
HYDRA build details:
    Version:                                 3.3.2
    Release Date:                            Tue Nov 12 21:23:16 CST 2019
    CC:                              gcc    
    CXX:                             g++    
    F77:                             gfortran   
    F90:                             gfortran 
```

Hopefully your build finished successfully. If not, you may have issues with missing dependencies. For any issue, I highly recommend copying and pasting the error message directly into Google.

## Up next
Now that you have built MPICH locally, you have some options of where you can proceed on this site. If you already have the hardware and resources to setup a local cluster, I suggest you proceed to the tutorial about [running an MPI cluster in LAN]({{ site.baseurl }}/tutorials/running-an-mpi-cluster-within-a-lan). If you don't have access to a cluster or want to learn more about building a virtual MPI cluster, check out the lesson about [building and running your own cluster on Amazon EC2]({{ site.baseurl }}/tutorials/launching-an-amazon-ec2-mpi-cluster/). If you have built a cluster in either way or simply want to run the rest of the lessons from your machine, proceed to the [MPI hello world lesson]({{ site.baseurl }}/tutorials/mpi-hello-world/), which provides an overview of the basics of programming and running your first MPI program.
