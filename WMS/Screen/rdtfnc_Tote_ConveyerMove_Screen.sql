-- 2530 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2530 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2530, 'ENG',
    @cLine01 = 'TOTE - CONVEYOR MOVE'
   ,@cLine03 = 'TOTE NO:'
   ,@cLine04 = '%08i01'
   ,@cLine06 = 'OR'
   ,@cLine08 = 'CASE ID:'
   ,@cLine09 = '%08i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1777
 
-- 2531 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2531 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2531, 'ENG',
    @cLine01 = 'TOTE - CONVEYOR MOVE'
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%18d02'
   ,@cLine05 = 'STATION: %10i03'
   ,@cLine07 = '%10d04'
   ,@cLine08 = '%10d05'
   ,@cLine09 = '%10d06'
   ,@cLine10 = '%10d07'
   ,@cLine11 = '%10d08'
   ,@cLine12 = '%10d09'
   ,@cLine13 = '%10d10'
   ,@cLine14 = '%e'
   ,@nFunc = 1777

-- 2532 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2532 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2532, 'ENG',
    @cLine01 = 'TOTE - CONVEYOR MOVE'
   ,@cLine03 = '1 = CREATE MOVE'
   ,@cLine05 = '9 = CANCEL MOVE'
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1777