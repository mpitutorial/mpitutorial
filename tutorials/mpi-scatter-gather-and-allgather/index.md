---
layout: post
title: MPI Scatter, Gather, and Allgather
author: Wes Kendall
categories: Beginner MPI
tags: MPI_Gather, MPI_Allgather, MPI_Scatter
redirect_from: '/mpi-scatter-gather-and-allgather/'
---

<p>In the <a href='/mpi-broadcast-and-collective-communication'>previous lesson</a>, we went over the essentials of collective communication. We covered the most basic collective communication routine - <code>MPI_Bcast</code>. In this lesson, we are going to expand on collective communication routines by going over two very important routines - <code>MPI_Scatter</code> and <code>MPI_Gather</code>. We will also cover a variant of MPI_Gather, known as MPI_Allgather. The code for this tutorial is available <a href="http://www.mpitutorial.com/lessons/mpi_scatter_gather_allgather.tgz">here</a> or can be <a href="https://github.com/wesleykendall/mpitutorial/tree/master/mpi_scatter_gather_allgather" target="_blank">viewed/cloned on GitHub</a>.</p><!--more-->
</p>

<h2>An Introduction to MPI_Scatter</h2>
<p>MPI_Scatter is a collective routine that is very similar to <code>MPI_Bcast</code> (If you are unfamiliar with these terms, please read the <a href='/mpi-broadcast-and-collective-communication'>previous lesson</a>). <code>MPI_Scatter</code> involves a designated root process sending data to all processes in a communicator. The primary difference between <code>MPI_Bcast</code> and <code>MPI_Scatter</code> is small but important. <code>MPI_Bcast</code> sends the <i>same</i> piece of data to all processes while <code>MPI_Scatter</code> sends <i>chunks of an array</i> to different processes. Check out the illustration below for further clarification.</p>

<center><img alt="MPI_Bcast vs MPI_Scatter" class="padded shadow" width="287" height="340" src="http://images.mpitutorial.com/broadcastvsscatter.png" /></center>

<p>In the illustration, <code>MPI_Bcast</code> takes a single data element at the root process (the red box) and copies it to all other processes. <code>MPI_Scatter</code> takes an array of elements and distributes the elements in the order of process rank. The first element (in red) goes to process zero, the second element (in green) goes to process one, and so on. Although the root process (process zero) contains the entire array of data, <code>MPI_Scatter</code> will copy the appropriate element into the receiving buffer of the process. Here is what the function prototype of <code>MPI_Scatter</code> looks like.</p>
<pre>
MPI_Scatter(void* send_data, int send_count, MPI_Datatype send_datatype,
            void* recv_data, int recv_count, MPI_Datatype recv_datatype,
            int root, MPI_Comm communicator)
</pre>

<p>Yes, the function looks big and scary, but let's examine it in more detail. The first parameter, <code>send_data</code>, is an array of data that resides on the root process. The second and third parameters, <code>send_count</code> and <code>send_datatype</code>, dictate how many elements of a specific MPI Datatype will be sent to each process. If <code>send_count</code> is one and <code>send_datatype</code> is <code>MPI_INT</code>, then process zero gets the first integer of the array, process one gets the second integer, and so on. If <code>send_count</code> is two, then process zero gets the first and second integers, process one gets the third and fourth, and so on. In practice, <code>send_count</code> is often equal to the number of elements in the array divided by the number of processes. What's that you say? The number of elements isn't divisible by the number of processes? Don't worry, we will cover that in a later lesson :)</p>

<p>The receiving parameters of the function prototype are nearly identical in respect to the sending parameters. The <code>recv_data</code> parameter is a buffer of data that can hold <code>recv_count</code> elements that have a datatype of <code>recv_datatype</code>. The last parameters, <code>root</code> and <code>communicator</code>, indicate the root process that is scattering the array of data and the communicator in which the processes reside.</p>

<h2>An Introduction to MPI_Gather</h2>
<p><code>MPI_Gather</code> is the inverse of <code>MPI_Scatter</code>. Instead of spreading elements from one process to many processes, <code>MPI_Gather</code> takes elements from many processes and gathers them to one single process. This routine is highly useful to many parallel algorithms, such as parallel sorting and searching. Below is a simple illustration of this algorithm.</p>

<center><img alt="MPI_Gather" class="padded shadow" width="280" height="154" src="http://images.mpitutorial.com/gather.png" /></center>

<p>Similar to <code>MPI_Scatter</code>, <code>MPI_Gather</code> takes elements from each process and gathers them to the root process. The elements are ordered by the rank of the process from which they were received. The function prototype for <code>MPI_Gather</code> is identical to that of <code>MPI_Scatter</code>.</p>
<pre>
MPI_Gather(void* send_data, int send_count, MPI_Datatype send_datatype,
           void* recv_data, int recv_count, MPI_Datatype recv_datatype,
           int root, MPI_Comm communicator)
</pre>

<p>In <code>MPI_Gather</code>, only the root process needs to have a valid receive buffer. All other calling processes can pass <code>NULL</code> for <code>recv_data</code>. Also, don't forget that the <i>recv_count</i> parameter is the count of elements received <i>per process</i>, not the total summation of counts from all processes. This can often confuse beginning MPI programmers.</p>

