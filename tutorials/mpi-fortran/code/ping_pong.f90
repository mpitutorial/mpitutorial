program ping_pong
  implicit none

  include 'mpif.h'

  integer world_rank, world_size, ierror
  integer partner_rank
  integer ping_pong_count, ping_pong_limit
  integer recv_status(MPI_STATUS_SIZE)


  call MPI_INIT(ierror)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, world_size, ierror)
  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank, ierror)

  ping_pong_count = 0
  ping_pong_limit = 10

  partner_rank = mod(world_rank + 1, 2)

  do while (ping_pong_count .lt. ping_pong_limit)
    if (world_rank .eq. mod(ping_pong_count, 2)) then
      ! Increment the ping pong count before you send it
      ping_pong_count = ping_pong_count + 1
      call MPI_SEND(ping_pong_count, 1, MPI_INT, partner_rank, 0, &
                    MPI_COMM_WORLD, ierror)
      print '(I0, " sent and incremented ping_pong_count ", I0, " to ", I0)', &
        world_rank, ping_pong_count, partner_rank
    else
      call MPI_RECV(ping_pong_count, 1, MPI_INT, partner_rank, 0, &
                    MPI_COMM_WORLD, recv_status, ierror)
      print '(I0,  " received ping_pong_count ", I0, " from ", I0)', &
        world_rank, ping_pong_count, partner_rank
    end if
  end do

  call MPI_FINALIZE(ierror)

end program

