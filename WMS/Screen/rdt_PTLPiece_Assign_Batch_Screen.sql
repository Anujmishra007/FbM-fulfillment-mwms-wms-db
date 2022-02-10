
-- Station, position, carton
DELETE rdt.RDTScn WHERE Scn = 4600 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4600, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'BATCH: '
   ,@cLine03 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 803
