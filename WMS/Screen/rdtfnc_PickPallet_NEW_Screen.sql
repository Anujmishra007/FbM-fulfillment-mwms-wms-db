
IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1864 AND Lang_Code = 'ENG' AND Message_Type = 'FNC')
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1864, 'ENG', 'FNC', 'Pick pallet (NEW)', 'rdtfnc_PickPallet_NEW', '4')
END

-- 6260 = PickSlipNo
DELETE rdt.RDTScn WHERE Scn = 6260 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6260, 'ENG',
   @cLine01 = 'PSNO: %10i01',
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1"]}', 
   @nFunc = 1864

-- 6261 = LOC
DELETE rdt.RDTScn WHERE Scn = 6261 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6261, 'ENG',
   @cLine01 = 'PSNO: %10d01',
   @cLine02 = '', 
   @cLine03 = 'PKZONE: %10i02',
   @cLine04 = '', 
   @cLine05 = 'LOC: %10d03',
   @cLine06 = 'LOC: %10i04',
   @cLine07 = '', 
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1"],"2":["3"],"3":["5","6"]}', 
   @nFunc = 1864
   
-- 6262 = ID
DELETE rdt.RDTScn WHERE Scn = 6262 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6262, 'ENG',
   @cLine01 = 'ID%18d01',
   @cLine02 = 'SKU:',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = '%20d04',
   @cLine06 = '%20d05',
   @cLine07 = '%20d06',
   @cLine08 = '%20d07',
   @cLine09 = '%20d08',
   @cLine10 = '%08d09 %05d10 %05d11', 
   @cLine11 = 'QTY:     %05d12 %05d13', 
   @cLine12 = 'ID%60i14',
   @cLine13 = '%60d15',
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1"],"2":["2","3","4","5"],"3":["6","7","8","9"],"4":["10","11"],"5":["12"],"6":["13"]}', 
   @nFunc = 1864
 
-- 6263 = SkipTask
DELETE rdt.RDTScn WHERE Scn = 6263 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6263, 'ENG',
   @cLine01 = '',
   @cLine02 = 'Skip Current Task?',
   @cLine03 = '',
   @cLine04 = '1 = YES',
   @cLine05 = '9 = NO',
   @cLine06 = '',
   @cLine07 = '',
   @cLine08 = 'OPTION: %01i01',
   @cLine14 = '%e',
   @nFunc = 1864

-- 6264 = To LOC
DELETE rdt.RDTScn WHERE Scn = 6264 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6264, 'ENG',
   @cLine01 = '',
   @cLine02 = 'SUGGESTED LOC:',
   @cLine03 = '%10d01',
   @cLine04 = '',
   @cLine05 = 'TO LOC:',
   @cLine06 = '%10i02',
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1","2"],"2":["5","6"]}', 
   @nFunc = 1864
