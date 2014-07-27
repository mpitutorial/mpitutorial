---
layout: post
title: MPI Hello World
author: Wes Kendall
categories: Beginner MPI
tags: MPI_Comm_rank, MPI_Comm_size, MPI_Finalize, MPI_Get_processor_name, MPI_Init
redirect_from: '/mpi-hello-world/'
---

<p>In this lesson, I will show you a basic MPI Hello World application and also discuss how to run an MPI program. The lesson will cover the basics of initializing MPI and running an MPI job across several processes. This lesson is intended to work with installations of MPICH2 (specifically 1.4). If you have not installed MPICH2, please refer back to the <a href="http://www.mpitutorial.com/installing-mpich2">installing MPICH2 lesson</a>.</p>

> **Note** - All of the code for this site is on [Gitub]({{ site.github.repo }}). This tutorial is under [tutorials/mpi-hello-world/code]({{ site.github.code }}/tutorials/mpi-hello-world/code).

<h2>MPI Hello World</h2>
First of all, the source code for this lesson can be downloaded <a href="http://www.mpitutorial.com/lessons/mpi_hello_world.tgz">here</a> or can be <a href="https://github.com/wesleykendall/mpitutorial/tree/master/mpi_hello_world" target="_blank">viewed/cloned on GitHub</a>. Download it, extract it, and change to the example directory. The directory should contain three files: makefile, mpi_hello_world.c, and run.perl. Here is the output from my terminal for downloading and extracting the example code.</p>

<pre>
>>> wget http://www.mpitutorial.com/lessons/mpi_hello_world.tgz
--2011-06-20 19:33:54-- http://www.mpitutorial.com/lessons/mpi_hello_world.tgz
Resolving www.mpitutorial.com... 50.56.34.184
Connecting to www.mpitutorial.com|50.56.34.184|80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1162 (1.1K) [application/x-gzip]
Saving to: `mpi_hello_world.tgz'<br/>

100%[============================>] 1,162        --.-K/s    in 0s<br/>

2011-06-20 19:33:54 (222 MB/s) - `mpi_hello_world.tgz' saved [1162/1162]<br/>

>>> tar -xzf mpi_hello_world.tgz
>>> cd mpi_hello_world
>>> ls
makefile  mpi_hello_world.c  run.perl
</pre>

<p>Open the mpi_hello_world.c source code. Below are some excerpts from the code.</p>
<pre lang="cpp">
#include <mpi.h>;

int main(int argc, char** argv) {
  // Initialize the MPI environment
  MPI_Init(NULL, NULL);

  // Get the number of processes
  int world_size;
  MPI_Comm_size(MPI_COMM_WORLD, &world_size);

  // Get the rank of the process
  int world_rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

  // Get the name of the processor
  char processor_name[MPI_MAX_PROCESSOR_NAME];
  int name_len;
  MPI_Get_processor_name(processor_name, &name_len);

  // Print off a hello world message
  printf("Hello world from processor %s, rank %d"
         " out of %d processors\n",
         processor_name, world_rank, world_size);

  // Finalize the MPI environment.
  MPI_Finalize();
}
</pre>
<p>You will notice that the first step to building an MPI program is including the MPI header files with <code>#include &lt;mpi.h&gt;</code>. After this, the MPI environment must be initialized with:
<pre>MPI_Init(int *argc, char ***argv)</pre>
<p> During <code>MPI_Init</code>, all of MPI's global and internal variables are constructed. For example, a communicator is formed around all of the processes that were spawned, and unique ranks are assigned to each process. Currently, <code>MPI_Init</code> takes two arguments that are not necessary, and the extra parameters are simply left as extra space in case future implementations might need them.</p>
<p>After <code>MPI_Init</code>, there are two main functions that are called. These two functions are used in almost every single MPI program that you will write.</p>

<pre>MPI_Comm_size(MPI_Comm communicator, int* size)
</pre>
<p><code>MPI_Comm_size</code> returns the size of a communicator. In our example, <code>MPI_COMM_WORLD</code> (which is constructed for us by MPI) encloses all of the processes in the job, so this call should return the amount of processes that were requested for the job.</p>

<pre>
MPI_Comm_rank(MPI_Comm communicator, int* rank)
</pre> 
<p>
<code>MPI_Comm_rank</code> returns the rank of a process in a communicator. Each process inside of a communicator is assigned an incremental rank starting from zero. The ranks of the processes are primarily used for identification purposes when sending and receiving messages.
</p>

