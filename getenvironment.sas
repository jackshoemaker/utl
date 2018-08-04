/* $Id:$ */
/* loads Windows environment symbols identified in SYMBOLS as SAS macro symbols of teh same name
   Usage: %GetEnvironment(SYMBOLS=MODE SRCHLQ);
*/
%macro GetEnvironment(SYMBOLS=);
    %global
        &SYMBOLS.;
    %local
        C TOKEN;
    %let C = 1;
    %let TOKEN = %scan( &SYMBOLS., &C., ' ' );
    %do %while(&TOKEN.^=);
        %let &TOKEN = %sysget(&TOKEN.);
        %let C = %eval( &C. + 1 );
        %let TOKEN = %scan( &SYMBOLS., &C., ' ' );
        %end;
%mend GetEnvironment;
/* EOF Jack N Shoemaker (JShoemaker@TextureHealth.com) */
