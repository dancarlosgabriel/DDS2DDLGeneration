**FREE
   // **************************************************************************
   // *   Member:       GENDDLSRC                                              *
   // *   Description:  Gen SQL DDL from DDS DDL-Source Creation               *
   // *                                                                        *
   // *                                Author : Reynaldo Dandreb M. Medilla    *
   // **************************************************************************

Ctl-opt Option(*SRCSTMT : *NODEBUGIO) DFTACTGRP(*NO);

// *****************************************************************************
// entry parms
// *****************************************************************************
Dcl-pi *N;
   pGenType char(10) const;
   pObjNam  char(10) const;
   pObjLib  char(10) const;
   pSrcPF   char(10) const;
   pSrcLib  char(10) const;
   pSrcNam  char(10) const;
   pFailed  char(1);
   pSkipLog char(1);
End-pi;

// Prototypes
Dcl-pr PerformLog Extpgm( 'GENDDLLOG' );
   pLogCode char(10) const;
   pRefObj  char(10) const;
   pRefLib  char(10) const;
   pSrcPF   char(10) const;
   pSrcLib  char(10) const;
   pSrcNam  char(10) const;
   pConvOK  char(1) const;
   pGenObjOK char(1) const;
   pMsg char(100) const;
End-pr;
// **************************************************************************
// *   Program variables
// **************************************************************************

Dcl-s wCurrUser Char(10) Inz(*User);
Dcl-s wSqlStmt Char(400);
Dcl-s wLogMsg Char(100);
Dcl-s wConvOK Char(1);
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

   // build then exec sql
   wSQLStmt = BldSQLStmt( pGenType );

   Exec SQL   Set Option Commit = *NONE, DatFmt = *ISO;
   Exec SQL   Execute Immediate :wSQLStmt;

   // on sql error , tag it and give signal
   If SqlStt <> cSQLOK;
      pFailed = 'Y';
   Endif;

   // as the name implies
   Exsr srUpdateLog;

Endsr;
// **********************************************************************
// Update Log File
// **********************************************************************
Begsr srUpdateLog;

   If pSkipLog = 'Y';
      Leavesr;
   Endif;

   If pFailed = 'Y';
      wConvOK = 'N';
      wLogMsg = 'An error occurred during DDS to DDL conversion, please see the job logs.';
   Else;
      wConvOK = 'Y';
      wLogMsg = 'DDS to DDL conversion process completed successfully.';
   Endif;

   PerformLog( 'DDS2DDL'  :
                pObjNam   :
                pObjLib   :
                pSrcPF    :
                pSrcLib   :
                pSrcNam   :
                wConvOK   :
                ' '       :
                wLogMsg   );

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
Dcl-proc BldSqlStmt;

   // return/parms defn
   Dcl-pi *N Like(wSQLStmt);
      GenType char(10) value;
   End-pi;

   // vars defn
   Dcl-s SQLStmt Like(wSQLStmt);
   Dcl-s ObjType Char(10);
   Dcl-s WithIx Char(1);

   // main logic  --------------------

   ObjType = GenType;
   If GenType = 'LF2INDEX' or GenType = 'LF2VIEW' or GenType = 'LF2VIEW@IX';
      ObjType = 'VIEW';
   Endif;

   SQLStmt = 'Call QSYS2.GENERATE_SQL( '                                    +
                           ' ''' + %Trim(pObjNam) + ''',  '                 +
                           ' ''' + %Trim(pObjLib) + ''',  '                 +
                           ' ''' + %Trim(ObjType) + ''',  '                 +
                           ' ''' + %Trim(pSrcPF)  + ''',  '                 +
                           ' ''' + %Trim(pSrcLib) + ''',  '                 +
                           ' ''' + %Trim(pSrcNam) + ''',  '                 +
                           ' REPLACE_OPTION => ' + cQ + '1' + cQ + ','      +
                           ' TRIGGER_OPTION => ' + cQ + '0' + cQ + ','      +
                           ' PRIVILEGES_OPTION => ' + cQ + '0' + cQ + ','   +
                           ' STATEMENT_FORMATTING_OPTION => ' + cQ + '0' + cQ + ',' +
                           ' CREATE_OR_REPLACE_OPTION => ' + cQ + '1' + cQ;

   // set parms specific to gentype

   If GenType = 'TABLE';
      SQLStmt = %Trim(SQLStmt) + ')';

   ElseIf GenType = 'LF2VIEW' OR GenType = 'VIEW' OR GenType = 'LF2VIEW@IX';
      WithIx  = '0';
      If GenType = 'LF2VIEW@IX';
         WithIx  = '1';
      Endif;

      SQLStmt = %Trim(SQLStmt) +  ' , ' +
                         ' INDEX_INSTEAD_OF_VIEW_OPTION => ' + cQ + '0' + cQ + ',' +
                         ' DROP_OPTION => ' + cQ + '1' + cQ + ',' +
                         ' ADDITIONAL_INDEX_OPTION => ' + cQ + WithIx + cQ + ')';

   ElseIf GenType = 'LF2INDEX' OR GenType = 'INDEX';
      SQLStmt = %Trim(SQLStmt) + ' , ' +
                           ' INDEX_INSTEAD_OF_VIEW_OPTION => ' + cQ + '1' + cQ + ',' +
                           ' DROP_OPTION => ' + cQ + '1' + cQ + ')';

   Endif;

     // NOTE: 'drop xxx' drop stmt is there to ensure seamless object creation for
     //      index or view via runsqlstm.

   Return SQLStmt;
End-proc;

