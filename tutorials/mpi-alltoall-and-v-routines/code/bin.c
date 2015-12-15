// Author: Wes Kendall
// Copyright 2014 www.mpitutorial.com
// This code is provided freely with the tutorials on mpitutorial.com. Feel
// free to modify it for your own use. Any distribution of the code must
// either provide a link to www.mpitutorial.com or keep this header intact.
//
// A program that bins random numbers using MPI_Alltoallv.
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mpi.h>

// Creates an array of random numbers for binning. Note that the numbers are
// between [0, 1)
float *create_random_numbers(int numbers_per_proc) {
  float *random_numbers = (float *)malloc(sizeof(float) * numbers_per_proc);
  int i;
  for (i = 0; i < numbers_per_proc; i++) {
    int r = rand();
    // Make sure that the random number is never exactly one.
    if (r == RAND_MAX) {
      r--;
    }
    random_numbers[i] = rand() / (float)(RAND_MAX);
  }
  return random_numbers;
}

// Given a number, determine which process owns it. Since numbers are from [0, 1),
// simply multiple the number by the size of the MPI world to figure out which
// process owns it
int which_process_owns_this_number(float rand_num, int world_size) {
  return (int)(rand_num * world_size);
}

// Gets the starting value for a process's bin
float get_bin_start(int world_rank, int world_size) {
  return (float)world_rank / world_size;
}

// Gets the ending value for a process's bin
float get_bin_end(int world_rank, int world_size) {
  return get_bin_start(world_rank + 1, world_size);
}

// This function returns the amount of numbers that will be sent to each
// process given the array of random numbers.
int *get_send_amounts_per_proc(float *rand_nums, int numbers_per_proc,
                               int world_size) {
  int *send_amounts_per_proc = (int *)malloc(sizeof(int) * world_size);
  // Initialize the amount of numbers per process to zero
  memset(send_amounts_per_proc, 0, sizeof(int) * world_size);

  // For each random number, determine which process owns it and increment
  // the amount of numbers for that process.
  int i;
  for (i = 0; i < numbers_per_proc; i++) {
    int owning_rank = which_process_owns_this_number(rand_nums[i], world_size);
    send_amounts_per_proc[owning_rank]++;
  }

  return send_amounts_per_proc;
}

// Given how many numbers each process is sending to the other processes, find
// out how many numbers you are receiving from each process. This function
// returns an array of counts indexed on the rank of the process from which it
// will receive the numbers.
int *get_recv_amounts_per_proc(int *send_amounts_per_proc, int world_size) {
  int *recv_amounts_per_proc = (int *)malloc(sizeof(int) * world_size);

  // Perform an Alltoall for the send counts. This will send the send counts
  // from each process and place them in the recv_amounts_per_proc array of
  // the receiving processes to let them know how many numbers they will
  // receive when binning occurs.
  MPI_Alltoall(send_amounts_per_proc, 1, MPI_INT, recv_amounts_per_proc, 1,
               MPI_INT, MPI_COMM_WORLD);
  return recv_amounts_per_proc;
}

// Given an array (of size "size") of counts, return the prefix sum of the
// counts.
int *prefix_sum(int *counts, int size) {
  int *prefix_sum_result = (int *)malloc(sizeof(int) * size);
  prefix_sum_result[0] = 0;
  int i;
  for (i = 1; i < size; i++) {
    prefix_sum_result[i] = prefix_sum_result[i - 1] + counts[i - 1];
  }
  return prefix_sum_result;
}

// Returns the sum of an array
int sum(int *arr, int size) {
  int sum_result = 0;
  int i;
  for (i = 0; i < size; i++) {
    sum_result += arr[i];
  }
  return sum_result;
}

// Used for sorting floating point numbers
int compare_float(const void *a, const void *b) {
  if (*(float *)a < *(float *)b) {
    return -1;
  } else if (*(float *)a > *(float *)b) {
    return 1;
  } else {
    return 0;
  }
}

