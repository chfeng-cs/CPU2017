#if !defined(SPEC_MPI)
! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

! This file could be used to provides MPI stubs for the code,

! 1) For instance, it can be used when FORESYS is used to analyze the code.
!  Without this file FORESYS generates numerous warnings about missing units:
!  "External unit mpi_xxxx not found in Forlib".

!  The write statements in the routines in this file are there to avoid 
!  "Dummy argument XXX not used" warnings by FORESYS.

!  The assignments in the routines in this file are there to avoid 
!  "Variable XXX has not been assigned a value" warnings by FORESYS.
!  (There is no need to also write the variables that are assigned.)

! 2) This file can also be used to compile a serial/sequential/one-node
!  version of the code when MPI is not available. A file mpif.h must be 
!  available. The only routines/functions actually called in this case are: 
!    MPI_INIT, MPI_COMM_SIZE, MPI_COMM_RANK, MPI_BARRIER and MPI_WTIME
!     MPI_COMM_SIZE returns SIZE = 1 (nnodes=1)
!     MPI_COMM_RANK returns RANK = 0 (my_id=master_id=0)
!     MPI_WTIME uses the timer in timerRoutine.f90.

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_BARRIER(COMM, IERROR) 
INTEGER :: COMM, IERROR
write(*,*) 'MPI_BARRIER: COMM = ', COMM
IERROR = 0
END SUBROUTINE MPI_BARRIER

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_BCAST(BUFFER, COUNT, DATATYPE, ROOT, COMM, IERROR) 
LOGICAL :: BUFFER 
INTEGER :: COUNT, DATATYPE, ROOT, COMM, IERROR 
write(*,*) COUNT, DATATYPE, ROOT, COMM, BUFFER
IERROR = 0
END SUBROUTINE MPI_BCAST

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_BCAST_INTEGERS(BUFFER, COUNT, DATATYPE, ROOT, COMM, IERROR) 
INTEGER, DIMENSION(*) :: BUFFER 
INTEGER :: COUNT, DATATYPE, ROOT, COMM, IERROR 
write(*,*) COUNT, DATATYPE, ROOT, COMM, BUFFER(1)
IERROR = 0
END SUBROUTINE MPI_BCAST_INTEGERS

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_BCAST_REALS(BUFFER, COUNT, DATATYPE, ROOT, COMM, IERROR) 
USE parameter_mod, ONLY : rfp
REAL(kind=rfp), DIMENSION(*) :: BUFFER 
INTEGER :: COUNT, DATATYPE, ROOT, COMM, IERROR 
write(*,*) COUNT, DATATYPE, ROOT, COMM, BUFFER(1)
IERROR = 0
END SUBROUTINE MPI_BCAST_REALS

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_BCAST_LOGICAL(BUFFER, COUNT, DATATYPE, ROOT, COMM, IERROR) 
LOGICAL :: BUFFER 
INTEGER :: COUNT, DATATYPE, ROOT, COMM, IERROR 
write(*,*) COUNT, DATATYPE, ROOT, COMM, BUFFER
IERROR = 0
END SUBROUTINE MPI_BCAST_LOGICAL

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_CART_RANK(COMM, COORDS, RANK, IERROR)
INTEGER :: COMM, COORDS(*), RANK, IERROR 
write(*,*) 'MPI_CART_RANK: ', COMM, COORDS(1)
RANK = 0
IERROR = 0
END SUBROUTINE MPI_CART_RANK

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_CART_CREATE(COMM_OLD, NDIMS, DIMS, PERIODS, REORDER,           &
                           COMM_CART, IERROR)
INTEGER :: COMM_OLD, NDIMS, DIMS(*), COMM_CART, IERROR 
LOGICAL :: PERIODS(*), REORDER 
write(*,*) COMM_OLD, NDIMS, DIMS(1), COMM_CART, PERIODS(1), REORDER
IERROR = 0
END SUBROUTINE MPI_CART_CREATE

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_CART_COORDS(COMM, RANK, MAXDIMS, COORDS, IERROR)
INTEGER :: COMM, RANK, MAXDIMS, COORDS(*), IERROR 
write(*,*) COMM, RANK, MAXDIMS, COORDS(1) 
IERROR = 0
COORDS(1) = 0
END SUBROUTINE MPI_CART_COORDS

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_CART_SHIFT(COMM, DIRECTION, DISP, RANK_SOURCE, RANK_DEST,      &
                          IERROR)
