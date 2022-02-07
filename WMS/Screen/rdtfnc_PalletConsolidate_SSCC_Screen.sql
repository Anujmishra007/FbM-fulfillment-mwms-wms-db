--rdtfnc_PalletConsodate_SSCC
-- 4540 - 4549

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1723)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName)
   VALUES ('1723', 'ENG', 'FNC', 'Pallet Consolidate', 'rdtfnc_PalletConsolidate_SSCC')
END

-- 4540 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4540 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4540, 'ENG',
    @cLine01 = 'ASRS PALLET:'
   ,@cLine02 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1723

-- 4541 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4541 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4541, 'ENG',
    @cLine01 = 'PLT: %18d01'  -- (james03)
   ,@cLine02 = 'LOC: %10d08'  -- (james03)
   ,@cLine03 = 'SPEC: %20d02'
   ,@cLine04 = 'HEIGHT: %07d03'
   ,@cLine05 = 'WEIGHT: %07d04'
   ,@cLine06 = 'SPECIAL INSTRUCTIONS'
   ,@cLine07 = '%20d05'
   ,@cLine08 = 'SKU/UPC:'
   ,@cLine09 = '%40i07'
   ,@cLine10 = '1 = PRINT SSCC'
   ,@cLine11 = '2 = PRINT & CONSOLE'
   ,@cLine12 = '3 = DONE'
   ,@cLine13 = 'OPTION: %01i06'
   ,@cLine14 = '%e'
   ,@nFunc = 1723

-- 4542 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4542 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4542, 'ENG',
    @cLine01 = 'ASRS/SHIPPER PALLET:'
   ,@cLine02 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1723

-- 4543 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4543 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4543, 'ENG',
    @cLine01 = 'ASRS/SHIPPER PALLET:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'SKU:           %05d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%40i12'
   ,@cLine08 = 'CARTON ID:'
   ,@cLine09 = '%60i06'
   ,@cLine10 = '%05d07   %05d08 %05d13'-- WMS-5526
   ,@cLine11 = 'CASE:   %05i09 %05i14' -- WMS-5526
   ,@cLine12 = 'BALQTY: %05d10 %05d15' -- WMS-5526
   ,@cLine13 = '1 = FINISH: %01i11'
   ,@cLine14 = '%e'
   ,@nFunc = 1723

-- 4544 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4544 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4544, 'ENG',
    @cLine01 = 'ASRS PALLET:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'SKU:           %05d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%30d05'
   ,@cLine07 = '       %05d06 %05d10'
   ,@cLine08 = '1=AVL: %05d07 %05d11'
   ,@cLine09 = '2=ALC: %05d08 %05d12'
   ,@cLine10 = '3=PCK: %05d09 %05d13'
   ,@cLine11 = '4=FINISH'
   ,@cLine12 = 'OPTION: %01i14'
   ,@cLine14 = '%e'
   ,@nFunc = 1723

-- 4545 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4545 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4545, 'ENG',
    @cLine01 = 'ASRS PALLET:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'SKU/UPC:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%40i10'
   ,@cLine08 = 'CARTON ID:'
   ,@cLine09 = '%60i05'
   ,@cLine10 = '%05d06   %05d07 %05d11'-- WMS-5526
   ,@cLine11 = 'CASE:   %05i08 %05i12' -- WMS-5526
   ,@cLine12 = 'BALQTY: %05d09 %05d13' -- WMS-5526
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1723

-- 4546 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4546 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4546, 'ENG',
    @cLine01 = 'ASRS PALLET:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'ENTER NO OF CARTON:'
   ,@cLine04 = '%05i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1723

-- (james03)
-- 4547 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4547 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4547, 'ENG',
    @cLine01 = 'ASRS PALLET:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'SSCC #:'
   ,@cLine04 = '%60i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1723