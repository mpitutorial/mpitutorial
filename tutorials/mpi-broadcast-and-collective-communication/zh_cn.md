---
layout: post
title: MPI 广播以及集体(collective)通信
author: Wes Kendall
categories: Beginner MPI
tags: MPI_Barrier, MPI_Bcast, MPI_Wtime
redirect_from: '/mpi-broadcast-and-collective-communication/zh_cn'
---

[MPI 教程]({{ site.baseurl }}/tutorials/) 到目前为止，我们讲解了点对点的通信，这种通信只会同时涉及两个不同的进程。这节课是我们 MPI *集体通信*（collective communication）的第一节课。集体通信指的是一个涉及 communicator 里面所有进程的一个方法。这节课我们会解释集体通信以及一个标准的方法 - broadcasting (广播)。

> **注意** - 这个网站的提到的所有代码都在 [GitHub]({{ site.github.repo }}) 上面。这篇教程的代码在 [tutorials/mpi-broadcast-and-collective-communication/code]({{ site.github.code }}/tutorials/mpi-broadcast-and-collective-communication/code)。

## 集体通信以及同步点
关于集体通信需要记住的一点是它在进程间引入了同步点的概念。这意味着所有的进程在执行代码的时候必须首先*都*到达一个同步点才能继续执行后面的代码。

在看具体的集体通信方法之前，让我们更仔细地看一下同步这个概念。事实上，MPI 有一个特殊的函数来做同步进程的这个操作。

```cpp
MPI_Barrier(MPI_Comm communicator)
```

这个函数的名字十分贴切（Barrier，屏障）- 这个方法会构建一个屏障，任何进程都没法跨越屏障，直到所有的进程都到达屏障。这边有一个示意图。假设水平的轴代表的是程序的执行，小圆圈代表不同的进程。

![MPI_Barrier example](../barrier.png)

进程0在时间点 (T 1) 首先调用 `MPI_Barrier`。然后进程0就一直等在屏障之前，之后进程1和进程3在 (T 2) 时间点到达屏障。当进程2最终在时间点 (T 3) 到达屏障的时候，其他的进程就可以在 (T 4) 时间点再次开始运行。

`MPI_Barrier` 在很多时候很有用。其中一个用途是用来同步一个程序，使得分布式代码中的某一部分可以被精确的计时。

想知道 `MPI_Barrier` 是怎么实现的么？我知道你当然想 :-) 还记得我们之前的在[发送和接收教程]({{ site.baseurl }}/tutorials/mpi-send-and-receive/zh_cn) 里的环程序么？帮你回忆一下，我们当时写了一个在所有进程里以环的形式传递一个令牌（token）的程序。这种形式的程序是最简单的一种实现屏障的方式，因为令牌只有在所有程序都完成之后才能被传递回第一个进程。

关于同步最后一个要注意的地方是：始终记得每一个你调用的集体通信方法都是同步的。也就是说，如果你没法让所有进程都完成 `MPI_Barrier`，那么你也没法完成任何集体调用。如果你在没有确保所有进程都调用 `MPI_Barrier` 的情况下调用了它，那么程序会空闲下来。这对初学者来说会很迷惑，所以小心这类问题。

## 使用 MPI_Bcast 来进行广播
*广播* (broadcast) 是标准的集体通信技术之一。一个广播发生的时候，一个进程会把同样一份数据传递给一个 communicator 里的所有其他进程。广播的主要用途之一是把用户输入传递给一个分布式程序，或者把一些配置参数传递给所有的进程。

广播的通信模式看起来像这样：

![MPI_Bcast 模式](../broadcast_pattern.png)

在这个例子里，进程0是我们的*根*进程，它持有一开始的数据。其他所有的进程都会从它这里接受到一份数据的副本。

在 MPI 里面，广播可以使用 `MPI_Bcast` 来做到。函数签名看起来像这样：

```cpp
MPI_Bcast(
    void* data,
    int count,
    MPI_Datatype datatype,
    int root,
    MPI_Comm communicator)
```

尽管根节点和接收节点做不同的事情，它们都是调用同样的这个 `MPI_Bcast` 函数来实现广播。当根节点(在我们的例子是节点0)调用 `MPI_Bcast` 函数的时候，`data` 变量里的值会被发送到其他的节点上。当其他的节点调用 `MPI_Bcast` 的时候，`data` 变量会被赋值成从根节点接受到的数据。

## 使用 MPI_Send 和 MPI_Recv 来做广播
粗略看的话，似乎 `MPI_Bcast` 仅仅是在 `MPI_Send` 和 `MPI_Recv` 基础上进行了一层包装。事实上，我们现在就可以自己来做这层封装。我们的函数叫做 `my_bcast`，在这里可以看到: [my_bcast.c]({{ site.github.code }}/tutorials/mpi-broadcast-and-collective-communication/code/my_bcast.c)。它跟 `MPI_Bcast` 接受一样的参数，看起来像这样：

```cpp
void my_bcast(void* data, int count, MPI_Datatype datatype, int root,
              MPI_Comm communicator) {
  int world_rank;
  MPI_Comm_rank(communicator, &world_rank);
  int world_size;
  MPI_Comm_size(communicator, &world_size);

  if (world_rank == root) {
    // If we are the root process, send our data to everyone
    int i;
    for (i = 0; i < world_size; i++) {
      if (i != world_rank) {
        MPI_Send(data, count, datatype, i, 0, communicator);
      }
    }
  } else {
    // If we are a receiver process, receive the data from the root
    MPI_Recv(data, count, datatype, root, 0, communicator,
             MPI_STATUS_IGNORE);
  }
}
```

