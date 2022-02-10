-- 951 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 951 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 951, 'ENG', 
   @cLine01 = 'ASN: %10i01',     -- ASN #
   @cLine02 = 'PO : %10i02',     -- PO #
   @cLine14 = '%e',
   @nFunc = 550

-- 952 = Loc screen
DELETE rdt.RDTScn WHERE Scn = 952 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 952, 'ENG', 
   @cLine01 = 'ASN: %10d02',     -- ASN #
   @cLine02 = 'PO : %10d03',     -- PO #
   @cLine03 = 'TOLOC: %10i01',   -- ToLOC
   @cLine14 = '%e',
   @nFunc = 550

-- 953 = Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 953 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 953, 'ENG', 
   @cLine01 = 'TOLOC: %10d02',   -- ToLOC
   @cLine02 = 'PLT ID: %30i01',  -- ID    extend from 18 to 30 (james13)
   @cLine14 = '%e',
   @nFunc = 550

-- 954 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 954 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 954, 'ENG', 
   @cLine01 = 'PLT ID: %18d04', -- ID
   @cLine02 = 'SKU:',
   @cLine03 = '%30i01',         -- SKU    extend to 30 chars (james14)
   @cLine05 = 'DESC:', 
   @cLine06 = '%20d02',         -- SKU desc 1
   @cLine07 = '%20d03',         -- SKU desc 2
   @cLine14 = '%e',
   @nFunc = 550

-- 955 = QTY, UOM... screen
DELETE rdt.RDTScn WHERE Scn = 955 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 955, 'ENG', 
   @cLine01 = 'SKU:',
   @cLine02 = '%20d01',         -- SKU
   @cLine03 = 'DESC:', 
   @cLine04 = '%20d02',         -- SKU desc 1
   @cLine05 = '%20d03',         -- SKU desc 2
   @cLine06 = 'IVAS:',        
   @cLine07 = '%20d04',         -- IVAS
   @cLine08 = '%20d09',         
   @cLine09 = '%20d08', -- Pack Information (ChewKP03)
   @cLine10 = 'UOM: %10i05',    -- UOM
   @cLine11 = 'QTY: %10i06*',    -- QTY
   @cLine13 = 'COND. CODE: %10i07', -- Reason code
   @cLine14 = '%e',
   @nFunc = 550

-- 956 = Lottable screen
DELETE rdt.RDTScn WHERE Scn = 956 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 956, 'ENG', 
   @cLine01 = '%20d01',   -- Lot label 01
   @cLine02 = '%60i02',   -- Lottable01      -- Extend to 60 chars (james16)
   @cLine03 = '%20d03',   -- Lot label 02
   @cLine04 = '%60i04',   -- Lottable02      -- Extend to 60 chars (james16)
   @cLine05 = '%20d05',   -- Lot label 03
   @cLine06 = '%60i06',   -- Lottable03      -- Extend to 60 chars (james16)
   @cLine07 = '%20d07',   -- Lot label 04
   @cLine08 = '%16i08',   -- Lottable04
   @cLine09 = '%20d09',   -- Lot label 05
   @cLine10 = '%16i10',   -- Lottable05
   @cLine14 = '%e',
   @nFunc = 550


-- 957 = Message screen
DELETE rdt.RDTScn WHERE Scn = 957 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 957, 'ENG', 
   @cLine02 = 'SKU received', 
   @cLine03 = '', 
   @cLine04 = '', 
   @cLine05 = 'Press ENTER to', 
   @cLine06 = 'receive next SKU', 
   @cLine14 = '%e',
   @nFunc = 550


-- 958. Dialogue Option
DELETE rdt.RDTScn WHERE Scn = 958 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 958, 'ENG', 
   @cLine01 = 'SKU NOT IN ASN',
   @cLine02 = 'OK TO ADD ?',
   @cLine04 = '1=YES',
   @cLine05 = '2=NO',
   @cLine07 = 'OPTION: %01i01',      
   @cLine14 = '%e',
   @nFunc = 550

-- SOS#131462
-- 962. Option
DELETE rdt.RDTScn WHERE Scn = 962 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 962, 'ENG', 
   @cLine01 = 'NEXT TASK?',
   @cLine03 = '1 = PRINT LABEL/NEXT',
   @cLine04 = '    PLT ID',
   @cLine05 = '2 = NEXT LOC',
   @cLine06 = '3 = PRINT LAST LABEL',
   @cLine07 = '    /EXIT ALL TASK',
   @cLine09 = 'OPTION: %01i01',      
   @cLine14 = '%e',
   @nFunc = 550


-- SOS#105912
-- 963. Message
DELETE rdt.RDTScn WHERE Scn = 963 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 963, 'ENG', 
   @cLine02 = 'SKU received', 
   @cLine03 = '', 
   @cLine04 = '', 
   @cLine05 = 'Press ENTER to', 
   @cLine06 = 'receive next PLTID', 
   @cLine14 = '%e',
   @nFunc = 550

-- SOS#142253
-- 964 = Verify Packkey Screen
DELETE rdt.RDTScn WHERE Scn = 964 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 964, 'ENG', 
   @cLine01 = 'SKU:',
   @cLine02 = '%20d01',         -- SKU
   @cLine03 = '', 
   @cLine04 = 'DESC:', 
   @cLine05 = '%20d02',         -- SKU desc 1
   @cLine06 = '%20d03',         -- SKU desc 2
   @cLine07 = '', 
   @cLine08 = 'IVAS:',        
   @cLine09 = '%20d04',         -- IVAS
   @cLine11 = 'VERIFY PACK KEY',   
   @cLine12 = 'UOM:     %05d05 %05d06',    -- UOM
   @cLine13 = 'PK QTY:  1     %05i07*',   -- QTY
   @cLine14 = '%e',
   @nFunc = 550
   
-- 965 = QTY, UOM... screen
DELETE rdt.RDTScn WHERE Scn = 965 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 965, 'ENG',
   @cLine01 = 'SKU:',
   @cLine02 = '%20d01',
   @cLine04 = 'DESC:',
   @cLine05 = '%20d02',
   @cLine06 = '%20d03',
   @cLine07 = 'IVAS:',
   @cLine08 = '%20d04',
   @cLine10 = '%05d10 %05d05 %05d06',
   @cLine11 = 'QTY:  %05i07 %05i08',
   @cLine13 = 'COND. CODE: %10i09',
   @cLine14 = '%e',
   @nFunc = 550   