INTEGER :: COMM, DIRECTION, DISP, RANK_SOURCE, RANK_DEST, IERROR 
write(*,*) COMM, DIRECTION, DISP, RANK_SOURCE, RANK_DEST, IERROR 
IERROR = 0
END SUBROUTINE MPI_CART_SHIFT

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_COMM_RANK(COMM, RANK, IERROR)
INTEGER :: COMM, RANK, IERROR 
write(*,*) 'MPI_COMM_RANK: COMM = ', COMM
RANK = 0 
IERROR = 0
END SUBROUTINE MPI_COMM_RANK

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_COMM_SIZE(COMM, SIZE, IERROR)
INTEGER :: COMM, SIZE, IERROR 
write(*,*) 'MPI_COMM_SIZE: COMM = ', COMM
SIZE = 1
IERROR = 0
END SUBROUTINE MPI_COMM_SIZE

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_FINALIZE(IERROR)
INTEGER :: IERROR 
IERROR = 0
END SUBROUTINE MPI_FINALIZE

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_INIT(IERROR)
INTEGER :: IERROR 
IERROR = 0
END SUBROUTINE MPI_INIT

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_RECV(BUF, COUNT, DATATYPE, SOURCE, TAG, COMM, STATUS, IERROR)
USE parameter_mod, ONLY : rfp
REAL(kind=rfp), DIMENSION(*) :: BUF
INTEGER :: COUNT, DATATYPE, SOURCE, TAG, COMM, STATUS(*), IERROR 
write(*,*) COUNT, DATATYPE, SOURCE, TAG, COMM
IERROR = 0
!BUF = 0.0
STATUS(1) = 0
END SUBROUTINE MPI_RECV

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_SSEND(BUF, COUNT, DATATYPE, DEST, TAG, COMM, IERROR)
USE parameter_mod, ONLY : rfp
REAL(kind=rfp), DIMENSION(*) :: BUF
INTEGER :: COUNT, DATATYPE, DEST, TAG, COMM, IERROR 
write(*,*) BUF(1), COUNT, DATATYPE, DEST, TAG, COMM
IERROR = 0
END SUBROUTINE MPI_SSEND

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_BSEND(BUF, COUNT, DATATYPE, DEST, TAG, COMM, IERROR)
USE parameter_mod, ONLY : rfp
REAL(kind=rfp), DIMENSION(*) :: BUF
INTEGER :: COUNT, DATATYPE, DEST, TAG, COMM, IERROR 
write(*,*) BUF(1), COUNT, DATATYPE, DEST, TAG, COMM
IERROR = 0
END SUBROUTINE MPI_BSEND

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_SENDRECV(SENDBUF, SENDCOUNT, SENDTYPE, DEST, SENDTAG,          &
                        RECVBUF, RECVCOUNT, RECVTYPE,SOURCE, RECVTAG,         &
                        COMM, STATUS, IERROR)
USE parameter_mod, ONLY : rfp
REAL(kind=rfp), DIMENSION(*) :: SENDBUF
REAL(kind=rfp), DIMENSION(*) :: RECVBUF 
INTEGER :: SENDCOUNT, SENDTYPE, DEST,   SENDTAG,                              &
           RECVCOUNT, RECVTYPE, SOURCE, RECVTAG,                              &
           COMM, STATUS(*), IERROR 
write(*,*) SENDCOUNT, SENDTYPE, DEST,   SENDTAG, SENDBUF(1), RECVBUF(1)
write(*,*) RECVCOUNT, RECVTYPE, SOURCE, RECVTAG, COMM, STATUS(1)
IERROR = 0
END SUBROUTINE MPI_SENDRECV

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_WAIT(REQUEST, STATUS, IERROR)
INTEGER :: REQUEST, STATUS(*), IERROR 
write(*,*) REQUEST, STATUS(1)
IERROR = 0
END SUBROUTINE MPI_WAIT

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_ISEND(BUF, COUNT, DATATYPE, DEST, TAG, COMM, REQ, IERROR)
USE parameter_mod, ONLY : rfp
REAL(kind=rfp), DIMENSION(*) :: BUF
INTEGER :: COUNT, DATATYPE, DEST, TAG, COMM, REQ, IERROR 
write(*,*) BUF(1), COUNT, DATATYPE, DEST, TAG, COMM
IERROR = 0
REQ = 0
END SUBROUTINE MPI_ISEND

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

FUNCTION MPI_WTICK() 
DOUBLE PRECISION :: MPI_WTICK
MPI_WTICK = 1d-7
END FUNCTION MPI_WTICK

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

