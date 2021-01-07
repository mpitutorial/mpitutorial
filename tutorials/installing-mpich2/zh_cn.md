---
layout: post
title: Installing MPICH2 on a Single Machine
author: Wes Kendall
categories: Beginner MPI
tags:
redirect_from: '/installing-mpich2/'
---

MPI 只是众多实现中所遵循的一个标准。
因此，这里有各种各样的 MPI 实现。
本站点提供的所有示例都将使用最受欢迎的实现之一 MPICH。
用户可以自由使用他们希望的任何实现，但是仅提供安装 MPICH 的说明。
此外，仅保证为课程提供的脚本和代码可以在最新版本的 MPICH 上执行和运行。

MPICH 是 MPI 的一种广泛使用的实现，主要由美国的 Argonne 国家实验室开发。
选择 MPICH 而不是其他实现的主要原因是由于我对界面的熟悉以及与 Argonne 国家实验室的密切关系。
我还鼓励其他人使用 OpenMPI，这也是一种广泛使用的实现。

## Installing MPICH

MPICH 的最新版本可在 [此处](https://www.mpich.org/) 获取。
网站上所有示例的版本是 3.3-2，该版本于 2019 年 9 月 13 日发布。
下载源代码，解压缩文件夹，然后切换到 MPICH 目录。

```
>>> tar -xzf mpich3-3.2.tar.gz
>>> cd mpich3-3.2
```

完成之后，您应该能够通过执行 `./configure` 来配置安装。
如果需要将 MPICH 安装到本地目录（例如，如果您没有对计算机的 root 访问权限），请使用 `./configure --prefix=/installation/directory/path`，如果您没有 Fortran 编译器，则可以通过使用 `./configure --disable-fortran` 来避免构建 MPI Fortran 库。输入 `./configure --help` 以获取有关可能的配置参数的更多信息。

```
>>> ./configure --disable-fortran
Configuring MPICH version 3.3.2
Running on system: Linux localhost.localdomain 5.8.18-100.fc31.x86_64 #1 SMP Mon Nov 2 20:32:55 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
checking build system type... x86_64-unknown-linux-gnu
```

配置完成后，应显示 *"Configuration completed."*
一旦完成，就该使用`make; sudo make install`命令来构建和安装 MPICH2 了。

```
>>> make; sudo make install
make
make  all-recursive

```

如果构建成功，则应该可以输入`mpiexec --version`并看到以下类似的内容。

```
>>> mpiexec --version
HYDRA build details:
    Version:                         3.3.2
    Release Date:                    Tue Nov 12 21:23:16 CST 2019
    CC:                              gcc
    CXX:                             g++
    F77:                             gfortran
    F90:                             gfortran
```

希望您的构建成功完成。
如果没有，您可能会遇到缺少依赖项的问题。
对于任何问题，我强烈建议您将错误消息直接复制并粘贴到 Google 中。

## 下一步

现在，您已经在本地构建了 MPICH，您可以在该站点上进行一些选择。
如果您已经具有用于设置本地集群的硬件和资源，建议您继续阅读有关 [在 LAN 中运行 MPI 集群]({{ site.baseurl }}/tutorials/running-an-mpi-cluster-within-a-lan) 的教程。
如果您无权访问集群或想了解有关构建虚拟化 MPI 集群的更多信息，请阅读有关 [在 Amazon EC2 上构建和运行自己的集群]({{ site.baseurl }}/tutorials/launching-an-amazon-ec2-mpi-cluster/)。
如果您以任何一种方式构建了集群，或者只是想从计算机上运行其余课程，请继续阅读 [MPI hello world 课程]({{ site.baseurl }}/tutorials/mpi-hello-world/)，其中概述了编程和运行第一个 MPI 程序的基础知识。
