EXECS=groups split
MPICC?=mpicc

all: ${EXECS}

split: split.c
	${MPICC} -o split split.c

groups: groups.c
	${MPICC} -o groups groups.c

clean:
	rm -f ${EXECS}
