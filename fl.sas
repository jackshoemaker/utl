/* $Id:$ */
%macro FL(MASK,FN=dir);
    filename &FN. pipe %unquote(%str(%'dir /b %")&MASK.%str(%"%'));
    run;
%mend FL;
/* EOF Jack N Shoemaker (JShoemaker@TextureHealth.com) */
