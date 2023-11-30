program probe
  use mpi_f08

  implicit none

  integer              :: world_rank, world_size
  integer, parameter   :: MAX_NUMBERS=100
  integer, allocatable :: numbers(:)
  integer              :: number_amount
  type(MPI_Status)     :: recv_status

  real :: r

  call MPI_INIT()
  call MPI_COMM_SIZE(MPI_COMM_WORLD, world_size)
  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank)


  if (world_rank .eq. 0) then
    ! Pick a random amount of integers to send to process one
    call random_seed()

    call random_number(r)
    number_amount = int(r * real(MAX_NUMBERS))
    allocate(numbers(MAX_NUMBERS))
    ! Send the random amount of integers to process one
    call MPI_SEND(numbers, number_amount, MPI_INT, 1, 0, &
                  MPI_COMM_WORLD)
    print '("0 sent ", I0, " numbers to 1")', number_amount
  else if (world_rank .eq. 1) then
    ! Probe for an incoming message from process zero
    call MPI_PROBE(0, 0, MPI_COMM_WORLD, recv_status)

    ! When probe returns, the status object has the size and other
    ! attributes of the incoming message. Get the message size
    call MPI_Get_count(recv_status, MPI_INT, number_amount)

    ! Allocate a buffer to hold the incoming numbers
    allocate(numbers(number_amount))

    ! Now receive the message with the allocated buffer
    call MPI_RECV(numbers, number_amount, MPI_INT, 0, 0, &
                  MPI_COMM_WORLD, MPI_STATUS_IGNORE)
    print '("1 dynamically received ", I0, " numbers from 0.")', &
      number_amount
    deallocate(numbers)
  end if

  call MPI_FINALIZE()

end program
