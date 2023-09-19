program hello_world_mpi
  use mpi

  implicit none

  integer :: process_rank, size_of_cluster, ierror
  integer :: resultlen

  character (len=MPI_MAX_PROCESSOR_NAME) :: process_name

  ! Initialize the MPI environment
  call MPI_INIT(ierror)

  ! Get the number of processes
  call MPI_COMM_SIZE(MPI_COMM_WORLD, size_of_cluster, ierror)

  ! Get the rank of the process
  call MPI_COMM_RANK(MPI_COMM_WORLD, process_rank, ierror)

  ! Get the name of the processor
  call MPI_GET_PROCESSOR_NAME(process_name, resultlen, ierror)

  ! Print off an hello world message
  write (*,*) 'Hello World from processor ', trim(process_name), ' rank ', &
    process_rank, 'of ', size_of_cluster, 'processors'

  ! Finalize the MPI environment
  call MPI_FINALIZE(ierror)

end program
