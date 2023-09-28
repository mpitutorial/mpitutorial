module subs
  implicit none
contains
  subroutine create_rand_nums(rand_nums, num_elements)
    ! Creates an array of random numbers. Each number has a value from 0 - 1
    integer, intent(in) :: num_elements
    real, intent(out)   :: rand_nums(num_elements)

    integer :: i

    do i = 1, num_elements
      rand_nums(i) = rand()
    end do

  end subroutine create_rand_nums
end module subs

program main
  use mpi
  use iso_fortran_env, only: error_unit
  use subs

  implicit none

  integer :: num_args
  character(12) :: arg
  integer :: num_elements_per_proc
  integer :: world_size, world_rank, ierror
  real :: r, local_sum, global_sum
  real, allocatable :: rand_nums(:)

  num_args = command_argument_count()

  if (num_args .ne. 1) then
    write (error_unit, *) 'Usage: reduce_avg num_elements_per_proc'
    stop
  end if

  call get_command_argument(1, arg)
  read (arg, *) num_elements_per_proc

  call MPI_INIT(ierror)

  call MPI_COMM_SIZE(MPI_COMM_WORLD, world_size, ierror)
  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank, ierror)

  ! Create a random array of elements on all processes.
  call srand(time()) ! Seed the random number generator to get different results each time for each processor
  ! Throw away first rand value
  r = rand()
  allocate(rand_nums(num_elements_per_proc))
  call create_rand_nums(rand_nums, num_elements_per_proc)

  ! Sum the numbers locally
  local_sum = sum(rand_nums)

  ! Print the random numbers on each process
  print '("Local sum for process ", I0, " - ", ES12.5, ", avg = ", ES12.5)', &
        world_rank, local_sum, local_sum / real(num_elements_per_proc)


  ! Reduce all of the local sums into the global sum
  call MPI_Reduce(local_sum, global_sum, 1, MPI_FLOAT, MPI_SUM, 0, &
                  MPI_COMM_WORLD, ierror)

  ! Print the result
  if (world_rank .eq. 0) then
    print '("Total sum = ", ES12.5, ", avg = ", ES12.5)', global_sum, &
          global_sum / (world_size * num_elements_per_proc)
  end if

  ! Clean up
  deallocate(rand_nums)

  call MPI_Barrier(MPI_COMM_WORLD, ierror)
  call MPI_FINALIZE(ierror)

end program main
