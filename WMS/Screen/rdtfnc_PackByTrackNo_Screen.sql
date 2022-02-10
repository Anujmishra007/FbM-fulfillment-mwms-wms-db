--rdtfnc_PackByTrackNo
-- 3120 - 3129

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 840)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('840', 'ENG', 'FNC', 'Pack By TrackNo', 'rdtfnc_PackByTrackNo', '9')
END

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
   
 
-- 3121 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3121 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3121, 'ENG',
    @cLine01 = 'Pack By TrackNo'
   ,@cLine03 = 'ORDERKEY:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'TRACK NO:'
   ,@cLine06 = '%18i02'
   ,@cLine14 = '%e'

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
   ,@cLine14 = '%e'   

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

-- update rdt.rdtscn with function id   
UPDATE RDT.RDTSCN SET FUNC = 840 WHERE SCN BETWEEN 3120 AND 3129
   
-- Note: This module no need set function no as it is shared across multi function