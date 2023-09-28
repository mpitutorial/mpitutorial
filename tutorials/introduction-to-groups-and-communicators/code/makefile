EXECS=comm_groups comm_split
MPICC?=mpicc

all: ${EXECS}

split: comm_split.c
	${MPICC} -o comm_split comm_split.c

groups: comm_groups.c
	${MPICC} -o comm_groups comm_groups.c

clean:
	rm -f ${EXECS}
