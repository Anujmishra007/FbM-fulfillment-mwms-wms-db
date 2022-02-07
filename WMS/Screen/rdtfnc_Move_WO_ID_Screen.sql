-- 2300 =  WORKORDER NO
DELETE rdt.RDTScn WHERE Scn = 2300 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2300, 'ENG', 
   @cLine01 = 'WORKORDER NO:', 
   @cLine02 = '%10i01', 
   @cLine14 = '%e'
   
-- 2301 = FromID
DELETE rdt.RDTScn WHERE Scn = 2301 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2301, 'ENG', 
   @cLine01 = 'FROM ID:', 
   @cLine02 = '%18i01', 
   @cLine03 = 'FROM LOC: %10d02', 
   @cLine14 = '%e'

-- 2302 = FromLOC
DELETE rdt.RDTScn WHERE Scn = 2302 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2302, 'ENG', 
   @cLine01 = '%20d01:', 
   @cLine02 = 'FROM ID:', 
   @cLine03 = '%18d02', 
   @cLine04 = 'FROM LOC: %10i03', 
   @cLine14 = '%e'

-- 2303 = Move to
DELETE rdt.RDTScn WHERE Scn = 2303 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2303, 'ENG', 
   @cLine01 = 'FROM ID:', 
   @cLine02 = '%18d01', 
   @cLine03 = 'FROM LOC: %10d02', 
   @cLine04 = '', 
   @cLine05 = 'SKU: %10d03', 
   @cLine06 = '%20d04', 
   @cLine07 = '%20d05', 
   @cLine08 = '%20d06',
   @cLine09 = 'UOM:%10d07', 
   @cLine10 = 'QTY:%10d08', 
   @cLine11 = '', 
   @cLine12 = 'TO LOC: %10i09', 
   @cLine14 = '%e'

-- 2304 = Message screen
DELETE rdt.RDTScn WHERE Scn = 2304 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2304, 'ENG', 
   @cLine02 = 'ID moved', 
   @cLine03 = 'successfully', 
   @cLine04 = '', 
   @cLine05 = 'Press ENTER or ESC', 
   @cLine06 = 'to continue', 
   @cLine14 = '%e'
