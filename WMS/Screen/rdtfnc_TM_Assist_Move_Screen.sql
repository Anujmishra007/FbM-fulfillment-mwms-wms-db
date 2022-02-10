-- 4080 = Final LOC screen
DELETE rdt.RDTScn WHERE Scn = 4080 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4080, 'ENG'
   ,@cLine01 = 'TM Move        ASTMV'
   ,@cLine02 = ''
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = ''
   ,@cLine06 = 'SUGGESTED LOC: '
   ,@cLine07 = '%10d02' 
   ,@cLine08 = ''
   ,@cLine09 = 'FINAL LOC: '    
   ,@cLine10 = '%10i03'
   ,@cLine11 = ''
   ,@cLine12 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1816

-- 4081 = next task screen
DELETE rdt.RDTScn WHERE Scn = 4081 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4081, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CURRENT TASK COMPLETE' 
   ,@cLine03 = ''
   ,@cLine04 = 'NEXT TASK TYPE:' 
   ,@cLine05 = '%10d01'    
   ,@cLine06 = ''
   ,@cLine07 = '' 
   ,@cLine08 = 'ENTER = NEXT TASK'
   ,@cLine09 = 'ESC   = EXIT' 
   ,@cLine14 = '%e'
   ,@nFunc = 1816
   
-- 4082 = SKU
DELETE rdt.RDTScn WHERE Scn = 4082 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4082, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU/UPC:',
   @cLine05 = '%60i03',
   @cLine14 = '%e',
   @nFunc = 1816
   
-- 4083 = QTY
DELETE rdt.RDTScn WHERE Scn = 4083 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4083, 'ENG',
   @cLine01 = 'SKU:         PPK:%03d14', 
   @cLine02 = '%20d01',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = '%20d04',
   @cLine06 = '%20d05',
   @cLine07 = '%20d06',
   @cLine08 = '%20d07',
   @cLine09 = '     %07d08   %07d11',  
   @cLine10 = 'AVL: %07d09   %07d12',  
   @cLine11 = 'MV:  %07i10   %07i13',
   @cLine12 = '', 
   @cLine13 = '%20d15',
   @cLine14 = '%e',
   @nFunc = 1816
   