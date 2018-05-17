---
layout: post
title: MPI Tutorial Introduction
author: Wes Kendall
categories: Beginner MPI
tags:
translations: zh_cn
redirect_from: '/mpi-introduction/'
---

Parallel computing is now as much a part of everyone's life as personal computers, smart phones, and other technologies are. You obviously understand this, because you have embarked upon the MPI Tutorial website. Whether you are taking a class about parallel programming, learning for work, or simply learning it because it's fun, you have chosen to learn a skill that will remain incredibly valuable for years to come. In my opinion, you have also taken the right path to expanding your knowledge about parallel programming - by learning the Message Passing Interface (MPI). Although MPI is lower level than most parallel programming libraries (for example, Hadoop), it is a great foundation on which to build your knowledge of parallel programming.

Before I dive into MPI, I want to explain why I made this resource. When I was in graduate school, I worked extensively with MPI. I was fortunate enough to work with important figures in the MPI community during my internships at [Argonne National Laboratory](http://www.anl.gov) and to use MPI on large supercomputing resources to do crazy things in my doctoral research. However, even with access to all of these resources and knowledgeable people, I still found that learning MPI was a difficult process.

Learning MPI was difficult for me because of three main reasons. First of all, the online resources for learning MPI were mostly outdated or not that thorough. Second, it was hard to find any resources that detailed how I could easily build or access my own cluster. And finally, the cheapest MPI book at the time of my graduate studies was a whopping 60 dollars - a hefty price for a graduate student to pay. Given how important parallel programming is in our day and time, I feel it is equally important for people to have access to better information about one of the fundamental interfaces for writing parallel applications.

Although I am by no means an MPI expert, I decided that it would be useful for me to disseminate all of the information I learned about MPI during graduate school in the form of easy tutorials with example code that can be executed on your *very own* cluster! I hope this resource will be a valuable tool for your career, studies, or life - because parallel programming is not only the present, it *is* the future.

## A brief history of MPI
Before the 1990's, programmers weren't as lucky as us. Writing parallel applications for different computing architectures was a difficult and tedious task. At that time, many libraries could facilitate building parallel applications, but there was not a standard accepted way of doing it.

During this time, most parallel applications were in the science and research domains. The model most commonly adopted by the libraries was the message passing model. What is the message passing model? All it means is that an application passes messages among processes in order to perform a task. This model works out quite well in practice for parallel applications. For example, a master process might assign work to slave processes by passing them a message that describes the work. Another example is a parallel merge sorting application that sorts data locally on processes and passes results to neighboring processes to merge sorted lists. Almost any parallel application can be expressed with the message passing model.

Since most libraries at this time used the same message passing model with only minor feature differences among them, the authors of the libraries and others came together at the Supercomputing 1992 conference to define a standard interface for performing message passing - the Message Passing Interface. This standard interface would allow programmers to write parallel applications that were portable to all major parallel architectures. It would also allow them to use the features and models they were already used to using in the current popular libraries.

By 1994, a complete interface and standard was defined (MPI-1). Keep in mind that MPI is *only* a definition for an interface. It was then up to developers to create implementations of the interface for their respective architectures. Luckily, it only took another year for complete implementations of MPI to become available. After its first implementations were created, MPI was widely adopted and still continues to be the *de-facto* method of writing message-passing applications.

![An accurate representation of the first MPI programmers.](90s_nerd.jpg)
*An accurate representation of the first MPI programmers.*

## MPI's design for the message passing model
Before starting the tutorial, I will cover a couple of the classic concepts behind MPI's design of the message passing model of parallel programming. The first concept is the notion of a *communicator*. A communicator defines a group of processes that have the ability to communicate with one another. In this group of processes, each is assigned a unique *rank*, and they explicitly communicate with one another by their ranks.

The foundation of communication is built upon send and receive operations among processes. A process may send a message to another process by providing the rank of the process and a unique *tag* to identify the message. The receiver can then post a receive for a message with a given tag (or it may not even care about the tag), and then handle the data accordingly. Communications such as this which involve one sender and receiver are known as *point-to-point* communications.

There are many cases where processes may need to communicate with everyone else. For example, when a master process needs to broadcast information to all of its worker processes. In this case, it would be cumbersome to write code that does all of the sends and receives. In fact, it would often not use the network in an optimal manner. MPI can handle a wide variety of these types of *collective* communications that involve all processes.

Mixtures of point-to-point and collective communications can be used to create highly complex parallel programs. In fact, this functionality is so powerful that it is not even necessary to start describing the advanced mechanisms of MPI. We will save that until a later lesson. For now, you should work on [installing MPI on a single machine]({{ site.baseurl }}/tutorials/installing-mpich2/) or [launching an Amazon EC2 MPI cluster]({{ site.baseurl }}/tutorials/launching-an-amazon-ec2-mpi-cluster/). If you already have MPI installed, great! You can head over to the [MPI Hello World lesson]({{ site.baseurl }}/tutorials/mpi-hello-world).
