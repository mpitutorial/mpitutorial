EXECS=random_rank
MPICC?=mpicc

all: ${EXECS}

mpi_rank.o: mpi_rank.c
	${MPICC} -c mpi_rank.c

random_rank: mpi_rank.o random_rank.c
	${MPICC} -o random_rank random_rank.c mpi_rank.o

clean:
	rm ${EXECS} *.o
