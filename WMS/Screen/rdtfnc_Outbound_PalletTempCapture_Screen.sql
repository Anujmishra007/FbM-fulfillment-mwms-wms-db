-- rdtfnc_Outbound_PalletTempCapture_Screen
-- 6540 - 6549
--FCR-1398

-- Function Menu Message
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
SELECT 1870, 'ENG', 'FNC', 'Outbound Pallet Temp Capture', 'rdtfnc_Outbound_PalletTempCapture', '0'
WHERE NOT EXISTS(SELECT 1 FROM RDT.RDTMsg WHERE Message_ID = 1870)

-- Function 1870
-- 6540 = MBOL screen
DELETE rdt.RDTScn WHERE Scn = 6540 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6540, 'ENG'
   ,@cLine01 = 'MBOL: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1870
   ,@cWebGroup = '{"1":["1"]}'


-- 6541 = Scan DropID/ID
DELETE rdt.RDTScn WHERE Scn = 6541 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6541, 'ENG'
   ,@cLine01 = 'MBOL: %10d01'
   ,@cLine02 = ''
   ,@cLine03 = 'ID/DROPID %10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1870
   ,@cWebGroup = '{"1":["1"],"2":["3"]}'


-- 6542 = Temperature Capture
DELETE rdt.RDTScn WHERE Scn = 6542 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6542, 'ENG'
   ,@cLine01 = 'MBOL: %10d01'
   ,@cLine02 = ''
   ,@cLine03 = 'ID/DROPID %10d02'
   ,@cLine04 = ''
   ,@cLine05 = 'Temp: %10i03 %d04'
   ,@cLine14 = '%e'
   ,@nFunc = 1870
   ,@cWebGroup = '{"1":["1"],"2":["3"],"3":["5"]}'


-- 6543 = Confirm Prompt
DELETE rdt.RDTScn WHERE Scn = 6543 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6543, 'ENG'
   ,@cLine01 = 'Temp entered %d03'
   ,@cLine02 = 'It is not in range.'
   ,@cLine03 = 'Do you want to '
   ,@cLine04 = 'continue?'
   ,@cLine05 = 'Options'
   ,@cLine06 = ''
   ,@cLine07 = '1 - YES'
   ,@cLine08 = '9 - NO'
   ,@cLine09 = ''
   ,@cLine10 = 'OPT%01i04'
   ,@cLine14 = '%e'
   ,@nFunc = 1870
   ,@cWebGroup = '{"1":["1","2","3","4"],"2":["5","6","7","8","9","10"]}'

