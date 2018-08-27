---
layout: post
title: MPI Hello World
author: Wes Kendall
categories: Beginner MPI
tags: MPI_Comm_rank, MPI_Comm_size, MPI_Finalize, MPI_Get_processor_name, MPI_Init
redirect_from: '/mpi-hello-world/zh_cn'
---

在这个课程里，在展示一个基础的 MPI Hello World 程序的同时我会介绍一下该如何运行 MPI 程序。这节课会涵盖如何初始化 MPI 的基础内容以及让 MPI 任务跑在几个不同的进程上。这节课程的代码是在 MPICH2（当时是1.4版本）上面运行通过的。（译者在 MPCH-3.2.1 上运行程序也没有问题）。如果你还没装 MPICH2，你参考[MPICH2 安装指南]({{ site.baseurl }}/tutorials/installing-mpich2/)

> **注意** - 这个网站的提到的所有代码都在 [GitHub]({{ site.github.repo }}) 上面。这篇教程的代码在 [tutorials/mpi-hello-world/code]({{ site.github.code }}/tutorials/mpi-hello-world/code)。


## Hello world 代码案例
让我们来看一下这节课的代码吧，完整的代码在 [mpi_hello_world.c]({{ site.github.code }}/tutorials/mpi-hello-world/code/mpi_hello_world.c)。
下面是一些重点内容的摘录。
```cpp
#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
    // 初始化 MPI 环境
    MPI_Init(NULL, NULL);

    // 通过调用以下方法来得到所有可以工作的进程数量
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    // 得到当前进程的秩
    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

    // 得到当前进程的名字
    char processor_name[MPI_MAX_PROCESSOR_NAME];
    int name_len;
    MPI_Get_processor_name(processor_name, &name_len);

    // 打印一条带有当前进程名字，秩以及
    // 整个 communicator 的大小的 hello world 消息。
    printf("Hello world from processor %s, rank %d out of %d processors\n",
           processor_name, world_rank, world_size);

    // 释放 MPI 的一些资源
    MPI_Finalize();
}
```

你应该已经注意到搭建一个 MPI 程序的第一步是引入 `#include <mpi.h>` 这个头文件。然后 MPI 环境必须以以下代码来初始化：

```cpp
MPI_Init(
    int* argc,
    char*** argv)
```

在 `MPI_Init` 的过程中，所有 MPI 的全局变量或者内部变量都会被创建。举例来说，一个通讯器 communicator 会根据所有可用的进程被创建出来（进程是我们通过 mpi 运行时的参数指定的），然后每个进程会被分配独一无二的秩 rank。当前来说，`MPI_Init` 接受的两个参数是没有用处的，不过参数的位置保留着，可能以后的实现会需要用到。

在 `MPI_Init` 之后，有两个主要的函数被调用到了。这两个函数是几乎所有 MPI 程序都会用到的。

```cpp
MPI_Comm_size(
    MPI_Comm communicator,
    int* size)
```

`MPI_Comm_size` 会返回 communicator 的大小，也就是 communicator 中可用的进程数量。在我们的例子中，`MPI_COMM_WORLD`（这个 communicator 是 MPI 帮我们生成的）这个变量包含了当前 MPI 任务中所有的进程，因此在我们的代码里的这个调用会返回所有的可用的进程数目。

```cpp
MPI_Comm_rank(
    MPI_Comm communicator,
    int* rank)
```

`MPI_Comm_rank` 这个函数会返回 communicator 中当前进程的 rank。 communicator 中每个进程会以此得到一个从0开始递增的数字作为 rank 值。rank 值主要是用来指定发送或者接受信息时对应的进程。

我们代码中使用到的一个不太常见的方法是：

```cpp
MPI_Get_processor_name(
    char* name,
    int* name_length)
```

`MPI_Get_processor_name` 会得到当前进程实际跑的时候所在的处理器名字。
代码中最后一个调用是：

```cpp
MPI_Finalize()
```
`MPI_Finalize` 是用来清理 MPI 环境的。这个调用之后就没有 MPI 函数可以被调用了。

## 运行 MPI hello world 程序
现在查看以下代码文件以及代码所在的文件夹，你会看到一个 makefile。

```
>>> git clone {{ site.github.repo }}
>>> cd mpitutorial/tutorials/mpi-hello-world/code
>>> cat makefile
EXECS=mpi_hello_world
MPICC?=mpicc

all: ${EXECS}

mpi_hello_world: mpi_hello_world.c
    ${MPICC} -o mpi_hello_world mpi_hello_world.c

clean:
    rm ${EXECS}
```

