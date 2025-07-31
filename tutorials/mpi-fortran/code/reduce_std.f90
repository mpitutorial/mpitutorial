program main
  use mpi_f08
  use iso_fortran_env, only: error_unit
  use subs

  implicit none

  integer :: num_args
  character(12) :: arg
  integer :: num_elements_per_proc
  integer :: world_size, world_rank
  real :: local_sum, global_sum, mean, local_sq_diff, global_sq_diff, stddev
  real, allocatable :: rand_nums(:)
  integer :: i

  num_args = command_argument_count()

  if (num_args .ne. 1) then
    write (error_unit, *) 'Usage: reduce_std num_elements_per_proc'
    stop
  end if

  call get_command_argument(1, arg)
  read (arg, *) num_elements_per_proc

  call MPI_INIT()

  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, world_size)

  ! Create a random array of elements on all processes.
  call random_seed() ! Seed the random number generator of processes uniquely
  allocate(rand_nums(num_elements_per_proc))
  call random_number(rand_nums)

  ! Sum the numbers locally
  local_sum = sum(rand_nums)

  ! Reduce all of the local sums into the global sum in order to
  ! calculate the mean
  call MPI_Allreduce(local_sum, global_sum, 1, MPI_FLOAT, MPI_SUM, &
                     MPI_COMM_WORLD)
  mean = global_sum / real(num_elements_per_proc * world_size)

  ! Compute the local sum of the squared differences from the mean
  local_sq_diff = 0.0
  do i = 1, num_elements_per_proc
    local_sq_diff = local_sq_diff + (rand_nums(i) - mean) * (rand_nums(i) - mean)
  end do

  ! Reduce the global sum of the squared differences to the root process
  ! and print off the answer
  call MPI_Reduce(local_sq_diff, global_sq_diff, 1, MPI_FLOAT, MPI_SUM, 0, &
                  MPI_COMM_WORLD)

  ! The standard deviation is the square root of the mean of the squared
  ! differences
  if (world_rank .eq. 0) then
    stddev = sqrt(global_sq_diff / (num_elements_per_proc * world_size))
    print '("Mean - ", ES12.5, ", Standard deviation = ", ES12.5)', &
          mean, stddev
  end if

  ! Clean up
  deallocate(rand_nums)

  call MPI_Barrier(MPI_COMM_WORLD)
  call MPI_FINALIZE()

end program main
