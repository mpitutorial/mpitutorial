EXECS=mpi_hello_world send_recv ping_pong ring check_status probe \
      my_bcast compare_bcast avg all_avg reduce_avg reduce_std \
      comm_split comm_groups
MPIF90?=mpif90
FFLAGS=-Wall

all: $(EXECS)

mpi_hello_world: mpi_hello_world.f90
	$(MPIF90) $(FFLAGS) mpi_hello_world.f90 -o mpi_hello_world

send_recv: send_recv.f90
	$(MPIF90) $(FFLAGS) send_recv.f90 -o send_recv

ping_pong: ping_pong.f90
	$(MPIF90) $(FFLAGS) ping_pong.f90 -o ping_pong

ring: ring.f90
	$(MPIF90) $(FFLAGS) ring.f90 -o ring

check_status: check_status.f90
	$(MPIF90) $(FFLAGS) check_status.f90 -o check_status

probe: probe.f90
	$(MPIF90) $(FFLAGS) probe.f90 -o probe

my_bcast: my_bcast.f90
	$(MPIF90) $(FFLAGS) my_bcast.f90 -o my_bcast

compare_bcast: compare_bcast.f90
	$(MPIF90) $(FFLAGS) compare_bcast.f90 -o compare_bcast

avg: avg.f90
	$(MPIF90) $(FFLAGS) avg.f90 -o avg

all_avg: all_avg.f90
	$(MPIF90) $(FFLAGS) all_avg.f90 -o all_avg

reduce_avg: reduce_avg.f90
	$(MPIF90) $(FFLAGS) reduce_avg.f90 -o reduce_avg

reduce_std: reduce_std.f90
	$(MPIF90) $(FFLAGS) reduce_std.f90 -o reduce_std

comm_split: comm_split.f90
	$(MPIF90) $(FFLAGS) comm_split.f90 -o comm_split

comm_groups: comm_groups.f90
	$(MPIF90) $(FFLAGS) comm_groups.f90 -o comm_groups

clean:
	rm -f $(EXECS)
