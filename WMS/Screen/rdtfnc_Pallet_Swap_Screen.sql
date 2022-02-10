-- 4160 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4160 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4160, 'ENG',
    @cLine01 = 'FROM ID: '
   ,@cLine02 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc   = 961

-- 4161 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4161 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4161, 'ENG',
    @cLine01 = 'FROM ID: '
   ,@cLine02 = '%18d01'
   ,@cLine04 = 'TO ID: '
   ,@cLine05 = '%18i02'
   ,@cLine14 = '%e'
   ,@nFunc   = 961

-- 4162 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4162 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4162, 'ENG',
    @cLine01 = 'ID SWAPPED '
   ,@cLine02 = 'SUCCESSFULLY.'
   ,@cLine04 = 'PRESS ENTER'
   ,@cLine05 = 'TO CONTINUE.'
   ,@cLine14 = '%e'
   ,@nFunc   = 961