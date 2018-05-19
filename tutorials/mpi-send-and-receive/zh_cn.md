---
layout: post
title: MPI Send and Receive
author: Wes Kendall
categories: Beginner MPI
tags: MPI_Recv, MPI_Send
redirect_from: '/mpi-send-and-receive/zh_cn'
---

发送和接收是 MPI 里面两个基础的概念。MPI 里面几乎所有单个的方法都可以使用基础的发送和接收 API 来实现。在这节课里，我会介绍怎么使用 MPI 的同步的（或阻塞的，原文是 blocking）发送和接收方法，以及另外的一些跟使用 MPI 进行数据传输的基础概念。

> **注意** - 这个网站的提到的所有代码都在 [GitHub]({{ site.github.repo }}) 上面。这篇教程的代码在 [tutorials/mpi-send-and-receive/code]({{ site.github.code }}/tutorials/mpi-send-and-receive/code)。


## MPI 的发送和接收简介
MPI 的发送和接收方法是按以下方式进行的：开始的时候，*A* 进程决定要发送一些消息给 *B* 进程。A进程就会把需要发送给B进程的所有数据打包好，放到一个缓存里面。因为所有数据会被打包到一个大的信息里面，因此缓存常常会被比作*信封*（就像我们把好多信纸打包到一个信封里面然后再寄去邮局）。数据打包进缓存之后，通信设备（通常是网络）就需要负责把信息传递到正确的地方。这个正确的地方也就是根据特定秩确定的那个进程。

尽管数据已经被送达到 B 了，但是进程 B 依然需要确认它想要接收 A 的数据。一旦它确定了这点，数据就被传输成功了。进程 A 会接收到数据传递成功的信息，然后去干其他事情。

有时候 A 需要传递很多不同的消息给 B。为了让 B 能比较方便地区分不同的消息，MPI 运行发送者和接受者额外地指定一些信息 ID (正式名称是*标签*, *tags*)。当 B 只要求接收某种特定标签的信息的时候，其他的不是这个标签的信息会先被缓存起来，等到 B 需要的时候才会给 B。

把这些概念记在心里的同时，让我们来看一下 MPI 发送和接收方法的定义。

```cpp
MPI_Send(
    void* data,
    int count,
    MPI_Datatype datatype,
    int destination,
    int tag,
    MPI_Comm communicator)
```

```cpp
MPI_Recv(
    void* data,
    int count,
    MPI_Datatype datatype,
    int source,
    int tag,
    MPI_Comm communicator,
    MPI_Status* status)
```

尽管一开始看起来参数有点多，慢慢地你会发现其实这些参数还是很好记忆的，因为大多数的 MPI 方法定义是类似的。第一个参数是数据缓存。第二个和第三个参数分别描述了数据的数量和类型。`MPI_send` 会精确地发送 count 指定的数量个元素，`MPI_Recv` 会**最多**接受 count 个元素（之后会详细讲）。第四个和第五个参数指定了发送方/接受方进程的秩以及信息的标签。第六个参数指定了使用的 communicator。`MPI_Recv` 方法特有的最后一个参数提供了接受到的信息的状态。

## 基础 MPI 数据结构
`MPI_send` 和 `MPI_Recv` 方法使用了 MPI 的数据结构作为一种在更高层次指定消息结构的方法。举例来说，如果一个进程想要发送一个整数给另一个进程，它会指定 count 为 1，数据结构为 `MPI_INT`。其他的 MPI 数据结构以及它们在 C 语言里对应的结构如下：

| MPI datatype | C equivalent |
| --- | --- |
| MPI_SHORT | short int |
| MPI_INT | int |
| MPI_LONG | long int |
| MPI_LONG_LONG | long long int |
| MPI_UNSIGNED_CHAR | unsigned char |
| MPI_UNSIGNED_SHORT | unsigned short int |
| MPI_UNSIGNED | unsigned int |
| MPI_UNSIGNED_LONG | unsigned long int |
| MPI_UNSIGNED_LONG_LONG | unsigned long long int |
| MPI_FLOAT | float |
| MPI_DOUBLE | double |
| MPI_LONG_DOUBLE | long double |
| MPI_BYTE | char |

