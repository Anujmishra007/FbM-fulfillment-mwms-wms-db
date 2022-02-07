/*
   Move by ID
*/

-- 1000 = FromID
DELETE rdt.RDTScn WHERE Scn = 1000 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1000, 'ENG', 
   @cLine01 = 'FROM ID:', 
   @cLine02 = '%20i01',  -- ColStringExp Changes SOS#339806
   @cLine03 = 'FROM LOC: %10d02', 
   @cLine14 = '%e'

-- 1001 = FromLOC
DELETE rdt.RDTScn WHERE Scn = 1001 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1001, 'ENG', 
   @cLine01 = 'FROM ID:', 
   @cLine02 = '%18d01', 
   @cLine03 = 'FROM LOC: %10i02', 
   @cLine14 = '%e'

-- 1002 = Move to
DELETE rdt.RDTScn WHERE Scn = 1002 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1002, 'ENG', 
   @cLine01 = 'FROM ID:', 
   @cLine02 = '%18d01', 
   @cLine03 = 'FROM LOC: %10d02', 
   @cLine04 = '', 
   @cLine05 = 'SKU: %10d03', 
   @cLine06 = '%20d04', 
   @cLine07 = '%20d05', 
   @cLine08 = '%20d06', 
   @cLine09 = 'UOM:    %05d07 %05d09', 
   @cLine10 = 'QTY:    %05d08 %05d10', 
   @cLine11 = '', 
   @cLine12 = 'TO LOC: %10i11', 
   @cLine13 = '%20d12',    -- WMS7487
   @cLine14 = '%e'

-- 1003 = Message screen
DELETE rdt.RDTScn WHERE Scn = 1003 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1003, 'ENG', 
   @cLine02 = 'ID moved', 
   @cLine03 = 'successfully', 
   @cLine04 = 'TO LOC: %10d01',     -- (james03)
   @cLine06 = 'Press ENTER or ESC', -- (james03)
   @cLine07 = 'to continue',        -- (james03)
   @cLine14 = '%e'
