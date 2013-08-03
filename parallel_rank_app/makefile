EXECS=mpi_rank
MPICC?=mpicc

all: ${EXECS}

mpi_rank: mpi_rank.c
	${MPICC} -o mpi_rank mpi_rank.c

clean:
	rm ${EXECS}
