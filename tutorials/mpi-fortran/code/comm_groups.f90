program main
  use mpi

  implicit none

  integer            :: world_rank, world_size, ierror
  integer            :: world_group, prime_group
  integer            :: prime_comm
  integer, parameter :: n = 7
  integer            :: ranks(n)
  integer            :: prime_rank, prime_size

  call MPI_Init(ierror)

  ! Get the rank and size in the original communicator
  call MPI_Comm_rank(MPI_COMM_WORLD, world_rank, ierror)
  call MPI_Comm_size(MPI_COMM_WORLD, world_size, ierror)

  ! Get the group of processes in MPI_COMM_WORLD
  call MPI_Comm_group(MPI_COMM_WORLD, world_group, ierror)

  ranks = [1, 2, 3, 5, 7, 11, 13]

  ! Construct a group containing all of the prime ranks in world_group
  call MPI_Group_incl(world_group, 7, ranks, prime_group, ierror)

  ! Create a new communicator based on the group
  call MPI_Comm_create_group(MPI_COMM_WORLD, prime_group, 0, prime_comm, ierror)

  prime_rank = -1
  prime_size = -1
  ! If this rank isn't in the new communicator, it will be MPI_COMM_NULL
  ! Using MPI_COMM_NULL for MPI_Comm_rank or MPI_Comm_size is erroneous
  if (MPI_COMM_NULL .ne. prime_comm) then
    call MPI_Comm_rank(prime_comm, prime_rank, ierror)
    call MPI_Comm_size(prime_comm, prime_size, ierror)
  end if

  print '("WORLD RANK/SIZE: ", I0, "/", I0, " --- PRIME RANK/SIZE: ", I0, "/", I0)', &
        world_rank, world_size, prime_rank, prime_size

  call MPI_Group_free(world_group, ierror)
  call MPI_Group_free(prime_group, ierror)

  if (MPI_COMM_NULL .ne. prime_comm) then
    call MPI_Comm_free(prime_comm, ierror)
  end if

  call MPI_Finalize(ierror)

end program main