我的 makefile 会去找 MPICC 这个环境变量。如果你把 MPICH2 装在了本地文件夹里面而不是全局 PATH 下面, 手动设置一下 MPICC 这个环境变量，把它指向你的 mpicc 二进制程序。mpicc 二进制程序其实只是对 gcc 做了一层封装，使得编译和链接所有的 MPI 程序更方便。

```
>>> export MPICC=/home/kendall/bin/mpicc
>>> make
/home/kendall/bin/mpicc -o mpi_hello_world mpi_hello_world.c
```
当你的程序编译好之后，它就可以被执行了。不过执行之前你也许会需要一些额外配置。比如如果你想要在好几个节点的集群上面跑这个 MPI 程序的话，你需要配置一个 host 文件（不是 /etc/hosts）。如果你在笔记本或者单机上运行的话，可以跳过下面这一段。

需要配置的 host 文件会包含你想要运行的所有节点的名称。为了运行方便，你需要确认一下所有这些节点之间能通过 SSH 通信，并且需要根据[设置认证文件这个教程]((http://www.eng.cam.ac.uk/help/jpmg/ssh/authorized_keys_howto.html)配置不需要密码的 SSH 访问。
我的 host 文件看起来像这样：

```
>>> cat host_file
cetus1
cetus2
cetus3
cetus4
```

为了用我提供的脚本来运行这个程序，你应该设置一个叫 MPI_HOSTS 的环境变量，把它指向 host 文件所在的位置。我的脚本会自动把这个 host 文件的配置项加到 MPI 启动命令里。如果单机跑的话就不用设这个环境变量。另外如果你的 MPI 没有装到全局环境的话，你还需要指定 MPIRUN 这个环境变量指向你的 mpirun 二进制程序。

准备就绪之后你就可以使用这个项目的我提供的 python 脚本来执行程序。脚本在 *tutorials* 目录下面，这个脚本可以用来跑我们这个教程里面提到的所有程序（而且它会帮你先编译一下程序）。你可以在 mpitutorial 这个文件夹的根目录下执行以下命令：

```
>>> export MPIRUN=/home/kendall/bin/mpirun
>>> export MPI_HOSTS=host_file
>>> cd tutorials
>>> ./run.py mpi_hello_world
/home/kendall/bin/mpirun -n 4 -f host_file ./mpi_hello_world
Hello world from processor cetus2, rank 1 out of 4 processors
Hello world from processor cetus1, rank 0 out of 4 processors
Hello world from processor cetus4, rank 3 out of 4 processors
Hello world from processor cetus3, rank 2 out of 4 processors
```

跟预想的一样，这个 MPI 程序运行在了我提供的所有节点上面。每个进程都被分配了一个单独的 rank，跟进程的名字一起打印出来了。你可以看到，在我们的输出的结果里，进程之间的打印顺序是任意的，因为我们的代码里并没有涉及到同步的操作。

我们可以在打印的内容上面那条看到脚本是如何调用 mpirun 这个程序的。mpirun 是 MPI 的实现用来启动任务的一个程序。进程会在 host 文件里指定的所有机器上面生成，MPI 程序就会在所有进程上面运行。我的脚步自定地提供了一个 *-n* 参数告诉 MPI 程序我要运行 4 个进程。你可以试着修改脚步来使用更多进程运行 MPI 程序。当心别把你的操作系统玩蹦了。:-)

你可能会问，*"我的节点都都是双核的机器，我怎么样可以让 MPI 先在每个节点上的每个核上生成进程，再去其他的机器？* 其实方案很简单。修改一下你的 host 文件，在每个节点名字的后面加一个冒号和每个处理器有的核数就行了。比如，我在 host 文件里指定我的每个节点有2个核。

```
>>> cat host_file
cetus1:2
cetus2:2
cetus3:2
cetus4:2
```

当我再次运行我的脚本，*哇!*，MPI 任务只在我的两个节点上生成了4个进程。


```
>>> ./run.py mpi_hello_world
/home/kendall/bin/mpirun -n 4 -f host_file ./mpi_hello_world
Hello world from processor cetus1, rank 0 out of 4 processors
Hello world from processor cetus2, rank 2 out of 4 processors
Hello world from processor cetus2, rank 3 out of 4 processors
Hello world from processor cetus1, rank 1 out of 4 processors
```

## 接下来
现在你对 MPI 程序有了基本的了解。接下来可以学习基础的 *点对点* （point-to-point）通信方法了。在下节课里，我讲解了 [MPI 里基础的发送和接收函数]({{ site.baseurl }}/tutorials/mpi-send-and-receive/zh_cn)。你也可以再去 [MPI tutorials]({{ site.baseurl }}/tutorials/) 首页查看所有其他的教程。

有问题或者感到疑惑？欢迎在下面留言，也许我或者其他的读者可以帮到你。
