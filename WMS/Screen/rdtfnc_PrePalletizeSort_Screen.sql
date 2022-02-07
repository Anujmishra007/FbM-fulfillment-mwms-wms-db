--rdtfnc_PrePalletizeSort
--5660-5669

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 1841 AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1841, 'ENG', 'FNC', 'PRE PALLETIZE SORT', 'rdtfnc_PrePalletizeSort', '9')

-- 5660 = ASN, LANE screen
DELETE rdt.RDTScn WHERE Scn = 5660 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5660, 'ENG',
    @cLine01 = 'PRE PALLETIZE SORT'
   ,@cLine02 = ''
   ,@cLine03 = 'ASN:'
   ,@cLine04 = '%10i01'
   ,@cLine05 = ''
   ,@cLine06 = 'LANE:'
   ,@cLine07 = '%10i02'
   ,@cLine13 = 'END SORTING?(1=YES)%01i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1841

-- 5661 = UCC screen
DELETE rdt.RDTScn WHERE Scn = 5661 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5661, 'ENG',
    @cLine01 = 'ASN:  %10d01'
   ,@cLine02 = 'LANE: %10d02'
   ,@cLine03 = 'UCC:'
   ,@cLine04 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1841

-- 5662 = TO ID screen
DELETE rdt.RDTScn WHERE Scn = 5662 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5662, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'POSITION:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'TO ID:'
   ,@cLine08 = '%18d03'
   ,@cLine09 = '%18i04'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'   
   ,@nFunc = 1841

-- 5663 = Close pallet screen
DELETE rdt.RDTScn WHERE Scn = 5663 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5663, 'ENG',
    @cLine01 = 'CLOSE PALLET ?'
   ,@cLine02 = ''
   ,@cLine03 = '%18d02'    -- Pallet ID
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''   
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine10 = 'COND: %10i03' --WMS-18096
   ,@cLine14 = '%e'   
   ,@nFunc = 1841

-- 5664 = Create new ucc screen
DELETE rdt.RDTScn WHERE Scn = 5664 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5664, 'ENG',
    @cLine01 = 'UCC NOT EXISTS'
   ,@cLine02 = 'CREATE NEW ?'
   ,@cLine03 = '1 = YES'
   ,@cLine04 = '2 = NO'
   ,@cLine05 = ''   
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'   
   ,@nFunc = 1841

-- 5665 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 5665 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5665, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'    -- Lottablenn 
   ,@cLine04 = '%20d03'    -- Lottablenn 
   ,@cLine05 = '%20d04'    -- Lottablenn 
   ,@cLine06 = '%20d05'    -- Lottablenn 
   ,@cLine07 = ''
   ,@cLine08 = 'SKU/UPC:'
   ,@cLine09 = '%60i06'
   ,@cLine11 = 'QTY: %05d07'
   ,@cLine14 = '%e'   
   ,@nFunc = 1841

-- 5666 = Qty screen
DELETE rdt.RDTScn WHERE Scn = 5666 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5666, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = ''
   ,@cLine09 = 'QTY: %05i05'
   ,@cLine14 = '%e'   
   ,@nFunc = 1841

-- 5667 = Override pallet screen
DELETE rdt.RDTScn WHERE Scn = 5667 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5667, 'ENG',
    @cLine01 = 'UCC Diff SKU/Material'
   ,@cLine02 = 'Cannot Combine Onto'
   ,@cLine03 = 'Same Pallet. Proceed?'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'   
   ,@nFunc = 1841

-- 5668 = Msg screen
DELETE rdt.RDTScn WHERE Scn = 5668 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5668, 'ENG',
    @cLine01 = 'SCAN PALLET ID'
   ,@cLine02 = 'TO CLOSE'
   ,@cLine03 = '%18i01' 
   ,@cLine04 = '99=CLOSE ALL PALLET'
   ,@cLine14 = '%e'   
   ,@nFunc = 1841

-- 5669 = Msg screen
DELETE rdt.RDTScn WHERE Scn = 5669 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5669, 'ENG',
    @cLine01 = '%20d01' -- Last ucc
   ,@cLine02 = '%20d02' -- PA task created
   ,@cLine03 = 'Pallet Is Closed'
   ,@cLine14 = '%e'   
   ,@nFunc = 1841