// Verifies that the binned numbers belong to the process.
void verify_bin_nums(float *binned_nums, int num_count, int world_rank,
                     int world_size) {
  int i;
  float bin_start = get_bin_start(world_rank, world_size);
  float bin_end = get_bin_end(world_rank, world_size);
  for (i = 0; i < num_count; i++) {
    if (binned_nums[i] >= bin_end || binned_nums[i] < bin_start) {
      fprintf(stderr, "Error: Binned number %f exceeds bin range [%f - %f) for process %d\n",
              binned_nums[i], bin_start, bin_end, world_rank);
    }
  }
}

int main(int argc, char** argv) {
  if (argc != 2) {
    fprintf(stderr, "Usage: bin numbers_per_proc\n");
    exit(1);
  }

  // Get the amount of random numbers to create per process
  int numbers_per_proc = atoi(argv[1]);

  MPI_Init(NULL, NULL);

  int world_rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
  int world_size;
  MPI_Comm_size(MPI_COMM_WORLD, &world_size);

  // Seed the random number generator to get different results each time
  srand(time(NULL) * world_rank);

  // Create the random numbers on this process. Note that all numbers
  // will be between 0 and 1
  float *rand_nums = create_random_numbers(numbers_per_proc);

  // Given the array of random numbers, determine how many will be sent
  // to each process (based on the which process owns the number).
  // The return value from this function is an array of counts
  // for each rank in the communicator.
  // The count represents how many numbers each process will receive
  // when they are binned from this process.
  int *send_amounts_per_proc = get_send_amounts_per_proc(rand_nums,
                                                         numbers_per_proc,
                                                         world_size);

  // Determine how many numbers you will receive from each process. This
  // information is needed to set up the binning call.
  int *recv_amounts_per_proc = get_recv_amounts_per_proc(send_amounts_per_proc,
                                                         world_size);

  // Do a prefix sum for the send/recv amounts to get the send/recv offsets for
  // the MPI_Alltoallv call (the binning call).
  int *send_offsets_per_proc = prefix_sum(send_amounts_per_proc, world_size);
  int *recv_offsets_per_proc = prefix_sum(recv_amounts_per_proc, world_size);

  // Allocate an array to hold the binned numbers for this process based on the total
  // amount of numbers this process will receive from others.
  int total_recv_amount = sum(recv_amounts_per_proc, world_size);
  float *binned_nums = (float *)malloc(sizeof(float) * total_recv_amount);

  // The final step before binning - arrange all of the random numbers so that they
  // are ordered by bin. For simplicity, we are simply going to sort the random
  // numbers, however, this could be optimized since the numbers don't need to be
  // fully sorted.
  qsort(rand_nums, numbers_per_proc, sizeof(float), &compare_float);

  // Perform the binning step with MPI_Alltoallv. This will send all of the numbers in
  // the rand_nums array to their proper bin. Each process will only contain numbers
  // belonging to its bin after this step. For example, if there are 4 processes, process
  // 0 will contain numbers in the [0, .25) range.
  MPI_Alltoallv(rand_nums, send_amounts_per_proc, send_offsets_per_proc, MPI_FLOAT,
                binned_nums, recv_amounts_per_proc, recv_offsets_per_proc, MPI_FLOAT,
                MPI_COMM_WORLD);

  // Print results
  printf("Process %d received %d numbers in bin [%f - %f)\n", world_rank, total_recv_amount,
         get_bin_start(world_rank, world_size), get_bin_end(world_rank, world_size));

  // Check that the bin numbers are correct
  verify_bin_nums(binned_nums, total_recv_amount, world_rank, world_size);

  MPI_Barrier(MPI_COMM_WORLD);
  MPI_Finalize();

  // Clean up
  free(rand_nums);
  free(send_amounts_per_proc);
  free(recv_amounts_per_proc);
  free(send_offsets_per_proc);
  free(recv_offsets_per_proc);
  free(binned_nums);
}
