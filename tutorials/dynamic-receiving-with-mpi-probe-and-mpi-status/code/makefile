EXECS=check_status probe
MPICC?=mpicc

all: ${EXECS}

check_status: check_status.c
	${MPICC} -o check_status check_status.c

probe: probe.c
	${MPICC} -o probe probe.c

clean:
	rm -f ${EXECS}
