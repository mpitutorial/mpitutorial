subroutine my_bcast(data, count, datatype, root, communicator)
  integer, intent (inout) :: data
  integer, intent (in) :: count, root, communicator, datatype

  integer world_rank, world_size, ierror
  integer i

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
end subroutine

program main
  implicit none

  include 'mpif.h'

  integer world_rank, ierror
  integer data

  call MPI_INIT(ierror)
  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank, ierror)

  if (world_rank .eq. 0) then
    data = 100
    print '("Process 0 broadcasting data ", I0)', data
    call my_bcast(data, 1, MPI_INT, 0, MPI_COMM_WORLD)
  else
    call my_bcast(data, 1, MPI_INT, 0, MPI_COMM_WORLD)
    print '("Process ", I0, " received data ", I0, " from root process")', &
      world_rank, data
  end if

  ! Finalize the MPI environment
  call MPI_FINALIZE(ierror)

end program

