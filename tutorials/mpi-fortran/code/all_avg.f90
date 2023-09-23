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

  function compute_avg(array, num_elements)
    ! Computes the average of an array of numbers
    real                :: compute_avg
    integer, intent(in) :: num_elements
    real, intent(in)    :: array(num_elements)

    compute_avg = sum(array) / real(num_elements)
  end function compute_avg
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
  real :: r, sub_avg, avg, original_data_avg
  real, allocatable :: rand_nums(:), sub_rand_nums(:), sub_avgs(:)

  num_args = command_argument_count()

  if (num_args .ne. 1) then
    write (error_unit, *) 'Usage: avg num_elements_per_proc'
    stop
  end if

  call get_command_argument(1, arg)

  read (arg, *) num_elements_per_proc
  ! Seed the random number generator to get different results each time
  call srand(time())
  ! Throw away first rand value
  r = rand()

  call MPI_INIT(ierror)

  call MPI_COMM_SIZE(MPI_COMM_WORLD, world_size, ierror)
  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank, ierror)

  ! Create a random array of elements on the root process. Its total
  ! size will be the number of elements per process times the number
  ! of processes
  if (world_rank .eq. 0) then
    allocate(rand_nums(num_elements_per_proc * world_size))
    call create_rand_nums(rand_nums, num_elements_per_proc * world_size)
  end if

  allocate(sub_rand_nums(num_elements_per_proc))

  call MPI_Scatter(rand_nums, num_elements_per_proc, MPI_FLOAT, sub_rand_nums, &
                   num_elements_per_proc, MPI_FLOAT, 0, MPI_COMM_WORLD, ierror)

  ! Compute the average of your subset
  sub_avg = compute_avg(sub_rand_nums, num_elements_per_proc)

  ! Gather all partial averages down to all the processes
  allocate(sub_avgs(world_size))
  call MPI_Allgather(sub_avg, 1, MPI_FLOAT, sub_avgs, 1, MPI_FLOAT, MPI_COMM_WORLD, ierror)

  ! Now that we have all of the partial averages, compute the
  ! total average of all numbers. Since we are assuming each process computed
  ! an average across an equal amount of elements, this computation will
  ! produce the correct answer.
  avg = compute_avg(sub_avgs, world_size)
  print '("Avg of all elements from proc ", I0, " is ", ES12.5)', world_rank, avg

  ! Clean up
  if (world_rank .eq. 0) then
    deallocate(rand_nums)
  end if
  deallocate(sub_avgs)
  deallocate(sub_rand_nums)

  call MPI_Barrier(MPI_COMM_WORLD, ierror)
  call MPI_FINALIZE(ierror)

end program main
