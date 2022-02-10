-- rdtfnc_CCStoreVerify
-- 3970 - 3979
DELETE rdt.rdtscn Where Scn = 3970 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3970, 'ENG',
   @cLine01 = 'PLS SCAN C&C LABEL:', 
   @cLine02 = '%20i01', 
   @cLine14 = '%e',
   @nFunc = 536

DELETE rdt.rdtscn Where Scn = 3971 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3971, 'ENG',
   @cLine01 = 'C&C LABEL:', 
   @cLine02 = '%20d01', 
   @cLine04 = '%20d02',
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '%20d06',
   @cLine09 = '%20d07',
   @cLine10 = '%20d08',
   @cLine11 = 'TO LOC:',
   @cLine12 = '%10d09',
   @cLine13 = '%10i10',
   @cLine14 = '%e',
   @nFunc = 536


