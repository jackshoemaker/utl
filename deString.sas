/* ---------------------------------------------------------------------------
 * deString macro converts all character data to numeric as needed
 *
 * Usage: %deString(IN=original,OUT=converted,<INSPECT=NNN|ALL>
 *
 * Parameters:
 *  IN - required - name of original data set
 *  OUT - required - name of converted (output) data set
 *  INSPECT - optional - a number or 'ALL' - determines number fo rows to scan
 * --------------------------------------------------------------------------- */
%macro deString(IN=,OUT=,INSPECT=100);

/* put the number of data set variables into the NVARS macro symbol */
data __IN_;
  if 0 then set &IN.;
  array pdv{*} _character_;
  call symput( 'NVARS', put( dim(pdv), z5. ) );
  stop;
  run;
  
/* put the list of columns into a space-delimited list.
 * this technique is limited by teh maximum size of a
 * macro symbol which is 32K.
 */
proc sql noprint;
  select name into :VARS separated by ' '
  from dictionary.columns
  where libname = 'WORK' and memname = '__IN_';
  quit;
  run;

/* figure out which variables are character.
 * create a list of these variables into NUMVAR macro symbol.
 * this symbol also constrained by maximum macro symbol size.
 */
data _null_;
  retain ischar00001 - ischar&NVARS. 0;
  length __r __n $ 32000 __v $ 32;
  %if &INSPECT = ALL %then %do;
  set &IN end = lastrec;
  %end;
  %else %do;
  set &IN( obs = &INSPECT. ) end = lastrec;
  %end;
  array pdv{*} &VARS.;
  array ischar{*} ischar00001 - ischar&NVARS.;
  do i = 1 to dim( pdv );
    __p = prxmatch( '/[a-z]|[A-Z]/', pdv{i} );
    if ischar{i} = 0 then do;
      ischar{i} = ( __p > 0 );
    end; 
  end;
  if lastrec then do;
    if sum( of ischar{*} ) ^= &NVARS. then do;
      call symput( 'NONUM', 'N' );
      do i = 1 to dim( pdv );
	if ischar{i} = 0 then do;
	  __v = scan( "&VARS.", i, ' ' );
	  __r = trim( __r ) || ' ' || '_' || trim( __v ); 
	  __n = trim( __n ) || ' ' || trim( __v );
	end;
      end;
    end;
    else do;
      call symput( 'NONUM', 'Y' );
    end;
    call symput( 'RENAME', trim( __r ) );
    call symput( 'NUMVAR', trim( __n ) );
  end;
  run;

/* rename the numberic varaibles on the way in.
 * use input function to convert to number.
 * drop the temporary renamed variables.
 */
data &OUT.
  %if &NONUM = N %then %do;
    ( drop =
    %let c = 1;
    %let r = %scan( &RENAME., &c, ' ' );
    %do %while(&r ^=);
      &r
      %let c = %eval( &c + 1 );
      %let r = %scan( &RENAME., &c, ' ' );
    %end;
    )
  %end;
  ;
  set &IN.
  %if &NONUM = N %then %do;
    ( rename = ( 
    %let c = 1;
    %let r = %scan( &RENAME., &c, ' ' );
    %let n = %scan( &NUMVAR., &c, ' ' );		      
    %do %while(&r ^=);
      &n = &r
      %let c = %eval( &c + 1 );
      %let r = %scan( &RENAME., &c, ' ' );
      %let n = %scan( &NUMVAR., &c, ' ' );		      
    %end;
    ) )
  %end;
  ;  
  %if &NONUM = N %then %do;
    %let c = 1;
    %let r = %scan( &RENAME., &c, ' ' );
    %let n = %scan( &NUMVAR., &c, ' ' );		      
    %do %while(&r ^=);
      &n = input( &r, best32. );
      %let c = %eval( &c + 1 );
      %let r = %scan( &RENAME., &c, ' ' );
      %let n = %scan( &NUMVAR., &c, ' ' );		      
    %end;
  %end;
  run;
  
%mend deString;
