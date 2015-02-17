EXECS=my_bcast compare_bcast
MPICC?=mpicc

all: ${EXECS}

my_bcast: my_bcast.c
	${MPICC} -o my_bcast my_bcast.c

compare_bcast: compare_bcast.c
	${MPICC} -o compare_bcast compare_bcast.c

clean:
	rm -f ${EXECS}
