/* $Id:$ */
%macro ODBCLibDef(LIB=_X_,SCHEMA=DATAMART,DB=CAPDB,ODBCDSN=PROD,ACCESS=RO);
    %local L ODBC_CRED;

    %if "&LIB." = "_X_" %then %let L = &SCHEMA.;
    %else %let L = &LIB.;

    %if "&ODBCDSN." = "DEVL" %then %let ODBC_CRED = &&AZURE_&DB..;
    %else %let ODBC_CRED = %str("dsn=&ODBCDSN.;Trusted_Connection=yes;database=&DB.");

    libname &L. odbc
        noprompt = &ODBC_CRED.
        schema = &SCHEMA.
        %if "&ACCESS." = "RO" %then %do;
        access = readonly
        %end;
        ;
    run;
%mend ODBCLibDef;
/* EOF Jack N Shoemaker (JShoemaker@TextureHealth.com) */
