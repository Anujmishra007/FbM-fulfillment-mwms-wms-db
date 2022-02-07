--rdtfnc_PTLCart_Zone
-- 4700-4709
IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE Message_id = 819 and message_type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('819', 'ENG', 'FNC', 'Cart Picking (Zone)', 'rdtfnc_PTLCart_Zone', '3')

-- 4700 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4700 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4700, 'ENG'
   ,@cLine01 = 'CART ID:  %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'PICKZONE: %10i02'
   ,@cLine04 = ''
   ,@cLine05 = 'METHOD:   %01i03'
   ,@cLine06 = ''
   ,@cLine07 = 'PICK SEQ: %01i04'
   ,@cLine08 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 819

-- 4701 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4701 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4701, 'ENG'
   ,@cLine01 = 'CART ID:  %10d01'
   ,@cLine02 = 'PICKZONE: %10d02'
   ,@cLine03 = 'METHOD:   %01d03'
   ,@cLine04 = 'PICK SEQ: %01d04'
   ,@cLine06 = 'TOTE SCANNED: %05d05'
   ,@cLine10 = 'CART IS READY.'
   ,@cLine11 = 'PRESS <ENTER> TO'
   ,@cLine12 = 'PROCEED.'
   ,@cLine14 = '%e'
   ,@nFunc = 819

-- 4702 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4702 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4702, 'ENG'
   ,@cLine01 = 'CART ID:  %10d03'
   ,@cLine02 = 'LOCATION:'
   ,@cLine03 = '%10d01'
   ,@cLine04 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 819

-- 4703 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4703 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4703, 'ENG'
   ,@cLine01 = 'CART ID:  %10d07'
   ,@cLine02 = 'LOCATION: %10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20i03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = 'SHORT PICK?'
   ,@cLine10 = '1 = YES 9 = NO %02i06' -- extend to 2 chars
   ,@cLine14 = '%e'
   ,@nFunc = 819

-- 4704 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4704 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4704, 'ENG'
   ,@cLine01 = 'CART ID:  %10d07'
   ,@cLine02 = 'SKU/UPC:'
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = 'SCAN TOTE:'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20i05'
   ,@cLine09 = 'TOTE FULL?'
   ,@cLine10 = '1 = YES 9 = NO %02i06' -- extend to 2 chars
   ,@cLine14 = '%e'
   ,@nFunc = 819

-- 4705 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4705 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4705, 'ENG'
   ,@cLine01 = 'CART ID:  %10d01'
   ,@cLine02 = 'PICKZONE: %10d02'
   ,@cLine03 = 'METHOD:   %01d03'
   ,@cLine04 = 'PICK SEQ: %01d04'
   ,@cLine06 = 'PICKING COMPLETED.'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine12 = 'PRESS <ENTER> TO'
   ,@cLine13 = 'CONTINUE'
   ,@cLine14 = '%e'
   ,@nFunc = 819

-- 4706 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4706 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4706, 'ENG'
   ,@cLine01 = 'CART ID:  %10d03'
   ,@cLine02 = 'OLD TOTE:'
   ,@cLine03 = '%20d01'
   ,@cLine04 = 'NEW TOTE:'
   ,@cLine05 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 819

-- 4707 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4707 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4707, 'ENG'
   ,@cLine01 = 'CART ID:  %10d02'
   ,@cLine02 = 'UNASSIGN CART?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
