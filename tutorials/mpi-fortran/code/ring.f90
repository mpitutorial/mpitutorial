program ring
  use mpi_f08

  implicit none

  integer :: world_rank, world_size
  integer :: token
  type(MPI_Status) :: recv_status


  call MPI_INIT()
  call MPI_COMM_SIZE(MPI_COMM_WORLD, world_size)
  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank)


  if (world_rank .ne. 0) then
    call MPI_RECV(token, 1, MPI_INT, world_rank - 1, 0, &
                  MPI_COMM_WORLD, recv_status)
    print '("Process ", I0, " received token ", I0, " from process ", I0)', &
      world_rank, token, world_rank - 1
  else
    ! Set the token's value if you are process 0
    token = -1
  end if

  call MPI_SEND(token, 1, MPI_INT, mod(world_rank + 1, world_size), 0, &
                MPI_COMM_WORLD)

  ! Now process 0 can receive from the last process.
  if (world_rank .eq. 0) then
    call MPI_RECV(token, 1, MPI_INT, world_size - 1, 0, &
                  MPI_COMM_WORLD, recv_status)
    print '("Process ", I0, " received token ", I0, " from process ", I0)', &
      world_rank, token, world_size - 1
  end if

  call MPI_FINALIZE()

end program
