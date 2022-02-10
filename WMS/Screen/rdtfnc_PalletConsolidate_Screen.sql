-- 4050 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4050 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4050, 'ENG',
     @cLine01 = 'FROM PALLET ID: '
    ,@cLine02 = '%20i01' 
    ,@cLine04 = 'Merge Pallet: %01i02'
    ,@cLine05 = '1 = Yes 2 = No'
    ,@cLine14 = '%e'

-- 4051 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4051 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4051, 'ENG',
    @cLine01 = 'FROM PALLET ID: '
   ,@cLine02 = '%20d01' 
   ,@cLine03 = 'STOR:%15d02'
   ,@cLine04 = 'SKU: %05d03' 
   ,@cLine05 = 'TOTAL QTY: %10d04' 
   ,@cLine07 = 'SKU/UPC: '    
   ,@cLine08 = '%20d05'
   ,@cLine09 = '%20d06'
   ,@cLine10 = '%20d07'
   ,@cLine11 = '%20i08'
   ,@cLine12 = '1 = MOVE SKU %01i09'
   ,@cLine14 = '%e'

-- 4052 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4052 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4052, 'ENG',
    @cLine01 = 'SKU: '    
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '         %05d04 %05d09'
   ,@cLine06 = 'QTY AVL: %05d05 %05d10'
   ,@cLine07 = 'QTY ALC: %05d06 %05d11'
   ,@cLine08 = 'QTY PCK: %05d07 %05d12'
   ,@cLine09 = 'QTY MV:  %05i08 %05i13'
   ,@cLine12 = '1=AVL,2=ALC,3=PCK %01i15' 
   ,@cLine13 = '%20d14' 
   ,@cLine14 = '%e'

-- 4053 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4053 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4053, 'ENG',
    @cLine01 = 'FROM PALLET ID: '
   ,@cLine02 = '%20d01' 
   ,@cLine03 = 'SKU: '    
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = '         %05d05 %05d07'
   ,@cLine10 = 'QTY MV:  %05d06 %05d08'
   ,@cLine11 = 'TO PALLET ID:'
   ,@cLine13 = '%20i09' 
   ,@cLine14 = '%e'

-- 4054 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4054 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4054, 'ENG',
    @cLine01 = 'FROM PALLET ID: '
   ,@cLine02 = '%20d01'
   ,@cLine04 = 'TO PALLET ID: '
   ,@cLine05 = '%20i02 '
   ,@cLine14 = '%e'

-- 4055 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4055 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4055, 'ENG',
    @cLine01 = 'PALLET ID moved '
   ,@cLine02 = 'successfully'
   ,@cLine04 = 'Press ENTER or ESC '
   ,@cLine05 = 'to continue '
   ,@cLine14 = '%e'

-- 4056 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4056 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4056, 'ENG',
    @cLine01 = 'TO PALLET Not Found.'
   ,@cLine02 = 'Create New?'
   ,@cLine04 = '1 = YES 2 = NO'
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'

-- 4057 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4057 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4057, 'ENG',
    @cLine01 = 'SCAN AN ORDERKEY TO'
   ,@cLine02 = 'MOVE SKU FROM PALLET'
   ,@cLine04 = 'ORDERKEY: %10i01'
   ,@cLine14 = '%e'