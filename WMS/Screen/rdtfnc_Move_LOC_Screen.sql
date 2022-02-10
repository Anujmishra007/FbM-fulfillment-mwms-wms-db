-- 1010 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1010 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1010, 'ENG',
    @cLine01 = 'FROM LOC: %10i02'
   ,@cLine14 = '%e'
 
-- 1011 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1011 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1011, 'ENG',
    @cLine01 = 'FROM LOC: %10d02'
   ,@cLine03 = 'SKU: %10d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20d06'
   ,@cLine07 = 'UOM:    %05d07 %05d09'
   ,@cLine08 = 'QTY:    %05d08 %05d10'
   ,@cLine10 = 'TO LOC: %10i11'
   ,@cLine11 = 'TO ID:' -- SOS#137962
   ,@cLine12 = '%20i12' -- SOS#137962
   ,@cLine13 = '%20d13' -- WMS7487
   ,@cLine14 = '%e'
 
-- 1012 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1012 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1012, 'ENG',
    @cLine02 = 'Stock in LOC moved'
   ,@cLine03 = 'successfully'
   ,@cLine04 = 'TO LOC: %10d01'      -- (james03)
   ,@cLine06 = 'Press ENTER or ESC'  -- (james03)  
   ,@cLine07 = 'to continue'         -- (james03)
   ,@cLine14 = '%e'

-- 1013 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1013 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1013, 'ENG',
    @cLine02 = 'Only move 10 records'
   ,@cLine03 = 'at one time.'
   ,@cLine05 = 'Remaining Rec = %04d01'
   ,@cLine07 = 'Continue Move?'
   ,@cLine09 = '1 = YES'
   ,@cLine10 = '2 = NO'
   ,@cLine12 = 'Option: %01i02'
   ,@cLine14 = '%e'
 