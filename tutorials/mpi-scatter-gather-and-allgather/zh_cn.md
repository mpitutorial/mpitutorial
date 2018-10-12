---
layout: post
title: MPI Scatter, Gather, and Allgather
author: Wes Kendall
categories: Beginner MPI
tags: MPI_Gather, MPI_Allgather, MPI_Scatter
redirect_from: '/mpi-scatter-gather-and-allgather/'
---
在[之前的课程]({{ site.baseurl }}/tutorials/mpi-broadcast-and-collective-communication/zh_cn)里，我们讲述了集体通信的必要知识点。我们讲了基础的广播通信机制 - `MPI_Bcast`。在这节课里，我们会讲述两个额外的机制来补充集体通信的知识 - `MPI_Scatter` 以及 `MPI_Gather`。我们还会讲一个 `MPI_Gather` 的变体：`MPI_Allgather`。

> **注意** - 这个网站的提到的所有代码都在 [GitHub]({{ site.github.repo }}) 上面。这篇教程的代码在 [tutorials/mpi-scatter-gather-and-allgather/code]({{ site.github.code }}/tutorials/mpi-scatter-gather-and-allgather/code)。

## MPI_Scatter 的介绍
`MPI_Scatter` 是一个跟 `MPI_Bcast` 类似的集体通信机制（如果你对这些词汇不熟悉的话，请阅读[上一节课]({{ site.baseurl }}/tutorials/mpi-broadcast-and-collective-communication/zh_cn)。`MPI_Scatter` 的操作会设计一个指定的根进程，根进程会将数据发送到 communicator 里面的所有进程。`MPI_Bcast` 和 `MPI_Scatter` 的主要区别很小但是很重要。`MPI_Bcast` 给每个进程发送的是*同样*的数据，然而 `MPI_Scatter` 给每个进程发送的是*一个数组的一部分数据*。下图进一步展示了这个区别。

![MPI_Bcast vs MPI_Scatter](../broadcastvsscatter.png)

在图中我们可以看到，`MPI_Bcast` 在根进程上接收一个单独的数据元素（红色的方块），然后把它复制到所有其他的进程。`MPI_Scatter` 接收一个数组，并把元素按进程的秩分发出去。第一个元素（红色方块）发往进程0，第二个元素（绿色方块）发往进程1，以此类推。尽管根进程（进程0）拥有整个数组的所有元素，`MPI_Scatter` 还是会把正确的属于进程0的元素放到这个进程的接收缓存中。下面的 `MPI_Scatter` 函数的原型。

```cpp
MPI_Scatter(
    void* send_data,
    int send_count,
    MPI_Datatype send_datatype,
    void* recv_data,
    int recv_count,
    MPI_Datatype recv_datatype,
    int root,
    MPI_Comm communicator)
```

这个函数看起来确实很大很吓人，别怕，我们来详细解释一下。第一个参数，`send_data`，是在根进程上的一个数据数组。第二个和第三个参数，`send_count` 和 `send_datatype` 分别描述了发送给每个进程的数据数量和数据类型。如果 `send_count` 是1，`send_datatype` 是 `MPI_INT`的话，进程0会得到数据里的第一个整数，以此类推。如果`send_count`是2的话，进程0会得到前两个整数，进程1会得到第三个和第四个整数，以此类推。在实践中，一般来说`send_count`会等于数组的长度除以进程的数量。除不尽怎么办？我们会在后面的课程中讲这个问题 :-)。

函数定义里面接收数据的参数跟发送的参数几乎相同。`recv_data` 参数是一个缓存，它里面存了`recv_count`个`recv_datatype`数据类型的元素。最后两个参数，`root` 和 `communicator` 分别指定开始分发数组的了根进程以及对应的communicator。

## MPI_Gather 的介绍
`MPI_Gather` 跟 `MPI_Scatter` 是相反的。`MPI_Gather` 从好多进程里面收集数据到一个进程上面而不是从一个进程分发数据到多个进程。这个机制对很多平行算法很有用，比如并行的排序和搜索。下图是这个算法的一个示例。

![MPI_Gather](../gather.png)

跟`MPI_Scatter`类似，`MPI_Gather`从其他进程收集元素到根进程上面。元素是根据接收到的进程的秩排序的。`MPI_Gather`的函数原型跟`MPI_Scatter`长的一样。

```cpp
MPI_Gather(
    void* send_data,
    int send_count,
    MPI_Datatype send_datatype,
    void* recv_data,
    int recv_count,
    MPI_Datatype recv_datatype,
    int root,
    MPI_Comm communicator)
```

在`MPI_Gather`中，只有根进程需要一个有效的接收缓存。所有其他的调用进程可以传递`NULL`给`recv_data`。另外，别忘记*recv_count*参数是从*每个进程*接收到的数据数量，而不是所有进程的数据总量之和。这一点对MPI初学者来说经常容易搞错。


