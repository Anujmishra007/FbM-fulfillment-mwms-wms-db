--rdtfnc_InboundPalletBuild_UCC  5970 - 5979

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1858 AND Lang_Code = 'ENG' AND Message_Type = 'FNC')
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1858, 'ENG', 'FNC', 'Pallet Build_UCC', 'rdtfnc_InboundPalletBuild_UCC', '2')
END

-- 5970 = Pallet screen
DELETE rdt.RDTScn WHERE Scn = 5970 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5970, 'ENG',
    @cLine01 = 'PALLET ID:'
   ,@cLine02 = '%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1858
 
-- 5971 = uCC screen
DELETE rdt.RDTScn WHERE Scn = 5971 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5971, 'ENG',
    @cLine01 = 'PALLET ID:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'UCC NO:'
   ,@cLine05 = '%20i02'
   ,@cLine10 = 'TOTAL UCC SCAN'
   ,@cLine11 = '%03d03'
   ,@cLine14 = '%e'
   ,@nFunc = 1858

-- 5972 = closePallet screen
DELETE rdt.RDTScn WHERE Scn = 5972 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5972, 'ENG',
    @cLine01 = 'CLOSE PALLET?'
   ,@cLine02 = ''
   ,@cLine03 = '1. YES'
   ,@cLine04 = '2. NO'
   ,@cLine05 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1858
   
SELECT * FROM rdt.rdtscn (NOLOCK) WHERE scn BETWEEN 5970 AND 5979
SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1858 AND Lang_Code = 'ENG' AND Message_Type = 'FNC'