目前来说，我们在 beginner 栏目里面只会使用到这些基础的数据结构。当我们有了足够多的基础知识之后，你会学习到如何创建自己的 MPI 数据类型来构建更复杂的消息类型。

## MPI 发送 / 接收 程序
跟开头说的一样，所有代码会在 [GitHub]({{ site.github.repo }}) 上, 这节课的代码在 [tutorials/mpi-send-and-receive/code]({{ site.github.code }}/tutorials/mpi-send-and-receive/code)。

第一个例子的代码在 [send_recv.c]({{ site.github.code }}/tutorials/mpi-send-and-receive/code/send_recv.c).
我们来看一下主要的部分：

```cpp
// 得到当前进程的 rank 以及整个 communicator 的大小
int world_rank;
MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
int world_size;
MPI_Comm_size(MPI_COMM_WORLD, &world_size);

int number;
if (world_rank == 0) {
    number = -1;
    MPI_Send(&number, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
} else if (world_rank == 1) {
    MPI_Recv(&number, 1, MPI_INT, 0, 0, MPI_COMM_WORLD,
             MPI_STATUS_IGNORE);
    printf("Process 1 received number %d from process 0\n",
           number);
}
```

`MPI_Comm_rank` 和 `MPI_Comm_size` 一开始是用来得到整个 communicator 空间的大小（也就是所有进程的数量）以及当前进程的秩。然后如果当前进程是 0 进程，那么我们就初始化一个数字 -1 然后把它发送给 1 进程。然后你可以看到 `else if` 条件语句里的话题，进程 1 会调用 `MPI_Recv` 去接受这个数字。然后会将接收到的数字打印出来。由于我们明确地发送接收了一个整数，因此 `MPI_INT` 数据类型被使用了。每个进程还使用了 0 作为消息标签来指定消息。由于我们这里只有一种类型的信息被传递了，因此进程也可以使用预先定义好的常量 `MPI_ANY_TAG` 来作为标签数字。

你可以把代码从[GitHub]({{ site.github.repo }})下载下来并运行 `run.py` 脚本.


```
>>> git clone {{ site.github.repo }}
>>> cd mpitutorial/tutorials
>>> ./run.py send_recv
mpirun -n 2 ./send_recv
Process 1 received number -1 from process 0
```
可以看到跟我们预想的一样，进程一收到了来自进程零传递的数字 -1。

## MPI 乒乓程序
接下来的程序比较有趣，是一个乒乓游戏。两个进程会一直使用 `MPI_Send` 和 `MPI_Recv` 方法来“推挡”消息，直到他们决定不玩了。
你可以看一眼代码[ping_pong.c]({{ site.github.code }}/tutorials/mpi-send-and-receive/code/ping_pong.c)。主要部分如下所示。

```cpp
int ping_pong_count = 0;
int partner_rank = (world_rank + 1) % 2;
while (ping_pong_count < PING_PONG_LIMIT) {
    if (world_rank == ping_pong_count % 2) {
        // Increment the ping pong count before you send it
        ping_pong_count++;
        MPI_Send(&ping_pong_count, 1, MPI_INT, partner_rank, 0, MPI_COMM_WORLD);
        printf("%d sent and incremented ping_pong_count %d to %d\n",
               world_rank, ping_pong_count,
               partner_rank);
    } else {
        MPI_Recv(&ping_pong_count, 1, MPI_INT, partner_rank, 0,
                 MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        printf("%d received ping_pong_count %d from %d\n",
               world_rank, ping_pong_count, partner_rank);
    }
}
```
这个程序是为2个进程执行而设计的。这两个进程一开始会根据我们写的一个简单的求余算法来确定各自的对手。`ping_pong_count` 一开始被初始化为0，然后每次发送消息之后会递增1。随着 `ping_pong_count` 的递增，两个进程会轮流成为发送者和接受者。最后，当我们设定的 limit 被触发的时候（我的代码里设定为10），进程就停止了发送和接收。程序的输出如下。

