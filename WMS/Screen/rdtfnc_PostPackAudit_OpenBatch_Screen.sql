-- 1101 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1101 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1101, 'ENG',
    @cLine01 = 'OPEN BATCH'
   ,@cLine03 = 'BATCH:'
   ,@cLine04 = '%15i01'
   ,@cLine14 = '%e'
