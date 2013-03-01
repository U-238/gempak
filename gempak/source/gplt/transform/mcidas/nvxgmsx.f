C Copyright(c) 1998, Space Science and Engineering Center, UW-Madison
C Refer to "McIDAS Software Acquisition and Distribution Policies"
C in the file  mcidas/data/license.txt

C *** $Id: nvxgmsx.dlm,v 1.4 1998/10/13 20:25:50 dglo Exp $ ***
C S. Chiswell/Unidata    2/02   Changed names of routines to avoid conflicts
C                               with GOES nav
C
C                               NVXINI --> GMSXINI
C                               NVXSAE --> GMSXSAE
C                               NVXEAS --> GMSXEAS
C                               NVXOPT --> GMSXOPT
C				NLLXYZ --> GMSLLXYZ
C				NXYZLL --> GMSXYZLL

      INTEGER FUNCTION GMSXINI(IFUNC,IPARMS)



      INTEGER IFUNC
      INTEGER IPARMS(*)
C      INTEGER OFFSET1
C      INTEGER OFFSET2
      CHARACTER*4 CLIT
      CHARACTER FORM*5
      CHARACTER CPARMS(3200)*1
      INTEGER*4	ICPRMS(800)
      EQUIVALENCE (CPARMS,ICPRMS)
      COMMON/GMSNAVCOM/NAVTYPE


      IF (IFUNC .EQ. 1) THEN


c* Remove "MORE" from every 128th word before initilizing
c* mapping common block.

C* UPC Replace use of MOVC with EQUIV to ICPRMS
C        OFFSET1 = 4
C        OFFSET2 = 0
C        CALL MOVC(504,IPARMS,OFFSET1,CPARMS,OFFSET2)
C        OFFSET1 = OFFSET1 + 508
C        OFFSET2 = OFFSET2 + 504
C
C      DO 100 i = 1, 4
C        CALL MOVC(508,IPARMS,OFFSET1,CPARMS,OFFSET2)
C        OFFSET1 = OFFSET1 + 512
C        OFFSET2 = OFFSET2 + 508
C100   continue

	DO I=1, 126
	   ICPRMS ( I ) = IPARMS( I + 1)
	END DO

	IOFF = 127
	DO J = 1, 4
	   DO I=1,127
	      ICPRMS ( IOFF ) = IPARMS ( IOFF + j + 1)
	      IOFF = IOFF + 1
	   END DO
	END DO
C* End UPC MOD


        FORM = 'short'
        CALL DECODE_OA_BLOCK(CPARMS,FORM)


      ELSE IF (IFUNC.EQ.2) THEN
         IF(INDEX(CLIT(IPARMS(1)),'XY').NE.0) NAVTYPE=1
         IF(INDEX(CLIT(IPARMS(1)),'LL').NE.0) NAVTYPE=2
      ENDIF


      GMSXINI = 0
      RETURN
      END

      INTEGER FUNCTION GMSXSAE(LIN,ELE,DUM1,LAT,LON,Z)
 
      INTEGER*4    IRET 
      INTEGER*4    MODE 
      COMMON/GMSNAVCOM/NAVTYPE
      REAL*4       RINF(8)
      REAL*8       DSCT
      REAL LAT
      REAL LON
      REAL ELE
      REAL LIN
      REAL DUM1
      REAL Z
      REAL LATLON(2)
      REAL SUBLAT
      REAL SUBLON
      REAL YLAT
      REAL YLON

        MODE=-1


        CALL SUBLATLON(LATLON)
        SUBLAT = LATLON(1) 
        SUBLON = LATLON(2) 
        CALL MGIVSR(MODE,ELE,LIN,LON,LAT,0.0,RINF,DSCT,IRET)
        IF(IRET .NE. 0)GOTO 100
        IF(ABS(LON) .GT. 180.)GOTO 100
        LON = (-1.)*LON
      IF((LON .GT. 90.-SUBLON).AND.(LON .LT. 270.-SUBLON))GOTO 100


      IF(NAVTYPE.EQ.1) THEN
         YLAT=LAT
         YLON=LON
         CALL LLCART(YLAT,YLON,LAT,LON,Z)
      ENDIF

      GMSXSAE = 0
      RETURN

