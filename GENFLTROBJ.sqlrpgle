**FREE
   // **************************************************************************
   // *   Member:       GENFLTROBJ                                             *
   // *   Description:  Gen SQL DDL from DDS Object Filtering                  *
   // *                                                                        *
   // *                                  Author : Reynaldo Dandreb M. Medilla  *
   // **************************************************************************

Ctl-opt Option(*SRCSTMT : *NODEBUGIO) DFTACTGRP(*NO);

// *****************************************************************************
// entry parms
// *****************************************************************************
Dcl-pi *N;
   pFltrCode char(1) const;
   pObjLib  char(10) const;
   pObjNam  char(10) const;
   pObjAtr  char(2) const;
   pFoundIt char(1);
End-pi;

// **************************************************************************
// *   Program variables
// **************************************************************************

Dcl-s wCurrUser Char(10) Inz(*User);
Dcl-s wCurrTimeS Timestamp Inz(*Sys);
Dcl-s wSqlStmt Char(400);
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
              From GENFILTER
              Where FFILTER = :pFltrCode And FOBJLIB = :pObjLib And FOBJNAM = :pObjNam;

   // record found then set return-parm
   If wI > 0;
      pFoundIt = 'Y';
   Else;
      pFoundIt = 'N';
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

