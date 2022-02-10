-- 3750 = Order screen
DELETE rdt.RDTScn WHERE Scn = 3750 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3750, 'ENG'
   ,@cLine01 = 'ORDERKEY: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 548

-- 3751 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 3751 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3751, 'ENG'
   ,@cLine01 = 'ORDERKEY: %10d01'
   ,@cLine02 = ''
   ,@cLine03 = 'TRACKING NO:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = ''
   ,@cLine08 = 'TOTAL TRACKING NO:'
   ,@cLine09 = 'OLD: %05d05'
   ,@cLine10 = 'NEW: %05i06'
   ,@cLine14 = '%e'
   ,@nFunc = 548

-- 3752 = Order screen
DELETE rdt.RDTScn WHERE Scn = 3752 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3752, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'TRACK NO UPDATED'
   ,@cLine03 = ''
   ,@cLine04 = 'PRESS ENTER OR ESC'
   ,@cLine14 = '%e'
   ,@nFunc = 548
      
   