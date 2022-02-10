-- 814 = Criteria screen
DELETE rdt.RDTScn WHERE Scn = 814 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 814, 'ENG',
    @cLine01 = 'REFNO:    %10i01'
   ,@cLine02 = 'PSNO:     %10i02'
   ,@cLine03 = 'LOADKEY:  %10i03'
   ,@cLine04 = 'ORDERKEY: %10i04'
   ,@cLine05 = 'CARTON ID:'
   ,@cLine06 = '%20i05'
   ,@cLine07 = 'PALLET ID:'
   ,@cLine08 = '%20i06'
   ,@cLine09 = 'TASKKEY:  %10i07'   -- WMS-8002
   ,@cLine14 = '%e'
 
-- 815 = Statistic screen
DELETE rdt.RDTScn WHERE Scn = 815 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 815, 'ENG',
    @cLine01 = 'REFNO:    %10d01'
   ,@cLine02 = 'PSNO:     %10d02'
   ,@cLine03 = 'LOADKEY:  %10d03'
   ,@cLine04 = 'ORDERKEY: %10d04'
   ,@cLine05 = 'CARTON ID:'
   ,@cLine06 = '%20d05'
   ,@cLine07 = 'PALLET ID:'
   ,@cLine08 = '%20d09'
   ,@cLine09 = 'TASKKEY:  %10d10'   -- WMS-8002
   ,@cLine10 = ''
   ,@cLine11 = 'SKU CKD: %11d06'
   ,@cLine12 = 'QTY CKD: %11d07'
   ,@cLine13 = '%20d08'
   ,@cLine14 = '%e'
 
-- 816 = SKU QTY screen
DELETE rdt.RDTScn WHERE Scn = 816 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 816, 'ENG',
    @cLine01 = 'SKU/UPC:     PPK:%03d16'
   ,@cLine02 = '%60i01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%10d06     %05d07'
   ,@cLine08 = '%20d08'
   ,@cLine09 = 'QTY:     %05i09 %05i10'
   ,@cLine10 = ''
   ,@cLine11 = 'COUNTED: %05d11 %05d12'
   ,@cLine12 = 'TOTAL:   %05d13 %05d14'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
 
 -- 817 = Discrepency screen
DELETE rdt.RDTScn WHERE Scn = 817 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 817, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'DISCREPENCY FOUND'
   ,@cLine03 = ''
   ,@cLine04 = '1 = SEND TO QC'
   ,@cLine05 = '2 = EXIT ANYWAY'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine09 = 'Reason Code' --WMS17278
   ,@cLine10 = '%20i02'      --WMS17278
   ,@cLine14 = '%e'

 -- 818 = Print packing list
DELETE rdt.RDTScn WHERE Scn = 818 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 818, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'PRINT PACKING LIST?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'

-- WMS-8002
-- 819 Capture data
DELETE rdt.RDTScn WHERE Scn = 819 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 819, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = 'CAPTURE DATA'
   ,@cLine04 = '%60i03'
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = '%20d13'
   ,@cLine14 = '%e'


-- WMS-8002
-- 819 Capture data
DELETE rdt.RDTScn WHERE Scn = 820 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 820, 'ENG'
   ,@cLine01 = 'Reason Code'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = '%20d13'
   ,@cLine14 = '%e'
-- WMS-17439
-- 5980 Capture data
DELETE rdt.RDTScn WHERE Scn = 5980 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5980, 'ENG'
   ,@cLine01 = 'CARTON: %10i01'
   ,@cLine02 = 'CUBE: %10i02'
   ,@cLine03 = 'WEIGHT:   %10i03'
   ,@cLine14 = '%e'
   
SELECT * FROM rdt.rdtscn (NOLOCK) WHERE scn = '5980'