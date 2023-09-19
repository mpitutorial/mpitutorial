program check_status
  use mpi

  implicit none

  integer            :: world_rank, world_size, ierror
  integer, parameter :: MAX_NUMBERS=100
  integer            :: numbers(MAX_NUMBERS)
  integer            :: number_amount
  integer            :: recv_status(MPI_STATUS_SIZE)

  real :: r

  call MPI_INIT(ierror)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, world_size, ierror)
  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank, ierror)


  if (world_rank .eq. 0) then
    ! Pick a random amount of integers to send to process one
    call srand(time())

    ! Throw away first value
    r = rand()

    number_amount = int(rand() * real(MAX_NUMBERS))
    ! Send the amount of integers to process one
    call MPI_SEND(numbers, number_amount, MPI_INT, 1, 9, &
                  MPI_COMM_WORLD, ierror)
    print '("0 sent ", I0, " numbers to 1")', number_amount
  else if (world_rank .eq. 1) then
    ! Receive at most MAX_NUMBERS from process zero
    call MPI_RECV(numbers, MAX_NUMBERS, MPI_INT, 0, 9, &
                  MPI_COMM_WORLD, recv_status, ierror)
    ! After receiving the message, check the status to determine how many
    ! numbers were actually received
    call MPI_Get_count(recv_status, MPI_INT, number_amount, ierror)
    ! Print off the amount of numbers, and also print additional information
    ! in the status object
    print '("1 received ", I0, " numbers from 0. Message source = ", I0, ", tag = ", I0)', &
      number_amount , recv_status(MPI_SOURCE) , recv_status(MPI_TAG)
  end if

  call MPI_Barrier(MPI_COMM_WORLD, ierror)

  call MPI_FINALIZE(ierror)

end program
