---
layout: post
title: Dynamic Receiving with MPI Probe (and MPI Status)
author: Wes Kendall
categories: Beginner MPI
tags: MPI_Get_count, MPI_Probe
redirect_from: '/dynamic-receiving-with-mpi-probe-and-mpi-status/'
---

在 [上一节]({{ site.baseurl }}/tutorials/mpi-send-and-receive/) 中，讨论了如何使用 `MPI_Send` 和 `MPI_Recv` 执行标准的点对点通信。
但仅仅只介绍了如何发送事先知道消息长度的消息。
尽管可以将消息的长度作为单独的发送/接收操作发送，但是 MPI 本身仅通过几个额外的函数调用即可支持动态消息。
在本节中，将讨论如何使用这些功能。

> **注意** - 教程所涉及的所有代码都在 [GitHub 上]({{ site.github.repo }})。本文的代码在 [tutorials/dynamic-receiving-with-mpi-probe-and-mpi-status/code]({{ site.github.code }}/tutorials/dynamic-receiving-with-mpi-probe-and-mpi-status/code) 下。

## MPI_Status 结构体

如 [上节]({{ site.baseurl }}/tutorials/mpi-send-and-receive/) 所述，`MPI_Recv` 将 `MPI_Status` 结构体的地址作为参数（可以使用 `MPI_STATUS_IGNORE` 忽略）。
如果我们将 `MPI_Status` 结构体传递给 `MPI_Recv` 函数，则操作完成后将在该结构体中填充有关接收操作的其他信息。
三个主要的信息包括：

1. **发送端秩**. 发送端的秩存储在结构体的 `MPI_SOURCE` 元素中。也就是说，如果我们声明一个 `MPI_Status stat` 变量，则可以通过 `stat.MPI_SOURCE` 访问秩。
2. **消息的标签**. 消息的标签可以通过结构体的 `MPI_TAG` 元素访问（类似于 `MPI_SOURCE`）。
3. **消息的长度**. 消息的长度在结构体中没有预定义的元素。相反，我们必须使用 `MPI_Get_count` 找出消息的长度。

```cpp
MPI_Get_count(
    MPI_Status* status,
    MPI_Datatype datatype,
    int* count)
```

在 `MPI_Get_count` 函数中，使用者需要传递 `MPI_Status` 结构体，消息的 `datatype`（数据类型），并返回 `count`。
变量 `count` 是已接收的 `datatype` 元素的数目。

为什么需要这些信息？
事实证明，`MPI_Recv` 可以将 `MPI_ANY_SOURCE` 用作发送端的秩，将 `MPI_ANY_TAG` 用作消息的标签。
在这种情况下，`MPI_Status` 结构体是找出消息的实际发送端和标签的唯一方法。
此外，并不能保证 `MPI_Recv` 能够接收函数调用参数的全部元素。
相反，它只接收已发送给它的元素数量（如果发送的元素多于所需的接收数量，则返回错误。）
`MPI_Get_count` 函数用于确定实际的接收量。

## `MPI_Status` 结构体查询的示例

查询 `MPI_Status` 结构体的程序在 [check_status.c]({{ site.github.code }}/tutorials/dynamic-receiving-with-mpi-probe-and-mpi-status/code/check_status.c) 中。
程序将随机数量的数字发送给接收端，然后接收端找出发送了多少个数字。
代码的主要部分如下所示。

```cpp
const int MAX_NUMBERS = 100;
int numbers[MAX_NUMBERS];
int number_amount;
if (world_rank == 0) {
    // Pick a random amount of integers to send to process one
    srand(time(NULL));
    number_amount = (rand() / (float)RAND_MAX) * MAX_NUMBERS;

    // Send the amount of integers to process one
    MPI_Send(numbers, number_amount, MPI_INT, 1, 0, MPI_COMM_WORLD);
    printf("0 sent %d numbers to 1\n", number_amount);
} else if (world_rank == 1) {
    MPI_Status status;
    // Receive at most MAX_NUMBERS from process zero
    MPI_Recv(numbers, MAX_NUMBERS, MPI_INT, 0, 0, MPI_COMM_WORLD,
             &status);

    // After receiving the message, check the status to determine
    // how many numbers were actually received
    MPI_Get_count(&status, MPI_INT, &number_amount);

    // Print off the amount of numbers, and also print additional
    // information in the status object
    printf("1 received %d numbers from 0. Message source = %d, "
           "tag = %d\n",
           number_amount, status.MPI_SOURCE, status.MPI_TAG);
}
```

如我们所见，进程 0 将最多 `MAX_NUMBERS` 个整数以随机数量发送到进程 1。
进程 1 然后调用 `MPI_Recv` 以获取总计 `MAX_NUMBERS` 个整数。
尽管进程 1 以 `MAX_NUMBERS` 作为 `MPI_Recv` 函数参数，但进程 1 将最多接收到此数量的数字。
在代码中，进程 1 使用 `MPI_INT` 作为数据类型的参数，调用 `MPI_Get_count`，以找出实际接收了多少个整数。
除了打印出接收到的消息的大小外，进程 1 还通过访问 status 结构体的 `MPI_SOURCE` 和 `MPI_TAG` 元素来打印消息的来源和标签。

