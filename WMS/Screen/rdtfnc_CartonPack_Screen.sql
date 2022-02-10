--rdtfnc_CartonPack
--5580-5589

IF NOT EXISTS( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 832)
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (832, 'ENG', 'FNC', 'CARTON PACK', 'rdtfnc_CartonPack', '3')

-- 5580 = Doc screen
DELETE rdt.RDTScn WHERE Scn = 5580 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5580, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 832
 
-- 5581 = SKU/CASE ID/SERIAL NO screen
DELETE rdt.RDTScn WHERE Scn = 5581 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5581, 'ENG'
   ,@cLine01 = 'CARTON ID:'
   ,@cLine02 = '%60i01'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 832

-- 5582 = Print packing list screen
DELETE rdt.RDTScn WHERE Scn = 5582 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5582, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PRINT PACKING LIST?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %02i01'
   ,@cLine14 = '%e'
   ,@nFunc = 832

-- 5583 = Pack info screen
DELETE rdt.RDTScn WHERE Scn = 5583 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5583, 'ENG'
   ,@cLine01 = 'CARTON: %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'WEIGHT: %10i02'
   ,@cLine04 = ''
   ,@cLine05 = 'CUBE:   %10i03'
   ,@cLine06 = ''
   ,@cLine07 = 'REF NO:'
   ,@cLine08 = '%20i04'
   ,@cLine09 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 832
 