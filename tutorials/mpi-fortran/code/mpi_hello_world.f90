program hello_world_mpi
  use mpi_f08

  implicit none

  integer :: world_rank, world_size
  integer :: name_len

  character (len=MPI_MAX_PROCESSOR_NAME) :: processor_name

  ! Initialize the MPI environment
  call MPI_INIT()

  ! Get the number of processes
  call MPI_COMM_SIZE(MPI_COMM_WORLD, world_size)

  ! Get the rank of the process
  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank)

  ! Get the name of the processor
  call MPI_GET_PROCESSOR_NAME(processor_name, name_len)

  ! Print off an hello world message
  print '("Hello world from processor ", A, ", rank ", I0, " out of ", I0, " processors")', &
    processor_name(:name_len), world_rank, world_size

  ! Finalize the MPI environment
  call MPI_FINALIZE()

end program
