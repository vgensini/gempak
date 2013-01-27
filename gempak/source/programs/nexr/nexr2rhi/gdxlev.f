	SUBROUTINE GDXLEV  ( cflag, line, cint, fflag, fline, fint,
     +			     scale, kx, ky, imin, jmin, imax, jmax, 
     +			     grid, nclvl, clvl, clbl, iccolr, icltyp, 
     +			     iclwid, iclabl, nflvl, flvl, ifcolr, 
     +			     iflabl, ifltyp, iscale, dmin, dmax, 
     +			     scflag, iret )
C************************************************************************
C* GDXLEV								*
C*									*
C* This subroutine decides which contour levels to create and the	*
C* colors and line types to use.					*
C*									*
C* GDXLEV  ( CFLAG, LINE, CINT, FFLAG, FLINE, FINT, SCALE, KX, KY,	*
C*           IMIN, JMIN, IMAX, JMAX, GRID, NCLVL, CLVL, CLBL, ICCOLR,	*
C*           ICLTYP, ICLWID, ICLABL, NFLVL, FLVL, IFCOLR, IFLABL,	*
C*	     IFLTYP, ISCALE, DMIN, DMAX, SCFLAG, IRET )			*
C*									*
C* Input parameters:							*
C*	CFLAG		LOGICAL		Line contour flag		*
C*	LINE		CHAR*		Line input string 		*
C*	CINT		CHAR*		Contour interval input 		*
C*	FFLAG		LOGICAL		Fill contour flag		*
C*	FLINE		CHAR*		Fill line input string		*
C*	FINT		CHAR*		Fill contour interval input	*
C*	SCALE		CHAR*		Scaling factor			*
C*	KX		INTEGER		Number of grid points in x dir	*
C*	KY		INTEGER		Number of grid points in y dir	*
C*	IMIN		INTEGER		Minimum x grid point		*
C*	JMIN		INTEGER		Minimum y grid point		*
C*	IMAX		INTEGER		Maximum x grid point		*
C*	JMAX		INTEGER		Maximum y grid points		*
C*									*
C* Input and output parameters:						*
C*	GRID (KX,KY)	REAL		Scaled grid data		*
C*									*
C* Output parameters:							*
C*	NCLVL		INTEGER		Number of line contours		*
C*	CLVL   (NLVL)	REAL		Line contour levels		*
C*	CLBL   (NLVL)	CHAR*		Line contour labels		*
C*	ICCOLR (NLVL)	INTEGER		Line contour colors		*
C*	ICLTYP (NLVL)	INTEGER		Line types			*
C*	ICLWID (NLVL)	INTEGER		Line widths			*
C*	ICLABL (NLVL)	INTEGER		Label types			*
C*	NFLVL		INTEGER		Number of fill contours		*
C*	FLVL   (NLVL)	REAL		Fill contour levels		*
C*	IFCOLR (NLVL+1)	INTEGER		Fill contour colors		*
C*	IFLABL (NLVL+1)	INTEGER		Fill contour labels		*
C*	IFLTYP (NLVL+1)	INTEGER		Fill contour types		*
C*	ISCALE		INTEGER		Scaling factor			*
C*	DMIN		REAL		Data minimum			*
C*	DMAX		REAL		Data maximum			*
C*	SCFLAG		LOGICAL		Suppress smalll contour flag	*
C*	IRET		INTEGER		Return code			*
C*					  0 = normal return		*
C**									*
C* Log:									*
C* K. Brill/NMC		01/92	Copied verbatim from GDNLEV		*
C* L. Sager/NMC		 8/93	Changed GR_SCAL to IN_SCAL & GR_SSCL	*
C* G. Krueger/EAI        8/93   Modified to get RINT from IN_CINT       *
C* M. Linda/GSC		 9/97	Changed a key word in the prologue	*
C* S. Jacobs/NCEP	 1/99	Changed call to IN_LINE			*
C* S. Jacobs/NCEP	 5/99	Changed call to IN_LINE			*
C* T. Lee/SAIC		10/01	Added contour fill types to calling seq.*
C* C. Bailey/HPC	 6/06	Added contour labels to calling seq.	*
C* C. Bailey/HPC	10/06	Added suppress smalll contour flag	*
C************************************************************************
	INCLUDE		'GEMPRM.PRM'
