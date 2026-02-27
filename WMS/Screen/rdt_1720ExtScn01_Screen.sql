-- FCR-8808
DELETE rdt.RDTScn WHERE Scn = 6770 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6770, 'ENG', 
   @cLine01 = 'PALLET CONSOLIDATION',
   @cLine03 = 'FROM PALLET ID:',
   @cLine04 = '%20d01',
   @cLine05 = 'TO PALLET ID:',
   @cLine06 = '%20d02',
   @cLine08 = 'CaseID:',
   @cLine09 = '%20i03',
   @cLine14 = '%e'
   ,@nFunc = 1720