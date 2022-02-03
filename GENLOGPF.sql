-- ---------------------------------------------------------------------------
-- Gen SQL DDL from DDS Log File
--
--                           Author : Reynaldo Dandreb M. Medilla
-- ---------------------------------------------------------------------------
CREATE OR REPLACE TABLE GENLOGPF (
  POBJLIB CHAR(10) NOT NULL,
  POBJNAM CHAR(10) NOT NULL,
  PSRCLIB CHAR(10) NOT NULL,
  PSRCPF CHAR(10) NOT NULL,
  PSRCNAM CHAR(10) NOT NULL,
  PGENDDLOK CHAR(1) NOT NULL,
  PGENOBJOK CHAR(1) NOT NULL,
  PDDLMSG CHAR(100) NOT NULL,
  POBJMSG CHAR(100) NOT NULL,
  PBYUSER CHAR(10) NOT NULL,
  PBYTIMES TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (POBJLIB,POBJNAM)
)
RCDFMT GENLOGPFR;

LABEL ON TABLE GENLOGPF
            IS 'DDS TO DDL Generation Log File';

LABEL ON COLUMN GENLOGPF (
  POBJLIB IS 'Object Lib',
  POBJNAM IS 'Object Name',
  PSRCLIB IS 'Source Lib',
  PSRCPF  IS 'Source PF',
  PSRCNAM IS 'Source Name',
  PGENDDLOK IS 'DDS to DDL          Success Flag',
  PGENOBJOK IS 'DDL Object Gen      Success Flag',
  PDDLMSG IS 'DDS2DDL Remarks',
  POBJMSG IS 'GENDDLOBJ Remarks',
  PBYUSER IS 'By User',
  PBYTIMES IS 'On Date and time'
);