C*
	CHARACTER*(*)	line, cint, scale, fline, fint, clbl (*)
	REAL		grid (*), clvl (*), flvl (*)
	INTEGER		iccolr (*), icltyp (*), iclwid (*), iclabl (*),
     +			ifcolr (*), iflabl (*), ifltyp (*)
	LOGICAL		cflag, fflag, scflag
C*
	CHARACTER*24	tlbl
	LOGICAL		onelev
C------------------------------------------------------------------------
	iret  = 0
	nclvl = 0
	nflvl = 0
C
C*	Do an automatic scaling.
C
	CALL IN_SCAL  ( scale, iscale, iscalv, iret )
	CALL GR_SSCL  ( iscale,  kx, ky, imin, jmin, imax, jmax, grid,
     +			dmin, dmax, ier )
C
C*	Get the levels for the line contours first.
C
	IF  ( cflag )  THEN
C
C*	  Find the contour levels to use.
C
	  kxky1 = kx * ky
	  CALL IN_CINT  ( cint, grid, kxky1, dmin, dmax, clvl, nclvl,
     +			  clbl, rint, iret )
	  IF  ( iret .ne. 0 )  THEN
	    nclvl = 0
	    iret = +1
	    RETURN
	  END IF
C
C*	  Eliminate duplicate levels; sort levels; assign line attributes.
C
	  IF  ( nclvl .gt. 0 )  THEN
C
C*	    Make sure there are no duplicate levels.
C
	    ilvl = 1
	    DO  i = 2, nclvl
		IF  ( clvl (i) .ne. clvl (i-1) )  THEN
		    ilvl = ilvl + 1
		    clvl (ilvl) = clvl (i)
		    clbl (ilvl) = clbl (i)
		END IF
	    END DO
	    nclvl = ilvl
C
C*	    Get the colors, line types, line widths and labels.
C
	    CALL IN_LINE ( line, clvl, nclvl, iccolr, icltyp, iclwid, 
     +			   iclabl, smth, fltr, scflag, iret )
C
C*	    Check that at least one line has a color.  
C
	    onelev = .false.
	    DO  i = 1, nclvl
		IF  ( iccolr (i) .gt. 0 )  onelev = .true.
	    END DO
	    IF  ( .not. onelev )  THEN
		nclvl = 0
	      ELSE
C
C*		Sort the levels from smallest to largest.
C
		DO  i = 1, nclvl - 1
		    DO  j = i+1, nclvl
			IF  ( clvl (i) .gt. clvl (j) )  THEN
			    jcol = iccolr (i)
			    jtyp = icltyp (i)
			    jwid = iclwid (i)
			    jlbl = iclabl (i)
			    csav = clvl (i)
			    tlbl = clbl (i)
			    iccolr (i) = iccolr (j)
			    icltyp (i) = icltyp (j)
			    iclwid (i) = iclwid (j)
			    iclabl (i) = iclabl (j)
			    clvl   (i) = clvl   (j)
			    clbl   (i) = clbl   (j)
			    iccolr (j) = jcol
			    icltyp (j) = jtyp
			    iclwid (j) = jwid
			    iclabl (j) = jlbl
			    clvl   (j) = csav
			    clbl   (j) = tlbl
			END IF
		    END DO
		END DO
	    END IF
	  END IF
	END IF
C
C*	Now, get the contour levels for the filled contours.
C
	IF  ( fflag )  THEN
C
C*	  Process color fill contours.
C
	  CALL IN_FILL ( fint, fline, dmin, dmax, flvl, nflvl, rfint, 
     +			 fmin, fmax, ifcolr, ifltyp, iflabl, iret )
	  IF  ( iret .ne. 0 )  THEN
	    CALL ER_WMSG ( 'IN', iret, ' ', ier )
	    iret = +1
	    nflvl = 0
	  END IF
	END IF
C*
	RETURN
	END
