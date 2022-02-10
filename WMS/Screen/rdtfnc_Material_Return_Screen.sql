-- 2850  = Scan-in the WORKORDER# screen
DELETE rdt.RDTScn WHERE Scn = 2850 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2850, 'ENG',
    @cLine01 = 'WORKORDER NO:'
   ,@cLine02 = '%10i01'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'
 
-- 2851 = Scan-in the LOC screen
DELETE rdt.RDTScn WHERE Scn = 2851 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2851, 'ENG',
    @cLine01 = 'WORKORDER NO:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = 'LOC: %10i02' 
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'

-- 2852 = Scan-in the SKU screen
DELETE rdt.RDTScn WHERE Scn = 2852 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2852, 'ENG',
    @cLine01 = 'WORKORDER NO:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = 'LOC: %10d02' 
   ,@cLine04 = 'SKU:' 
   ,@cLine05 = '%20i03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'

-- 2853 = Scan-in the LOTTABLES screen
DELETE rdt.RDTScn WHERE Scn = 2853 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2853, 'ENG',
    @cLine01 = 'Lottable01:' 
   ,@cLine02 = '%18i01'
   ,@cLine03 = 'Lottable02:'
   ,@cLine04 = '%18i02'
   ,@cLine05 = 'Lottable03:'
   ,@cLine06 = '%18i03'
   ,@cLine07 = 'Lottable04'
   ,@cLine08 = '(DD/MM/YYYY):'
   ,@cLine09 = '%10i04'
   ,@cLine10 = 'Lottable05'
   ,@cLine11 = '(DD/MM/YYYY):'
   ,@cLine12 = '%10i05'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'

-- 2854 = Scan-in the UOM & QTY screen
DELETE rdt.RDTScn WHERE Scn = 2854 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2854, 'ENG',
    @cLine01 = 'SKU:' 
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'DESC:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = 'UOM: %10i04'
   ,@cLine07 = 'QTY: %10i05'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'

-- 2855 = Enter Option
DELETE rdt.RDTScn WHERE Scn = 2855 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2855, 'ENG',
    @cLine01 = '%20d01' 
   ,@cLine02 = 'Confirm Adjustment?' 
   ,@cLine03 = ''
   ,@cLine04 = '1=YES/NEXT BATCH'
   ,@cLine05 = '2=NO'
   ,@cLine06 = '3=YES/EXIT ALL TASK'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