<h2>Computing average of numbers with MPI_Scatter and MPI_Gather</h2>
<p>In the <a href="http://www.mpitutorial.com/lessons/mpi_scatter_gather_allgather.tgz">code for this lesson</a>, I have provided an example program that computes the average across all numbers in an array. The program is in avg.c. Although the program is quite simple, it demonstrates how one can use MPI to divide work across processes, perform computation on subsets of data, and then aggregate the smaller pieces into the final answer. The program takes the following steps:</p>
<ol>
<li>Generate a random array of numbers on the root process (process 0).</li>
<li>Scatter the numbers to all processes, giving each process an equal amount of numbers.</li>
<li>Each process computes the average of their subset of the numbers.</li>
<li>Gather all averages to the root process. The root process then computes the average of these numbers to get the final average.</li>
</ol>
<p>The main part of the code with the MPI calls looks like this:</p>
<pre lang="cpp">
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
</pre>
<p>At the beginning of the code, the root process creates an array of random numbers. When <code>MPI_Scatter</code> is called, each process now contains <code>elements_per_proc</code> elements of the original data. Each process computes the average of their subset of data and then the root process gathers each individual average. The total average is computed on this much smaller array of numbers.
</p>
<p>Using the run script included in the code for this lesson, the output of your program should be similar to the following. Note that the numbers are randomly generated, so your final result might be different from mine.</p>

<pre>
>>> make
/home/kendall/bin/mpicc -o avg avg.c
>>> ./run.perl avg
/home/kendall/bin/mpirun -n 4 ./avg 100
Avg of all elements is 0.478699
Avg computed across original data is 0.478699
</pre>

<h2>MPI_Allgather and modification of average program</h2>
<p>So far, we have covered two MPI routines that perform <i>many-to-one</i> or <i>one-to-many</i> communication patterns, which simply means that many processes send/receive to one process. Oftentimes it is useful to be able to send many elements to many processes (i.e. a <i>many-to-many</i> communication pattern). <code>MPI_Allgather</code> has this characteristic.</p> 

<p>Given a set of elements distributed across all processes, <code>MPI_Allgather</code> will gather all of the elements to all the processes. In the most basic sense, <code>MPI_Allgather</code> is an <code>MPI_Gather</code> followed by an <code>MPI_Bcast</code>. The illustration below shows how data is distributed after a call to <code>MPI_Allgather</code>.</p>

<center><img alt="MPI_Gather" class="padded shadow" width="211" height="169" src="http://images.mpitutorial.com/allgather.png" /></center>

<p>Just like <code>MPI_Gather</code>, the elements from each process are gathered in order of their rank, except this time the elements are gathered to all processes. Pretty easy, right? The function declaration for <code>MPI_Allgather</code> is almost identical to MPI_Gather with the difference that there is no root process in <code>MPI_Allgather</code>.
</p>
<pre>
MPI_Allgather(void* send_data, int send_count, MPI_Datatype send_datatype,
              void* recv_data, int recv_count, MPI_Datatype recv_datatype,
              MPI_Comm communicator)
</pre>

<p>I have modified the average computation code to use <code>MPI_Allgather</code>. You can view the source in all_avg.c from the <a href="http://www.mpitutorial.com/lessons/mpi_scatter_gather_allgather.tgz">lesson code</a>. The main difference in the code is shown below.</p>
<pre lang="cpp">
// Gather all partial averages down to all the processes
float *sub_avgs = (float *)malloc(sizeof(float) * world_size);
MPI_Allgather(&sub_avg, 1, MPI_FLOAT, sub_avgs, 1, MPI_FLOAT,
              MPI_COMM_WORLD);

// Compute the total average of all numbers.
float avg = compute_avg(sub_avgs, world_size);
</pre>
<p>The partial averages are now gathered to everyone using <code>MPI_Allgather</code>. The averages are now printed off from all of the processes. Example output of the program should look like the following:</p>

<pre>
>>> make
/home/kendall/bin/mpicc -o avg avg.c
/home/kendall/bin/mpicc -o all_avg all_avg.c
>>> ./run.perl all_avg
/home/kendall/bin/mpirun -n 4 ./all_avg 100
Avg of all elements from proc 1 is 0.479736
Avg of all elements from proc 3 is 0.479736
Avg of all elements from proc 0 is 0.479736
Avg of all elements from proc 2 is 0.479736
</pre>

<p>As you may have noticed, the only difference between all_avg.c and avg.c is that all_avg.c prints the average across all processes with <code>MPI_Allgather</code>.</p>

<h2>Up Next</h2>
<p>In the next lesson, I cover an application example of using <code>MPI_Gather</code> and <code>MPI_Scatter</code> to <a href="/performing-parallel-rank-with-mpi">perform parallel rank computation</a>.</p>
<p>For all beginner lessons, go the the <a href="http://www.mpitutorial.com/beginner-mpi-tutorial/">beginner MPI tutorial</a>.</p>