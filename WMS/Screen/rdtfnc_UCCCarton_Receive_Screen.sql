-- 2910 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 2910 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2910, 'ENG', 
   @cLine01 = 'ASN: %10i01',  -- ASN #
   @cLine02 = 'PO : %10i02',  -- PO #
   @cLine14 = '%e'

-- 2911 = Loc screen
DELETE rdt.RDTScn WHERE Scn = 2911 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2911, 'ENG', 
   @cLine01 = 'TOLOC: %10i01',   -- ToLOC
   @cLine14 = '%e'

-- 2912 = Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 2912 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2912, 'ENG', 
   @cLine01 = 'PLT ID: %18i01',  -- ID
   @cLine14 = '%e'

-- 2913 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 2913 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2913, 'ENG', 
   @cLine01 = 'SKU:',
   @cLine02 = '%20i01',    -- SKU
   @cLine03 = 'QTY: %05i02',
   @cLine04 = '%20d03',    -- Lot label 01
   @cLine05 = '%18i04',    -- Lottable01
   @cLine06 = '%20d05',    -- Lot label 02
   @cLine07 = '%18i06',    -- Lottable02
   @cLine08 = '%20d07',    -- Lot label 03
   @cLine09 = '%18i08',    -- Lottable03
   @cLine10 = '%20d09',    -- Lot label 04
   @cLine11 = '%16i10',    -- Lottable04
   @cLine12 = '%20d11',    -- Lot label 05
   @cLine13 = '%16i12',    -- Lottable05
   @cLine14 = '%e'

-- 2914 = LPN screen
DELETE rdt.RDTScn WHERE Scn = 2914 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2914, 'ENG', 
   @cLine01 = 'LPN:',
   @cLine02 = '%20i01',    
   @cLine03 = 'SKU:   SCANNED:%05d11',
   @cLine04 = '%20d02',    -- SKU
   @cLine05 = '%20d03',    -- STYLE/COLOR/SIZE OR DESCR
   @cLine06 = '%20d04',    
   @cLine07 = 'QTY: %10d05',        
   @cLine08 = 'LOTTABLES 01 - 05',
   @cLine09 = '1:%18d06',  -- Lottable01     
   @cLine10 = '2:%18d07',  -- Lottable02
   @cLine11 = '3:%18d08',  -- Lottable03
   @cLine12 = '4:%16d09',  -- Lottable04
   @cLine13 = '5:%16d10',  -- Lottable05
   @cLine14 = '%e'

-- 2915 = LPN screen
DELETE rdt.RDTScn WHERE Scn = 2915 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2915, 'ENG', 
   @cLine01 = 'LPN:',
   @cLine02 = '%20i01',    
   @cLine03 = 'SKU:   SCANNED:%05d11',
   @cLine04 = '%20d02',    -- SKU
   @cLine05 = '%20d03',    -- STYLE/COLOR/SIZE OR DESCR
   @cLine06 = '%20d04',    
   @cLine07 = 'QTY: %10d05',        
   @cLine08 = 'EDIT (1=Y;2=N):%01i12',
   @cLine09 = '1:%18d06',  -- Lottable01     
   @cLine10 = '2:%18d07',  -- Lottable02
   @cLine11 = '3:%18d08',  -- Lottable03
   @cLine12 = '4:%16d09',  -- Lottable04
   @cLine13 = '5:%16d10',  -- Lottable05
   @cLine14 = '%e'

-- 2916 = SKU, QTY, LOTTABLES... screen
DELETE rdt.RDTScn WHERE Scn = 2916 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2916, 'ENG', 
   @cLine01 = 'LPN:',
   @cLine02 = '%20d01',    
   @cLine03 = 'SKU:   SCANNED:%05d12',
   @cLine04 = '%20d02',    -- SKU
   @cLine05 = 'QTY: %10i03',        
   @cLine06 = '%20d04',    -- Lot label 01
   @cLine07 = '%18i05',    -- Lottable01
   @cLine08 = '%20d06',    -- Lot label 02
   @cLine09 = '%18i07',    -- Lottable02
   @cLine10 = '%20d08',    -- Lot label 03
   @cLine11 = '%18i09',    -- Lottable03
   @cLine12 = '%20d10',    -- Lot label 04
   @cLine13 = '%16i11',    -- Lottable04
   @cLine14 = '%e'

-- 2917 = VAS screen
DELETE rdt.RDTScn WHERE Scn = 2917 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2917, 'ENG', 
   @cLine01 = 'VAS INSTRUCTIONS',
   @cLine02 = 'STEP: %05d01',       -- Line1 
   @cLine03 = '%20d02',       -- Line1 
   @cLine04 = '%20d03',       -- Line2
   @cLine05 = '%20d04',       -- Line3
   @cLine06 = '%20d05',       -- Line4
   @cLine07 = '%20d06',       -- Line5
   @cLine08 = '%20d07',       -- Line6
   @cLine09 = '%20d08',       -- Line7
   @cLine10 = 'ENTER = NEXT SCREEN',
   @cLine11 = 'ESC   = PREV SCREEN',
   @cLine14 = '%e'