---
layout: post
title: Point-to-Point Communication Application - Random Walk
author: Wes Kendall
categories: Beginner MPI
tags:
redirect_from: '/point-to-point-communication-application-random-walk/'
---

<p>It's time to go through an application example using some of the concepts introduced in the <a href="http://www.mpitutorial.com/mpi-send-and-receive/" target="_blank">sending and receiving tutorial</a> and the <a href="http://www.mpitutorial.com/dynamic-receiving-with-mpi-probe-and-mpi-status/" target="_blank">MPI_Probe and MPI_Status lesson</a>. The code for the application can be downloaded <a href="http://www.mpitutorial.com/lessons/random_walk_app.tgz">here</a> or can be <a href="https://github.com/wesleykendall/mpitutorial/tree/master/random_walk_app" target="_blank">viewed/cloned on GitHub</a>. The application simulates a process which I refer to as "random walking." The basic problem definition of a random walk is as follows. Given a <i>Min</i>, <i>Max</i>, and random walker <i>W</i>, make walker <i>W</i> take <i>S</i> random walks of arbitrary length to the right. If the process goes out of bounds, it wraps back around. <i>S</i> can only move one unit to the right or left at a time.</p>

<center><img src="http://images.mpitutorial.com/random_walk.png" alt="Random walk illustration" width="238" height="44" class="padded shadow"></center>

<p>Although the application in itself is very basic, the parallelization of random walking can simulate the behavior of a wide variety of parallel applications. More on that later. For now, let's overview how to parallelize the random walk problem.</p>
<!--more-->
<h2>Parallelization of the Random Walking Problem</h2>
<p>Our first task, which is pertinent to many parallel programs, is splitting the domain across processes. The random walk problem has a one-dimensional domain of size <i>Max - Min + 1</i> (since <i>Max</i> and <i>Min</i> are inclusive to the walker). Assuming that walkers can only take integer-sized steps, we can easily partition the domain into near-equal-sized chunks across processes. For example, if <i>Min</i> is 0 and <i>Max</i> is 20 and we have four processes, the domain would be split like this.</p>

<center><img src="http://images.mpitutorial.com/domain_decomp.png" alt="Domain decomposition example" width="238" height="88" class="padded shadow"></center>

<p>The first three processes own five units of the domain while the last process takes the last five units plus the one remaining unit.</p>
<p>Once the domain has been partitioned, the application will initialize walkers. As explained earlier, a walker will take <i>S</i> walks with a random total walk size. For example, if the walker takes a walk of size six on process zero (using the previous domain decomposition), the execution of the walker will go like this:
<ol>
<li>The walker starts taking incremental steps. When it hits value four, however, it has reached the end of the bounds of process zero. Process zero now has to communicate the walker to process one.</li>

<center><img class="padded shadow" width="238" height="123" src="http://images.mpitutorial.com/walk_step_one.png" alt="Random walk, step one"></center>

<li>Process one receives the walker and continues walking until it has reached its total walk size of six. The walker can then proceed on a new random walk.</li>
</ol>
<p>In this example, <i>W</i> only had to be communicated one time from process zero to process one. If <i>W</i> had to take a longer walk, however, it may have needed to be passed through more processes along its path through the domain. </p>

<h2>Coding the Application using MPI_Send and MPI_Recv</h2>
<p>This application can be coded using <code>MPI_Send</code> and <code>MPI_Recv</code>. Before we begin looking at code, let's establish some preliminary characteristics and functions of the program:</p>
<ul>
<li>Each process determines their part of the domain.</li>
<li>Each process initializes exactly <i>N</i> walkers, all which start at the first value of their local domain.</li>
<li>
Each walker has two associated integer values: the current position of the walker and the number of steps left to take.
</li>
<li>
Walkers start traversing through the domain and are passed to other processes until they have completed their walk.
</li>
<li>
The processes terminate when all walkers have finished.
</li>
</ul>

