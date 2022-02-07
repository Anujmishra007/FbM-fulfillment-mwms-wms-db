-- 2990 = ID, LOC
DELETE rdt.RDTScn WHERE Scn = 2990 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2990, 'ENG'
   ,@cLine01 = 'ID:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1791

-- 2991 = Suggested LOC, final LOC
DELETE rdt.RDTScn WHERE Scn = 2991 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2991, 'ENG'
   ,@cLine01 = 'SUGGESTED LOC:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'FINAL LOC:'
   ,@cLine05 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1791

-- 2992 = Message screen
DELETE rdt.RDTScn WHERE Scn = 2992 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2992, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Successful putaway'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER to'
   ,@cLine06 = 'putaway next ID'
   ,@cLine14 = '%e'
   ,@nFunc = 1791
