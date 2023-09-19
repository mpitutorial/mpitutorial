program send_recv
  use mpi

  implicit none

  integer :: world_rank, world_size, ierror
  integer :: num
  integer :: recv_status(MPI_STATUS_SIZE)


  call MPI_INIT(ierror)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, world_size, ierror)
  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank, ierror)

  if (world_rank .eq. 0) then
    num = -1
    call MPI_SEND(num, 1, MPI_INT, 1, 0, &
                  MPI_COMM_WORLD, ierror)
  else if (world_rank .eq. 1) then
    call MPI_RECV(num, 1, MPI_INT, 0, 0, &
                  MPI_COMM_WORLD, recv_status, ierror)
    print '("Process 1 received number ", I0, " from process 0")', num
  end if

  call MPI_FINALIZE(ierror)

end program
