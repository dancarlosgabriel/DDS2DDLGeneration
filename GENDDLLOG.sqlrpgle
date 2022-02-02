**FREE
   // **************************************************************************
   // *   Src Name    : GENDDLLOG                                              *
   // *   Description : Gen SQL DDL from DDS Audit Logging                     *
   // *                                                                        *
   // *                                 Author : Reynaldo Dandreb M. Medilla   *
   // **************************************************************************

Ctl-opt Option(*SRCSTMT : *NODEBUGIO) DFTACTGRP(*NO);

// *****************************************************************************
// entry parms
// *****************************************************************************
Dcl-pi *N;
   pLogCode char(10) const;
   pRefObj  char(10) const;
   pRefLib  char(10) const;
   pSrcPF   char(10) const;
   pSrcLib  char(10) const;
   pSrcNam  char(10) const;
   pDDLOK char(1) const;
   pOBJOK char(1) const;
   pMsg char(100) const;
End-pi;

// **************************************************************************
// *   Program variables
// **************************************************************************

Dcl-s wCurrUser Char(10) Inz(*User);
Dcl-s wCurrTimeS Timestamp Inz(*Sys);
Dcl-s wSqlStmt Char(400);
Dcl-s wDDLOK Char(1);
Dcl-s wOBJOK Char(1);
Dcl-s wDDLMSG Char(100);
Dcl-s wOBJMSG Char(100);
Dcl-s wI int(10);

Dcl-c cSQLOK '00000';
Dcl-c cSQLEOF '02000';
Dcl-c cQ '''';

// **************************************************************************
//  Main Program Logic
// **************************************************************************

Exsr srMain;
Exsr srEndPgm;

// **********************************************************************
// main routine
// **********************************************************************
Begsr srMain;

   Exec SQL   Set Option Commit = *NONE, DatFmt = *ISO;

   Exec SQL   Select count(*) Into :wI
              From GENLOGPF
              Where POBJLIB = :pRefLib  And POBJNAM = :pRefObj;

   // record exists then maintain 1rcd per reflib+refobj
   If wI > 0;
      If pLogCode = 'DDS2DDL';
         Exec SQL   Update GENLOGPF
                    Set PGENDDLOK = :pDDLOK, PDDLMSG = :pMsg, PBYUSER = :wCurrUser
                    Where POBJLIB = :pRefLib  And POBJNAM = :pRefObj;
      ElseIf pLogCode = 'GENDDLOBJ';
         Exec SQL   Update GENLOGPF
                    Set PGENOBJOK = :pOBJOK, POBJMSG = :pMsg, PBYUSER = :wCurrUser
                    Where POBJLIB = :pRefLib  And POBJNAM = :pRefObj;
      Endif;

   Else;
      // crt new log record
      If pLogCode = 'DDS2DDL';
         wDDLOK  = pDDLOK;
         wOBJOK  = 'X';
         wDDLMSG = pMsg;
      ElseIf pLogCode = 'GENDDLOBJ';
         wDDLOK  = 'X';
         wOBJOK  = pOBJOK;
         wOBJMSG = pMsg;
      Endif;

      Exec SQL   Insert into GENLOGPF
                 Values(:pRefLib, :pRefObj, :pSrcLib, :pSrcPF, :pSrcNam,
                   :wDDLOK, :wOBJOK, :wDDLMSG, :wOBJMSG, :wCurrUser, DEFAULT);
   Endif;

Endsr;
// **********************************************************************
// terminal logic
// **********************************************************************
Begsr srEndPgm;

   *INLR = *On;
   Return;

Endsr;

// ----------------------------------------------------------------------
//  User Defined Functions
// ----------------------------------------------------------------------
// Dcl-proc xxx;
// Return yyy;
// End-proc;

