-- 1700 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1700 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1700, 'ENG',
     @cLine01 = 'FROM DROPID: '
    ,@cLine02 = '%20i01' -- DropID Extend Field to 20
    ,@cLine04 = 'Merge Pallet: %01i02'
    ,@cLine05 = '1 = Yes 2 = No'
    ,@cLine14 = '%e'

-- 1701 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1701 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1701, 'ENG',
    @cLine01 = 'FROM DROPID: '
   ,@cLine02 = '%20d01' -- DropID Extend Field to 20
   ,@cLine03 = 'SKU/UPC: '    
   ,@cLine04 = '%20i02'
   ,@cLine14 = '%e'

-- 1702 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1702 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1702, 'ENG',
    @cLine01 = 'FROM DROPID: '
   ,@cLine02 = '%20d01' 
   ,@cLine03 = 'SKU'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'    
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%18i06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%18i08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = '%16i10'    
   ,@cLine14 = '%e'

-- 1703 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1703 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1703, 'ENG',
    @cLine01 = 'SKU: '
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%18d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%18d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%16d07'
   ,@cLine09 = '         %05d08 %05d11'
   ,@cLine10 = 'QTY AVL: %05d09 %05d12'
   ,@cLine11 = 'QTY MV:  %05i10 %05i13'
   ,@cLine14 = '%e'

-- 1704 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1704 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1704, 'ENG',
    @cLine01 = 'FROM DROPID: '
   ,@cLine02 = '%20d01' -- DropID Extend Field to 20
   ,@cLine03 = 'SKU: '
   ,@cLine04 = '%20d02 '
   ,@cLine05 = '%20d03 '
   ,@cLine06 = '%20d04 '
   ,@cLine07 = '         %05d05 %05d07'
   ,@cLine08 = 'QTY MV:  %05d06 %05d08'
   ,@cLine09 = 'TO DROPID: '
   ,@cLine10 = '%20i09' -- DropID Extend Field to 20
   ,@cLine14 = '%e'

-- 1705 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1705 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1705, 'ENG',
    @cLine01 = 'FROM DROPID: '
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'ORDERKEY: %10d03'   -- SOS#172046
   ,@cLine04 = '%10d04'             -- SOS#172046
   ,@cLine05 = '%20d05'             -- SOS#172046
   ,@cLine06 = '%25d06'             -- SOS#172046
   ,@cLine07 = '%20d07'             -- SOS#172046
   ,@cLine08 = '%10d08'             -- SOS#172046
   ,@cLine09 = '%10d09'            -- SOS#172046
   ,@cLine10 = '%10d10'            -- SOS#172046
   ,@cLine11 = 'TO DROPID: '
   ,@cLine12 = '%20i02 '
   ,@cLine14 = '%e'

-- 1706 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1706 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1706, 'ENG',
    @cLine01 = 'DROP ID moved '
   ,@cLine02 = 'successfully'
   ,@cLine04 = 'Press ENTER or ESC '
   ,@cLine05 = 'to continue '
   ,@cLine14 = '%e'

-- 1707 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1707 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1707, 'ENG',
    @cLine01 = 'TO DROPID Not Found.'
   ,@cLine02 = 'Create New?'
   ,@cLine04 = '1 = YES 2 = NO'
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'

-- 1708 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1708 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1708, 'ENG',
    @cLine01 = 'PRINT LABEL ? %01i01'
   ,@cLine03 = '1 = YES 2 = NO'
   ,@cLine14 = '%e'
   
