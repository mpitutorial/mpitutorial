---
layout: post
title: Using MPI with Fortran
author: Stephen Cook
categories: Beginner MPI
tags:
translations:
redirect_from: '/mpi-fortran/'
---

The MPI specification defines bindings for use within Fortran, a programming language frequently used for scientific computing.
In this tutorial, we shall see some of the specifics for using MPI with Fortran, focussing on the similarities and differences compared to the C binding covered in the other tutorials.

> **Note** - Fortran versions of most of the MPI example code is provided on [GitHub]({{ site.github.repo }}) under [tutorials/mpi-fortran/code]({{ site.github.code }}/tutorials/mpi-fortran/code).

## Fortran Hello World code example

We shall first have a look at the Fortran 2008 version of a Hello World located in [mpi_hello_world.f90]({{ site.github.code }}/tutorials/mpi-fortran/code/mpi_hello_world.f90).

```fortran
program hello_world_mpi
  use mpi_f08

  implicit none

  integer :: world_rank, world_size
  integer :: name_len

  character (len=MPI_MAX_PROCESSOR_NAME) :: processor_name

  ! Initialize the MPI environment
  call MPI_INIT()

  ! Get the number of processes
  call MPI_COMM_SIZE(MPI_COMM_WORLD, world_size)

  ! Get the rank of the process
  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank)

  ! Get the name of the processor
  call MPI_GET_PROCESSOR_NAME(processor_name, name_len)

  ! Print off an hello world message
  print '("Hello world from processor ", A, ", rank ", I0, " out of ", I0, " processors")', &
    processor_name(:name_len), world_rank, world_size

  ! Finalize the MPI environment
  call MPI_FINALIZE()

end program
```

Comparing this with the equivalent C code in [mpi_hello_world.c]({{ site.github.code }}/tutorials/mpi-hello-world/code/mpi_hello_world.c):

```c
#include <mpi.h>
#include <stdio.h>

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
    printf("Hello world from processor %s, rank %d out of %d processors\n",
           processor_name, world_rank, world_size);

    // Finalize the MPI environment.
    MPI_Finalize();
}
```

We see many similarities but a few important differences.

## Importing and initializing MPI

In order to make MPI calls from within a Fortran program, the library must be imported and then initialized.

The modern implementation of MPI was introduced with MPI 3.0 and Fortran 2008, and is imported into the program with

```fortran
USE mpi_f08
```

The fortran binding to the MPI routines are implemented as subroutines, and require the syntax

```fortran
call MPI_XXXXXX()
```

> **Note** - Unlike C, Fortran is case insensitive.  We adopt the convention of using all-capital names of the MPI routines.

As an example, the first few lines of a fortran MPI program may look like this:

```fortran
use mpi_f08
implicit none
call MPI_INIT()
```

All the Fortran routines have an optional argument to return an error-code, so the above could could also be

```fortran
use mpi_f08
implicit none
integer :: ierror
call MPI_INIT(ierror)
```

The routine `MPI_INIT` has no required arguments and an error code can be returned as an optional argument.
Compare this with the C function `MPI_Init` which has two required arguments (the number of command-line arguments and a list of these as character arrays) and can optionally give the error code as the return value.

## Other MPI routines

Despite the differences in arguments required by the C and Fortran versions of `MPI_Init`, most other Fortran MPI routines share similar interfaces as the C implementations.
Again, the Fortran 2008 routines all end in the optional argument `IERROR`.

```fortran
program hello_world_mpi
  use mpi_f08
  integer ::  world_size
  call MPI_INIT()

  ! Get the number of processes
  call MPI_COMM_SIZE(MPI_COMM_WORLD, world_size)
  ! Alternatively:
  ! MPI_COMM_SIZE(MPI_COMM_WORLD, world_size, ierror)
```

Fortran versions of most of the C MPI example code from these tutorials has been translated to Fortran and is provided on [GitHub]({{ site.github.repo }}) under [tutorials/mpi-fortran/code]({{ site.github.code }}/tutorials/mpi-fortran/code).
These have mostly been written to mirror the C versions, with some Fortran-specific functionality added where it does not impact the MPI code (such as using the fortran function `sum` instead of performing a summation in a loop).

## Older MPI implementations

Prior to the introduction of `mpi_f08`, the library was imported with the syntax

```fortran
USE mpi
```

or the Fortran77 compatible

```fortran
INCLUDE 'mpif.h'
```

In the older versions of the interface (both `mpi` and `mpif.h`), most of the arguments such as the communicator object or the probe return status are integers or arrays of integers.
In the newer syntax, these objects are implemented as custom typedefs (as in the C interface) leading to better compile-time argument checking.
There is also an error code returned with all MPI calls, which is a required argument in the older versions, and an optional argument in the modern implementation.
