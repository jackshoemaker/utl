/* $Id:$ */
%macro GetLatest(HLQ=.,MASK=*.*,RESULT=LATEST);
    %global &RESULT.;

    filename dir pipe %unquote(%str(%'dir /b %")&HLQ.\&MASK.%str(%"%'));
    run;

    data _null_;
        length latest fn fp $ 200;
        retain latest latestmod;
        infile dir lrecl = 200 end = lastrec;
        input;
        fn = trim( _infile_ );
        fp = trim( "&HLQ.\" || _infile_ );
        rc = filename( 'abc', fp );
        fid = fopen( 'abc' );
        ModDate = input( finfo( fid, foptname( fid, 6 ) ), datetime22. );
        rc = fclose( fid );
        if ModDate > latestmod then do;
            latestmod = ModDate;
            latest = fn;
            end;
        if lastrec then call symputx( "&RESULT.", trim( latest ) );
    run;

    filename dir clear;
    run;
%mend GetLatest;
/* EFO Jack N Shoemaker (JShoemaker@TextureHealth.com) */
