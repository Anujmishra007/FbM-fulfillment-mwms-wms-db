-- 2400 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2400 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2400, 'ENG',
    @cLine01 = 'E-COMM DISPATCH'
   ,@cLine03 = 'TOTE NO:'
   ,@cLine04 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1712

-- 2401 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2401 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2401, 'ENG',
    @cLine01 = 'E-COMM DISPATCH'
   ,@cLine03 = 'TOTE NO:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'SKU/UPC:'
   ,@cLine06 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1712

-- 2402 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2402 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2402, 'ENG',
    @cLine01 = 'E-COMM DISPATCH'
   ,@cLine03 = 'TOTE NO:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'ORDERKEY:'
   ,@cLine06 = '%10d02'
   ,@cLine07 = 'SKU/UPC:'
   ,@cLine08 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1712

-- 2403 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2403 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2403, 'ENG',
    @cLine01 = 'E-COMM DISPATCH'
   ,@cLine03 = 'RSN: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1712

-- 2404 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2404 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2404, 'ENG',
    @cLine01 = 'E-COMM DISPATCH'
   ,@cLine02 = 'More Tote to be'
   ,@cLine03 = 'scanned, Continue?'
   ,@cLine05 = '%18d01'
   ,@cLine06 = '%18d02'
   ,@cLine07 = '%18d03'
   ,@cLine08 = '%18d04'
   ,@cLine09 = '%18d05'
   ,@cLine10 = '%18d06'
   ,@cLine11 = '1 = Yes 9 = No'
   ,@cLine12 = 'OPTION: %02i07'  -- (james12)
   ,@cLine14 = '%e'
   ,@nFunc = 1712

-- 2405 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2405 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2405, 'ENG',
    @cLine01 = 'E-COMM DISPATCH'
   ,@cLine03 = 'PARK TOTE'
   ,@cLine05 = 'Press ENTER or ESC'
   ,@cLine06 = 'to continue'
   ,@nFunc = 1712

-- 2406 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2406 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2406, 'ENG',
    @cLine01 = 'E-COMM DISPATCH'
   ,@cLine03 = 'PRINT C23 DOCUMENT.'
   ,@cLine04 = 'PLS CHANGE TO'
   ,@cLine05 = 'PLAIN PAPER.'
   ,@cLine08 = 'PRESS ENTER/ESC'
   ,@cLine09 = 'TO CONTINUE.'
   ,@cLine14 = '%e'
   ,@nFunc = 1712
   
select * from rdt.rdtscn with (nolock) where scn between 2400 and 2409 
 
