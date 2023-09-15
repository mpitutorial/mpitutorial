program probe
  implicit none

  include 'mpif.h'

  integer world_rank, world_size, ierror
  integer MAX_NUMBERS
  parameter (MAX_NUMBERS=100)
  integer, allocatable :: numbers(:)
  integer number_amount
  integer recv_status(MPI_STATUS_SIZE)

  real r

  call MPI_INIT(ierror)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, world_size, ierror)
  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank, ierror)


  if (world_rank .eq. 0) then
    ! Pick a random amount of integers to send to process one
    call srand(time())

    ! Throw away first value
    r = rand()

    number_amount = int(rand() * real(MAX_NUMBERS))
    allocate(numbers(MAX_NUMBERS))
    ! Send the random amount of integers to process one
    call MPI_SEND(numbers, number_amount, MPI_INT, 1, 0, &
                  MPI_COMM_WORLD, ierror)
    print '("0 sent ", I0, " numbers to 1")', number_amount
  else if (world_rank .eq. 1) then
    ! Probe for an incoming message from process zero
    call MPI_PROBE(0, 0, MPI_COMM_WORLD, recv_status, ierror)

    ! When probe returns, the status object has the size and other
    ! attributes of the incoming message. Get the message size
    call MPI_Get_count(recv_status, MPI_INT, number_amount, ierror)

    ! Allocate a buffer to hold the incoming numbers
    allocate(numbers(number_amount))

    ! Now receive the message with the allocated buffer
    call MPI_RECV(numbers, number_amount, MPI_INT, 0, 0, &
                  MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierror)
    print '("1 dynamically received ", I0, " numbers from 0.")', &
      number_amount
    deallocate(numbers)
  end if

  call MPI_FINALIZE(ierror)

end program

