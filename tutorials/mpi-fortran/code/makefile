EXECS=mpi_hello_world send_recv ping_pong ring check_status probe my_bcast compare_bcast
MPIF90?=mpif90

all: $(EXECS)

mpi_hello_world: mpi_hello_world.f90
	$(MPIF90) mpi_hello_world.f90 -o mpi_hello_world

send_recv: send_recv.f90
	$(MPIF90) send_recv.f90 -o send_recv

ping_pong: ping_pong.f90
	$(MPIF90) ping_pong.f90 -o ping_pong

ring: ring.f90
	$(MPIF90) ring.f90 -o ring

check_status: check_status.f90
	$(MPIF90) check_status.f90 -o check_status

probe: probe.f90
	$(MPIF90) probe.f90 -o probe

my_bcast: my_bcast.f90
	$(MPIF90) my_bcast.f90 -o my_bcast

compare_bcast: compare_bcast.f90
	$(MPIF90) compare_bcast.f90 -o compare_bcast


clean:
	rm -f $(EXECS)

