program main
  use mpi_f08

  implicit none

  integer :: world_rank, world_size
  integer :: color
  type(MPI_Comm) :: row_comm
  integer :: row_rank, row_size

  call MPI_INIT()

  ! Get the rank and size in the original communicator
  call MPI_Comm_rank(MPI_COMM_WORLD, world_rank)
  call MPI_Comm_size(MPI_COMM_WORLD, world_size)

  color = world_rank / 4 ! Determine color based on row

  ! Split the communicator based on the color and use the original rank for ordering
  call MPI_Comm_split(MPI_COMM_WORLD, color, world_rank, row_comm)

  call MPI_Comm_rank(row_comm, row_rank)
  call MPI_Comm_size(row_comm, row_size)

  print '("WORLD RANK/SIZE: ", I0, "/", I0, " --- ROW RANK/SIZE: ", I0, "/", I0)', &
        world_rank, world_size, row_rank, row_size

  call MPI_Comm_free(row_comm)

  call MPI_Finalize()

end program main
