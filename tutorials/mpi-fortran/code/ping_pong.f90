program ping_pong
  use mpi_f08

  implicit none

  integer :: world_rank, world_size
  integer :: partner_rank
  integer :: ping_pong_count, ping_pong_limit
  type(MPI_Status) :: recv_status


  call MPI_INIT()
  call MPI_COMM_SIZE(MPI_COMM_WORLD, world_size)
  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank)

  ping_pong_count = 0
  ping_pong_limit = 10

  partner_rank = mod(world_rank + 1, 2)

  do while (ping_pong_count .lt. ping_pong_limit)
    if (world_rank .eq. mod(ping_pong_count, 2)) then
      ! Increment the ping pong count before you send it
      ping_pong_count = ping_pong_count + 1
      call MPI_SEND(ping_pong_count, 1, MPI_INT, partner_rank, 0, &
                    MPI_COMM_WORLD)
      print '(I0, " sent and incremented ping_pong_count ", I0, " to ", I0)', &
        world_rank, ping_pong_count, partner_rank
    else
      call MPI_RECV(ping_pong_count, 1, MPI_INT, partner_rank, 0, &
                    MPI_COMM_WORLD, recv_status)
      print '(I0,  " received ping_pong_count ", I0, " from ", I0)', &
        world_rank, ping_pong_count, partner_rank
    end if
  end do

  call MPI_FINALIZE()

end program
