--rdtfnc_PTL_OrderPick
-- 3460 - 3469


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('811', 'ENG', 'FNC', 'SC - PICKING', 'rdtfnc_PTL_OrderPicking', '0')

-- Screen 1
-- Scn = 3460 
DELETE rdt.RDTScn WHERE Scn = 3460 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3460, 'ENG', 
   @cLine01 = 'SC - PICKING',
   @cLine03 = 'CART ID:',
   @cLine04 = '%10i01',
   @cLine06 = 'PICKZONE:', -- SOS303322
   @cLine07 = '%10i02',    -- SOS303322
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 3461 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3461, 'ENG', 
   @cLine01 = 'CART ID: %10d01',
   @cLine02 = 'LOC: %10d02',        -- Green
   @cLine03 = '%20d12', -- WaveKey
   @cLine04 = '%20d13', -- ID       
   @cLine05 = '%20d11', -- PD DropID -- Green
   @cLine06 = 'SKU / UPC:',
   @cLine07 = '%20d03',             -- Yellow
   @cLine08 = '%40i04', -- extend from 20 to 40 (james01)
   @cLine09 = '%20d05', -- SKU DESCR 1 
   @cLine10 = '%20d06', -- SKU DESCR 2
   @cLine11 = '2 %18d07',
   @cLine12 = '4 %18d08',
   @cLine13 = 'ORD:%05d09 QTY: %05d10', -- Yellow
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 3462 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3462, 'ENG', 
   @cLine01 = 'LOC: %10d02',            -- Green
   @cLine02 = '%20d01', -- WaveKey
   @cLine03 = '%20d13', -- ID           
   @cLine04 = '%20d12', -- PD DropID    -- Green 
   @cLine05 = '%20d03', -- SKU          
   @cLine06 = '%20d04', -- SKU DESCR 1 
   @cLine07 = '%20d05', -- SKU DESCR 2
   @cLine08 = 'L2:%18d06',
   @cLine09 = 'L4:%18d07',
   @cLine10 = '%20d08', -- Cart & Qty  -- Yellow
   @cLine11 = '%20d09', -- Cart & Qty  -- Yellow
   @cLine12 = '%20d10', -- Cart & Qty  -- Yellow
   @cLine13 = '1=CLOSE TOTE OP:%01i11 ',
   @cLine14 = '%e'

-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 3463 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3463, 'ENG', 
   @cLine01 = 'SC - PICKING',
   @cLine03 = 'CLOSE TOTE ID:',
   @cLine04 = '%20i01',
   @cLine14 = '%e'   

-- Screen 5
DELETE rdt.RDTScn WHERE Scn = 3464 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3464, 'ENG', 
   @cLine01 = 'SC - PICKING',
   @cLine03 = 'NEW TOTE ID:',
   @cLine04 = '%20i01',
   @cLine14 = '%e'   

-- Screen 6
DELETE rdt.RDTScn WHERE Scn = 3465 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3465, 'ENG', 
   @cLine01 = 'SHORT PICK !',
   @cLine02 = 'REASON CODE:',
   @cLine03 = '%10i01',
   @cLine04 = '%20d02', -- ROW#1 POSITION       -- SOS303322
   @cLine05 = '%20d03', -- ROW#1 TOTE 
   @cLine06 = '%20d04', -- ROW#2 POSITION
   @cLine07 = '%20d05', -- ROW#2 TOTE 
   @cLine08 = '%20d06', -- ROW#3 POSITION
   @cLine09 = '%20d07', -- ROW#3 TOTE 
   @cLine10 = '%20d08', -- ROW#4 POSITION
   @cLine11 = '%20d09', -- ROW#5 TOTE 
   @cLine12 = '%20d10', -- ROW#5 POSITION
   @cLine13 = '%20d11', -- ROW#5 TOTE 
   @cLine14 = '%e'

-- Screen 7
DELETE rdt.RDTScn WHERE Scn = 3466 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3466, 'ENG', 
   @cLine01 = 'SKU: ',  
   @cLine02 = '%20d01', -- SKU
   @cLine03 = '%20d02', -- ROW#1 POSITION
   @cLine04 = '%20d03', -- ROW#1 TOTE 
   @cLine05 = '%20d04', -- ROW#2 POSITION
   @cLine06 = '%20d05', -- ROW#2 TOTE 
   @cLine07 = '%20d06', -- ROW#3 POSITION
   @cLine08 = '%20d07', -- ROW#3 TOTE 
   @cLine09 = '%20d08', -- ROW#4 POSITION
   @cLine10 = '%20d09', -- ROW#5 TOTE 
   @cLine11 = '%20d10', -- ROW#5 POSITION
   @cLine12 = '%20d11', -- ROW#5 TOTE 
   @cLine13 = '1=CLOSE TOTE OP:%01i12 ',
   @cLine14 = '%e'

UPDATE RDT.RDTScn SET Func = 811 WHERE Scn Between 3460 AND 3469 