--rdtfnc_PackByTrackNo
-- 3120 - 3129

DELETE RDT.RDTMsg WHERE Message_ID = 840 AND Lang_Code = 'ENG' AND Message_Type = 'FNC'
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('840', 'ENG', 'FNC', 'Pack By TrackNo', 'rdtfnc_PackByTrackNo', '9')

-- 3120 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3120 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3120, 'ENG',
    @cLine01 = 'Pack By TrackNo'
   ,@cLine03 = 'ORDERKEY:'
   ,@cLine04 = '%10i01'
   ,@cLine06 = 'TOTE ID:'  -- SOS353558
   ,@cLine07 = '%20i02'
   ,@cLine09 = 'REF NO:'   -- WMS-15906
   ,@cLine10 = '%40i03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["3","4"],"2":["6","7"],"3":["9","10"]}'
   ,@nFunc = 840
 
-- 3121 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3121 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3121, 'ENG',
    @cLine01 = 'Pack By TrackNo'
   ,@cLine03 = 'ORDERKEY:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'TRACK NO:'
   ,@cLine06 = '%18i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["3","4"],"2":["6","7"]}'
   ,@nFunc = 840
   
-- 3122 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3122 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3122, 'ENG',
    @cLine01 = 'ORDERKEY: %10d01'
   ,@cLine02 = 'TRACK NO:'
   ,@cLine03 = '%18d02'
   ,@cLine04 = 'CARTON NO: %05i03'
   ,@cLine05 = ''
   ,@cLine06 = 'TTL EXP : %05d04'
   ,@cLine07 = 'TTL PACK: %05d05'
   ,@cLine08 = ''
   ,@cLine09 = 'SKU:'
   ,@cLine10 = '%30i06'    -- SOS300492 Extend to 30 chars
   ,@cLine11 = 'ABORT? (1=YES) %01i07'
   ,@cLine12 = ''
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3"],"3":["4"],"4":["6","7"],"5":["9","10"],"6":["11"],"7":["13"]}'
   ,@nFunc = 840
   
/* -- For CN only SOS320585
   UPDATE rdt.rdtScnDetail SET TextColor = 'yellow' WHERE Scn = 3122 AND FieldNo = 15
*/
   
-- 3123 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3123 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3123, 'ENG',
    @cLine01 = 'Pack By TrackNo'
   ,@cLine03 = 'ORDERKEY:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'TRACK NO:'
   ,@cLine06 = '%18d02'
   ,@cLine07 = 'CARTON NO: %05d03'
   ,@cLine09 = 'CARTON TYPE:'
   ,@cLine10 = '%10i04'
   ,@cLine11 = 'CARTON WEIGHT:'
   ,@cLine12 = '%10i05    KG'
   ,@cLine13 = '%20d15' -- WMS-13913
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["3","4"],"2":["5","6"],"3":["7"],"4":["9","10"],"5":["11","12"],"6":["13"]}'
   ,@nFunc = 840
   
-- 3124 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3124 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3124, 'ENG',
    @cLine01 = 'Pick&Pack Completed'
   --,@cLine02 = 'And Label/Report'
   --,@cLine03 = 'Printed'
   ,@cLine02 = '%20d01'    -- SOS300492 change to variable content
   ,@cLine03 = '%20d02'    -- SOS300492 change to variable content
   ,@cLine05 = 'Press ENTER'
   ,@cLine06 = 'For next Pick&Pack'
   ,@cLine13 = '%20d15'  -- FCR-3728
   ,@cLine14 = '%e'   
   ,@cWebGroup = '{"1":["1"],"2":["2","3"],"3":["4"],"4":["5","6"],"5":["13"]}'
   ,@nFunc = 840
   
-- 3125 used by Multi sku screen

-- WMS13965
-- 3126 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3126 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3126, 'ENG',
    @cLine01 = 'Pack By TrackNo'
   ,@cLine02 = ''
   ,@cLine03 = 'CONFIRM UNPACK ?'    
   ,@cLine04 = '1 = YES'    
   ,@cLine05 = '2 = NO'
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'   
   ,@cWebGroup = '{"1":["3","4"],"2":["6","7"],"3":["9","10"],"4":["12","13"]}'
   ,@nFunc = 840
   
--WMS-22084 - Capture Info
DELETE rdt.RDTScn WHERE Scn = 3127 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3127, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%20i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20i08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%20i10'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"],"4":["7","8"],"5":["9","10"]}'
   ,@nFunc = 840
   
-- update rdt.rdtscn with function id   
UPDATE RDT.RDTSCN SET FUNC = 840 WHERE SCN BETWEEN 3120 AND 3129
   
-- Note: This module no need set function no as it is shared across multi function