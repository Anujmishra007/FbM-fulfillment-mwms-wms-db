--rdtfnc_PalletPack
--5400-5409

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 835)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (835, 'ENG', 'FNC', 'PALLET PACK', 'rdtfnc_PalletPack', '3')
END

-- 5400 = Doc screen
DELETE rdt.RDTScn WHERE Scn = 5400 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5400, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 835

-- 5401 = Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 5401 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5401, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%20i02'
   ,@cLine04 = 'CARTON COUNT:'
   ,@cLine05 = '%05i03'
   ,@cLine14 = '%e'
   ,@nFunc = 835

-- 5402 = Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 5402 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5402, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PRINT PACKING LIST?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 835

-- WMS-17874
-- 5403 = Pack info screen
DELETE rdt.RDTScn WHERE Scn = 5403 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5403, 'ENG'
   ,@cLine01 = 'CARTON: %10i01'
   ,@cLine02 = 'WEIGHT: %10i02'
   ,@cLine03 = 'CUBE:   %10i03'
   ,@cLine04 = 'REF NO:'
   ,@cLine05 = '%20i04'
   ,@cLine06 = 'LENGTH: %10i05'  
   ,@cLine07 = 'WIDTH:  %10i06'  
   ,@cLine08 = 'HEIGHT: %10i07'  
   ,@cLine14 = '%e'
   ,@nFunc = 835   