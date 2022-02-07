-- Screen 1
-- Scn = 2580. CCREF
DELETE rdt.RDTScn WHERE Scn = 2580 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2580, 'ENG', 
   @cLine01 = 'CCREF : %10i01',
   @cLine14 = '%e'

-- Screen 2
-- Scn = 2581. SHEET NO OR SELECTION CRITERIA
DELETE rdt.RDTScn WHERE Scn = 2581 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2581, 'ENG', 
   @cLine01 = 'CCREF : %10d01',
   @cLine02 = 'SHEET : %10i02',
   @cLine03 = '     OR',
   @cLine04 = 'ZONE  : %10i03',
   @cLine05 = '      : %10i04',
   @cLine06 = '      : %10i05',
   @cLine07 = '      : %10i06',
   @cLine08 = '      : %10i07',
   @cLine10 = 'AISLE : %10i08',
   @cLine11 = 'LEVEL : %10i09',
   @cLine14 = '%e'

-- Screen 3   
-- Scn = 2582. COUNT NO
DELETE rdt.RDTScn WHERE Scn = 2582 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2582, 'ENG', 
   @cLine01 = 'CCREF : %10d01',
   @cLine02 = 'SHEET : %10d02',
   @cLine03 = 'CNT NO: %01i03',
   @cLine14 = '%e'
   
-- Screen 4   
-- Scn = 2583. LOC
DELETE rdt.RDTScn WHERE Scn = 2583 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2583, 'ENG', 
   @cLine01 = 'CCREF : %10d01',
   @cLine02 = 'SHEET : %10d02',
   @cLine03 = 'CNT NO: %01d03',
   @cLine05 = 'LOC: %10d04',
   @cLine06 = 'LOC: %10i05',
   @cLine08 = 'TOTAL RECORDS: %05d06',   
   @cLine14 = '%e'
   
-- Screen 4a
-- Scn = 2584. LOC - Option
DELETE rdt.RDTScn WHERE Scn = 2584 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2584, 'ENG', 
   @cLine01 = 'LOC not same as',
   @cLine02 = 'Suggestted LOC',
   @cLine04 = 'Continue CycleCount?',
   @cLine06 = 'OPT: %01i01',
   @cLine08 = '1=YES',
   @cLine09 = '2=NO',   
   @cLine14 = '%e'
   
-- Screen 4b
-- Scn = 2585. Last LOC - Option
DELETE rdt.RDTScn WHERE Scn = 2585 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2585, 'ENG', 
   @cLine01 = 'Last LOC',
   @cLine03 = 'Add New LOC?',
   @cLine05 = 'OPT: %01i01',
   @cLine07 = '1=Yes',
   @cLine08 = '2=No',   
   @cLine14 = '%e'
   
-- Screen 4c
-- Scn = 2586. Re-Count LOC - Option
DELETE rdt.RDTScn WHERE Scn = 2586 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2586, 'ENG', 
   @cLine01 = 'LOC has been counted',
   @cLine02 = 'Re-count?',
   @cLine04 = 'OPT: %01i01',
   @cLine06 = '1=Yes',
   @cLine07 = '2=No',   
   @cLine14 = '%e'

-- Screen 5
-- Scn = 2587. ID
DELETE rdt.RDTScn WHERE Scn = 2587 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2587, 'ENG', 
   @cLine01 = 'CCREF: %10d01',
   @cLine02 = 'SHEET: %10d02',
   @cLine03 = 'CNT NO: %01d03',
   @cLine04 = 'LOC: %10d04',
   @cLine05 = 'LOC: %10d05',   
   @cLine07 = 'ID:',
   @cLine08 = '%18i06',  
   @cLine14 = '%e'

-- Screen 6
-- 2588. SINGLE SKU/UPC - Increase QTY
DELETE rdt.RDTScn WHERE Scn = 2588 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2588, 'ENG', 
   @cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'SKU/UPC:        %03d02'
   ,@cLine03 = '%20i03'              --sku
   ,@cLine04 = '%20d04'              --desc
   ,@cLine05 = '%20d05'              --desc
   ,@cLine06 = '%20d06'              --lottable01label
   ,@cLine07 = '%18i07'              --lottable01
   ,@cLine08 = '%20d08'              --lottable02label
   ,@cLine09 = '%18i09'              --lottable02
   ,@cLine10 = '%20d10'              --lottable03label
   ,@cLine11 = '%18i11'              --lottable03
   ,@cLine12 = '%20d12'              --lottable04label
   ,@cLine13 = '%16i13'              --lottable04
   ,@cLine14 = '%e'       

-- Screen 7
-- Scn = 2589. Diff SKU
DELETE rdt.RDTScn WHERE Scn = 2589 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2589, 'ENG', 
   @cLine02 = 'SKU Changed',
   @cLine04 = 'New SKU: ',
   @cLine05 = '%20d01',
   @cLine06 = 'Old SKU: ',
   @cLine07 = '%20d02',
   @cLine09 = 'Press ESC to Continue',
   @cLine14 = '%e'