```
>>> ./run.py ping_pong
0 sent and incremented ping_pong_count 1 to 1
0 received ping_pong_count 2 from 1
0 sent and incremented ping_pong_count 3 to 1
0 received ping_pong_count 4 from 1
0 sent and incremented ping_pong_count 5 to 1
0 received ping_pong_count 6 from 1
0 sent and incremented ping_pong_count 7 to 1
0 received ping_pong_count 8 from 1
0 sent and incremented ping_pong_count 9 to 1
0 received ping_pong_count 10 from 1
1 received ping_pong_count 1 from 0
1 sent and incremented ping_pong_count 2 to 0
1 received ping_pong_count 3 from 0
1 sent and incremented ping_pong_count 4 to 0
1 received ping_pong_count 5 from 0
1 sent and incremented ping_pong_count 6 to 0
1 received ping_pong_count 7 from 0
1 sent and incremented ping_pong_count 8 to 0
1 received ping_pong_count 9 from 0
1 sent and incremented ping_pong_count 10 to 0
```

这个程序在其他机器上运行的输出可能会由于进程调度的不同跟上面的不一样。不管怎么样，你可以看到，进程0和进程1在轮流发送和接收 ping_pong_count。

## 环程序
我还添加了另一个使用 `MPI_Send` 和 `MPI_Recv` 的样例程序，这个程序使用到了多个进程。在这个例子里，一个值会在各个进程之间以一个环的形式传递。代码在 [ring.c]({{ site.github.code }}/tutorials/mpi-send-and-receive/code/ring.c)。主要的部分如下。

```cpp
int token;
if (world_rank != 0) {
    MPI_Recv(&token, 1, MPI_INT, world_rank - 1, 0,
             MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    printf("Process %d received token %d from process %d\n",
           world_rank, token, world_rank - 1);
} else {
    // Set the token's value if you are process 0
    token = -1;
}
MPI_Send(&token, 1, MPI_INT, (world_rank + 1) % world_size,
         0, MPI_COMM_WORLD);

// Now process 0 can receive from the last process.
if (world_rank == 0) {
    MPI_Recv(&token, 1, MPI_INT, world_size - 1, 0,
             MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    printf("Process %d received token %d from process %d\n",
           world_rank, token, world_size - 1);
}
```

这个环程序在进程0上面初始化了一个值-1，赋值给 token。然后这个值会依次传递给每个进程。程序会在进程0从最后一个进程接收到值之后结束。如你所见，我们的逻辑避免了死锁的发生。具体来说，进程0保证了在想要接受数据之前发送了 token。所有其他的进程只是简单的调用 `MPI_Recv` (从他们的邻居进程接收数据)，然后调用 `MPI_Send` (发送数据到他们的邻居进程)把数据从环上传递下去。
`MPI_Send` 和 `MPI_Recv` 会阻塞直到数据传递完成。因为这个特性，打印出来的数据是跟数据传递的次序一样的。用5个进程的话，输出应该是这样的：

```
>>> ./run.py ring
Process 1 received token -1 from process 0
Process 2 received token -1 from process 1
Process 3 received token -1 from process 2
Process 4 received token -1 from process 3
Process 0 received token -1 from process 4
```

如你所见，进程0先把-1这个值传递给了进程1。然后数据会在环里一直传递到进程0。
## 接下来

现在你有了对于 `MPI_Send` 和 `MPI_Recv` 的基础理解，是时候对这些方法进行一些深入研究了。下节课，我会讲解[如何预估和动态地接受信息]({{ site.baseurl }}/tutorials/dynamic-receiving-with-mpi-probe-and-mpi-status/)。你也可以再去 [MPI tutorials]({{ site.baseurl }}/tutorials/) 首页查看所有其他的教程。

有问题或者感到疑惑？欢迎在下面留言，也许我或者其他的读者可以帮到你。