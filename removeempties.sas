/* $Id:$ */
%macro RemoveEmpties(INDSN=,OUTDSN=);
    /* groom data to remove 100 percent missing columns - apply column labels */

    proc format;
        value nm . = '0' other = '1';
        value $ch ' ' = '0' other = '1';
        value ty 1 = 'NUM' 2 = 'CHAR';
    run;

    ods listing close;
    ods output onewayfreqs = tables( keep = table f_: frequency percent );
    run;

    proc freq data = &INDSN.;
        tables _all_ / missing;
        format _numeric_ nm. _character_ $ch.;
    run;

    ods output close;
    ods listing;
    run;

    data tables;
        set tables end = lastrec;
        length name $ 32;
        retain empties 0;
        if ( abs( percent - 100.00 ) < 0.005 ) & ( cats(of f_:) = '0' ) then do;
            name = scan( table, 2, ' ' );
            empties + 1;
            output;
            end;
        if lastrec then call symputx( 'EMPTIES', empties );
    run;

    proc sql noprint;
        select name into :EMPTY_COLS separated by ' ' from tables;
    quit;

    %put MHN-NOTE: These &EMPTIES. columns are 100 percent missing and therefore dropped from the [&INDSN.] data set. >&EMPTY_COLS.<;

    data &OUTDSN.( drop = &EMPTY_COLS. );
        set &INDSN.;
    run;
%mend RemoveEmpties;
/* EOF Jack N Shoemaker (JShoemaker@TextureHealth.com) */
