---
layout: post
title: Installing MPICH2 on a Single Machine
author: Wes Kendall
categories: Beginner MPI
tags:
redirect_from: '/installing-mpich2/'
---

MPI is simply a standard which others follow in their implementation. Because of this, there are a wide variety of MPI implementations out there. One of the most popular implementations, MPICH2, will be used for all of the examples provided through this site. Users are free to use any implementation they wish, but only instructions for installing MPICH2 will be provided. Furthermore, the scripts and code provided for the lessons are only guaranteed to execute and run with the lastest version of MPICH2.

MPICH2 is a widely-used implementation of MPI that is developed primarily by Argonne National Laboratory in the United States. The main reason for choosing MPICH2 over other implementations is simply because of my familiarity with the interface and because of my close relationship with Argonne National Laboratory. I also encourage others to check out OpenMPI, which is also a widely-used implementation.

## Installing MPICH2
The latest version of MPICH2 is available [here](http://www.mcs.anl.gov/research/projects/mpich2/). The version that I will be using for all of the examples on the site is 1.4, which was released June 16, 2011. Go ahead and download the source code, uncompress the folder, and change into the MPICH2 directory.

```
>>> tar -xzf mpich2-1.4.tar.gz
>>> cd mpich2-1.4
```

Once doing this, you should be able to configure your installation by performing `./configure`. I added a couple of parameters to my configuration to avoid building the MPI Fortran library. If you need to install MPICH2 to a local directory (for example, if you don't have root access to your machine), type `./configure --prefix=/installation/directory/path` For more information about possible configuration parameters, type `./configure --help`

```
>>> ./configure --disable-fortran
Configuring MPICH2 version 1.4 with '--disable-f77' '--disable-fc'
Running on system: Darwin Wes-Kendalls-Macbook-Pro.local 10.7.0 Darwin Kernel Version 10.7.0: Sat Jan 29 15:17:16 PST 2011; root:xnu1504.9.37~1/RELEASE_I386 i386
checking for gcc... gcc
```

When configuration is done, it should say *"Configuration completed."* Once this is through, it is time to build and install MPICH2 with `make; sudo make install`.

```
>>> make; sudo make install
Beginning make
Using variables CC='gcc' CFLAGS='   -O2' LDFLAGS=' ' F77='' FFLAGS=' ' FC='' FCFLAGS=' ' CXX='c++' CXXFLAGS='  -O2' AR='ar' CPP='gcc-E' CPP
```

If your build was successful, you should be able to type `mpiexec --version` and see something similar to this.

```
>>> mpiexec --version
HYDRA build details:
    Version:                         3.1.4
    Release Date:                    Fri Feb 20 15:02:56 CST 2015
    CC:                              gcc
    CXX:                             g++
    F77:
    F90:
```

Hopefully your build finished successfully. If not, you may have issues with missing dependencies. For any issue, I highly recommend copying and pasting the error message directly into Google.

## Up next
Now that you have built MPICH2 locally, you have some options of where you can proceed on this site. If you already have the hardware and resources to setup a local cluster, I suggest you proceed to the tutorial about [running an MPI cluster in LAN]({{ site.baseurl }}/tutorials/running-an-mpi-cluster-within-a-lan). If you don't have access to a cluster or want to learn more about building a virtual MPI cluster, check out the lesson about [building and running your own cluster on Amazon EC2]({{ site.baseurl }}/tutorials/launching-an-amazon-ec2-mpi-cluster/). If you have built a cluster in either way or simply want to run the rest of the lessons from your machine, proceed to the [MPI hello world lesson]({{ site.baseurl }}/tutorials/mpi-hello-world/), which provides an overview of the basics of programming and running your first MPI program.
