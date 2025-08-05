IF NOT EXISTS( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 957 AND Lang_Code = 'ENG' AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('957', 'ENG', 'FNC', 'Pick Case', 'rdtfnc_PickCase', '0')

-- 5290 = PickSlipNo screen
DELETE rdt.RDTScn WHERE Scn = 5290 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5290, 'ENG'
   ,@cLine01 = 'PSNO: %10i01'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"]}'
   ,@nFunc = 957

-- 5291 = Pick zone screen
DELETE rdt.RDTScn WHERE Scn = 5291 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5291, 'ENG'
   ,@cLine01 = 'PSNO:   %10d01'
   ,@cLine02 = ''
   ,@cLine03 = 'PKZONE: %10i02'
   ,@cLine04 = ''
   ,@cLine05 = 'DROPID:'
   ,@cLine06 = '%20i03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["3"],"3":["5","6"]}'
   ,@nFunc = 957

-- 5292 = SKU QTY screen
 DELETE rdt.RDTScn WHERE Scn = 5292 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5292, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'ID:'
   ,@cLine03 = '%18d08'
   ,@cLine04 = 'SKU:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = 'UCC:'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%60i05'
   ,@cLine11 = 'TOTAL CASE: %05d06'
   ,@cLine12 = 'TOTAL SCAN: %05d07'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3"],"3":["4","5","6","7"], "4":["8","9","10"],"5":["11","12"]}'
   ,@nFunc = 957

-- 5293 = Message screen
DELETE rdt.RDTScn WHERE Scn = 5293 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5293, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'No more task in LOC'
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER or ESC'
   ,@cLine06 = 'to continue'
   ,@cLine14 = '%e'
   ,@cAutoDisappear = '1'
   ,@nFunc = 957

-- 5294 = Short pick screen
DELETE rdt.RDTScn WHERE Scn = 5294 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5294, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Short the Pick by%05d02Cases?'
--    ,@cLine02 = 'CONFIRM SHORT PICK?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '0 = NO'
--    ,@cLine06 = '3 = CLOSE DROPID' -- (ChewKP01)
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 957

-- 5295 = Skip LOC screen
DELETE rdt.RDTScn WHERE Scn = 5295 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5295, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'SKIP LOC?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 957
   
-- 5296 = Confirm LOC screen
DELETE rdt.RDTScn WHERE Scn = 5296 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5296, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'LOC: %10i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 957