## 使用 `MPI_Scatter` 和 `MPI_Gather` 来计算平均数
在[这节课的代码]({{ site.github.code }}/tutorials/mpi-scatter-gather-and-allgather/code)里，我提供了一个用来计算数组里面所有数字的平均数的样例程序（[avg.c]({{ site.github.code }}/tutorials/mpi-scatter-gather-and-allgather/code/avg.c)）。尽管这个程序十分简单，但是它展示了我们如何使用MPI来把工作拆分到不同的进程上，每个进程对一部分数据进行计算，然后再把每个部分计算出来的结果汇集成最终的答案。这个程序有以下几个步骤：
1. 在根进程（进程0）上生成一个充满随机数字的数组。
2. 把所有数字用`MPI_Scatter`分发给每个进程，每个进程得到的同样多的数字。
3. 每个进程计算它们各自得到的数字的平均数。
4. 根进程收集所有的平均数，然后计算这个平均数的平均数，得出最后结果。

代码里面有 MPI 调用的主要部分如下所示：

```cpp
if (world_rank == 0) {
  rand_nums = create_rand_nums(elements_per_proc * world_size);
}

// Create a buffer that will hold a subset of the random numbers
float *sub_rand_nums = malloc(sizeof(float) * elements_per_proc);

// Scatter the random numbers to all processes
MPI_Scatter(rand_nums, elements_per_proc, MPI_FLOAT, sub_rand_nums,
            elements_per_proc, MPI_FLOAT, 0, MPI_COMM_WORLD);

// Compute the average of your subset
float sub_avg = compute_avg(sub_rand_nums, elements_per_proc);
// Gather all partial averages down to the root process
float *sub_avgs = NULL;
if (world_rank == 0) {
  sub_avgs = malloc(sizeof(float) * world_size);
}
MPI_Gather(&sub_avg, 1, MPI_FLOAT, sub_avgs, 1, MPI_FLOAT, 0,
           MPI_COMM_WORLD);

// Compute the total average of all numbers.
if (world_rank == 0) {
  float avg = compute_avg(sub_avgs, world_size);
}
```

代码开头根进程创建里一个随机数的数组。当`MPI_Scatter`被调用的时候，每个进程现在都持有`elements_per_proc`个原始数据里面的元素。每个进程计算子数组的平均数，然后根进程收集这些平均数。然后总的平均数就可以在这个小的多的平均数数组里面被计算出来。

如果你运行这个[repo]({{ site.github.code }})下面*tutorials*目录下的代码，输出应该跟下面的类似。注意因为数字是随机生成的，所以你的最终结果可能跟我的不一样。


```
>>> cd tutorials
>>> ./run.py avg
/home/kendall/bin/mpirun -n 4 ./avg 100
Avg of all elements is 0.478699
Avg computed across original data is 0.478699
```

## MPI_Allgather 以及修改后的平均程序
到目前为止，我们讲解了两个用来操作*多对一*或者*一对多*通信模式的MPI方法，也就是说多个进程要么向一个进程发送数据，要么从一个进程接收数据。很多时候发送多个元素到多个进程也很有用（也就是*多对多*通信模式）。`MPI_Allgather`就是这个作用。

对于分发在所有进程上的一组数据来说，`MPI_Allgather`会收集所有数据到所有进程上。从最基础的角度来看，`MPI_Allgather`相当于一个`MPI_Gather`操作之后跟着一个`MPI_Bcast`操作。下面的示意图显示了`MPI_Allgather`调用之后数据是如何分布的。

![MPI_Allgather](../allgather.png)

就跟`MPI_Gather`一样，每个进程上的元素是根据他们的秩为顺序被收集起来的，只不过这次是收集到了所有进程上面。很简单吧？`MPI_Allgather`的方法定义跟`MPI_Gather`几乎一样，只不过`MPI_Allgather`不需要root这个参数来指定根节点。

```cpp
MPI_Allgather(
    void* send_data,
    int send_count,
    MPI_Datatype send_datatype,
    void* recv_data,
    int recv_count,
    MPI_Datatype recv_datatype,
    MPI_Comm communicator)
```

我把计算平均数的代码修改成了使用`MPI_Allgather`来计算。你可以在[all_avg.c]({{ site.github.code }}/tutorials/mpi-scatter-gather-and-allgather/code/all_avg.c)这个文件里看到源代码。主要的不同点如下所示。

```cpp
// Gather all partial averages down to all the processes
float *sub_avgs = (float *)malloc(sizeof(float) * world_size);
MPI_Allgather(&sub_avg, 1, MPI_FLOAT, sub_avgs, 1, MPI_FLOAT,
              MPI_COMM_WORLD);

// Compute the total average of all numbers.
float avg = compute_avg(sub_avgs, world_size);
```

现在每个子平均数被`MPI_Allgather`收集到了所有进程上面。最终平均数在每个进程上面都打印出来了。样例运行之后应该跟下面的输出结果类似。


```
>>> ./run.py all_avg
/home/kendall/bin/mpirun -n 4 ./all_avg 100
Avg of all elements from proc 1 is 0.479736
Avg of all elements from proc 3 is 0.479736
Avg of all elements from proc 0 is 0.479736
Avg of all elements from proc 2 is 0.479736
```

跟你注意到的一样，all_avg.c 和 avg.c 之间的唯一的区别就是 all_avg.c 使用`MPI_Allgather`把平均数在每个进程上都打印出来了。

## 接下来
下节课，我会使用`MPI_Gather`和`MPI_Scatter`做一个应用程序来[进行并行等级计算]({{ site.baseurl }}/tutorials/performing-parallel-rank-with-mpi/)。

你也可以在 [MPI tutorials]({{ site.baseurl }}/tutorials/) 查看所有课程。
