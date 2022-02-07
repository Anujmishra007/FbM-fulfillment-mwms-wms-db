-- 3160 = ID
DELETE rdt.RDTScn WHERE Scn = 3160 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3160, 'ENG'
   ,@cLine01 = 'ID:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 915
