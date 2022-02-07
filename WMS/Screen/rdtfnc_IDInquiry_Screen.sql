-- 3640 = Scan LABELNO screen
DELETE rdt.RDTScn WHERE Scn = 3640 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3640, 'ENG',
    @cLine01 = 'LABELNO:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1801

-- 3641 = Scan LABELNO Show Details screen
DELETE rdt.RDTScn WHERE Scn = 3641 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3641, 'ENG',
    @cLine01 = 'LABELNO:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = 'MBOLKEY: %20d03'
   ,@cLine05 = 'LOADKEY: %20d04'
   ,@cLine06 = 'ORDERKEY: %20d05'
   ,@cLine07 = 'SOSTATUS: %20d06'
   ,@cLine08 = 'PSNO: %20d07'
   ,@cLine09 = 'SKU:'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = '%20d10'
   ,@cLine13 = 'QTY: %20d11'
   ,@cLine14 = '%e'
   ,@nFunc = 1801

-- 3642 = MultiSKU Info (1 SKU) screen
DELETE rdt.RDTScn WHERE Scn = 3642 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3642, 'ENG',
    @cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'QTY: %20d04'
   ,@cLine14 = '%e'
   ,@nFunc = 1801

-- 3643 = MultiSKU Info (2 SKU) screen
DELETE rdt.RDTScn WHERE Scn = 3643 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3643, 'ENG',
    @cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'QTY: %20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = 'QTY: %20d08'
   ,@cLine14 = '%e'
   ,@nFunc = 1801

-- 3644 = MultiSKU Info (3 SKU) screen
DELETE rdt.RDTScn WHERE Scn = 3644 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3644, 'ENG',
    @cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'QTY: %20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = 'QTY: %20d08'
   ,@cLine10 = '%20d09'
   ,@cLine11 = '%20d10'
   ,@cLine12 = '%20d11'
   ,@cLine13 = 'QTY: %20d12'
   ,@cLine14 = '%e'
   ,@nFunc = 1801