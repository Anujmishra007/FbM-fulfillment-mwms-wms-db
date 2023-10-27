--rdtfnc_PrePalletizeSort
--5660-5669

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 1865 AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1865, 'ENG', 'FNC', 'PALLET SORT REVERSAL', 'rdtfnc_PrePalletizeSort_Reversal', '9')

-- 6290 = ASN, LANE screen
DELETE rdt.RDTScn WHERE Scn = 6290 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6290, 'ENG',
    @cLine01 = 'PALLET SORT REVERSAL'
   ,@cLine02 = ''
   ,@cLine03 = 'ASN:'
   ,@cLine04 = '%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1865

-- 6291 = UCC screen
DELETE rdt.RDTScn WHERE Scn = 6291 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6291, 'ENG',
    @cLine01 = 'PALLET SORT REVERSAL'
   ,@cLine02 = ''
   ,@cLine03 = 'ASN: %10d01'
   ,@cLine05 = 'TO ID:'
   ,@cLine06 = '%18i02'
   ,@cLine08 = 'LANE:'
   ,@cLine09 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1865

-- 6292 = TO ID screen
DELETE rdt.RDTScn WHERE Scn = 6292 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6292, 'ENG',
    @cLine01 = 'PALLET SORT REVERSAL'
   ,@cLine02 = ''
   ,@cLine03 = 'TO ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'LANE: %10d02'
   ,@cLine07 = 'SCAN UCC TO'
   ,@cLine08 = 'REMOVE FROM PALLET'
   ,@cLine09 = '%20i03'
   ,@cLine10 = ''
   ,@cLine11 = 'COUNTER: %10d04'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1865