FUNCTION MPI_WTIME() 
DOUBLE PRECISION :: MPI_WTIME
real :: return_time
call timer(return_time, 0.0)
MPI_WTIME = return_time
END FUNCTION MPI_WTIME

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_BUFFER_ATTACH( BUFFER, SIZE, IERROR)
USE parameter_mod, ONLY : rfp
REAL(kind=rfp), DIMENSION(*) :: BUFFER
INTEGER :: SIZE, IERROR
write(*,*) SIZE, BUFFER(1) 
IERROR = 0
END SUBROUTINE MPI_BUFFER_ATTACH

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_BUFFER_DETACH( BUFFER, SIZE, IERROR)
USE parameter_mod, ONLY : rfp
REAL(kind=rfp), DIMENSION(*) :: BUFFER
INTEGER :: SIZE, IERROR 
write(*,*) SIZE, BUFFER(1) 
IERROR = 0
END SUBROUTINE MPI_BUFFER_DETACH

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_PACK_SIZE(INCOUNT, DATATYPE, COMM, SIZE, IERROR)
INTEGER :: INCOUNT, DATATYPE, COMM, SIZE, IERROR 
write(*,*) INCOUNT, DATATYPE, COMM
IERROR = 0
SIZE = 1
END SUBROUTINE MPI_PACK_SIZE

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_GATHER(SENDBUF, SENDCOUNT, SENDTYPE,                           &
                      RECVBUF, RECVCOUNT, RECVTYPE, ROOT, COMM, IERROR) 
INTEGER :: SENDBUF
INTEGER, DIMENSION(*) :: RECVBUF 
INTEGER :: SENDCOUNT, SENDTYPE, RECVCOUNT, RECVTYPE, ROOT, COMM, IERROR 
write(*,*) SENDCOUNT, SENDTYPE, SENDBUF  , RECVTYPE, ROOT, COMM, RECVBUF(1)
IERROR = 0
END SUBROUTINE MPI_GATHER

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_TYPE_STRUCT(COUNT,ARRAY_OF_BLOCKLENGTHS,ARRAY_OF_DISPLACEMENTS,&
                           ARRAY_OF_TYPES,NEWTYPE, IERROR)
INTEGER :: COUNT, ARRAY_OF_BLOCKLENGTHS(*), ARRAY_OF_DISPLACEMENTS(*),        &
           ARRAY_OF_TYPES(*), NEWTYPE, IERROR 
write(*,*) COUNT, ARRAY_OF_BLOCKLENGTHS(1), ARRAY_OF_DISPLACEMENTS(1)
write(*,*) ARRAY_OF_TYPES(1)
NEWTYPE = 0
IERROR = 0
END SUBROUTINE MPI_TYPE_STRUCT

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_TYPE_COMMIT(DATATYPE, IERROR)
INTEGER :: DATATYPE, IERROR 
write(*,*) DATATYPE
IERROR = 0
END SUBROUTINE MPI_TYPE_COMMIT

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_TYPE_EXTENT(DATATYPE, EXTENT, IERROR)
INTEGER :: DATATYPE, EXTENT, IERROR 
write(*,*) DATATYPE
EXTENT = 0
IERROR = 0
END SUBROUTINE MPI_TYPE_EXTENT

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_TYPE_FREE(DATATYPE, IERROR)
INTEGER :: DATATYPE, IERROR 
write(*,*) DATATYPE
IERROR = 0
END SUBROUTINE MPI_TYPE_FREE

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_TYPE_VECTOR(COUNT,BLOCKLENGTH,STRIDE,OLDTYPE,NEWTYPE,IERROR)
INTEGER :: COUNT, BLOCKLENGTH, STRIDE, OLDTYPE, NEWTYPE, IERROR 
write(*,*) COUNT, BLOCKLENGTH, STRIDE, OLDTYPE, NEWTYPE, IERROR 
IERROR = 0
END SUBROUTINE MPI_TYPE_VECTOR

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_TYPE_HVECTOR(COUNT,BLOCKLENGTH,STRIDE,OLDTYPE,NEWTYPE,IERROR)
INTEGER :: COUNT, BLOCKLENGTH, STRIDE, OLDTYPE, NEWTYPE, IERROR 
write(*,*) COUNT, BLOCKLENGTH, STRIDE, OLDTYPE, NEWTYPE, IERROR 
IERROR = 0
END SUBROUTINE MPI_TYPE_HVECTOR

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_IRECV(BUF, COUNT, DATATYPE, SOURCE, TAG, COMM, REQ, IERROR)
USE parameter_mod, ONLY : rfp
REAL(kind=rfp), DIMENSION(*) :: BUF
INTEGER :: COUNT, DATATYPE, SOURCE, TAG, COMM, REQ, IERROR 
write(*,*) COUNT, DATATYPE, SOURCE, TAG, COMM
IERROR = 0
REQ = 0
!BUF = 0.0
END SUBROUTINE MPI_IRECV

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_WAITALL(COUNT, REQUEST, STATUS, IERROR)
INTEGER :: COUNT, REQUEST(*), STATUS(*), IERROR 
write(*,*) COUNT, REQUEST(1), STATUS(1)
IERROR = 0
END SUBROUTINE MPI_WAITALL

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_SENDRECV_REPLACE(SENDBUF, SENDCOUNT, SENDTYPE, DEST, SENDTAG,  &
                                RECVBUF, RECVCOUNT, RECVTYPE,SOURCE, RECVTAG, &
                                COMM, STATUS, IERROR)