为了澄清起见，`MPI_Get_count` 的返回值是相对于传递的数据类型而言的。
如果用户使用 `MPI_CHAR` 作为数据类型，则返回的数量将是原来的四倍（假设整数是四个字节，而 char 是一个字节）。
如果你从 [库]({{ site.github.code }}) 的 *tutorials* 目录中运行 check_status 程序，则输出应类似于：

```
>>> cd tutorials
>>> ./run.py check_status
mpirun -n 2 ./check_status
0 sent 92 numbers to 1
1 received 92 numbers from 0. Message source = 0, tag = 0
```

正如预期的那样，进程 0 将随机数目的整数发送给进程 1，进程 1 将打印出接收到的消息的有关信息。

## 使用 `MPI_Probe` 找出消息大小

现在您了解了 `MPI_Status` 的工作原理，现在我们可以使用它来发挥更高级的优势。
除了传递接收消息并简易地配备一个很大的缓冲区来为所有可能的大小的消息提供处理（就像我们在上一个示例中所做的那样），您可以使用 `MPI_Probe` 在实际接收消息之前查询消息大小。
函数原型看起来像这样：

```cpp
MPI_Probe(
    int source,
    int tag,
    MPI_Comm comm,
    MPI_Status* status)
```

`MPI_Probe` 看起来与 `MPI_Recv` 非常相似。
实际上，您可以将 `MPI_Probe` 视为 `MPI_Recv`，除了不接收消息外，它们执行相同的功能。
与 `MPI_Recv` 类似，`MPI_Probe` 将阻塞具有匹配标签和发送端的消息。
当消息可用时，它将填充 status 结构体。
然后，用户可以使用 `MPI_Recv` 接收实际的消息。

[教程代码]({{ site.github.code }}/tutorials/dynamic-receiving-with-mpi-probe-and-mpi-status/code) 在 probe.c 中有一个示例。
以下是源代码的主要部分

```cpp
int number_amount;
if (world_rank == 0) {
    const int MAX_NUMBERS = 100;
    int numbers[MAX_NUMBERS];
    // Pick a random amount of integers to send to process one
    srand(time(NULL));
    number_amount = (rand() / (float)RAND_MAX) * MAX_NUMBERS;

    // Send the random amount of integers to process one
    MPI_Send(numbers, number_amount, MPI_INT, 1, 0, MPI_COMM_WORLD);
    printf("0 sent %d numbers to 1\n", number_amount);
} else if (world_rank == 1) {
    MPI_Status status;
    // Probe for an incoming message from process zero
    MPI_Probe(0, 0, MPI_COMM_WORLD, &status);

    // When probe returns, the status object has the size and other
    // attributes of the incoming message. Get the message size
    MPI_Get_count(&status, MPI_INT, &number_amount);

    // Allocate a buffer to hold the incoming numbers
    int* number_buf = (int*)malloc(sizeof(int) * number_amount);

    // Now receive the message with the allocated buffer
    MPI_Recv(number_buf, number_amount, MPI_INT, 0, 0,
             MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    printf("1 dynamically received %d numbers from 0.\n",
           number_amount);
    free(number_buf);
}
```

与上一个示例类似，进程 0 选择随机数量的数字发送给进程 1。
不同之处在于，进程 1 现在调用 `MPI_Probe`，以找出进程 0 试图发送多少个元素（利用 `MPI_Get_count`）。
然后，进程 1 分配适当大小的缓冲区并接收数字。
执行本示例代码，结果看起来类似于：

```
>>> ./run.py probe
mpirun -n 2 ./probe
0 sent 93 numbers to 1
1 dynamically received 93 numbers from 0
```

尽管这个例子很简单，但是 `MPI_Probe` 构成了许多动态 MPI 应用程序的基础。
例如，控制端/执行子程序在交换变量大小的消息时通常会大量使用 `MPI_Probe`。
作为练习，对 `MPI_Recv` 进行包装，将 `MPI_Probe` 用于您可能编写的任何动态应用程序。
它将使代码看起来更美好：-)

## 接下来

对于使用标准的阻塞点对点通信例程的理解是否清晰？
如果是的，那么您已经有能力编写无数的并行应用程序！
让我们来看一个使用所学例程的高级示例。
查看 [使用 `MPI_Send`，`MPI_Recv` 和 `MPI_Probe` 的应用程序示例]({{ site.baseurl }}/tutorials/point-to-point-communication-application-random-walk/).

遇到麻烦？ 困惑？
随时在下面发表评论，也许我或其他读者会有所帮助。
