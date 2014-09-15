EXECS=bin
MPICC?=mpicc

all: ${EXECS}

bin: bin.c
	${MPICC} -o bin bin.c

clean:
	rm -f ${EXECS} *.o
