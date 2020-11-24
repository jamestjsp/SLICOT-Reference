      SUBROUTINE AB09AD( DICO, JOB, EQUIL, ORDSEL, N, M, P, NR, A, LDA,
     $                   B, LDB, C, LDC, HSV, TOL, IWORK, DWORK, LDWORK,
     $                   IWARN, INFO )
C
C     SLICOT RELEASE 5.7.
C
C     Copyright (c) 2002-2020 NICONET e.V.
C
C     PURPOSE
C
C     To compute a reduced order model (Ar,Br,Cr) for a stable original
C     state-space representation (A,B,C) by using either the square-root
C     or the balancing-free square-root Balance & Truncate (B & T)
C     model reduction method.
C
C     ARGUMENTS
C
C     Mode Parameters
C
C     DICO    CHARACTER*1
C             Specifies the type of the original system as follows:
C             = 'C':  continuous-time system;
C             = 'D':  discrete-time system.
C
C     JOB     CHARACTER*1
C             Specifies the model reduction approach to be used
C             as follows:
C             = 'B':  use the square-root Balance & Truncate method;
C             = 'N':  use the balancing-free square-root
C                     Balance & Truncate method.
C
C     EQUIL   CHARACTER*1
C             Specifies whether the user wishes to preliminarily
C             equilibrate the triplet (A,B,C) as follows:
C             = 'S':  perform equilibration (scaling);
C             = 'N':  do not perform equilibration.
C
C     ORDSEL  CHARACTER*1
C             Specifies the order selection method as follows:
C             = 'F':  the resulting order NR is fixed;
C             = 'A':  the resulting order NR is automatically determined
C                     on basis of the given tolerance TOL.
C
C     Input/Output Parameters
C
C     N       (input) INTEGER
C             The order of the original state-space representation, i.e.
C             the order of the matrix A.  N >= 0.
C
C     M       (input) INTEGER
C             The number of system inputs.  M >= 0.
C
C     P       (input) INTEGER
C             The number of system outputs.  P >= 0.
C
C     NR      (input/output) INTEGER
C             On entry with ORDSEL = 'F', NR is the desired order of the
C             resulting reduced order system.  0 <= NR <= N.
C             On exit, if INFO = 0, NR is the order of the resulting
C             reduced order model. NR is set as follows:
C             if ORDSEL = 'F', NR is equal to MIN(NR,NMIN), where NR
C             is the desired order on entry and NMIN is the order of a
C             minimal realization of the given system; NMIN is
C             determined as the number of Hankel singular values greater
C             than N*EPS*HNORM(A,B,C), where EPS is the machine
C             precision (see LAPACK Library Routine DLAMCH) and
C             HNORM(A,B,C) is the Hankel norm of the system (computed
C             in HSV(1));
C             if ORDSEL = 'A', NR is equal to the number of Hankel
C             singular values greater than MAX(TOL,N*EPS*HNORM(A,B,C)).
C
C     A       (input/output) DOUBLE PRECISION array, dimension (LDA,N)
C             On entry, the leading N-by-N part of this array must
C             contain the state dynamics matrix A.
C             On exit, if INFO = 0, the leading NR-by-NR part of this
C             array contains the state dynamics matrix Ar of the reduced
C             order system.
C
C     LDA     INTEGER
C             The leading dimension of array A.  LDA >= MAX(1,N).
C
C     B       (input/output) DOUBLE PRECISION array, dimension (LDB,M)
C             On entry, the leading N-by-M part of this array must
C             contain the original input/state matrix B.
C             On exit, if INFO = 0, the leading NR-by-M part of this
C             array contains the input/state matrix Br of the reduced
C             order system.
C
C     LDB     INTEGER
C             The leading dimension of array B.  LDB >= MAX(1,N).
C
C     C       (input/output) DOUBLE PRECISION array, dimension (LDC,N)
C             On entry, the leading P-by-N part of this array must
C             contain the original state/output matrix C.
C             On exit, if INFO = 0, the leading P-by-NR part of this
C             array contains the state/output matrix Cr of the reduced
C             order system.
C
C     LDC     INTEGER
C             The leading dimension of array C.  LDC >= MAX(1,P).
C
C     HSV     (output) DOUBLE PRECISION array, dimension (N)
C             If INFO = 0, it contains the Hankel singular values of
C             the original system ordered decreasingly. HSV(1) is the
C             Hankel norm of the system.
C
C     Tolerances
C
C     TOL     DOUBLE PRECISION
C             If ORDSEL = 'A', TOL contains the tolerance for
C             determining the order of reduced system.
C             For model reduction, the recommended value is
C             TOL = c*HNORM(A,B,C), where c is a constant in the
C             interval [0.00001,0.001], and HNORM(A,B,C) is the
C             Hankel-norm of the given system (computed in HSV(1)).
C             For computing a minimal realization, the recommended
C             value is TOL = N*EPS*HNORM(A,B,C), where EPS is the
C             machine precision (see LAPACK Library Routine DLAMCH).
C             This value is used by default if TOL <= 0 on entry.
C             If ORDSEL = 'F', the value of TOL is ignored.
C
C     Workspace
C
C     IWORK   INTEGER array, dimension (LIWORK)
C             LIWORK = 0, if JOB = 'B';
C             LIWORK = N, if JOB = 'N'.
C
C     DWORK   DOUBLE PRECISION array, dimension (LDWORK)
C             On exit, if INFO = 0, DWORK(1) returns the optimal value
C             of LDWORK.
C
C     LDWORK  INTEGER
C             The length of the array DWORK.
C             LDWORK >= MAX(1,N*(2*N+MAX(N,M,P)+5)+N*(N+1)/2).
C             For optimum performance LDWORK should be larger.
C
C     Warning Indicator
C
C     IWARN   INTEGER
C             = 0:  no warning;
C             = 1:  with ORDSEL = 'F', the selected order NR is greater
C                   than the order of a minimal realization of the
C                   given system. In this case, the resulting NR is
C                   set automatically to a value corresponding to the
C                   order of a minimal realization of the system.
C
C     Error Indicator
C
C     INFO    INTEGER
C             = 0:  successful exit;
C             < 0:  if INFO = -i, the i-th argument had an illegal
C                   value;
C             = 1:  the reduction of A to the real Schur form failed;
C             = 2:  the state matrix A is not stable (if DICO = 'C')
C                   or not convergent (if DICO = 'D');
C             = 3:  the computation of Hankel singular values failed.
C
C     METHOD
C
C     Let be the stable linear system
C
C          d[x(t)] = Ax(t) + Bu(t)
C          y(t)    = Cx(t)                               (1)
C
C     where d[x(t)] is dx(t)/dt for a continuous-time system and x(t+1)
C     for a discrete-time system. The subroutine AB09AD determines for
C     the given system (1), the matrices of a reduced order system
C
C          d[z(t)] = Ar*z(t) + Br*u(t)
C          yr(t)   = Cr*z(t)                             (2)
C
C     such that
C
C           HSV(NR) <= INFNORM(G-Gr) <= 2*[HSV(NR+1) + ... + HSV(N)],
C
C     where G and Gr are transfer-function matrices of the systems
C     (A,B,C) and (Ar,Br,Cr), respectively, and INFNORM(G) is the
C     infinity-norm of G.
C
C     If JOB = 'B', the square-root Balance & Truncate method of [1]
C     is used and, for DICO = 'C', the resulting model is balanced.
C     By setting TOL <= 0, the routine can be used to compute balanced
C     minimal state-space realizations of stable systems.
C
C     If JOB = 'N', the balancing-free square-root version of the
C     Balance & Truncate method [2] is used.
C     By setting TOL <= 0, the routine can be used to compute minimal
C     state-space realizations of stable systems.
C
C     REFERENCES
C
C     [1] Tombs M.S. and Postlethwaite I.
C         Truncated balanced realization of stable, non-minimal
C         state-space systems.
C         Int. J. Control, Vol. 46, pp. 1319-1330, 1987.
C
C     [2] Varga A.
C         Efficient minimal realization procedure based on balancing.
C         Proc. of IMACS/IFAC Symp. MCTS, Lille, France, May 1991,
C         A. El Moudui, P. Borne, S. G. Tzafestas (Eds.),
C         Vol. 2, pp. 42-46.
C
C     NUMERICAL ASPECTS
C
C     The implemented methods rely on accuracy enhancing square-root or
C     balancing-free square-root techniques.
C                                         3
C     The algorithms require less than 30N  floating point operations.
C
C     CONTRIBUTOR
C
C     C. Oara and A. Varga, German Aerospace Center,
C     DLR Oberpfaffenhofen, March 1998.
C     Based on the RASP routines SRBT and SRBFT.
C
C     REVISIONS
C
C     May 2, 1998.
C     November 11, 1998, V. Sima, Research Institute for Informatics,
C     Bucharest.
C
C     KEYWORDS
C
C     Balancing, minimal state-space representation, model reduction,
C     multivariable system, state-space model.
C
C     ******************************************************************
C
C     .. Parameters ..
      DOUBLE PRECISION  ONE, C100
      PARAMETER         ( ONE = 1.0D0, C100 = 100.0D0 )