100   GMSXSAE = -1
      RETURN
      END


      INTEGER FUNCTION GMSXEAS(INLAT,INLON,Z,LIN,ELE,DUM1)
      INTEGER MODE
      INTEGER*4    IRET 
      COMMON/GMSNAVCOM/NAVTYPE
      REAL*4       RINF(8)
      REAL*8       DSCT
      REAL       INLAT
      REAL       INLON
      REAL       LAT
      REAL       LON
      REAL       LIN
      REAL       ELE
      REAL DUM1
      REAL LATLON(2)
      REAL SUBLAT
      REAL SUBLON
      REAL X
      REAL Y
      REAL Z

      LAT=INLAT
      LON=INLON

      IF(NAVTYPE.EQ.1) THEN
         X=LAT
         Y=LON
         CALL CARTLL(X,Y,Z,LAT,LON)
      ENDIF

      MODE=1

      CALL SUBLATLON(LATLON)
      SUBLAT = LATLON(1)
      SUBLON = LATLON(2)
      IF( ABS(LAT).GT.90 ) GOTO 100
      IF( ABS(LON).GT. 180 ) GOTO 100
      IF( LON.GT.90.-SUBLON .AND. LON.LT.270.-SUBLON) GOTO 100
      LON=(-1.0)*LON

        CALL MGIVSR(MODE,ELE,LIN,LON,LAT,0.0,RINF,DSCT,IRET)
        IF(IRET .NE. 0)GOTO 100

      GMSXEAS = 0
      RETURN
100   GMSXEAS = -1
      RETURN
      END


      INTEGER FUNCTION GMSXOPT(IFUNC,XIN,XOUT)
C
C IFUNC= 'SPOS'    SUBSATELLITE LAT/LON
C
C        XIN - NOT USED
C        XOUT - 1. SUB-SATELLITE LATITUDE
C             - 2. SUB-SATELLITE LONGITUDE
C
C
C IFUNC= 'ANG '   ANGLES
C
C        XIN - 1. SSYYDDD
C              2. TIME (HOURS)
C              3. LATITUDE
C              4. LONGITUDE (***** WEST NEGATIVE *****)
C        XOUT- 1. SATELLITE ANGLE
C              2. SUN ANGLE
C              3. RELATIVE ANGLE
C
C
C
C IFUNC= 'HGT '   INPUT HEIGHT FOR PARALLAX
C
C        XIN - 1. HEIGHT (KM)
C
      REAL*4 XIN(*),XOUT(*)
      CHARACTER*4 CLIT,CFUNC
      CFUNC=CLIT(IFUNC)
      GMSXOPT=0
      IF(CFUNC.EQ.'SPOS') THEN
         CALL SUBLATLON(XOUT)
C         CALL SDEST('IN NVX OPT USING --- SPOS',0)
      ELSE IF(CFUNC.EQ.'ANG ') THEN
C         CALL SDEST('IN NVX OPT USING --- ANG ',0)
      ELSE IF(CFUNC.EQ.'HGT ') THEN
C         CALL SDEST('IN NVX OPT USING --- HGT ',0)
      ELSE
         GMSXOPT=1
      ENDIF
      RETURN
      END
