-- 2460 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2460 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2460, 'ENG',
    @cLine01 = 'TOTE CONSOLIDATION'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM TOTE:'
   ,@cLine04 = '%10i01'       -- SOS312212
   ,@cLine05 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 973

-- 2461 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2461 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2461, 'ENG',
    @cLine01 = 'TOTE CONSOLIDATION'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM TOTE:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'STORE:'
   ,@cLine06 = '%15d02'
   ,@cLine07 = 'SKU/UPC:'
   ,@cLine08 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 973

-- 2462 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2462 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2462, 'ENG',
    @cLine01 = 'TOTE CONSOLIDATION'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM TOTE:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'STORE:'
   ,@cLine06 = '%15d02'
   ,@cLine07 = 'SKU:'
   ,@cLine08 = '%20d03'
   ,@cLine09 = '         %05d04'
   ,@cLine10 = 'QTY AVL: %05d05'
   ,@cLine11 = 'QTY MV:  %05i06'
   ,@cLine14 = '%e'
   ,@nFunc = 973

-- 2463 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2463 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2463, 'ENG',
    @cLine01 = 'TOTE CONSOLIDATION'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM TOTE:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'STORE:'
   ,@cLine06 = '%15d02'
   ,@cLine07 = 'SKU:'
   ,@cLine08 = '%20d03'
   ,@cLine09 = '         %05d04'
   ,@cLine10 = 'QTY MV:  %05d05'
   ,@cLine11 = 'TO TOTE:'
   ,@cLine12 = '%10i06'    -- SOS312212
   ,@cLine14 = '%e'
   ,@nFunc = 973

-- 2464 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2464 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2464, 'ENG',
    @cLine01 = 'TOTE CONSOLIDATION'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM TOTE:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'STORE:'
   ,@cLine06 = '%15d02'
   ,@cLine07 = 'LOC:'
   ,@cLine08 = '%10d04'
   ,@cLine09 = 'TO TOTE:'
   ,@cLine10 = '%18i03'    -- SOS312212
   ,@cLine13 = '%20d05'    -- SOS319877   (extended info)
   ,@cLine14 = '%e'
   ,@nFunc = 973

-- 2465 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2465 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2465, 'ENG',
    @cLine01 = 'TOTE CONSOLIDATION'
   ,@cLine02 = ''
   ,@cLine03 = 'TO TOTE not found.'
   ,@cLine04 = 'Create New?'
   ,@cLine05 = ''
   ,@cLine06 = '1=Yes 9=NO'
   ,@cLine07 = 'Option: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 973

-- 2466 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2466 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2466, 'ENG',
    @cLine01 = 'TOTE CONSOLIDATION'
   ,@cLine02 = ''
   ,@cLine03 = 'SKU Moved'
   ,@cLine04 = 'Successfully'
   ,@cLine05 = ''
   ,@cLine06 = 'TO TOTE:'
   ,@cLine07 = '%18d01'
   ,@cLine12 = 'Press ENTER or ESC'
   ,@cLine13 = 'to continue'
   ,@cLine14 = '%e'
   ,@nFunc = 973

-- 2467 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2467 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2467, 'ENG',
    @cLine01 = 'TOTE CONSOLIDATION'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM TOTE:'
   ,@cLine04 = '%18d04'
   ,@cLine05 = ''
   ,@cLine06 = 'STORE: %10d02'
   ,@cLine07 = 'LOC:   %10d03'
   ,@cLine08 = ''
   ,@cLine09 = 'Merge Tote: %01i01'
   ,@cLine10 = '1= Whole 9= Partial'
   ,@cLine14 = '%e'
   ,@nFunc = 973


-- 2468 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2468 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2468, 'ENG',
    @cLine01 = 'TOTE CONSOLIDATION'
   ,@cLine02 = 'TO TOTE:'
   ,@cLine03 = '%18d01'
   ,@cLine04 = ''
   ,@cLine05 = 'CLOSE PTS TOTE ?'
   --,@cLine06 = 'PRINT LABEL AND'
   --,@cLine07 = 'MANIFEST ??'
   ,@cLine07 = '1 = YES'
   ,@cLine08 = '9 = NO'
   ,@cLine09 = 'Option: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 973   
   
-- 2469 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2469 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2469, 'ENG',
    @cLine01 = 'TOTE CONSOLIDATION'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM TOTE:'
   ,@cLine04 = '%18d01'       
   ,@cLine05 = 'SKU:'
   ,@cLine06 = '%20i02'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine09 = 'STORE: %10d06'
   ,@cLine10 = 'LOC: %20d07'
   ,@cLine11 = 'LOC: %20d08'
   ,@cLine12 = 'LOC: %20d09'
   ,@cLine13 = 'TO LOC: %10i05'
   ,@cLine14 = '%e'
   ,@nFunc = 973