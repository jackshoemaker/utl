/* $Id:$ */
%macro NetCred(HOST=apps.closedloop.ai);
    %global
        USER PASS
        ;
/* pass in a HOST get back a USER and PASS based on private .netrc file */
data _null_;
    length token $ 32 host $ 100 user $ 32 pass $ 200;
    infile '%USERPROFILE%\.netrc' lrecl = 256;
    input;
    t = 1;
    token = scan( _infile_, t, ' ' );
    do while( not( missing( token ) ) );
        if token = 'machine' then do;
            host = scan( _infile_, t + 1, ' ' );
            end;
        else if token = 'login' then do;
            user = scan( _infile_, t + 1, ' ' );
            end;
        else if token = 'password' then do;
            pass = scan( _infile_, t + 1, ' ' );
            end;
        else do;
            put 'MHN-ERROR: Unexpected TOKEN ' t= token= / _infile_;
            end;
        t + 2;
        token = scan( _infile_, t, ' ' );
        end;
    if trim( host ) = "&HOST." then do;
        call symputx( 'USER', trim( user ) );
        call symputx( 'PASS', trim( pass ) );
        end;
run;
%mend NetCred;
/* EOF Jack N Shoemaker (JShoemaker@TextureHealth.com) */
