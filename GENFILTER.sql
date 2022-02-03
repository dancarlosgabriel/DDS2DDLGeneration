-- ---------------------------------------------------------------------------
-- Gen SQL DDL from DDS Filter File
--
--                               Author : Reynaldo Dandreb M. Medilla
-- ---------------------------------------------------------------------------
CREATE OR REPLACE TABLE GENFILTER (
  FFILTER  CHAR(1) NOT NULL,
  FOBJLIB CHAR(10) NOT NULL,
  FOBJNAM CHAR(10) NOT NULL,
  FOBJATR CHAR(2) NOT NULL,
  FNOTES CHAR(200) NOT NULL,
  FBYUSER CHAR(10) NOT NULL,
  FBYTIMES TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (FFILTER,FOBJLIB,FOBJNAM,FOBJATR)
)
RCDFMT GENFILTERR;

LABEL ON TABLE GENFILTER
            IS 'DDS TO DDL Generation Filter File';

LABEL ON COLUMN GENFILTER (
  FFILTER IS 'Filter Flag         I-incld E-excld',
  FOBJLIB IS 'Object Lib',
  FOBJNAM IS 'Object Name',
  FOBJATR IS 'Object Attr          PF/TB/LF/VW/IX',
  FNOTES IS 'Filter Notes',
  FBYUSER IS 'By User',
  FBYTIMES IS 'On Date and time'
);


