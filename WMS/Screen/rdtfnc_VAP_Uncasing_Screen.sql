--rdtfnc_VAP_Uncasing
--4400 - 4409

IF NOT EXISTS ( SELECT 1 FROM rdt.rdtmsg (nolock) where message_id = 1151 and message_type = 'FNC')
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1151, 'ENG', 'FNC', 'JOB/UNCASING', 'rdtfnc_VAP_Uncasing', '9')
END

-- Screen 1
-- Scn = 4400 
DELETE rdt.RDTScn WHERE Scn = 4400 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4400, 'ENG', 
   @cLine01 = 'UNCASING',
   @cLine03 = 'WORKSTATION ID:',
   @cLine04 = '%20i01',
   @cLine06 = 'JOB ID:',
   @cLine07 = '%10i02',
   @cLine09 = 'WORKORDER #:',
   @cLine10 = '%10i03',
   @cLine14 = '%e',
   @nFunc = 1151

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 4401 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4401, 'ENG', 
   @cLine01 = 'UNCASING    %05d09',
   @cLine03 = 'JOB ID: %10d01',
   @cLine04 = 'WORKORD #: %10d02',
   @cLine05 = 'STATUS: %10d03',
   @cLine06 = 'WO #: %10d04',
   @cLine07 = 'QTY REMAIN: %07d05',
   @cLine08 = 'DESCRIPTION',
   @cLine09 = '%60d06',
   @cLine10 = 'SKU:',
   @cLine11 = '%20d07',
   @cLine12 = '1 = SELECT JOB     %01i08',
   @cLine13 = 'ENTER FOR NEXT JOB',
   @cLine14 = '%e',
   @nFunc = 1151

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 4402 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4402, 'ENG', 
   @cLine01 = 'UNCASING',
   @cLine03 = 'PALLET ID:',
   @cLine04 = '%20i01',
   @cLine05 = 'JOB ID:',
   @cLine06 = '%10i02',
   @cLine07 = 'WORK #:',
   @cLine08 = '%10i03',
   @cLine14 = '%e',
   @nFunc = 1151

-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 4403 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4403, 'ENG', 
   @cLine01 = 'UNCASING',
   @cLine03 = 'PALLET ID:',
   @cLine04 = '%20d01',
   @cLine05 = 'JOB ID: %10d02',
   @cLine06 = 'WORKORDER #:',
   @cLine07 = '%10d03',
   @cLine08 = 'PALLET ID QTY:',
   @cLine09 = '%07i04',
   @cLine10 = 'TOTAL REMAINING QTY:',
   @cLine11 = '%07d05',
   @cLine12 = 'START TIME:',
   @cLine13 = '%20d06',
   @cLine14 = '%e',
   @nFunc = 1151

-- Screen 5
DELETE rdt.RDTScn WHERE Scn = 4404 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4404, 'ENG', 
   @cLine01 = 'UNCASING',
   @cLine03 = 'PALLET ID:',
   @cLine04 = '%20i01',
   @cLine12 = 'END TIME:',
   @cLine13 = '%20d02',
   @cLine14 = '%e',
   @nFunc = 1151

-- Screen 6
DELETE rdt.RDTScn WHERE Scn = 4405 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4405, 'ENG', 
   @cLine01 = 'UNCASING    %05d10',
   @cLine03 = 'PALLET ID:',
   @cLine04 = '%20d01',
   @cLine05 = 'SKU:',
   @cLine06 = '%20d02',
   @cLine07 = '%20d03',
   @cLine08 = '%20d04',
   @cLine09 = 'QTY: %07d05',
   @cLine10 = '1:%18d06',
   @cLine11 = '2:%18d07',
   @cLine12 = '3:%18d08',
   @cLine13 = '1 = SELECT SKU     %01i09',
   @cLine14 = '%e',
   @nFunc = 1151