<p>A miscellaneous and less-used function in this program is:</p>
<pre>
MPI_Get_processor_name(char* name, int* name_length)
</pre>
<p><code>MPI_Get_processor_name</code> obtains the actual name of the processor on which the process is executing. The final call in this program is:</p>
<pre>MPI_Finalize()</pre>
<p><code>MPI_Finalize</code> is used to clean up the MPI environment. No more MPI calls can be made after this one.</p>
</p>

<h2>Running MPI Hello World</h2>
Now compile the example by typing <code>make</code>. My makefile looks for the MPICC environment variable. If you installed MPICH2 to a local directory, set your MPICC environment variable to point to your mpicc binary. The mpicc program in your installation is really just a wrapper around gcc, and it makes compiling and linking all of the necessary MPI routines much easier. </p>

<pre>
>>> export MPICC=/home/kendall/bin/mpicc
>>> make
/home/kendall/bin/mpicc -o mpi_hello_world mpi_hello_world.c
</pre>

<p>After your program is compiled, it is ready to be executed. Now comes the part where you might have to do some additional configuration. If you are running MPI programs on a cluster of nodes, you will have to set up a host file. If you are simply running MPI on a laptop or a single machine, disregard the next piece of information.</p>

<p>The host file contains names of all of the computers on which your MPI job will execute. For ease of execution, you should be sure that all of these computers have SSH access, and you should also <a target="_blank" rel="nofollow" href="http://www.eng.cam.ac.uk/help/jpmg/ssh/authorized_keys_howto.html">setup an authorized keys file</a> to avoid a password prompt for SSH. My host file looks like this.</p>

<pre>
>>> cat host_file
cetus1
cetus2
cetus3
cetus4
</pre>

<p>For the run script that I have provided in the download, you should set an environment variable called MPI_HOSTS and have it point to your hosts file. My script will automatically include it in the command line when the MPI job is launched. If you do not need a hosts file, simply do not set the environment variable. Also, if you have a local installation of MPI, you should set the MPIRUN environment variable to point to the mpirun binary from the installation. After this, call <code>./run.perl mpi_hello_world</code> to run the example application.</p>

<pre>
>>> export MPIRUN=/home/kendall/bin/mpirun
>>> export MPI_HOSTS=host_file
>>> ./run.perl mpi_hello_world
/home/kendall/bin/mpirun -n 4 -f host_file ./mpi_hello_world
Hello world from processor cetus2, rank 1 out of 4 processors
Hello world from processor cetus1, rank 0 out of 4 processors
Hello world from processor cetus4, rank 3 out of 4 processors
Hello world from processor cetus3, rank 2 out of 4 processors
</pre>

<p>As expected, the MPI program was launched across all of the hosts in my host file. Each process was assigned a unique rank, which was printed off along with the process name. As one can see from my example output, the output of the processes is in an arbitrary order since there is no synchronization involved before printing.</p>

<p>Notice how the script called mpirun. This is program that the MPI implementation uses to launch the job. Processes are spawned across all the hosts in the host file and the MPI program executes across each process. My script automatically supplies the <i>-n</i> flag to set the number of MPI processes to four. Try changing the run script and launching more processes! Don't accidentally crash your system though. :-)</p>

<p>Now you might be asking, <i>"My hosts are actually dual-core machines. How can I get MPI to spawn processes across the individual cores first before individual machines?"</i> The solution is pretty simple. Just modify your hosts file and place a colon and the number of cores per processor after the host name. For example, I specified that each of my hosts has two cores.</p>

<pre>
>>> cat host_file
cetus1:2
cetus2:2
cetus3:2
cetus4:2
</pre>

<p>When I execute the run script again, <i>voila!</i>, the MPI job spawns two processes on only two of my hosts.</p>

<pre>
>>> ./run.perl mpi_hello_world
/home/kendall/bin/mpirun -n 4 -f host_file ./mpi_hello_world
Hello world from processor cetus1, rank 0 out of 4 processors
Hello world from processor cetus2, rank 2 out of 4 processors
Hello world from processor cetus2, rank 3 out of 4 processors
Hello world from processor cetus1, rank 1 out of 4 processors
</pre>

<h2>Up Next</h2>
<p>Now that you have a basic understanding of how an MPI program is executed, it is now time to learn fundamental point-to-point communication routines. In the next lesson, I cover <a href="http://www.mpitutorial.com/mpi-send-and-receive/">basic sending and receiving routines in MPI</a>. Feel free to also examine the <a href="http://www.mpitutorial.com/beginner-mpi-tutorial">beginner MPI tutorial</a> for a complete reference of all of the beginning MPI lessons.</p>

<p>Having trouble? Confused? Feel free to leave a comment below and perhaps I or another reader can be of help.</p>