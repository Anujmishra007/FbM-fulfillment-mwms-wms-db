--rdtfnc_Scan_Pallet_To_Mbol
--5530-5539

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1666)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1666, 'ENG', 'FNC', 'Scan Pallet To Mbol', 'rdtfnc_Scan_Pallet_To_Mbol', '9')
END

-- 5540 = Mbol screen
DELETE rdt.RDTScn WHERE Scn = 5540 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5540, 'ENG'
   ,@cLine01 = 'MBOLKEY:'
   ,@cLine02 = '%10i01'
   ,@cLine04 = 'CREATE MBOLKEY:' --WMS-18206
   ,@cLine05 = '%1i02'           --WMS-18206
   ,@cLine14 = '%e'
   ,@nFunc = 1622

-- 5541 = Pallet id screen
DELETE rdt.RDTScn WHERE Scn = 5541 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5541, 'ENG'
   ,@cLine01 = 'MBOLKEY:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'PALLET ID:'
   ,@cLine05 = '%30i02'
   ,@cLine06 = 'SCANNED: %05d03'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1622
