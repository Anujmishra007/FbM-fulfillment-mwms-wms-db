-- 6772 To ID
DELETE rdt.RDTScn WHERE Scn = 6772 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6772, 'ENG'
   ,@cLine01 = 'To ID:'
   ,@cLine02 = '%60i01'
   ,@cLine14 = '%e'
   ,@nFunc = 605
