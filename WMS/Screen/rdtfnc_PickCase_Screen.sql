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

-- 6387 = SSCC FCR-454
DELETE rdt.RDTScn WHERE Scn = 6387 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6387, 'ENG'
   ,@cLine01 = 'SSCC'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 957

-- 6388 = UCCNo FCR-454
DELETE rdt.RDTScn WHERE Scn = 6388 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6388, 'ENG'
   ,@cLine01 = 'LOC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'Style: %13d02'
   ,@cLine04 = 'Size: %13d03'
   ,@cLine05 = 'Measurement: %07d04'
   ,@cLine06 = 'UCC:'
   ,@cLine07 = '%20i05'
   ,@cLine08 = 'Total Case: %08d06'
   ,@cLine09 = 'Total Scan: %08d07'
   ,@cLine10 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4","5"],"3":["6","7"],"4":["8","9"],"5":["10"]}'
   ,@nFunc = 957

-- 6389 = TOLOC FCR-454
DELETE rdt.RDTScn WHERE Scn = 6389 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6389, 'ENG'
   ,@cLine01 = 'TOLOC:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 957

-- 6410 = Close Pallet? FCR-454
DELETE rdt.RDTScn WHERE Scn = 6410 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6410, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Close Pallet?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4","5"],"3":["8"]}'
   ,@nFunc = 957

-- 6443 = SKU QTY with image
DELETE rdt.RDTScn WHERE Scn = 6443 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6443, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'ID:'
   ,@cLine03 = '%18d08'
   ,@cLine04 = 'SKU:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20m10'
   ,@cLine09 = 'UCC:'
   ,@cLine10 = '%20d09'
   ,@cLine11 = '%60i05'
   ,@cLine12 = 'TOTAL CASE: %05d06'
   ,@cLine13 = 'TOTAL SCAN: %05d07'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3"],"3":["4","5","6","7","8"],"4":["9","10"],"5":["11","12"]}'
   ,@nFunc = 957

/* 2025-03-26 NLT013   FCR-2704 Re-allocation if short happens    */
-- 6523 = Confirm Short 
DELETE rdt.RDTScn WHERE Scn = 6523 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6523, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Short the Pick by%05d02Cases?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '0 = NO'
   ,@cLine06 = '9 = Alternate PICK LOC'
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 957