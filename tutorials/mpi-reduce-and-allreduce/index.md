---
layout: post
title: MPI Reduce and Allreduce
author: Wes Kendall
categories: Beginner MPI
tags: MPI_Allreduce, MPI_Reduce
redirect_from: '/mpi-reduce-and-allreduce/'
---

In the <a href="/performing-parallel-rank-with-mpi">previous lesson</a>, we went over an application example of using <code>MPI_Scatter</code> and <code>MPI_Gather</code> to perform parallel rank computation with MPI. We are going to expand on collective communication routines even more in this lesson by going over <code>MPI_Reduce</code> and <code>MPI_Allreduce</code>. The code for this tutorial is available as a <a href="http://www.mpitutorial.com/lessons/mpi_reduce_allreduce.tgz">tgz file</a> or can be <a href="https://github.com/wesleykendall/mpitutorial/tree/master/mpi_reduce_allreduce" target="_blank">viewed/cloned on GitHub</a>.

<h2>An introduction to reduce</h2>
"Reduce" is a classic concept from functional programming. Data reduction involves reducing a set of numbers into a smaller set of numbers via a function. For example, let's say we have a list of numbers <code>[1, 2, 3, 4, 5]</code>. Reducing this list of numbers with the sum function would produce <code>sum([1, 2, 3, 4, 5]) = 15</code>. Similarly, the multiplication reduction would yield <code>multiply([1, 2, 3, 4, 5]) = 120</code>.</p>

<p>As you might have imagined, it can be very cumbersome to apply reduction functions across a set of distributed numbers. Along with that, it is difficult to efficiently program non-commutative reductions, i.e. reductions that must occur in a set order. Luckily, MPI has a handy function called <code>MPI_Reduce</code> that will handle almost all of the common reductions that a programmer needs to do in a parallel application.</p>

<h2>MPI_Reduce</h2>
Similar to <code>MPI_Gather</code>, <code>MPI_Reduce</code> takes an array of input elements on each process and returns an array of output elements to the root process. The output elements contain the reduced result. The prototype for <code>MPI_Reduce</code> looks like this:
<pre>
MPI_Reduce(void* send_data, void* recv_data, int count,
           MPI_Datatype datatype, MPI_Op op, int root,
           MPI_Comm communicator)
</pre>
The <code>send_data</code> parameter is an array of elements of type <code>datatype</code> that each process wants to reduce. The <code>recv_data</code> is only relevant on the process with a rank of <code>root</code>. The <code>recv_data</code> array contains the reduced result and has a size of <code>sizeof(datatype) * count</code>. The <code>op</code> parameter is the operation that you wish to apply to your data. MPI contains a set of common reduction operations that can be used. Although custom reduction operations can be defined, it is beyond the scope of this lesson. The reduction operations defined by MPI include:
<ul>
    <li><code>MPI_MAX</code> - Returns the maximum element.</li>
    <li><code>MPI_MIN</code> - Returns the minimum element.</li>
    <li><code>MPI_SUM</code> - Sums the elements.</li>
    <li><code>MPI_PROD</code> - Multiplies all elements.</li>
    <li><code>MPI_LAND</code> - Performs a logical "and" across the elements.</li>
    <li><code>MPI_LOR</code> - Performs a logical "or" across the elements.</li>
    <li><code>MPI_BAND</code> - Performs a bitwise "and" across the bits of the elements.</li>
    <li><code>MPI_BOR</code> - Performs a bitwise "or" across the bits of the elements.</li>
    <li><code>MPI_MAXLOC</code> - Returns the maximum value and the rank of the process that owns it.</li>
    <li><code>MPI_MINLOC</code> - Returns the minimum value and the rank of the process that owns it.</li>
</ul>
Below is an illustration of the communication pattern of <code>MPI_Reduce</code>.

<center><img alt="MPI_Reduce" src="http://images.mpitutorial.com/mpi_reduce_1.png" width="429" height="190" /></center>

<p>In the above, each process contains one integer. MPI_Reduce is called with a root process of 0 and using <code>MPI_SUM</code> as the reduction operation. The four numbers are summed to the result and stored on the root process.</p>

<p>It is also useful to see what happens when processes contain multiple elements. The illustration below shows reduction of multiple numbers per process.</p>

<center><img alt="MPI_Reduce" src="http://images.mpitutorial.com/mpi_reduce_2.png" width="429" height="190" /></center>

<p>The processes from the above illustration each have two elements. The resulting summation happens on a per-element basis. In other words, instead of summing all of the elements from all the arrays into one element, the i<sup>th</sup> element from each array are summed into the i<sup>th</sup> element in result array of process 0.</p>

<p>Now that you understand how <code>MPI_Reduce</code> looks, we can jump into some code examples.</p>
<h2>Computing average of numbers with MPI_Reduce</h2>
In the <a href="/mpi-scatter-gather-and-allgather">previous lesson</a>, I showed you how to compute average using <code>MPI_Scatter</code> and <code>MPI_Gather</code>. Using <code>MPI_Reduce</code> simplifies the code from the last lesson quite a bit. Below is an excerpt from <a href="https://github.com/wesleykendall/mpitutorial/blob/master/mpi_reduce_allreduce/avg.c" target="_blank">avg.c</a> in the example code from this lesson.
<pre lang="cpp"> 
  float *rand_nums = NULL;
  rand_nums = create_rand_nums(num_elements_per_proc);

  // Sum the numbers locally
  float local_sum = 0;
  int i;
  for (i = 0; i &lt; num_elements_per_proc; i++) {
    local_sum += rand_nums[i];
  }

  // Print the random numbers on each process
  printf("Local sum for process %d - %f, avg = %f\n",
         world_rank, local_sum, local_sum / num_elements_per_proc);

  // Reduce all of the local sums into the global sum
  float global_sum;
  MPI_Reduce(&amp;local_sum, &amp;global_sum, 1, MPI_FLOAT, MPI_SUM, 0,
             MPI_COMM_WORLD);

  // Print the result
  if (world_rank == 0) {
    printf("Total sum = %f, avg = %f\n", global_sum,
           global_sum / (world_size * num_elements_per_proc));
  }