USE parameter_mod, ONLY : rfp
REAL(kind=rfp), DIMENSION(*) :: SENDBUF
REAL(kind=rfp), DIMENSION(*) :: RECVBUF 
INTEGER :: SENDCOUNT, SENDTYPE, DEST,   SENDTAG,                              &
           RECVCOUNT, RECVTYPE, SOURCE, RECVTAG,                              &
           COMM, STATUS(*), IERROR 
write(*,*) SENDCOUNT, SENDTYPE, DEST,   SENDTAG, SENDBUF(1), RECVBUF(1)
write(*,*) RECVCOUNT, RECVTYPE, SOURCE, RECVTAG, COMM, STATUS(1)
IERROR = 0
END SUBROUTINE MPI_SENDRECV_REPLACE

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_BSEND_INIT(BUF, COUNT, DATATYPE, DEST, TAG, COMM, REQUEST,     &
                          IERROR)
USE parameter_mod, ONLY : rfp
REAL(kind=rfp) :: BUF(*)
INTEGER :: REQUEST, COUNT, DATATYPE, DEST, TAG, COMM, IERROR

write(*,*) REQUEST, COUNT, DATATYPE, DEST, TAG, COMM
IERROR = 0
END SUBROUTINE MPI_BSEND_INIT

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_RECV_INIT(BUF, COUNT, DATATYPE, SOURCE, TAG, COMM, REQUEST,    &
                         IERROR)
USE parameter_mod, ONLY : rfp
REAL(kind=rfp) :: BUF(*)
INTEGER :: COUNT, DATATYPE, SOURCE, TAG, COMM, REQUEST, IERROR 
WRITE(*,*) COUNT, DATATYPE, SOURCE, TAG, COMM, REQUEST
IERROR = 0
END SUBROUTINE MPI_RECV_INIT

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_DIMS_CREATE(NNODES, NDIMS, DIMS, IERROR)
INTEGER :: NNODES, NDIMS, DIMS(*), IERROR
WRITE(*,*) NNODES, NDIMS, DIMS(1)
IERROR = 0
END SUBROUTINE MPI_DIMS_CREATE

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE MPI_START(REQUEST, IERROR)
INTEGER :: REQUEST, IERROR
WRITE(*,*) REQUEST, IERROR
IERROR = 0
END SUBROUTINE MPI_START

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE  MPI_ALLREDUCE(SENDBUF, RECVBUF, COUNT, DATATYPE, OP, COMM, IERROR)
USE parameter_mod, ONLY : rfp
REAL(kind=rfp) :: SENDBUF(*), RECVBUF(*)
INTEGER :: COUNT, DATATYPE, OP, COMM, IERROR 
IERROR = 0
END SUBROUTINE MPI_ALLREDUCE

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========
SUBROUTINE  MPI_ABORT(MPI_COMM_WORLD, IIII, IERROR)
INTEGER :: III, COMM, IERROR 

END SUBROUTINE MPI_ABORT

! ========== THIS FILE IS NORMALLY NOT USED WHEN COMPILING THE CODE ==========

SUBROUTINE  MPI_REDUCE(SENDBUF, RECVBUF, COUNT, DATATYPE, OP, COMM, IERROR)
USE parameter_mod, ONLY : rfp
REAL(kind=rfp) :: SENDBUF(*), RECVBUF(*)
INTEGER :: COUNT, DATATYPE, OP, COMM, IERROR 
IERROR = 0
END SUBROUTINE MPI_REDUCE
#endif
