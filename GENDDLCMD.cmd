/***************************************************************************/
/**   Src Name    : GENDDLCMD                                              */
/**   Description : Gen SQL DDL from DDS Command                           */
/**                                                                        */
/**                                   Author : Reynaldo Dandreb M. Medilla */
/***************************************************************************/
             CMD        PROMPT('Generate DDL from DDS')

             PARM       KWD(OBJLIB) TYPE(*NAME) MIN(1) +
                          PROMPT('Object Lib to gen DDL src from')

             PARM       KWD(SRCPF) TYPE(*NAME) MIN(1) +
                          PROMPT('Source PF for DDL source')

             PARM       KWD(SRCLIB) TYPE(*NAME) MIN(1) +
                          PROMPT('Library for DDL source')

             PARM       KWD(DDLOBJLIB) TYPE(*NAME) MIN(0) +
                          PROMPT('Target SQL Object Library')

             PARM       KWD(CUSTOMCODE) TYPE(*CHAR) LEN(20) +
                          SPCVAL(('CUSTOM-RUN') ('PF-ONLY') +
                          ('FILE={NAME}')) +
                          CHOICE('CUSTOM-RUN,PF-ONLY,FILE={NAME}') +
                          PROMPT('Valid Pre-defined Codes')

             PARM       KWD(SKIPGENOBJ) TYPE(*CHAR) LEN(1) +
                          RSTD(*YES) DFT(Y) VALUES('Y' 'N') +
                          PROMPT('Skip/Not skip SQL Obj creation')


