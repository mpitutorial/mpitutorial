program main
  use mpi_f08

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

  integer :: world_rank, ierror
  integer :: data(1)

  call MPI_INIT()
  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank)

  if (world_rank .eq. 0) then
    data = 100
    print '("Process 0 broadcasting data ", I0)', data
    call my_bcast(data, 1, MPI_INT, 0, MPI_COMM_WORLD, ierror)
  else
    call my_bcast(data, 1, MPI_INT, 0, MPI_COMM_WORLD, ierror)
    print '("Process ", I0, " received data ", I0, " from root process")', &
      world_rank, data
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
