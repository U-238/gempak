	SUBROUTINE SNTGRF  ( iytype, ratio, xstrt, xstop, ystrt, ystop,
     +			     rmargn, iret )
C************************************************************************
C* SNTGRF								*
C*									*
C* This subroutine sets the graph margins and sets up the graph in	*
C* GEMPLT.  The margins are set to 7, 4, 5, 3.				*
C*									*
C* SNTGRF  ( IYTYPE, RATIO, XSTRT, XSTOP, YSTRT, YSTOP, RMARGN, IRET )	*
C*									*
C* Input parameters:							*
C*	IYTYPE		INTEGER		Coordinate system		*
C*					  1 = linear			*
C*					  2 = log			*
C*					  3 = ** KAPPA			*
C*					  4 = log with skew x		*
C*	RATIO		REAL		Height to width plot ratio	*
C*	XSTRT		REAL		Left x				*
C*	XSTOP		REAL		Right x				*
C*	YSTRT		REAL		Bottom y			*
C*	YSTOP		REAL		Top y				*
C*	RMARGN (4)	REAL		Margins				*
C*									*
C* Output parameters:							*
C*	IRET		INTEGER		Return code			*
C*					  0 = normal return		*
C*					 -5 = error setting graph	*
C**									*
C* Log:									*
C* G. Huffman/USRA	 5/89	Copy of GDTGRF				*
C* S. Schotz/GSC	 7/90	Use rmargn instead of margin		*
C* K. Brill/NMC         01/92   Replace GERROR with ER_WMSG             *
C* K. Brill/NMC		02/92	Change left margin from 5 to 7		*
C************************************************************************
	INCLUDE		'GEMPRM.PRM'
C*
	REAL		rmargn(*)
C----------------------------------------------------------------------
	iret = 0
C
C*	Set graph margins.
C
	IF  ( rmargn(1) .lt. 0. )  THEN
	    CALL GSGMGN  ( 7., 4., 5., 3., ier )
	  ELSE
	    CALL GSGMGN  ( rmargn (1), rmargn (2), rmargn (3), 
     +			   rmargn (4), ier )
	END IF
C
C*	Set graph.
C
	jxtype = 1
	jytype = iytype
	IF  ( iytype .eq. 4 )  THEN
	    jxtype = 4
	    jytype = 2
	END IF
	CALL GSGRAF  ( jxtype, jytype, ratio, xstrt, ystrt, xstop,
     +		       ystop,  iret )
	IF  ( iret .ne. 0 )  THEN
	    CALL ER_WMSG  ( 'GEMPLT', iret, ' ', ier )
	    iret = -5
	    CALL ER_WMSG  ( 'SNTSER', iret, ' ', ier )
	END IF
C*
	RETURN
	END