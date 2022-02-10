/*
   Move SKU
*/

-- 1030 = LOC
DELETE rdt.RDTScn WHERE Scn = 1030 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1030, 'ENG',
   @cLine01 = 'FROM LOC: %10i01',
   @cLine14 = '%e',
   @nFunc = 513

-- 1031 = ID
DELETE rdt.RDTScn WHERE Scn = 1031 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1031, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%20i02',
   @cLine14 = '%e',
   @nFunc = 513
   
-- 1032 = SKU
DELETE rdt.RDTScn WHERE Scn = 1032 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1032, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU/UPC:',
   @cLine05 = '%60i03',
   @cLine14 = '%e',
   @nFunc = 513
   
-- 1033 = QTY
DELETE rdt.RDTScn WHERE Scn = 1033 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1033, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU:         PPK:%03d12', 
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '     %07d06   %07d09',  -- (james10)
   @cLine09 = 'AVL: %07d07   %07d10',  -- (james10)
   @cLine10 = 'MV:  %07i08   %07i11',  -- (james10)
   @cLine13 = '%20d15',  -- (WMS9098)
   @cLine14 = '%e',
   @nFunc = 513

-- 1034 = To ID
DELETE rdt.RDTScn WHERE Scn = 1034 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1034, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU:         PPK:%03d13', 
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '     %07d06 %07d09',    -- (james10)
   @cLine09 = 'AVL: %07d07 %07d10',    -- (james10)
   @cLine10 = 'MV:  %07d08 %07d11',    -- (james10)
   @cLine11 = 'TO ID:',
   @cLine12 = '%20i12',
   @cLine14 = '%e',
   @nFunc = 513
   
-- 1035 = To LOC
DELETE rdt.RDTScn WHERE Scn = 1035 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1035, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU:         PPK:%03d14', 
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '     %07d06 %07d09',    -- (james10)
   @cLine09 = 'AVL: %07d07 %07d10',    -- (james10)
   @cLine10 = 'MV:  %07d08 %07d11',    -- (james10)
   @cLine11 = 'TO ID:',
   @cLine12 = '%18d12',
   @cLine13 = 'TO LOC: %10i13',
   @cLine14 = '%e',
   @nFunc = 513

-- 1036 = Message screen
DELETE rdt.RDTScn WHERE Scn = 1036 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1036, 'ENG',
   @cLine02 = 'SKU moved',
   @cLine03 = 'successfully',
   @cLine04 = 'TO LOC: %10d01',     -- (james08)
   @cLine06 = 'Press ENTER or ESC', -- (james08)
   @cLine07 = 'to continue',        -- (james08)
   @cLine14 = '%e',
   @nFunc = 513

-- 1037 = Suggest LOC screen
DELETE rdt.RDTScn WHERE Scn = 1037 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1037, 'ENG', 
   @cLine01 = '%20d01',
   @cLine02 = '%20d02',
   @cLine03 = '%20d03',
   @cLine04 = '%20d04',
   @cLine05 = '%20d05',
   @cLine06 = '%20d06',
   @cLine07 = '%20d07', --WMS15504 (cc01)
   @cLine08 = '%20d08', --WMS15504 (cc01)
   @cLine09 = '%20d09', --WMS15504 (cc01)
   @cLine10 = '%20d10', --WMS15504 (cc01)
   @cLine11 = '%20d11', --WMS15504 (cc01)
   @cLine14 = '%e',
   @nFunc = 513
   