<p>Let's begin by writing code for the domain decomposition. The function will take in the total domain size and find the appropriate subdomain for the MPI process. It will also give any remainder of the domain to the final process. For simplicity, I just call <code>MPI_Abort</code> for any errors that are found. The function, called <code>decompose_domain</code>, looks like this:</p>
<pre lang="cpp">
  void decompose_domain(int domain_size, int world_rank,
                        int world_size, int* subdomain_start,
                        int* subdomain_size) {
    if (world_size > domain_size) {
      // Don't worry about this special case. Assume the domain size
      // is greater than the world size.
      MPI_Abort(MPI_COMM_WORLD, 1);
    }
    *subdomain_start = domain_size / world_size * world_rank;
    *subdomain_size = domain_size / world_size;
    if (world_rank == world_size - 1) {
      // Give remainder to last process
      *subdomain_size += domain_size % world_size;
    }
  }
</pre>
<p>As you can see, the function splits the domain in even chunks, taking care of the case when a remainder is present. The function returns a subdomain start and a subdomain size.</p>

<p>Next, we need to create a function that initializes walkers. We first define a walker structure that looks like this:</p>
<pre lang="cpp">
  typedef struct {
    int location;
    int num_steps_left_in_walk;
  } Walker;
</pre>
<p>Our initialization function, called <code>initialize_walkers</code>, takes the subdomain bounds and adds walkers to an <code>incoming_walkers</code> vector (by the way, this application is in C++).</p>
<pre lang="cpp">
  void initialize_walkers(int num_walkers_per_proc, int max_walk_size,
                          int subdomain_start, int subdomain_size,
                          vector<Walker>* incoming_walkers) {
    Walker walker;
    for (int i = 0; i < num_walkers_per_proc; i++) {
      // Initialize walkers in the middle of the subdomain
      walker.location = subdomain_start;
      walker.num_steps_left_in_walk =
        (rand() / (float)RAND_MAX) * max_walk_size;
      incoming_walkers->push_back(walker);
    }
  }
</pre>
<p>After initialization, it is time to progress the walkers. Let's start off by making a walking function. This function is responsible for progressing the walker until it has finished its walk. If it goes out of local bounds, it is added to the <code>outgoing_walkers</code> vector.</p>
<pre lang="cpp">
  void walk(Walker* walker, int subdomain_start, int subdomain_size,
            int domain_size, vector<Walker>* outgoing_walkers) {
    while (walker->num_steps_left_in_walk > 0) {
      if (walker->location == subdomain_start + subdomain_size) {
        // Take care of the case when the walker is at the end
        // of the domain by wrapping it around to the beginning
        if (walker->location == domain_size) {
          walker->location = 0;
        }
        outgoing_walkers->push_back(*walker);
        break;
      } else {
        walker->num_steps_left_in_walk--;
        walker->location++;
      }
    }
  }
</pre>
<p>
Now that we have established an initialization function (that populates an incoming walker list) and a walking function (that populates an outgoing walker list), we only need two more functions: a function that sends outgoing walkers and a function that receives incoming walkers. The sending function looks like this:
</p>
<pre lang="cpp">
  void send_outgoing_walkers(vector<Walker>* outgoing_walkers, 
                             int world_rank, int world_size) {
    // Send the data as an array of MPI_BYTEs to the next process.
    // The last process sends to process zero.
    MPI_Send((void*)outgoing_walkers->data(), 
             outgoing_walkers->size() * sizeof(Walker), MPI_BYTE,
             (world_rank + 1) % world_size, 0, MPI_COMM_WORLD);
    // Clear the outgoing walkers
    outgoing_walkers->clear();
  }
