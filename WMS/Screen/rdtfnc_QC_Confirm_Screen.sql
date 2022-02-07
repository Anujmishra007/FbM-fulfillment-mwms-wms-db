-- 2420 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2420 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2420, 'ENG',
    @cLine01 = 'QC CONFIRMATION'
   ,@cLine03 = 'TOTE NO/CASE ID:'
   ,@cLine04 = '%18i01'
   ,@cLine14 = '%e'