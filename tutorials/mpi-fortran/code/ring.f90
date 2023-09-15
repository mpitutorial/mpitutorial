program ring
  implicit none

  include 'mpif.h'

  integer world_rank, world_size, ierror
  integer token
  integer recv_status(MPI_STATUS_SIZE)


  call MPI_INIT(ierror)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, world_size, ierror)
  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank, ierror)


  if (world_rank .ne. 0) then
    call MPI_RECV(token, 1, MPI_INT, world_rank - 1, 0, &
                  MPI_COMM_WORLD, recv_status, ierror)
    print '("Process ", I0, " received token ", I0, " from process ", I0)', &
      world_rank, token, world_rank - 1
  else
    ! Set the token's value if you are process 0
    token = -1
  end if

  call MPI_SEND(token, 1, MPI_INT, mod(world_rank + 1, world_size), 0, &
                MPI_COMM_WORLD, ierror)

  ! Now process 0 can receive from the last process.
  if (world_rank .eq. 0) then
    call MPI_RECV(token, 1, MPI_INT, world_size - 1, 0, &
                  MPI_COMM_WORLD, recv_status, ierror)
    print '("Process ", I0, " received token ", I0, " from process ", I0)', &
      world_rank, token, world_size - 1
  end if

  call MPI_FINALIZE(ierror)

end program