C     .. Scalar Arguments ..
      CHARACTER         DICO, EQUIL, JOB, ORDSEL
      INTEGER           INFO, IWARN, LDA, LDB, LDC, LDWORK, M, N, NR, P
      DOUBLE PRECISION  TOL
C     .. Array Arguments ..
      INTEGER           IWORK(*)
      DOUBLE PRECISION  A(LDA,*), B(LDB,*), C(LDC,*), DWORK(*), HSV(*)
C     .. Local Scalars ..
      LOGICAL           FIXORD
      INTEGER           IERR, KI, KR, KT, KTI, KW, NN
      DOUBLE PRECISION  MAXRED, WRKOPT
C     .. External Functions ..
      LOGICAL           LSAME
      EXTERNAL          LSAME
C     .. External Subroutines ..
      EXTERNAL          AB09AX, TB01ID, TB01WD, XERBLA
C     .. Intrinsic Functions ..
      INTRINSIC         DBLE, MAX, MIN
C     .. Executable Statements ..
C
      INFO   = 0
      IWARN  = 0
      FIXORD = LSAME( ORDSEL, 'F' )
C
C     Test the input scalar arguments.
C
      IF( .NOT. ( LSAME( DICO, 'C' ) .OR. LSAME( DICO, 'D' ) ) ) THEN
         INFO = -1
      ELSE IF( .NOT. ( LSAME( JOB, 'B' ) .OR. LSAME( JOB, 'N' ) ) ) THEN
         INFO = -2
      ELSE IF( .NOT. ( LSAME( EQUIL, 'S' ) .OR.
     $                 LSAME( EQUIL, 'N' ) ) ) THEN
         INFO = -3
      ELSE IF( .NOT. ( FIXORD .OR. LSAME( ORDSEL, 'A' ) ) ) THEN
         INFO = -4
      ELSE IF( N.LT.0 ) THEN
         INFO = -5
      ELSE IF( M.LT.0 ) THEN
         INFO = -6
      ELSE IF( P.LT.0 ) THEN
         INFO = -7
      ELSE IF( FIXORD .AND. ( NR.LT.0 .OR. NR.GT.N ) ) THEN
         INFO = -8
      ELSE IF( LDA.LT.MAX( 1, N ) ) THEN
         INFO = -10
      ELSE IF( LDB.LT.MAX( 1, N ) ) THEN
         INFO = -12
      ELSE IF( LDC.LT.MAX( 1, P ) ) THEN
         INFO = -14
      ELSE IF( LDWORK.LT.MAX( 1, N*( 2*N + MAX( N, M, P ) + 5 ) +
     $                         ( N*( N + 1 ) )/2 ) ) THEN
         INFO = -19
      END IF
