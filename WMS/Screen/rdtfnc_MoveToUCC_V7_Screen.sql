--rdtfnc_MoveToUCC_V7
--5670-5679

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 639 AND Message_Type = 'FNC')
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (639, 'ENG', 'FNC', 'MOVE TO UCC V7', 'rdtfnc_MoveToUCC_V7', '3')
END

-- 5670 = Scan TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 5670 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5670, 'ENG',
    @cLine01 = 'MOVE TO UCC'
   ,@cLine03 = 'TO LOC: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 639

-- 5671 =  Scan TO ID screen
DELETE rdt.RDTScn WHERE Scn = 5671 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5671, 'ENG',
    @cLine01 = 'TO LOC: %10d01'
   ,@cLine02 = 'TO ID:'
   ,@cLine03 = '%18i02'
   ,@cLine14 = '%e'
   ,@nFunc = 639

-- 5672 =  Scan FROM LOC screen
DELETE rdt.RDTScn WHERE Scn = 5672 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5672, 'ENG',
    @cLine01 = 'TO LOC: %10d01'
   ,@cLine02 = 'TO ID:'
   ,@cLine03 = '%18d02'
   ,@cLine05 = 'FROM LOC: %10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 639

-- 5673 =  Scan FROM ID screen
DELETE rdt.RDTScn WHERE Scn = 5673 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5673, 'ENG',
    @cLine01 = 'TO LOC: %10d01'
   ,@cLine02 = 'TO ID:'
   ,@cLine03 = '%18d02'
   ,@cLine05 = 'FROM LOC: %10d03'
   ,@cLine06 = 'FROM ID:'
   ,@cLine07 = '%18i04'
   ,@cLine14 = '%e'
   ,@nFunc = 639

-- 5674 =  Scan SKU screen
DELETE rdt.RDTScn WHERE Scn = 5674 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5674, 'ENG',
    @cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%18d02'
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 639

-- 5675 =  Enter QTY MOVE screen
DELETE rdt.RDTScn WHERE Scn = 5675 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5675, 'ENG',
    @cLine01 = 'SKU/UPC:     %05d01'
   ,@cLine02 = '%20i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20d06'    -- Lottablenn 
   ,@cLine07 = '%20d07'    -- Lottablenn 
   ,@cLine08 = '%20d08'    -- Lottablenn 
   ,@cLine09 = '%20d09'    -- Lottablenn 
   ,@cLine10 = '1:%18d10'
   ,@cLine11 = 'QTY AVL: %05d11 %05d12'
   ,@cLine12 = 'QTY MV:  %05i13 %05i14'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 639
	
-- 5676 =  Scan TO UCC screen
DELETE rdt.RDTScn WHERE Scn = 5676 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5676, 'ENG',
    @cLine01 = 'TO UCC:'
   ,@cLine02 = '%60i01'
   ,@cLine03 = ''
   ,@cLine12 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 639

-- 5677 =  Close Pallet screen
DELETE rdt.RDTScn WHERE Scn = 5677 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5677, 'ENG',
    @cLine01 = 'CLOSE PALLET?'
   ,@cLine02 = ''
   ,@cLine03 = '1 = YES'
   ,@cLine04 = '2 = NO'
   ,@cLine05 = ''
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 639
