
--5290-5299
-- 5290 = PickSlipNo screen
DELETE rdt.RDTScn WHERE Scn = 5290 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5290, 'ENG'
   ,@cLine01 = 'PSNO: %10i01'
   ,@cLine14 = '%e'
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
   ,@nFunc = 957

-- 5292 = SKU QTY screen
 DELETE rdt.RDTScn WHERE Scn = 5292 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5292, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'ID:'
   ,@cLine03 = '%18d08'
   --,@cLine04 = 'SKU:'
   --,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'UCC:'
   ,@cLine08 = '%20d09'
   ,@cLine09 = '%60i05'
   ,@cLine10 = ''
   ,@cLine11 = 'TOTAL CASE: %05d06'
   ,@cLine12 = 'TOTAL SCAN: %05d07'
   ,@cLine14 = '%e'
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
   ,@nFunc = 957

-- 5294 = Short pick screen
DELETE rdt.RDTScn WHERE Scn = 5294 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5294, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CONFIRM SHORT PICK?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = '3 = CLOSE DROPID' -- (ChewKP01) 
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 957

-- 5295 = Skip LOC screen
DELETE rdt.RDTScn WHERE Scn = 5296 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5296, 'ENG'
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
   ,@nFunc = 957


