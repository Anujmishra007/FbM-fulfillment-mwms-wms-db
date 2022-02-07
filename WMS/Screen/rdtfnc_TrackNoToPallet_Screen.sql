-- 4930 = Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 4930 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4930, 'ENG',
    @cLine01 = 'PALLET KEY:' 
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'LOC:'
   ,@cLine05 = '%10i02'
   ,@cLine14 = '%e'      
   ,@nFunc = 1663

-- 4931 = Carton type screen
DELETE rdt.RDTScn WHERE Scn = 4931 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4931, 'ENG',
    @cLine01 = 'PALLET KEY:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'CARTON TYPE:'
   ,@cLine05 = '%30i02'
   ,@cLine14 = '%e'   
   ,@nFunc = 1663

-- 4932 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4932 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4932, 'ENG'
   ,@cLine01 = 'PALLET KEY:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'MBOLKEY:'
   ,@cLine05 = '%10d02'
   ,@cLine06 = ''
   ,@cLine07 = 'TRACK NO:'
   ,@cLine08 = '%30i03' -- WMS-12486 Extend to 30 chars
   ,@cLine09 = ''
   ,@cLine10 = 'TOTAL TRACK NO:'
   ,@cLine11 = '%05d04'
   ,@cLine14 = '%e'
   ,@nFunc = 1663

-- 4933 = Weight screen
DELETE rdt.RDTScn WHERE Scn = 4933 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4933, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'ORDER WEIGHT:'
   ,@cLine03 = '%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1663

-- 4934 = Carton type screen
DELETE rdt.RDTScn WHERE Scn = 4934 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4934, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'CARTON TYPE:'
   ,@cLine03 = '%30i01'
   ,@cLine04 = ''
   ,@cLine05 = 'ACT CTN: %01i02'
   ,@cLine06 = ''
   ,@cLine07 = 'SCANNED: %03d03'
   ,@cLine14 = '%e'   
   ,@nFunc = 1663
   
-- 4935 = Close pallet screen
DELETE rdt.RDTScn WHERE Scn = 4935 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4935, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'CLOSE PALLET?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'   
   ,@nFunc = 1663