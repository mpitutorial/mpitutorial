program main
  use mpi_f08
  use iso_fortran_env, only: error_unit

  implicit none
  interface
    subroutine my_bcast(data, count, datatype, root, communicator, ierror)
      import MPI_Comm, MPI_Datatype
      implicit none
      integer, intent (in)    :: count, root
      type(MPI_Comm), intent (in) :: communicator
      type(MPI_Datatype), intent (in) :: datatype
      integer, intent (inout) :: data(count)
      integer, intent (out)   :: ierror
    end subroutine my_bcast
  end interface

  integer              :: num_args, num_elements, num_trials
  character(12)        :: args(2)
  integer              :: world_rank, ierror
  double precision     :: total_my_bcast_time, total_mpi_bcast_time
  integer              :: i
  integer, allocatable :: data(:)

  num_args = command_argument_count()

  if (num_args .ne. 2) then
    write (error_unit, *) 'Usage: compare_bcast num_elements num_trials'
    stop
  end if

  call get_command_argument(1, args(1))
  call get_command_argument(2, args(2))

  read (args(1), *) num_elements
  read (args(2), *) num_trials

  call MPI_INIT()

  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank)

  total_my_bcast_time = 0.0
  total_mpi_bcast_time = 0.0

  allocate(data(num_elements))

  do i = 1, num_trials
    ! Time my_bcast
    ! Synchronize before starting timing
    call MPI_Barrier(MPI_COMM_WORLD)
    total_my_bcast_time = total_my_bcast_time - MPI_Wtime()
    call my_bcast(data, num_elements, MPI_INT, 0, MPI_COMM_WORLD, ierror)
    ! Synchronize again before obtaining final time
    call MPI_Barrier(MPI_COMM_WORLD)
    total_my_bcast_time = total_my_bcast_time + MPI_Wtime()

    ! Time MPI_Bcast
    call MPI_Barrier(MPI_COMM_WORLD)
    total_mpi_bcast_time = total_mpi_bcast_time - MPI_Wtime()
    call MPI_Bcast(data, num_elements, MPI_INT, 0, MPI_COMM_WORLD, ierror)
    call MPI_Barrier(MPI_COMM_WORLD)
    total_mpi_bcast_time = total_mpi_bcast_time + MPI_Wtime()
  end do

  ! Print off timing information
  if (world_rank .eq. 0) then
    print '("Data size = ", I0, ", Trials = ", I0)', num_elements, num_trials
    print '("Avg my_bcast time = ", ES12.5)', total_my_bcast_time / num_trials
    print '("Avg mpi_bcast time = ", ES12.5)', total_mpi_bcast_time / num_trials
  end if

  ! Finalize the MPI environment

  call MPI_FINALIZE()

end program

subroutine my_bcast(data, count, datatype, root, communicator, ierror)
  use mpi_f08
  implicit none
  integer, intent (in)    :: count, root
  type(MPI_Comm), intent (in) :: communicator
  type(MPI_Datatype), intent (in) :: datatype
  integer, intent (inout) :: data(count)
  integer, intent (out)   :: ierror

  integer :: world_rank, world_size
  integer :: i

  call MPI_COMM_SIZE(communicator, world_size, ierror)
  call MPI_COMM_RANK(communicator, world_rank, ierror)

  if (world_rank .eq. root) then
    ! If we are the root process, send our data to everyone
    do i = 0, world_size - 1
      if (i .ne. world_rank) then
        call MPI_SEND(data, count, datatype, i, 0, communicator, ierror)
      end if
    end do
  else
    ! If we are a receiver process, receive the data from the root
    call MPI_RECV(data, count, datatype, root, 0, communicator, MPI_STATUS_IGNORE, ierror)
  end if
end subroutine my_bcast