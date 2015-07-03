EXECS=random_rank
MPICC?=mpicc

all: ${EXECS}

tmpi_rank.o: tmpi_rank.c
	${MPICC} -c tmpi_rank.c

random_rank: tmpi_rank.o random_rank.c
	${MPICC} -o random_rank random_rank.c tmpi_rank.o

clean:
	rm -f ${EXECS} *.o
