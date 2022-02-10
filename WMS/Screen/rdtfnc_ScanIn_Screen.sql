--rdtfnc_ScanIn
--5950-5959

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1589)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1589, 'ENG', 'FNC', 'Scan In', 'rdtfnc_ScanIn', '9')
END

-- 5950 = Scan In
DELETE rdt.RDTScn WHERE Scn = 5950 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5950, 'ENG', 
    @cLine01 = 'SCAN IN'
   ,@cLine03 = 'PICKSLIP NO: ' 
   ,@cLine04 = '%10i01'
   ,@cLine06 = 'PICKER ID: ' 
   ,@cLine07 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1589
   