**FREE
   // **************************************************************************
   // *   Member:       DUPDEPFILS                                             *
   // *   Description:  Gen SQL DDL from DDS Dependent Files creation          *
   // *                                                                        *
   // *                                 Author : Reynaldo Dandreb M. Medilla   *
   // **************************************************************************

Ctl-opt Option(*SRCSTMT : *NODEBUGIO) DFTACTGRP(*NO) BNDDIR('QC2LE');

// *****************************************************************************
// entry parms
// *****************************************************************************
Dcl-pi *N;
   pRefLib char(10) const;
   pRefPF  char(10) const;
   pTgtLib char(10) const;
   pFailed char(1) ;
End-pi;

// prototypes
Dcl-pr RunCmd Int(10) Extproc( 'system' );
   Cmd pointer Value Options(*string);
End-pr;
// **************************************************************************
// *   Program variables
// **************************************************************************

Dcl-s wCurrUser Char(10) Inz(*User);
Dcl-s wCurrTimeS Timestamp Inz(*Sys);
Dcl-s wSqlStmt Char(400);
Dcl-s wErrMsgId char(7) Import('_EXCP_MSGID');
Dcl-s wI int(10);
Dcl-s xFLIB Char(10);
Dcl-s xFFIL Char(10);
Dcl-s xFFDP Char(10);
Dcl-s wCmd Char(255);

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

   // success is always assumed here, so pFailed is not set

   Exec SQL   Set Option Commit = *NONE, DatFmt = *ISO;

   Exec SQL   Declare C0 CURSOR FOR
                Select DBFLIB, DBFFIL, DBFFDP
                From QADBFDEP
                Where DBFLIB = :pRefLib And DBFFIL = :pRefPF
                Order By DBFLIB, DBFFIL
              For Read Only;

   Exec SQL   Open C0;

   DoW (1 = 1);
      Exec SQL  Fetch Next from C0 into :xFLIB, :xFFIL, :xFFDP;
      If SqlStt = cSQLEOF;
         Leave;
      Endif;

      Exsr CrtDupNow;
   Enddo;

   Exec SQL   Close C0;

Endsr;
// **********************************************************************
// duplicate the object
// **********************************************************************
Begsr CrtDupNow;

   Clear wErrMsgId;

   wCmd = 'ChkObj Obj(' + %trim(pTgtLIB) + '/' + %trim(xFFDP) + ') ObjType(*File)';
   RunCmd( wCmd );

   // skip copy if object exists
   If wErrMsgID = 'CPF9801';
      wCmd = 'Crtdupobj Obj(' + %trim(xFFDP) + ') ' +
                    'FromLib(' + %trim(xFLIB) + ') ObjType(*File) ' +
                    'ToLib(' + %trim(pTgtLIB) + ')';
      RunCmd( wCmd);
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

