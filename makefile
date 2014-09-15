.PHONY: clean all

all:
	$(MAKE) -C mpi_alltoall_and_v_routines all
	$(MAKE) -C mpi_bcast all
	$(MAKE) -C mpi_hello_world all
	$(MAKE) -C mpi_probe_status all
	$(MAKE) -C mpi_reduce_allreduce all
	$(MAKE) -C mpi_scatter_gather_allgather all
	$(MAKE) -C mpi_send_recv all
	$(MAKE) -C parallel_rank_app all
	$(MAKE) -C random_walk_app all

clean:
	$(MAKE) -C mpi_alltoall_and_v_routines clean 
	$(MAKE) -C mpi_bcast clean
	$(MAKE) -C mpi_hello_world clean
	$(MAKE) -C mpi_probe_status clean
	$(MAKE) -C mpi_reduce_allreduce clean
	$(MAKE) -C mpi_scatter_gather_allgather clean
	$(MAKE) -C mpi_send_recv clean
	$(MAKE) -C parallel_rank_app clean
	$(MAKE) -C random_walk_app clean