C
C
C
C
C-----SUBSIDIARY SUBPROGRAMS
C
C
C
c     FUNCTION ICON1(YYMMDD)
C
C     CONVERTS YYMMDD TO YYDDD
C
c     IMPLICIT INTEGER(A-Z)
c     DIMENSION NUM(12)
c     DATA NUM/0,31,59,90,120,151,181,212,243,273,304,334/
C
c     YEAR=MOD(YYMMDD/10000,100)
c     MONTH=MOD(YYMMDD/100,100)
c     DAY=MOD(YYMMDD,100)
c     IF(MONTH.LT.0.OR.MONTH.GT.12)MONTH=1
c     JULDAY=DAY+NUM(MONTH)
c     IF(MOD(YEAR,4).EQ.0.AND.MONTH.GT.2) JULDAY=JULDAY+1
c     ICON1=1000*YEAR+JULDAY
c     RETURN
c     END
C
C MRNLLXYZ MB   09/15/83; BYPASS GEOLAT & MAKE WEST = +
C MRLLXYZ  MB    7/09/82;  CNVERT LAT/LON TO/FROM EARTH-CENTERED X,Y,Z
c     SUBROUTINE GMSLLXYZ(XLAT,XLON,X,Y,Z)
C-----CONVERT LAT,LON TO EARTH CENTERED X,Y,Z
C     (DALY, 1978)
C-----XLAT,XLON ARE IN DEGREES, WITH NORTH AND WEST POSITIVE
C-----X,Y,Z ARE GIVEN IN KM. THEY ARE THE COORDINATES IN A RECTANGULAR
C        FRAME WITH ORIGIN AT THE EARTH CENTER, WHOSE POSITIVE
C        X-AXIS PIERCES THE EQUATOR AT LON 0 DEG, WHOSE POSITIVE Y-AXIS
C        PIERCES THE EQUATOR AT LON 90 DEG, AND WHOSE POSITIVE Z-AXIS
C        INTERSECTS THE NORTH POLE.
c     AB=40546851.22
c     ASQ=40683833.48
c     BSQ=40410330.18
c     R=6371.221
c     RSQ=R*R
c     RDPDG=1.745329252E-02
c     YLAT=RDPDG*XLAT
C-----CONVERT TO GEOCENTRIC (SPHERICAL) LATITUDE
CCC     YLAT=GEOLAT(YLAT,1)
c     YLAT=ATAN2(BSQ*SIN(YLAT),ASQ*COS(YLAT))
c     YLON=-RDPDG*XLON
c     SNLT=SIN(YLAT)
c     CSLT=COS(YLAT)
c     CSLN=COS(YLON)
c     SNLN=SIN(YLON)
c     TNLT=(SNLT/CSLT)**2
c     R=AB*SQRT((1.0+TNLT)/(BSQ+ASQ*TNLT))
c     X=R*CSLT*CSLN
c     Y=R*CSLT*SNLN
c     Z=R*SNLT
c     RETURN
c     END
c     SUBROUTINE GMSXYZLL(X,Y,Z,XLAT,XLON)
C-----CONVERT EARTH-CENTERED X,Y,Z TO LAT & LON
C-----X,Y,Z ARE GIVEN IN KM. THEY ARE THE COORDINATES IN A RECTANGULAR
C        COORDINATE SYSTEM WITH ORIGIN AT THE EARTH CENTER, WHOSE POS.
C        X-AXIS PIERCES THE EQUATOR AT LON 0 DEG, WHOSE POSITIVE Y-AXIS
C        PIERCES THE EQUATOR AT LON 90 DEG, AND WHOSE POSITIVE Z-AXIS
C        INTERSECTS THE NORTH POLE.
C-----XLAT,XLON ARE IN DEGREES, WITH NORTH AND WEST POSITIVE
C
c     ASQ=40683833.48
c     BSQ=40410330.18
c     RDPDG=1.745329252E-02
C
c     XLAT=100.0
c     XLON=200.0
c     IF(X.EQ.0..AND.Y.EQ.0..AND.Z.EQ.0.) GO TO 90
c     A=ATAN(Z/SQRT(X*X+Y*Y))
C-----CONVERT TO GEODETIC LATITUDE
CCC     XLAT=GEOLAT(ATAN(Z/SQRT(X*X+Y*Y)),2)/RDPDG
c     XLAT=ATAN2(ASQ*SIN(A),BSQ*COS(A))/RDPDG
c     XLON=-ATAN2(Y,X)/RDPDG
c  90 RETURN
c     END