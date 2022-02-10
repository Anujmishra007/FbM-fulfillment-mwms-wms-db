-- 2800  = Scan-in the WORKORDER# screen
DELETE rdt.RDTScn WHERE Scn = 2800 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2800, 'ENG',
    @cLine01 = 'WORKORDER NO:'
   ,@cLine02 = '%10i01'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'
 
-- 2801 = Scan-in the LOC & SKU screen
DELETE rdt.RDTScn WHERE Scn = 2801 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2801, 'ENG',
    @cLine01 = 'WORKORDER NO:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = 'LOC: %10i02' 
   ,@cLine04 = 'SKU:' 
   ,@cLine05 = '%20i03'
   ,@cLine06 = 'DESCR:'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'

-- 2802 = Scan-in the LOTTABLE screen
DELETE rdt.RDTScn WHERE Scn = 2802 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2802, 'ENG',
    @cLine01 = 'WORKORDER NO:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = 'LOC: %10d02' 
   ,@cLine04 = 'SKU:' 
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine09 = 'Lottable02:'
   ,@cLine10 = '%18i06'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'

-- 2803 = Scan-in the LOTTABLE screen
DELETE rdt.RDTScn WHERE Scn = 2803 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2803, 'ENG',
    @cLine01 = '%20d01:' 
   ,@cLine02 = '%18d02'
   ,@cLine03 = '%20d03:'
   ,@cLine04 = '%18d04'
   ,@cLine05 = '%20d05:'
   ,@cLine06 = '%18d06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%10d08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%10d10'
   ,@cLine11 = 'UOM: %10i11'
   ,@cLine12 = 'QTY: %10i12'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'

-- 2804 = Enter Option
DELETE rdt.RDTScn WHERE Scn = 2804 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2804, 'ENG',
    @cLine01 = '%20d01' 
   ,@cLine02 = 'Confirm Adjustment?' 
   ,@cLine03 = ''
   ,@cLine04 = '1=YES/NEXT LOC'
   ,@cLine05 = '2=NO'
   ,@cLine06 = '3=YES/EXIT ALL TASK'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
