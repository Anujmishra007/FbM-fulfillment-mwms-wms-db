-- Screen 1
-- Scn = 730. CCREF
DELETE rdt.RDTScn WHERE Scn = 730 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 730, 'ENG', 
   @cLine01 = 'CCREF : %10i01',
   @cLine14 = '%e'

-- Screen 2
-- Scn = 731. SHEET NO OR SELECTION CRITERIA
DELETE rdt.RDTScn WHERE Scn = 731 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 731, 'ENG', 
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
-- Scn = 732. COUNT NO
DELETE rdt.RDTScn WHERE Scn = 732 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 732, 'ENG', 
   @cLine01 = 'CCREF : %10d01',
   @cLine02 = 'SHEET : %10d02',
   @cLine03 = 'CNT NO: %01i03',
   @cLine14 = '%e'
   
-- Screen 4   
-- Scn = 733. LOC
DELETE rdt.RDTScn WHERE Scn = 733 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 733, 'ENG', 
   @cLine01 = 'CCREF : %10d01',
   @cLine02 = 'SHEET : %10d02',
   @cLine03 = 'CNT NO: %01d03',
   @cLine05 = 'LOC: %10d04',
   @cLine06 = 'LOC: %10i05',
   @cLine14 = '%e'
   
-- Screen 5
-- Scn = 734. ID
DELETE rdt.RDTScn WHERE Scn = 734 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 734, 'ENG', 
   @cLine01 = 'CCREF: %10d01',
   @cLine02 = 'SHEET: %10d02',
   @cLine03 = 'CNT NO: %01d03',
   @cLine04 = 'LOC: %10d04',
   @cLine05 = 'LOC: %10d05',   
   @cLine07 = 'OPT: %01i06',   
   @cLine08 = 'ID:',
   @cLine09 = '%18i07',  
   @cLine11 = '1=EMPTY LOC',
   @cLine14 = '%e'

-- Screen 6
-- 735. BOM
DELETE rdt.RDTScn WHERE Scn = 735 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 735, 'ENG', 
   @cLine01 = 'BOM COUNT', 
   @cLine03 = 'LOC: %10d01',
   @cLine04 = 'ID:',
   @cLine05 = '%18d02',
   @cLine07 = 'ENTER BOM:',
   @cLine08 = '%20i03',
   @cLine14 = '%e'      

-- Screen 7
-- 736. BOM – Count QTY
DELETE rdt.RDTScn WHERE Scn = 736 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 736, 'ENG', 
   @cLine01 = 'BOM:       OPT:%01i01',	
   @cLine02 = '%20d02', 
   @cLine03 = '%20d03',
   @cLine04 = 'QTY:%05i04 %10d05', 
   @cLine05 = 'ID:', 
   @cLine06 = '%18d06',  
   @cLine07 = 'LOTTABLE',
   @cLine08 = '1 %18d07',
   @cLine09 = '2 %18d08',
   @cLine10 = '3 %18d09',
   @cLine11 = '4 %18d10',
   @cLine12 = '5 %18d11',
   @cLine13 = '1=BOM LOOKUP',
   @cLine14 = '%e'

-- Screen 8
-- 737. BOM – Add BOM
DELETE rdt.RDTScn WHERE Scn = 737 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 737, 'ENG', 
   @cLine01 = 'ADD BOM',
   @cLine03 = 'LOC: %10d01',
   @cLine04 = 'ID:',
   @cLine05 = '%18d02',
   @cLine07 = 'ENTER BOM:',
   @cLine08 = '%20i03',
   @cLine14 = '%e'
    
-- Screen 9    
-- 738. BOM – Add Qty
DELETE rdt.RDTScn WHERE Scn = 738 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 738, 'ENG', 
   @cLine01 = 'ADD BOM',
   @cLine03 = 'LOC: %10d01',
   @cLine04 = 'ID:',
   @cLine05 = '%18d02',
   @cLine07 = 'BOM:',
   @cLine08 = '%20d03',
   @cLine09 = '%20d04',
   @cLine10 = 'QTY:%05i05 %10d06',
   @cLine14 = '%e'   
  
-- Screen 10  
-- 739. BOM – Add Lottable
DELETE rdt.RDTScn WHERE Scn = 739 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 739, 'ENG', 
   @cLine01 = 'ADD BOM',	
   @cLine03 = '%20d01',
   @cLine04 = '%18i02',
   @cLine05 = '%20d03',
   @cLine06 = '%18i04',
   @cLine07 = '%20d05',
   @cLine08 = '%18i06',
   @cLine09 = '%20d07',
   @cLine10 = '%16i08',
   @cLine14 = '%e'

-- Screen 11
-- 740. SKU - BOM Lookup
DELETE rdt.RDTScn WHERE Scn = 740 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 740, 'ENG', 
   @cLine01 = 'BOM LOOKUP',
   @cLine03 = '%20d01', -- Parrent SKU
   @cLine04 = '%05d02', -- UOM
   @cLine05 = '%05d03', -- Color
   @cLine06 = '%13d04', -- Size #1
   @cLine07 = '%13d05', -- Size #2
   @cLine08 = '%13d06', -- Size #3
   @cLine09 = '%13d07', -- Size #4
   @cLine10 = '%13d08', -- Size #5
   @cLine11 = '%13d09', -- Size #6
   @cLine12 = 'ENTER = NEXT RECORD',
   @cLine13 = 'ESC   = EXIT',
   @cLine14 = '%e'

   