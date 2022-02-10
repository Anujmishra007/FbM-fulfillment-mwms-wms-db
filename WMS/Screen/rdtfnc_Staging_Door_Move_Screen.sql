-- 2200 = Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 2200 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2200, 'ENG',
    @cLine01 = 'STAGE/DOOR MOVE'
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%18i01'
   ,@cLine06 = 'OPTION: %01i02'
   ,@cLine08 = '1 = TO STAGING'
   ,@cLine09 = '2 = TO DOOR'
   ,@cLine10 = '3 = STAGING TO' -- (Vicky04)
   ,@cLine11 = '    STAGING' -- (Vicky04)
   ,@cLine14 = '%e'
 
-- 2201 = Staging screen
DELETE rdt.RDTScn WHERE Scn = 2201 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2201, 'ENG',
    @cLine01 = 'STAGE MOVE'
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'STAGING LANE:'
   ,@cLine06 = '%10d02'
   ,@cLine07 = '%10i03'
   ,@cLine14 = '%e'
 
-- 2202 = Staging screen
DELETE rdt.RDTScn WHERE Scn = 2202 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2202, 'ENG',
    @cLine01 = 'STAGE MOVE'
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'STAGING LANE:'
   ,@cLine06 = '%10d02'
   ,@cLine08 = 'Move Completed'
   ,@cLine14 = '%e'


-- 2203 = Door screen
DELETE rdt.RDTScn WHERE Scn = 2203 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2203, 'ENG',
    @cLine01 = 'DOOR MOVE'
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'DOOR:'
   ,@cLine06 = '%11i02' -- (ChewKP01)
   ,@cLine14 = '%e'
 
-- 2204 = Door screen
DELETE rdt.RDTScn WHERE Scn = 2204 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2204, 'ENG',
    @cLine01 = 'DOOR MOVE'
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'DOOR:'
   ,@cLine06 = '%10d02'
   ,@cLine08 = 'Move Completed'
   ,@cLine14 = '%e'

-- (Vicky04) - Start
-- 2205 = Staging To Staging screen
DELETE rdt.RDTScn WHERE Scn = 2205 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2205, 'ENG',
    @cLine01 = 'STAGE TO STAGE MOVE'
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'FROM STAGING LANE:'
   ,@cLine06 = '%10i02'
   ,@cLine14 = '%e'

-- 2206 = Staging To Staging screen
DELETE rdt.RDTScn WHERE Scn = 2206 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2206, 'ENG',
    @cLine01 = 'STAGE TO STAGE MOVE'
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'FROM STAGING LANE:'
   ,@cLine06 = '%10d02'
   ,@cLine07 = 'TO STAGING LANE:'
   ,@cLine08 = '%10i03'
   ,@cLine14 = '%e'
 
 
-- 2207 = Staging to Staging screen
DELETE rdt.RDTScn WHERE Scn = 2207 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2207, 'ENG',
    @cLine01 = 'STAGE TO STAGE MOVE'
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'FROM STAGING LANE:'
   ,@cLine06 = '%10d02'
   ,@cLine07 = 'TO STAGING LANE:'
   ,@cLine08 = '%10d03'
   ,@cLine10 = 'Move Completed'
   ,@cLine14 = '%e'
-- (Vicky04) - End