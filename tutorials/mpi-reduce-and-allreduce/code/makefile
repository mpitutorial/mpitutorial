EXECS=avg stddev
MPICC?=mpicc

all: ${EXECS}

avg: avg.c
	${MPICC} -o avg avg.c

stddev: stddev.c
	${MPICC} -o stddev stddev.c -lm

clean:
	rm ${EXECS}
