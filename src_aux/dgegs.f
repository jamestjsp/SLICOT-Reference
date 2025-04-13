      SUBROUTINE DGEGS( JOBVSL, JOBVSR, N, A, LDA, B, LDB, ALPHAR,
     $                  ALPHAI, BETA, VSL, LDVSL, VSR, LDVSR, WORK,
     $                  LWORK, INFO )
*
*  -- This is a compatibility wrapper for DGEGS which was removed in 
*     LAPACK 3.2 and replaced by DGGES
*
      IMPLICIT NONE
*
*     .. Scalar Arguments ..
      CHARACTER          JOBVSL, JOBVSR
      INTEGER            INFO, LDA, LDB, LDVSL, LDVSR, LWORK, N
*     ..
*     .. Array Arguments ..
      DOUBLE PRECISION   A( LDA, * ), ALPHAI( * ), ALPHAR( * ),
     $                   B( LDB, * ), BETA( * ), VSL( LDVSL, * ),
     $                   VSR( LDVSR, * ), WORK( * )
*     ..
*     .. External Functions and Subroutines ..
      EXTERNAL           DGGES
      LOGICAL            SELCTG
      EXTERNAL           SELCTG
*
*  Purpose
*  =======
*
*  DGEGS is a compatibility wrapper that calls DGGES, which replaced 
*  DGEGS in LAPACK 3.2.
*
*  =====================================================================
*
*     .. Local Variables ..
      LOGICAL            BWORK( 1 )
      INTEGER            SDIM
*     ..
*     
      CALL DGGES( JOBVSL, JOBVSR, 'N', SELCTG, N, A, LDA, B, LDB, SDIM,
     $            ALPHAR, ALPHAI, BETA, VSL, LDVSL, VSR, LDVSR, WORK,
     $            LWORK, BWORK, INFO )
*
      RETURN
*
*     End of DGEGS
*
      END
      
      LOGICAL FUNCTION SELCTG( AR, AI, B )
*     Dummy sorting function for DGGES - never called because sort='N'
      DOUBLE PRECISION   AR, AI, B
      SELCTG = .FALSE.
      RETURN
      END