根节点把数据传递给所有其他的节点，其他的节点接收根节点的数据。很简单对吧？如果你从这个 [repo]({{ site.github.code }}/tutorials/mpi-broadcast-and-collective-communication/code/) *tutorials* 目录下面运行这个程序的话，输出看起来应该像这样：


```
>>> cd tutorials
>>> ./run.py my_bcast
mpirun -n 4 ./my_bcast
Process 0 broadcasting data 100
Process 2 received data 100 from root process
Process 3 received data 100 from root process
Process 1 received data 100 from root process
```

不管你信不信，其实我们的函数效率特别低！假设每个进程都只有一个「输出/输入」网络连接。我们的方法只是使用了进程0的一个输出连接来传递数据。比较聪明的方法是使用一个基于树的沟通算法对网络进行更好的利用。比如这样：

![MPI_Bcast tree](../broadcast_tree.png)

在示意图里，进程0一开始传递数据给进程1。跟我们之前的例子类似，第二个阶段的时候进程0依旧会把数据传递给进程2。这个例子中不同的是进程1在第二阶段也会传递数据给进程3。在第二阶段，两个网络连接在同时发生了。在这个树形算法里，能够利用的网络连接每个阶段都会比前一阶段翻番，直到所有的进程接受到数据为止。

你觉得你能用代码把这个算法实现么？实现这个算法有点超出我们这个课的主要目的了，如果你觉得你足够勇敢的话，可以去看这本超酷的书：[Parallel Programming with MPI](http://www.amazon.com/gp/product/1558603395/ref=as_li_qf_sp_asin_tl?ie=UTF8&tag=softengiintet-20&linkCode=as2&camp=217145&creative=399377&creativeASIN=1558603395) 这本书里面有完整的代码。

## MPI_Bcast 和 MPI_Send 以及 MPI_Recv 的比较
`MPI_Bcast` 的实现使用了一个类似的树形广播算法来获得比较好的网络利用率。我们的实现跟 `MPI_Bcast` 比起来怎么样呢？我们可以运行 `compare_bcast`，在课程代码里我们提供了这个程序 ([compare_bcast.c]({{ site.github.code }}/tutorials/mpi-broadcast-and-collective-communication/code/compare_bcast.c))。在看代码之前，先让我们看一个 MPI 跟时间相关的函数 - `MPI_Wtime`。`MPI_Wtime` 不接收参数，它仅仅返回以浮点数形式展示的从1970-01-01到现在为止进过的秒数，跟 C 语言的 `time` 函数类似。我们可以多次调用 `MPI_Wtime` 函数，并去差值，来计算我们的代码运行的时间。

让我们看一下我们的比较代码：

```cpp
for (i = 0; i < num_trials; i++) {
  // Time my_bcast
  // Synchronize before starting timing
  MPI_Barrier(MPI_COMM_WORLD);
  total_my_bcast_time -= MPI_Wtime();
  my_bcast(data, num_elements, MPI_INT, 0, MPI_COMM_WORLD);
  // Synchronize again before obtaining final time
  MPI_Barrier(MPI_COMM_WORLD);
  total_my_bcast_time += MPI_Wtime();

  // Time MPI_Bcast
  MPI_Barrier(MPI_COMM_WORLD);
  total_mpi_bcast_time -= MPI_Wtime();
  MPI_Bcast(data, num_elements, MPI_INT, 0, MPI_COMM_WORLD);
  MPI_Barrier(MPI_COMM_WORLD);
  total_mpi_bcast_time += MPI_Wtime();
}
```
代码里的 `num_trials` 是一个指明一共要运行多少次实验的变量。我们分别记录两个函数运行所需的累加时间，平均的时间会在程序结束的时候打印出来。完整的代码在 [compare_bcast.c]({{ site.github.code }}/tutorials/mpi-broadcast-and-collective-communication/code/compare_bcast.c) 

如果你从这个 [repo]({{ site.github.code }}) *tutorials* 目录下面运行这个程序的话，输出看起来应该像这样：

```
>>> cd tutorials
>>> ./run.py compare_bcast
/home/kendall/bin/mpirun -n 16 -machinefile hosts ./compare_bcast 100000 10
Data size = 400000, Trials = 10
Avg my_bcast time = 0.510873
Avg MPI_Bcast time = 0.126835
```

我们指定了16个进程来运行代码，每次广播发送 100,000 个整数，然后每次运行跑10个循环。如你所见，我的实验使用了通过网络连接起来的16个进程，结果显示运行我们的实现和 MPI 官方的实现体现了明显的时间差异。这里是一些不同进程数目运行时候的时间差异：

| Processors | my_bcast | MPI_Bcast |
| --- | --- | --- |
| 2 | 0.0344 | 0.0344 |
| 4 | 0.1025 | 0.0817 |
| 8 | 0.2385 | 0.1084 |
| 16 | 0.5109 | 0.1296 |

可以看到，2个进程运行的时候是没有时间差异的。这是因为 `MPI_Bcast` 的树算法在使用两个进程的时候并没有提供额外的网络利用率。然而，进程数量稍微增加到即使只有16个的时候我们也可以看到明显的差异。

试着自己运行一下代码，用更多的进程试试！

## 结论 / 接下来
现在对集体通信接口有了更好的理解么？在[接下来的教程]({{ site.baseurl }}/tutorials/mpi-scatter-gather-and-allgather/zh_cn)里，我会介绍另外的几个常用集体通信接口 - [gathering and scattering]({{ site.baseurl }}/tutorials/mpi-scatter-gather-and-allgather/zh_cn).
需要看所有教程的话，可以去 [MPI 教程]({{ site.baseurl }}/tutorials/) 页面。