</pre>
<p>The function that receives incoming walkers should use <code>MPI_Probe</code> since it does not know beforehand how many walkers it will receive. This is what it looks like:</p>
<pre lang="cpp">
  void receive_incoming_walkers(vector<Walker>* incoming_walkers,
                                int world_rank, int world_size) {
    // Probe for new incoming walkers
    MPI_Status status;
    // Receive from the process before you. If you are process zero,
    // receive from the last process
    int incoming_rank =
      (world_rank == 0) ? world_size - 1 : world_rank - 1;
    MPI_Probe(incoming_rank, 0, MPI_COMM_WORLD, &status);

    // Resize your incoming walker buffer based on how much data is
    // being received
    int incoming_walkers_size;
    MPI_Get_count(&status, MPI_BYTE, &incoming_walkers_size);
    incoming_walkers->resize(incoming_walkers_size / sizeof(Walker));
    MPI_Recv((void*)incoming_walkers->data(), incoming_walkers_size,
             MPI_BYTE, incoming_rank, 0, MPI_COMM_WORLD,
             MPI_STATUS_IGNORE); 
  }
</pre>
<p>Now we have established the main functions of the program. We have to tie all these function together as follows:</p>
<ol>
<li>Initialize the walkers.</li>
<li>Progress the walkers with the <code>walk</code> function.</li>
<li>Send out any walkers in the <code>outgoing_walkers</code> vector.</li>
<li>Receive new walkers and put them in the <code>incoming_walkers</code> vector.</li>
<li>Repeat steps two through four until all walkers have finished.</li>
</ol>
<p>The first attempt at writing this program is below. For now, we will not worry about how to determine when all walkers have finished. Before you look at the code, I must warn you - this code is incorrect! With this in mind, lets look at my code and hopefully you can see what might be wrong with it.</p>
<pre lang="cpp">
  // Find your part of the domain
  decompose_domain(domain_size, world_rank, world_size,
                   &subdomain_start, &subdomain_size);
  // Initialize walkers in your subdomain
  initialize_walkers(num_walkers_per_proc, max_walk_size,
                     subdomain_start, subdomain_size,
                     &incoming_walkers);

  while (!all_walkers_finished) { // Determine walker completion later
    // Process all incoming walkers
    for (int i = 0; i < incoming_walkers.size(); i++) {
       walk(&incoming_walkers[i], subdomain_start, subdomain_size,
            domain_size, &outgoing_walkers); 
    }

    // Send all outgoing walkers to the next process.
    send_outgoing_walkers(&outgoing_walkers, world_rank,
                          world_size);

    // Receive all the new incoming walkers
    receive_incoming_walkers(&incoming_walkers, world_rank,
                             world_size);
  }
</pre>
<p>Everything looks normal, but the order of function calls has introduced a very likely scenario - <b>deadlock</b>. </p>

<h2>Deadlock and Prevention</h2>
<p>According to Wikipedia, deadlock "<i>refers to a specific condition when two or more processes are each waiting for the other to release a resource, or more than two processes are waiting for resources in a circular chain.</i>" In our case, the above code will result in a circular chain of <code>MPI_Send</code> calls. </p>

<center><img class="padded shadow" width="308" height="68" src="http://images.mpitutorial.com/deadlock-1.png" alt="Deadlock"></center>

<p>It is worth noting that the above code will actually <b>not</b> deadlock most of the time. Although <code>MPI_Send</code> is a blocking call, the <a rel="nofollow" target="_blank" href="http://www.amazon.com/gp/product/0262692163/ref=as_li_tf_tl?ie=UTF8&tag=softengiintet-20&linkCode=as2&camp=217145&creative=399377&creativeASIN=0262692163">MPI specification</a> says that MPI_Send blocks until <b>the send buffer can be reclaimed.</b> This means that <code>MPI_Send</code> will return when the network can buffer the message. If the sends eventually can't be buffered by the network, they will block until a matching receive is posted. In our case, there are enough small sends and frequent matching receives to not worry about deadlock, however, a big enough network buffer should never be assumed.</p>
<p>
Since we are only focusing on <code>MPI_Send</code> and <code>MPI_Recv</code> in this lesson, the best way to avoid the possible sending and receiving deadlock is to order the messaging such that sends will have matching receives and vice versa. One easy way to do this is to change our loop around such that even-numbered processes send outgoing walkers before receiving walkers and odd-numbered processes do the opposite. Given two stages of execution, the sending and receiving will now look like this:</p>

