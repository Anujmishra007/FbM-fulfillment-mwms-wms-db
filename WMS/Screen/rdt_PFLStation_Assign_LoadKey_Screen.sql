
-- LoadKey
DELETE rdt.RDTScn WHERE Scn = 5512 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5512, 'ENG'
   ,@cLine01 = 'LoadKey:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 801