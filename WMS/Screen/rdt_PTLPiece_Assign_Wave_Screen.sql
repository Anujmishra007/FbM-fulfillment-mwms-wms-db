
-- Station, position, carton
DELETE rdt.RDTScn WHERE Scn = 4607 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4607, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'WaveKey:'
   ,@cLine03 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 803