<center><img class="padded shadow" width="308" height="148" src="http://images.mpitutorial.com/deadlock-2.png" alt="Deadlock prevention"></center>

<p><b>Note - Executing this with one process can still deadlock. To avoid this, simply don't perform sends and receives when using one process.</b> You may be asking, does this still work with an odd number of processes? We can go through a similar diagram again with three processes:</p>

<center><img class="padded shadow" width="260" height="218" src="http://images.mpitutorial.com/deadlock-3.png" alt="Deadlock solution"></center>

<p>As you can see, at all three stages, there is at least one posted <code>MPI_Send</code> that matches a posted <code>MPI_Recv</code>, so we don't have to worry about the occurrence of deadlock.</p>

<h2>Determining Completion of All Walkers</h2>
<p> Now comes the final step of the program - determining when every single walker has finished. Since walkers can walk for a random length, they can finish their journey on any process. Because of this, it is difficult for all processes to know when all walkers have finished without some sort of additional communication. One possible solution is to have process zero keep track of all of the walkers that have finished and then tell all the other processes when to terminate. This solution, however, is quite cumbersome since each process would have to report any completed walkers to process zero and then also handle different types of incoming messages. </p>
<p>
For this lesson, we will keep things simple. Since we know the maximum distance that any walker can travel and the smallest total size it can travel for each pair of sends and receives (the subdomain size), we can figure out the amount of sends and receives each process should do before termination. Using this characteristic of the program along with our strategy to avoid deadlock, the final main part of the program looks like this:</p>
<pre lang="cpp">
  // Find your part of the domain
  decompose_domain(domain_size, world_rank, world_size,
                   &subdomain_start, &subdomain_size);
  // Initialize walkers in your subdomain
  initialize_walkers(num_walkers_per_proc, max_walk_size,
                     subdomain_start, subdomain_size,
                     &incoming_walkers);

  // Determine the maximum amount of sends and receives needed to 
  // complete all walkers
  int maximum_sends_recvs =
    max_walk_size / (domain_size / world_size) + 1;
  for (int m = 0; m < maximum_sends_recvs; m++) {
    // Process all incoming walkers
    for (int i = 0; i < incoming_walkers.size(); i++) {
       walk(&incoming_walkers[i], subdomain_start, subdomain_size,
            domain_size, &outgoing_walkers); 
    }

    // Send and receive if you are even and vice versa for odd
    if (world_rank % 2 == 0) {
      send_outgoing_walkers(&outgoing_walkers, world_rank,
                            world_size);
      receive_incoming_walkers(&incoming_walkers, world_rank,
                               world_size);
    } else {
      receive_incoming_walkers(&incoming_walkers, world_rank,
                               world_size);
      send_outgoing_walkers(&outgoing_walkers, world_rank,
                            world_size);
    }
  }
</pre>
<h2>Running the Application</h2>
<p>The code for the application can be downloaded <a href="http://www.mpitutorial.com/lessons/random_walk_app.tgz">here</a> or can be <a href="https://github.com/wesleykendall/mpitutorial/tree/master/random_walk_app" target="_blank">viewed/cloned on GitHub</a>. In contrast to the other lessons, this code uses C++. When <a href="http://www.mpitutorial.com/installing-mpich2/">installing MPICH2</a>, you also installed the C++ MPI compiler (unless you explicitly configured it otherwise). If you installed MPICH2 in a local directory, make sure that you have set your MPICXX environment variable to point to the correct mpicxx compiler in order to use my makefile.</p>

<p>In my code, I have set up the run script to provide default values for the program: 100 for the domain size, 500 for the maximum walk size, and 20 for the number of walkers per process. The run script should spawn five MPI processes, and the output should look similar to this:</p>

