// Author: Wes Kendall
// Copyright 2013 www.mpitutorial.com
// This code is provided freely with the tutorials on mpitutorial.com. Feel
// free to modify it for your own use. Any distribution of the code must
// either provide a link to www.mpitutorial.com or keep this header in tact.
//
// Code that performs a parallel rank
//
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <assert.h>

typedef struct {
  int comm_rank;
  union {
    float f;
    int i;
  } number;
} CommRankNumber;

// Gathers numbers for MPI_Rank to process zero. Allocates enough space given the MPI datatype and
// returns a void * buffer to process 0. It returns NULL to all other processes.
void *gather_numbers_to_root(void *number, MPI_Datatype datatype, MPI_Comm comm) {
  int world_rank, world_size;
  MPI_Comm_rank(comm, &world_rank);
  MPI_Comm_size(comm, &world_size);

  // Allocate an array on the root process of a size depending on the MPI datatype being used.
  int datatype_size;
  MPI_Type_size(datatype, &datatype_size);
  void *gathered_numbers;
  if (world_rank == 0) {
    gathered_numbers = malloc(datatype_size * world_size);
  }

  // Gather all of the numbers on the root process
  MPI_Gather(number, 1, datatype, gathered_numbers, 1, datatype, 0, comm);

  return gathered_numbers;
}

// Gets the rank of the recv_buf, which is of type datatype. The rank is returned
// in send_buf and is of type datatype.  
int MPI_Rank(void *send_buf, void *recv_buf, MPI_Datatype datatype, MPI_Comm comm) {
  // Check base cases first - Only support MPI_INT and MPI_FLOAT for this function.
  if (datatype != MPI_INT && datatype != MPI_FLOAT) {
    return MPI_ERR_TYPE;
  }

  // To calculate the rank, we must gather the numbers to one process, sort the numbers, and then
  // scatter the resulting rank values. Start by gathering the numbers on process 0 of comm.
  void *numbers = gather_numbers_to_root(send_buf, datatype, comm);
}


int main(int argc, char** argv) {
  if (argc != 2) {
    fprintf(stderr, "Usage: parallel_rank\n");
    exit(1);
  }

  MPI_Init(NULL, NULL);

  int world_rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
  int world_size;
  MPI_Comm_size(MPI_COMM_WORLD, &world_size);
  
  // Seed the random number generator to get different results each time
  srand(time(NULL) * world_rank);

  float rand_num = rand() / (float)RAND_MAX;
  int rank;
  MPI_Rank(&rand_num, &rank, MPI_FLOAT, MPI_COMM_WORLD);
  printf("Rank for %f on process %d - %d\n", rand_num, world_rank, rank);
 
  MPI_Barrier(MPI_COMM_WORLD);
  MPI_Finalize();
}
