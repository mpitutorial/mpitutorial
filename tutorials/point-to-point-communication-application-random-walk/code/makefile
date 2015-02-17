EXECS=random_walk
MPICXX?=mpicxx

all: ${EXECS}

random_walk: random_walk.cc
	${MPICXX} -o random_walk random_walk.cc

clean:
	rm -f ${EXECS}
