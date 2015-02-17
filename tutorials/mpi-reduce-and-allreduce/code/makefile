EXECS=reduce_avg reduce_stddev
MPICC?=mpicc

all: ${EXECS}

reduce_avg: reduce_avg.c
	${MPICC} -o reduce_avg reduce_avg.c

reduce_stddev: reduce_stddev.c
	${MPICC} -o reduce_stddev reduce_stddev.c -lm

clean:
	rm -f ${EXECS}
