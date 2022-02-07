--rdtfnc_VAP_Uncasing
--4430 - 4439

if not exists ( select 1 from rdt.rdtmsg (nolock) where message_id = 1153 and message_type = 'fnc')
begin
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('1153', 'ENG', 'FNC', 'Palletizing', 'rdtfnc_VAP_Palletize', '9')
end

-- Screen 1
-- Scn = 4430 
DELETE rdt.RDTScn WHERE Scn = 4430 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4430, 'ENG', 
   @cLine01 = 'PALLETIZING',
   @cLine03 = 'PALLET ID:',
   @cLine04 = '%20i01',
   @cLine06 = 'JOB ID:',
   @cLine07 = '%10i02',
   @cLine09 = 'WORKORDER #:',
   @cLine10 = '%10i03',
   @cLine12 = 'START TIME',
   @cLine13 = '%20d04',
   @cLine14 = '%e',
   @nFunc = 1153

-- Screen 2
-- Scn = 4431 
DELETE rdt.RDTScn WHERE Scn = 4431 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4431, 'ENG', 
   @cLine01 = 'PALLETIZING    PAGE: %05d14',
   @cLine02 = 'JOB ID   : %10d01',
   @cLine03 = 'WORKORD #: %10d02',
   @cLine04 = 'ID:%18d03',
   @cLine05 = 'L01: %18d04',
   @cLine06 = 'L02: %18d05',
   @cLine07 = 'L03: %18d06',
   @cLine08 = 'L04: %16d07',
   @cLine09 = 'L07: %30d08',
   @cLine10 = 'L08: %30d09',
   @cLine11 = '%20d10',
   @cLine12 = '       %05d11 %05d12',
   @cLine13 = 'CHOOSE LOTTABLE (Y/N): %01i13',
   @cLine14 = '%e',
   @nFunc = 1153 

-- Screen 3
-- Scn = 4432 
DELETE rdt.RDTScn WHERE Scn = 4432 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4432, 'ENG', 
   @cLine01 = 'PALLETIZING',
   @cLine02 = 'JOB ID  : %10d01',
   @cLine03 = 'WORKORD#: %10d02',
   @cLine04 = 'ID:%18d03',
   @cLine05 = '%05d04 %05d05 %05d06',
   @cLine06 = 'QTY REMAIN:',
   @cLine07 = '      %05d07 %05d08',
   @cLine08 = 'QTY COMPLETE:',
   @cLine09 = '      %05i09 %05i10',
   @cLine10 = 'PRINT LABEL (Y/N): %01i11',
   @cLine11 = 'END PALLET  (Y/N): %01i12',
   @cLine14 = '%e',
   @nFunc = 1153

-- Screen 4
-- Scn = 4433 
DELETE rdt.RDTScn WHERE Scn = 4433 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4433, 'ENG', 
   @cLine01 = 'PALLETIZING',
   @cLine03 = 'PALLET ID:',
   @cLine04 = '%20d01',
   @cLine05 = 'L01: %18i02',
   @cLine06 = 'L02: %18i03',
   @cLine07 = 'L03: %18i04',
   @cLine08 = 'L04: %16i05',
   @cLine09 = 'L07: %30i06',
   @cLine10 = 'L08: %30i07',
   @cLine12 = 'END TIME',
   @cLine13 = '%20d08',
   @cLine14 = '%e',
   @nFunc = 1153

-- Screen 5
-- Scn = 4434 
DELETE rdt.RDTScn WHERE Scn = 4434 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4434, 'ENG', 
   @cLine01 = 'PALLETIZING',
   @cLine03 = '%20d01',
   @cLine04 = 'COMPLETE !',
   @cLine06 = 'PRESS ENTER',
   @cLine07 = 'TO CONTINUE.',
   @cLine14 = '%e',
   @nFunc = 1153