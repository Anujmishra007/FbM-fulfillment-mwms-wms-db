--rdtfnc_PostPackSort
--5590-5599

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1837)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1837, 'ENG', 'FNC', 'POST PACK SORT', 'rdtfnc_PostPackSort', '9')
END

-- 5590 = Doc screen
DELETE rdt.RDTScn WHERE Scn = 5590 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5590, 'ENG'
   ,@cLine01 = 'POST PACK SORTING'
   ,@cLine02 = 'CARTON ID:'
   ,@cLine03 = '%20i01'
   ,@cLine04 = ''
   ,@cLine05 = 'PALLET ID:'
   ,@cLine06 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1837
 
-- 5591 = SKU/CASE ID/SERIAL NO screen
DELETE rdt.RDTScn WHERE Scn = 5591 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5591, 'ENG'
   ,@cLine01 = 'POST PACK SORTING'
   ,@cLine02 = 'CARTON ID:'
   ,@cLine03 = '%20d01'
   ,@cLine04 = 'LOADKEY: %10d02'
   ,@cLine05 = 'LOC:     %10d03'
   ,@cLine07 = ''
   ,@cLine08 = 'PALLET ID:'
   ,@cLine09 = '%20i04'
   ,@cLine14 = '%e'
   ,@nFunc = 1837

-- 5592 = Print packing list screen
DELETE rdt.RDTScn WHERE Scn = 5592 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5592, 'ENG'
   ,@cLine01 = 'POST PACK SORTING'
   ,@cLine02 = ''
   ,@cLine03 = 'CLOSE PALLET ?'
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1837

--wms-17386  
-- 5593 = Display Msg screen
DELETE rdt.RDTScn WHERE Scn = 5593 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5593, 'ENG'
   ,@cLine01 = 'POST PACK SORTING'
   ,@cLine02 = 'CARTON ID:'
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = '%20d10'
   ,@cLine13 = '%20d11'
   ,@cLine14 = '%e'
   ,@nFunc = 1837
   
SELECT * FROM rdt.rdtscn (NOLOCK) WHERE scn BETWEEN  5590 AND 5599

