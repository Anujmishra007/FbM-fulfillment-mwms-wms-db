-- 2760 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2760 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2760, 'ENG',
    @cLine01 = 'PICKSLIP NO:'
   ,@cLine02 = '%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 620
 
-- 2761 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2761 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2761, 'ENG',
    @cLine01 = 'CASE ID/PLT ID:'
   ,@cLine02 = '%30i01'
   ,@cLine03 = 'LAST SCANNED:'
   ,@cLine04 = 'SKU:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
	,@cLine10 = 'TTL CASE: %05d05'
	,@cLine11 = 'TTL PLT : %05d06'
   ,@cLine14 = '%e'
   ,@nFunc = 620

-- 2762 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2762 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2762, 'ENG',
    @cLine01 = 'CASE/PLT # '
   ,@cLine02 = 'NOT EXISTS,'
   ,@cLine03 = 'CONTINUE TO SCAN'
   ,@cLine04 = 'SKU/BOTTLE CODE?'
   ,@cLine07 = '1 = YES    2 = NO'
   ,@cLine09 = 'Option: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 620
   
-- 2763 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2763 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2763, 'ENG',
    @cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
	,@cLine03 = '%20d02'
	,@cLine04 = '%20d03'
	,@cLine08 = 'QTY: %05i04'
	,@cLine10 = 'PACKKEY : %10d05'
	,@cLine11 = 'CASE CNT: %05d06'
   ,@cLine14 = '%e'
   ,@nFunc = 620

-- Reserve 2764 & 2765 for future enhancement for case packing

-- 2766 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2766 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2766, 'ENG',
    @cLine01 = 'SKU:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = 'LAST SCANNED:'
	,@cLine04 = '%20d02'   
	,@cLine05 = '%20d03'
	,@cLine06 = '%20d04'
	,@cLine08 = 'QTY: %05i06'
	,@cLine10 = 'L2%18i07'
	,@cLine12 = 'TTL QTY: %05d05'
   ,@cLine14 = '%e'
   ,@nFunc = 620
   
-- 2767 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2767 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2767, 'ENG',
    @cLine01 = 'PRINT THE CARTON'
   ,@cLine02 = 'LABEL ?'
   ,@cLine06 = '1 = YES    2 = NO'
   ,@cLine08 = 'Option: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 620

-- 2768 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2768 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2768, 'ENG',
    @cLine01 = 'PLEASE KEY IN'
   ,@cLine02 = 'LOTTABLE02'
	,@cLine04 = 'L2%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 620