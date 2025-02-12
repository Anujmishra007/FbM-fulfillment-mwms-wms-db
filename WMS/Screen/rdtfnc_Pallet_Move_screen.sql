-- 3360 = ID, LOC
DELETE rdt.RDTScn WHERE Scn = 3360 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3360, 'ENG'
   ,@cLine01 = 'ID:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1721

-- 3361 = Suggested LOC, final LOC
DELETE rdt.RDTScn WHERE Scn = 3361 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3361, 'ENG'
   ,@cLine01 = 'ID:'
   ,@cLine02 = '%20d01'
   ,@cLine04 = 'TO LOC:'
   ,@cLine05 = '%10d03'
   ,@cLine06 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1721

-- 3362 = Message screen
DELETE rdt.RDTScn WHERE Scn = 3362 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3362, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Successful putaway'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER to'
   ,@cLine06 = 'putaway next ID'
   ,@cLine14 = '%e'
   ,@nFunc = 1721
