program send_recv
  use mpi_f08

  implicit none

  integer :: world_rank, world_size
  integer :: num
  type(MPI_Status) :: recv_status


  call MPI_INIT()
  call MPI_COMM_SIZE(MPI_COMM_WORLD, world_size)
  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank)

  if (world_rank .eq. 0) then
    num = -1
    call MPI_SEND(num, 1, MPI_INT, 1, 0, &
                  MPI_COMM_WORLD)
  else if (world_rank .eq. 1) then
    call MPI_RECV(num, 1, MPI_INT, 0, 0, &
                  MPI_COMM_WORLD, recv_status)
    print '("Process 1 received number ", I0, " from process 0")', num
  end if

  call MPI_FINALIZE()

end program
