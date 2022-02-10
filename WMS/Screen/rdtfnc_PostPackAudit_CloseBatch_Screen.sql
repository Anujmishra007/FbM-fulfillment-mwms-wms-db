-- -- 1102 = Option screen
-- DELETE rdt.RDTScn WHERE Scn = 1102 AND Lang_Code = 'ENG'
-- EXECUTE rdt.rdtAddScn 1102, 'ENG',
--     @cLine01 = 'Close this batch?'
--    ,@cLine02 = '%15d01'
--    ,@cLine04 = '1=YES'
--    ,@cLine05 = '2=NO'
--    ,@cLine07 = 'Option: %01i02'
--    ,@cLine14 = '%e'
--  
-- 
-- -- 1103 = Message screen
-- DELETE rdt.RDTScn WHERE Scn = 1103 AND Lang_Code = 'ENG'
-- EXECUTE rdt.rdtAddScn 1103, 'ENG',
--     @cLine01 = 'Batch closed'
--    ,@cLine02 = 'successfully'
--    ,@cLine04 = 'Press ENTER or ESC'
--    ,@cLine05 = 'to continue'
--    ,@cLine14 = '%e'

-- SOS#137534 - Add Batch Screen as 1st Screen, revamp of existing Screen (Vicky01) - Start

-- 1102 = Batch screen
DELETE rdt.RDTScn WHERE Scn = 1102 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1102, 'ENG',
    @cLine01 = 'CLOSE BATCH'
   ,@cLine03 = 'BATCH:'
   ,@cLine04 = '%15i01'
   ,@cLine14 = '%e'
 

-- 1103 = Option screen
DELETE rdt.RDTScn WHERE Scn = 1103 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1103, 'ENG',
    @cLine01 = 'Close this batch?'
   ,@cLine02 = '%15d01'
   ,@cLine04 = '1=YES'
   ,@cLine05 = '2=NO'
   ,@cLine07 = 'Option: %01i02'
   ,@cLine14 = '%e'
 

-- 1104 = Message screen
DELETE rdt.RDTScn WHERE Scn = 1104 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1104, 'ENG',
    @cLine01 = 'Batch closed'
   ,@cLine02 = 'successfully'
   ,@cLine04 = 'Press ENTER or ESC'
   ,@cLine05 = 'to continue'
   ,@cLine14 = '%e'
 
-- SOS#137534 - (Vicky01) - Start