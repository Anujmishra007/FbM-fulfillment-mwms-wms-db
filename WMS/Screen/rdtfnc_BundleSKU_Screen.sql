-- 6020 = Work order screen
DELETE rdt.RDTScn WHERE Scn = 6020 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6020, 'ENG'
   ,@cLine01 = 'WORK ORDER:' 
   ,@cLine02 = '%10i01'
   ,@cLine03 = ''
   ,@cLine14 = '%e'      
   ,@nFunc = 649

-- 6021 = Parent screen
DELETE rdt.RDTScn WHERE Scn = 6021 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6021, 'ENG'
   ,@cLine01 = 'WO: %10d01' 
   ,@cLine02 = ''
   ,@cLine03 = 'PARENT SKU:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = 'SERIAL NO: '
   ,@cLine06 = '%20i03'
   ,@cLine12 = ''
   ,@cLine13 = 'QTY: %10d04'
   ,@cLine14 = '%e'      
   ,@nFunc = 649
   
-- 6022 = Child screen
DELETE rdt.RDTScn WHERE Scn = 6022 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6022, 'ENG'
   ,@cLine01 = 'WO: %10d01' 
   ,@cLine02 = ''
   ,@cLine03 = 'PARENT SKU:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = 'SERIAL NO: '
   ,@cLine06 = '%20d03'
   ,@cLine07 = ''
   ,@cLine08 = 'CHILD SKU:'
   ,@cLine09 = '%20d04'
   ,@cLine10 = 'SERIAL NO/SKU:'
   ,@cLine11 = '%60i05'
   ,@cLine12 = ''
   ,@cLine13 = 'QTY: %10d06'
   ,@cLine14 = '%e'   
   ,@nFunc = 649

-- 6023 = Child MAC screen
DELETE rdt.RDTScn WHERE Scn = 6023 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6023, 'ENG'
   ,@cLine01 = 'WO: %10d01' 
   ,@cLine02 = ''
   ,@cLine03 = 'PARENT SKU:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = 'CHILD SKU:'
   ,@cLine06 = '%20d03'
   ,@cLine07 = ''
   ,@cLine08 = 'ETHERNET MAC:'
   ,@cLine09 = '%20i04'
   ,@cLine10 = ''
   ,@cLine11 = 'WIFI MAC:'
   ,@cLine12 = '%20i05'
   ,@cLine14 = '%e'   
   ,@nFunc = 649
