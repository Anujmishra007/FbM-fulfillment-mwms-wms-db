-- 825 = UCC, SKU, DESCR, QTY, UOM, PPK, LOTTABLE1, LOTTABLE2,..., LOTTABLE5
DELETE rdt.RDTScn WHERE Scn = 825 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 825, 'ENG', 
   @cLine01 = 'UCC:',
   @cLine02 = '%20i01*',
   @cLine03 = '%20d02',             -- SKU
   @cLine04 = '%20d03',             -- SKU DESCR1
   @cLine05 = '%20d04',             -- SKU DESCR2
   @cLine06 = 'QTY: %05d05 %05d06', -- QTY, UOM
   @cLine07 = 'PPK: %05d07',        -- PPK
   @cLine08 = '1 %18d08',           -- LOTTABLE1
   @cLine09 = '2 %18d09',           -- LOTTABLE2
   @cLine10 = '3 %18d10',           -- LOTTABLE3   
   @cLine11 = '4 %18d11',           -- LOTTABLE4
   @cLine12 = '5 %18d12',           -- LOTTABLE5 
   --@cLine13 = 'ENTER = next page',          -- (ChewKP01) 
   @cLine13 = '%20d13',          -- (ChewKP01) 
   @cLine14 = '%e'

-- 826 = STORER, FACILITY, LOC, ID 
DELETE rdt.RDTScn WHERE Scn = 826 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 826, 'ENG', 
   @cLine01 = 'STORER:',
   @cLine02 = '%15d01',
   @cLine03 = 'FACILITY: %05d02', 
   @cLine04 = 'LOC: %10d03', 
   @cLine05 = 'ID:', 
   @cLine06 = '%18d04',   
   @cLine08 = '%e'

-- SOS#131462
-- 827 = UCC, SKU, DESCR, QTY, UOM, PPK, STATUS, LOC, LOT
DELETE rdt.RDTScn WHERE Scn = 827 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 827, 'ENG', 
   @cLine01 = 'UCC:',
   @cLine02 = '%20i01*',
   @cLine03 = '%20d02',             -- SKU
   @cLine04 = '%20d03',             -- SKU DESCR1
   @cLine05 = '%20d04',             -- SKU DESCR2
   @cLine06 = 'QTY: %05d05 %05d06', -- QTY, UOM
   @cLine07 = 'PPK: %05d07',        -- PPK
   @cLine08 = 'STATUS: %01d08',      -- STATUS
   @cLine09 = 'LOC: %10d09',        -- LOC
   @cLine10 = 'LOT: %10d10',        -- LOT 
   @cLine13 = 'ENTER = next page',          
   @cLine14 = '%e'

-- 828 = STORER, FACILITY, ID, LOTTABLE1, LOTTABLE2,..., LOTTABLE5
DELETE rdt.RDTScn WHERE Scn = 828 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 828, 'ENG', 
   @cLine01 = 'STORER:',
   @cLine02 = '%15d01',
   @cLine03 = 'FACILITY: %05d02', 
   @cLine04 = 'ID:', 
   @cLine05 = '%18d03',   
   @cLine07 = '1 %18d08',           -- LOTTABLE1
   @cLine08 = '2 %18d09',           -- LOTTABLE2
   @cLine09 = '3 %18d10',           -- LOTTABLE3   
   @cLine10 = '4 %18d11',           -- LOTTABLE4
   @cLine11 = '5 %18d12',           -- LOTTABLE5 
   @cLine14 = '%e'

