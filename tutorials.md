---
layout: page
title: Tutorials
redirect_from: '/beginner-mpi-tutorial/'
---

Welcome to the MPI tutorials! In these tutorials, you will learn a wide array of concepts about MPI. Below are the available lessons, each of which contain example code.

The tutorials assume that the reader has a basic knowledge of C, some C++, and Linux.

## Introduction and MPI installation
* [MPI tutorial introduction]({{ site.baseurl }}/tutorials/mpi-introduction/) ([中文版]({{ site.baseurl }}/tutorials/mpi-introduction/zh_cn))
* [Installing MPICH2 on a single machine]({{ site.baseurl }}/tutorials/installing-mpich2/)
* [Launching an Amazon EC2 MPI cluster]({{ site.baseurl }}/tutorials/launching-an-amazon-ec2-mpi-cluster/)
* [Running an MPI cluster within a LAN]({{ site.baseurl }}/tutorials/running-an-mpi-cluster-within-a-lan/)
* [Running an MPI hello world application]({{ site.baseurl }}/tutorials/mpi-hello-world/) ([中文版]({{ site.baseurl }}/tutorials/mpi-hello-world/zh_cn))

## Blocking point-to-point communication
* [Sending and receiving with MPI_Send and MPI_Recv]({{ site.baseurl }}/tutorials/mpi-send-and-receive/) ([中文版]({{ site.baseurl }}/tutorials/mpi-send-and-receive/zh_cn))
* [Dynamic receiving with MPI_Probe and MPI_Status]({{ site.baseurl }}/tutorials/dynamic-receiving-with-mpi-probe-and-mpi-status/)
* [Point-to-point communication application - Random walking]({{ site.baseurl }}/tutorials/point-to-point-communication-application-random-walk/)

## Basic collective communication
* [Collective communication introduction with MPI_Bcast]({{ site.baseurl }}/tutorials/mpi-broadcast-and-collective-communication/) ([中文版]({{ site.baseurl }}/tutorials/mpi-broadcast-and-collective-communication/zh_cn))
* [Common collectives - MPI_Scatter, MPI_Gather, and MPI_Allgather]({{ site.baseurl }}/tutorials/mpi-scatter-gather-and-allgather/) ([中文版]({{ site.baseurl }}/tutorials/mpi-scatter-gather-and-allgather/zh_cn))
* [Application example - Performing parallel rank computation with basic collectives]({{ site.baseurl }}/tutorials/performing-parallel-rank-with-mpi/)

## Advanced collective communication
* [Using MPI_Reduce and MPI_Allreduce for parallel number reduction]({{ site.baseurl }}/tutorials/mpi-reduce-and-allreduce/)

## Groups and communicators
* [Introduction to groups and communicators]({{ site.baseurl }}/tutorials/introduction-to-groups-and-communicators/)
