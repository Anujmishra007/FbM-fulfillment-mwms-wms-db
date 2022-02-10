-- 2260  = Scan-in the WORKORDER# screen
DELETE rdt.RDTScn WHERE Scn = 2260 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2260, 'ENG',
    @cLine01 = 'WORKORDER NO:'
   ,@cLine02 = '%10i01'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'
 
-- 2261 = Scan-in the LOC screen
DELETE rdt.RDTScn WHERE Scn = 2261 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2261, 'ENG',
    @cLine01 = 'LOC: %10i01' 
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'

-- 2262 = Scan-in the PALLET ID screen
DELETE rdt.RDTScn WHERE Scn = 2262 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2262, 'ENG',
    @cLine01 = 'LOC: %10d01' 
   ,@cLine02 = 'PLT ID:' 
   ,@cLine03 = '%18i02'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'

-- 2263 = Scan-in/Display the SKU screen
DELETE rdt.RDTScn WHERE Scn = 2263 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2263, 'ENG',
    @cLine01 = 'SKU:' 
   ,@cLine02 = '%20i01'
   ,@cLine03 = 'DESC:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'

-- 2264 = Scan-in the LOTTABLE screen
DELETE rdt.RDTScn WHERE Scn = 2264 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2264, 'ENG',
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

-- 2265 = Input UOM, QTY... screen
DELETE rdt.RDTScn WHERE Scn = 2265 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2265, 'ENG',
    @cLine01 = 'SKU:' 
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'DESC:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = 'UOM: %10i04'
   ,@cLine07 = 'QTY: %10i05'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'

-- 2266 = Enter Option
DELETE rdt.RDTScn WHERE Scn = 2266 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2266, 'ENG',
    @cLine01 = '%20d01' 
   ,@cLine02 = 'Confirm Adjustment?' 
   ,@cLine03 = ''
   ,@cLine04 = '1=YES/NEXT PLT ID'
   ,@cLine05 = '2=NO'
   ,@cLine06 = '3=YES/EXIT ALL TASK'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
