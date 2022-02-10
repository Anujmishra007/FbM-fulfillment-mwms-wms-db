-- 1060 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1060 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1060, 'ENG',
    @cLine01 = 'CARTON CONSOLIDATION'
   ,@cLine02 = ''
   ,@cLine03 = 'PICKSLIP NO:'
   ,@cLine04 = '%10i01'
   ,@cLine05 = 'FROM CARTON'
   ,@cLine06 = '%18i02'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION %01i03'
   ,@cLine09 = '1 = FULL 2 = PARTIAL'
   ,@cLine14 = '%e'
   ,@nFunc = 990

-- 1061 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1061 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1061, 'ENG',
    @cLine01 = 'CARTON CONSOLIDATION'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM CARTON:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'SKU/UPC:'
   ,@cLine06 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 990

-- 1062 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1062 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1062, 'ENG',
    @cLine01 = 'CARTON CONSOLIDATION'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM CARTON:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'SKU:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = '         %05d03'
   ,@cLine08 = 'QTY AVL: %05d04'
   ,@cLine09 = 'QTY MV:  %05i05'
   ,@cLine14 = '%e'
   ,@nFunc = 990

-- 1063 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1063 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1063, 'ENG',
    @cLine01 = 'CARTON CONSOLIDATION'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM CARTON:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'SKU:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = '         %05d03'
   ,@cLine08 = 'QTY MV:  %05d04'
   ,@cLine10 = 'TO CARTON:'
   ,@cLine12 = '%18i05'
   ,@cLine14 = '%e'
   ,@nFunc = 990

-- 1064 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1064 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1064, 'ENG',
    @cLine01 = 'CARTON CONSOLIDATION'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM CARTON:'
   ,@cLine04 = '%18d01'
   ,@cLine06 = 'TO CARTON:'
   ,@cLine07 = '%18i02'
   ,@cLine14 = '%e'
   ,@nFunc = 990

-- 1065 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1065 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1065, 'ENG',
    @cLine01 = 'CARTON CONSOLIDATION'
   ,@cLine02 = ''
   ,@cLine03 = 'CARTON MERGE'
   ,@cLine04 = 'SUCCESSFULLY!!!'
   ,@cLine14 = '%e'
   ,@nFunc = 990