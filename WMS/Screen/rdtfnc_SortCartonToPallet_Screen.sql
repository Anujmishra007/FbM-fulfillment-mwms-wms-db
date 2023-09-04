-- rdtfnc_SortCartonToPallet

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1655)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1655, 'ENG', 'FNC', 'SORT CTN TO PLT', 'rdtfnc_SortCartonToPallet', '9')
END

-- 6280 = Carton ID screen
DELETE rdt.RDTScn WHERE Scn = 6280 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6280, 'ENG'
   ,@cLine01 = 'CARTON ID:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'OR'
   ,@cLine05 = ''
   ,@cLine06 = 'PALLET ID:'
   ,@cLine07 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1655
 
-- 6281 = Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 6281 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6281, 'ENG'
   ,@cLine01 = 'CARTON ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'LOC: %10d02'
   ,@cLine05 = ''
   ,@cLine06 = 'PALLET ID:'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20i04'
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = '%20d05'
   ,@cLine14 = '%e'
   ,@nFunc = 1655

-- 6282 = Close pallet screen
DELETE rdt.RDTScn WHERE Scn = 6282 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6282, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CLOSE PALLET?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1655
