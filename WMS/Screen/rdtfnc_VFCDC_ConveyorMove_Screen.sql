


-- 3620 = TOLOC screen
DELETE rdt.RDTScn WHERE Scn = 3620 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3620, 'ENG',
    @cLine01 = 'WCS - CONVEYOR MOVE' -- (ChewKP01) 
   ,@cLine03 = 'TOLOC:'
   ,@cLine04 = '%15i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1799

-- 3621 = LPNNO screen
DELETE rdt.RDTScn WHERE Scn = 3621 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3621, 'ENG',
    @cLine01 = 'WCS - CONVEYOR MOVE' -- (ChewKP01) 
   ,@cLine03 = 'LPNNO:'
   ,@cLine04 = '%20i01'
   ,@cLine06 = 'LPNNO:'
   ,@cLine07 = '%20d02'
   ,@cLine08 = '%20d03'
   ,@cLine09 = '%20d04'
   ,@cLine10 = '%20d05'
   ,@cLine11 = '%20d06'
   ,@cLine12 = '%20d07'
   ,@cLine13 = '%20d08'
   ,@cLine14 = '%e'
   ,@nFunc = 1799

-- 3622 = Create/Cancel Option
DELETE rdt.RDTScn WHERE Scn = 3622 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3622, 'ENG',
    @cLine01 = 'WCS - CONVEYOR MOVE' -- (ChewKP01) 
   ,@cLine03 = '1 = CREATE MOVE'
   ,@cLine05 = '9 = CANCEL MOVE'
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1799