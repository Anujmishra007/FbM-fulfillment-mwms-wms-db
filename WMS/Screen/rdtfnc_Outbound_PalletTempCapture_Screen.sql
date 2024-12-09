-- rdtfnc_Outbound_PalletTempCapture_Screen
-- 6540 - 6549

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
   ,@cLine02 = 'is not in range. Do you want to continue?'
   ,@cLine03 = ''
   ,@cLine04 = 'Options'
   ,@cLine05 = ''
   ,@cLine06 = '1 Yes'
   ,@cLine07 = '9 No'
   ,@cLine08 = ''
   ,@cLine09 = 'OPT: %01i04'
   ,@cLine14 = '%e'
   ,@nFunc = 1870
   ,@cWebGroup = '{"1":["1","2"],"3":["9"]}'