C
      IF( INFO.NE.0 ) THEN
C
C        Error return.
C
         CALL XERBLA( 'AB09AD', -INFO )
         RETURN
      END IF
C
C     Quick return if possible.
C
      IF( MIN( N, M, P ).EQ.0 .OR. ( FIXORD .AND. NR.EQ.0 ) ) THEN
         NR = 0
         DWORK(1) = ONE
         RETURN
      END IF
C
C     Allocate working storage.
C
      NN = N*N
      KT = 1
      KR = KT + NN
      KI = KR + N
      KW = KI + N
C
      IF( LSAME( EQUIL, 'S' ) ) THEN
C
C        Scale simultaneously the matrices A, B and C:
C        A <- inv(D)*A*D,  B <- inv(D)*B and C <- C*D, where D is a
C        diagonal matrix.
C
         MAXRED = C100
         CALL TB01ID( 'A', N, M, P, MAXRED, A, LDA, B, LDB, C, LDC,
     $                DWORK, INFO )
      END IF
C
C     Reduce A to the real Schur form using an orthogonal similarity
C     transformation A <- T'*A*T and apply the transformation to
C     B and C: B <- T'*B and C <- C*T.
C
      CALL TB01WD( N, M, P, A, LDA, B, LDB, C, LDC, DWORK(KT), N,
     $             DWORK(KR), DWORK(KI), DWORK(KW), LDWORK-KW+1, IERR )
      IF( IERR.NE.0 ) THEN
         INFO = 1
         RETURN
      END IF
C
      WRKOPT = DWORK(KW) + DBLE( KW-1 )
      KTI = KT  + NN
      KW  = KTI + NN
C
      CALL AB09AX( DICO, JOB, ORDSEL, N, M, P, NR, A, LDA, B, LDB, C,
     $             LDC, HSV, DWORK(KT), N, DWORK(KTI), N, TOL, IWORK,
     $             DWORK(KW), LDWORK-KW+1, IWARN, IERR )
C
      IF( IERR.NE.0 ) THEN
         INFO = IERR + 1
         RETURN
      END IF
C
      DWORK(1) = MAX( WRKOPT, DWORK(KW) + DBLE( KW-1 ) )
C
      RETURN
C *** Last line of AB09AD ***
      END
