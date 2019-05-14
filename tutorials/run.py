#!/usr/bin/python
import sys
import os
import subprocess

# Enter runnable programs here, keyed on the program executable name and followed
# by a tuple of the tutorial name and the default number of nodes
programs = {
    # From the mpi-hello-world tutorial
    'mpi_hello_world': ('mpi-hello-world', 4),

    # From mpi-send-and-receive tutorial
    'send_recv': ('mpi-send-and-receive', 2),
    'ping_pong': ('mpi-send-and-receive', 2),
    'ring': ('mpi-send-and-receive', 5),

    # From the dynamic-receiving-with-mpi-probe-and-mpi-status tutorial
    'check_status': ('dynamic-receiving-with-mpi-probe-and-mpi-status', 2),
    'probe': ('dynamic-receiving-with-mpi-probe-and-mpi-status', 2),

    # From the point-to-point-communication-application-random-walk tutorial
    'random_walk': ('point-to-point-communication-application-random-walk', 5, ['100', '500', '20']),

    # From the mpi-broadcast-and-collective-communication tutorial
    'my_bcast': ('mpi-broadcast-and-collective-communication', 4),
    'compare_bcast': ('mpi-broadcast-and-collective-communication', 16, ['100000', '10']),

    # From the mpi-scatter-gather-and-allgather tutorial
    'avg': ('mpi-scatter-gather-and-allgather', 4, ['100']),
    'all_avg': ('mpi-scatter-gather-and-allgather', 4, ['100']),

    # From the performing-parallel-rank-with-mpi tutorial
    'random_rank': ('performing-parallel-rank-with-mpi', 4, ['100']),

    # From the mpi-reduce-and-allreduce tutorial
    'reduce_avg': ('mpi-reduce-and-allreduce', 4, ['100']),
    'reduce_stddev': ('mpi-reduce-and-allreduce', 4, ['100']),

    # From the groups-and-communicators tutorial
    'split': ('introduction-to-groups-and-communicators', 16),
    'groups': ('introduction-to-groups-and-communicators', 16)
}

program_to_run = sys.argv[1] if len(sys.argv) > 1 else None
if not program_to_run in programs:
    print('Must enter program name to run. Possible programs are: {0}'.format(programs.keys()))
else:
    # Try to compile before running
    with open(os.devnull, 'wb') as devnull:
        subprocess.call(
            ['cd ./{0}/code && make'.format(programs[program_to_run][0])],
            stdout=devnull, stderr=subprocess.STDOUT, shell=True)

    mpirun = os.environ.get('MPIRUN', 'mpirun')
    hosts = '' if not os.environ.get('MPI_HOSTS') else '-f {0}'.format(os.environ.get('MPI_HOSTS'))

    sys_call = '{0} -n {1} {2} ./{3}/code/{4}'.format(
        mpirun, programs[program_to_run][1], hosts, programs[program_to_run][0], program_to_run)

    if len(programs[program_to_run]) > 2:
        sys_call = '{0} {1}'.format(sys_call, ' '.join(programs[program_to_run][2]))

    print(sys_call)
    subprocess.call([sys_call], shell=True)
