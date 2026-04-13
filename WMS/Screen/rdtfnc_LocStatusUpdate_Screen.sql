--rdtfnc_LocStatusUpdate
--Screen: 6870-6871

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1879)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1879, 'ENG', 'FNC', 'Loc Status Update', 'rdtfnc_LocStatusUpdate', '0')
END

-- 6870 = Scan Location Screen
DELETE rdt.RDTScn WHERE Scn = 6870 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6870, 'ENG',
    @cLine01 = 'Scan Location:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 1879

-- 6871 = Status Selection Screen
DELETE rdt.RDTScn WHERE Scn = 6871 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6871, 'ENG',
    @cLine01 = 'LOC: '
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'LOC Status: '
   ,@cLine04 = '%10d02'
   ,@cLine05 = ''
   ,@cLine06 = 'New Location Status:'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine09 = '%20d05'
   ,@cLine10 = '%20d06'
   ,@cLine11 = '%20d07'
   ,@cLine12 = 'Option: '
   ,@cLine13 = '%02i08'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["6","7","8","9","10","11"],"4":["12","13"]}'
   ,@nFunc = 1879
