// Author: Wes Kendall
// Copyright 2013 www.mpitutorial.com
// This code is provided freely with the tutorials on mpitutorial.com. Feel
// free to modify it for your own use. Any distribution of the code must
// either provide a link to www.mpitutorial.com or keep this header in tact.
//
// Header file for MPI_Rank
//
#ifndef __PARALLEL_RANK_H
#define __PARALLEL_RANK_H 1

int MPI_Rank(void *send_data, void *recv_data, MPI_Datatype datatype, MPI_Comm comm);

#endif
