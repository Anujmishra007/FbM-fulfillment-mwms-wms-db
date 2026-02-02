-- 6622 Case ID
DELETE rdt.RDTScn WHERE Scn = 6622 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6622, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Case ID:'
   ,@cLine03 = '%01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 600