</pre>
<p>In the code above, each process creates random numbers and makes a <code>local_sum</code> calculation. The <code>local_sum</code> is then reduced to the root process using <code>MPI_SUM</code>. The global average is then <code>global_sum / (world_size * num_elements_per_proc)</code>. Running the code with the script yields the following results on my machine:</p>
<pre>
./run.perl avg
mpirun -n 4  ./avg 100
Local sum for process 0 - 51.385098, avg = 0.513851
Local sum for process 1 - 51.842468, avg = 0.518425
Local sum for process 2 - 49.684948, avg = 0.496849
Local sum for process 3 - 47.527420, avg = 0.475274
Total sum = 200.439941, avg = 0.501100
</pre>

<p>Now it is time to move on to the sibling of <code>MPI_Reduce</code> - <code>MPI_Allreduce</code>.</p>

<h2>MPI_Allreduce</h2>
<p>Many parallel applications will require accessing the reduced results across all processes rather than the root process. In a similar complementary style of <code>MPI_Allgather</code> to <code>MPI_Gather</code>, <code>MPI_Allreduce</code> will reduce the values and distribute the results to all processes. The function prototype is the following:</p>
<pre>
MPI_Allreduce(void* send_data, void* recv_data, int count,
              MPI_Datatype datatype, MPI_Op op, MPI_Comm communicator)
</pre>
<p>As you might have noticed, <code>MPI_Allreduce</code> is identical to <code>MPI_Reduce</code> with the exception that it does not need a root process id (since the results are distributed to all processes). The following illustrates the communication pattern of <code>MPI_Allreduce</code>:</p>

<center><img alt="MPI_Allreduce" src="http://images.mpitutorial.com/mpi_allreduce_1.png" width="429" height="190" /></center>

<p><code>MPI_Allreduce</code> is the equivalent of doing <code>MPI_Reduce</code> followed by an <code>MPI_Bcast</code>. Pretty simple, right?</p>

<h2>Computing standard deviation with MPI_Allreduce</code>
<p>
Many computational problems require doing multiple reductions to solve problems. One such problem is finding the standard deviation of a distributed set of numbers. For those that may have forgotten, standard deviation is a measure of the dispersion of numbers from their mean. A lower standard deviation means that the numbers are closer together and vice versa for higher standard deviations.
</p>
<p>To find the standard deviation, one must first compute the average of all numbers. After the average is computed, the sums of the squared difference from the mean are computed. The square root of the average of the sums is the final result. Given the problem description, we know there will be at least two sums of all the numbers, translating into two reductions. An excerpt from <a href="https://github.com/wesleykendall/mpitutorial/blob/master/mpi_reduce_allreduce/stddev.c" target="_blank">stddev.c</a> in the example code shows what this looks like in MPI.</p>

<pre lang="cpp">
  rand_nums = create_rand_nums(num_elements_per_proc);

  // Sum the numbers locally
  float local_sum = 0;
  int i;
  for (i = 0; i < num_elements_per_proc; i++) {
    local_sum += rand_nums[i];
  }

  // Reduce all of the local sums into the global sum in order to
  // calculate the mean
  float global_sum;
  MPI_Allreduce(&local_sum, &global_sum, 1, MPI_FLOAT, MPI_SUM,
                MPI_COMM_WORLD);
  float mean = global_sum / (num_elements_per_proc * world_size);

  // Compute the local sum of the squared differences from the mean
  float local_sq_diff = 0;
  for (i = 0; i < num_elements_per_proc; i++) {
    local_sq_diff += (rand_nums[i] - mean) * (rand_nums[i] - mean);
  }

  // Reduce the global sum of the squared differences to the root process
  // and print off the answer
  float global_sq_diff;
  MPI_Reduce(&local_sq_diff, &global_sq_diff, 1, MPI_FLOAT, MPI_SUM, 0,
             MPI_COMM_WORLD);

  // The standard deviation is the square root of the mean of the squared
  // differences.
  if (world_rank == 0) {
    float stddev = sqrt(global_sq_diff /
                        (num_elements_per_proc * world_size));
    printf("Mean - %f, Standard deviation = %f\n", mean, stddev);
  }
</pre>

<p>In the above code, each process computes the <code>local_sum</code> of elements and sums them using <code>MPI_Allreduce</code>. After the global sum is available on all processes, the <code>mean</code> is computed so that <code>local_sq_diff</code> can be computed. Once all of the local squared differences are computed, <code>global_sq_diff</code> is found by using <code>MPI_Reduce</code>. The root process can then compute the standard deviation by taking the square root of the mean of the global squared differences.</p>

<p>Running the example code produces output that looks like the following:</p>
<pre>
./run.perl stddev
mpirun -n 4  ./stddev 100
Mean - 0.501100, Standard deviation = 0.301126
</pre>

<h2>Up next</h2>
<p>Now that you are comfortable using all of the common collectives - <code>MPI_Bcast</code>, <code>MPI_Scatter</code>, <code>MPI_Gather</code>, and <code>MPI_Reduce</code>, we can utilize them to build a sophisticated parallel application. In the next lesson, we will utilize most of our collective routines to create a parallel sorting application. Stay tuned!
</p>
<p>For all beginner lessons, go the the <a href="/beginner-mpi-tutorial/">beginner MPI tutorial</a>.</p>