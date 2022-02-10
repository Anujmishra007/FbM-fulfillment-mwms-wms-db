-- 3690 = Scan TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 3690 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3690, 'ENG',
    @cLine01 = 'MOVE TO UCC'
   ,@cLine03 = 'TO LOC: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1804

-- 3691 =  Scan TO ID screen
DELETE rdt.RDTScn WHERE Scn = 3691 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3691, 'ENG',
    @cLine01 = 'TO LOC: %10d01'
   ,@cLine02 = 'TO ID:'
   ,@cLine03 = '%18i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1804

-- 3692 =  Scan FROM LOC screen
DELETE rdt.RDTScn WHERE Scn = 3692 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3692, 'ENG',
    @cLine01 = 'TO LOC: %10d01'
   ,@cLine02 = 'TO ID:'
   ,@cLine03 = '%18d02'
   ,@cLine05 = 'FROM LOC: %10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1804

-- 3693 =  Scan FROM ID screen
DELETE rdt.RDTScn WHERE Scn = 3693 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3693, 'ENG',
    @cLine01 = 'TO LOC: %10d01'
   ,@cLine02 = 'TO ID:'
   ,@cLine03 = '%18d02'
   ,@cLine05 = 'FROM LOC: %10d03'
   ,@cLine06 = 'FROM ID:'
   ,@cLine07 = '%18i04'
   ,@cLine14 = '%e'
   ,@nFunc = 1804

-- 3694 =  Scan SKU screen
DELETE rdt.RDTScn WHERE Scn = 3694 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3694, 'ENG',
    @cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%18d02'
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1804

-- 3695 =  Enter QTY MOVE screen
DELETE rdt.RDTScn WHERE Scn = 3695 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3695, 'ENG',
    @cLine01 = 'SKU/UPC:     %05d08'
   ,@cLine02 = '%20i11' -- (ChewKP03) 
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '1:%18d04'
   ,@cLine07 = '2:%18d05'
   ,@cLine08 = '3:%16d06'
   ,@cLine09 = '4:%16d07'
   ,@cLine10 = '1:%18d09' -- (ChewKP03) 
   ,@cLine11 = 'QTY AVL: %05d12 %05d13'
   ,@cLine12 = 'QTY MV:  %05i14 %05i15'
   ,@cLine13 = '%20d10'
   ,@cLine14 = '%e'
   ,@nFunc = 1804
	
-- 3696 =  Scan TO UCC screen
DELETE rdt.RDTScn WHERE Scn = 3696 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3696, 'ENG',
    @cLine01 = 'TO UCC:'
   ,@cLine02 = '%60i01'
   ,@cLine03 = ''
   ,@cLine12 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1804

-- 3697 =  Close Pallet screen
DELETE rdt.RDTScn WHERE Scn = 3697 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3697, 'ENG',
    @cLine01 = 'CLOSE PALLET?'
   ,@cLine02 = ''
   ,@cLine03 = '1 = YES'
   ,@cLine04 = '2 = NO'
   ,@cLine05 = ''
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1804