<pre>
>>> tar -xzf random_walk_app.tgz
>>> cd random_walk_app
>>> make
mpicxx -o random_walk random_walk.cc
>>> ./run.perl random_walk
mpirun -n 5 ./random_walk 100 500 20
Process 2 initiated 20 walkers in subdomain 40 - 59
Process 2 sending 18 outgoing walkers to process 3
Process 3 initiated 20 walkers in subdomain 60 - 79
Process 3 sending 20 outgoing walkers to process 4
Process 3 received 18 incoming walkers
Process 3 sending 18 outgoing walkers to process 4
Process 4 initiated 20 walkers in subdomain 80 - 99
Process 4 sending 18 outgoing walkers to process 0
Process 0 initiated 20 walkers in subdomain 0 - 19
Process 0 sending 17 outgoing walkers to process 1
Process 0 received 18 incoming walkers
Process 0 sending 16 outgoing walkers to process 1
Process 0 received 20 incoming walkers
</pre>

<p>The output continues until processes finish all sending and receiving of all walkers.</p>
<h2>So What's Next?</h2>
<p>If you have made it through this entire application and feel comfortable, then good! This application is quite advanced for a first real application. If you still don't feel comfortable with <code>MPI_Send</code>, <code>MPI_Recv</code>, and <code>MPI_Probe</code>, I'd recommend going through some of the examples in <a href="http://mpitutorial.com/recommended-books/">my recommended books</a> for more practice.</p>

<p>Next, we will start learning about <i>collective</i> communication in MPI. We will start off by going over <a href="http://mpitutorial.com/mpi-broadcast-and-collective-communication/">MPI Broadcast</a>. For all beginner lessons, go to the <a href="http://mpitutorial.com/beginner-mpi-tutorial/">beginner MPI tutorial</a>.</p>
<p>Also, at the beginning, I told you that the concepts of this program are applicable to many parallel programs. I don't want to leave you hanging, so I have included some additional reading material below for anyone that wishes to learn more. Enjoy :-)</p>

<h1 class="additional-reading">Additional Reading</h1>
<h2>Random Walking and Its Similarity to Parallel Particle Tracing</h2>

<img width="150" height="198" class="nonpadded shadow" align="left" src="http://images.mpitutorial.com/tornado.png" alt="Flow visualization of tornado"><p>The random walk problem that we just coded, although seemingly trivial, can actually form the basis of simulating many types of parallel applications. Some parallel applications in the scientific domain require many types of randomized sends and receives. One example application is parallel particle tracing.</p>
<p>Parallel particle tracing is one of the primary methods that are used to visualize flow fields. Particles are inserted into the flow field and then traced along the flow using numerical integration techniques (such as Runge-Kutta). The traced paths can then be rendered for visualization purposes. One example rendering is of the tornado image at the top left. 
</p> 
<p>
Performing efficient parallel particle tracing can be very difficult. The main reason for this is because the direction in which particles travel can only be determined after each incremental step of the integration. Therefore, it is hard for processes to coordinate and balance all communication and computation. To understand this better, lets look at a typical parallelization of particle tracing.
</p>
<center><img width="417" height="919" class="nonpadded shadow" src="http://images.mpitutorial.com/parallel_particle_tracing.png" alt="Parallel particle tracing illustration"></center>
<p>In this illustration, we see that the domain is split among six process. Particles (sometimes referred to as "<i>seeds</i>") are then placed in the subdomains (similar to how we placed walkers in subdomains), and then they begin tracing. When particles go out of bounds, they have to be exchanged with processes which have the proper subdomain. This process is repeated until the particles have either left the entire domain or have reached a maximum trace length.</p>
<p>The parallel particle tracing problem can be solved with <code>MPI_Send</code>, <code>MPI_Recv</code>, and <code>MPI_Probe</code> in a similar manner to our application that we just coded. There are, however, much more sophisticated MPI routines that can get the job done more efficiently. We will talk about these in the coming lessons :-) </p>

<p>I hope you can now see at least one example of how the random walk problem is similar to other parallel applications!</p>