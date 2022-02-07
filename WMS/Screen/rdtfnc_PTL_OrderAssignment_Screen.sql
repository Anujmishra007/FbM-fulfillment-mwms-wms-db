--rdtfnc_PTL_OrderAssignment
-- 3450 - 3459


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('810', 'ENG', 'FNC', 'SC - ASSIGN ORDERS', 'rdtfnc_PTL_OrderAssignment', '0')

-- Screen 1
-- Scn = 3450 
DELETE rdt.RDTScn WHERE Scn = 3450 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3450, 'ENG', 
   @cLine01 = 'SC - ASSIGN ORDERS',
   @cLine03 = 'CART ID:',
   @cLine04 = '%10i01',
   @cLine06 = 'PICKZONE:', -- SOS314306
   @cLine07 = '%10i02',    -- SOS314306
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 3451 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3451, 'ENG', 
   @cLine01 = 'SC - ASSIGN ORDERS',
   @cLine03 = 'CART ID: %10d01',
   @cLine04 = 'PK ZONE: %10d05', -- SOS314306
   @cLine05 = 'ORDERKEY:',
   @cLine06 = '%10i02',
   @cLine07 = 'CART POSITION:',
   @cLine08 = '%10i03',
   @cLine09 = 'TOTE ID:',
   @cLine10 = '%20i04',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 3452 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3452, 'ENG', 
   @cLine01 = 'SC - ASSIGN ORDERS',
   @cLine03 = 'CART ID: %10d01',
   @cLine05 = 'POSITIONS NOT YET',
   @cLine06 = 'ASSIGNED:',
   @cLine07 = '%05d02 %05d03 %05d04',
   @cLine08 = '%05d05 %05d06 %05d07',
   @cLine09 = '%05d08 %05d09 %05d10',
   @cLine14 = '%e'


-- Screen 4 variable position (SOS314306)
DELETE rdt.RDTScn WHERE Scn = 3453 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3453, 'ENG', 
   @cLine01 = 'SC - ASSIGN ORDERS',
   @cLine03 = 'CART ID: %10d01',
   @cLine04 = 'PICKZONE:%10d07', -- SOS314306
   @cLine05 = 'POSITIONS NOT YET',
   @cLine06 = 'ASSIGNED:',
   @cLine07 = '%20d02',    -- ROW#1 POSITION
   @cLine08 = '%20d03',    -- ROW#2 POSITION
   @cLine09 = '%20d04',    -- ROW#3 POSITION
   @cLine10 = '%20d05',    -- ROW#4 POSITION
   @cLine11 = '%20d06',    -- ROW#5 POSITION
   @cLine14 = '%e'
      
UPDATE RDT.RDTScn SET Func = 810 WHERE Scn Between 3450 AND 3459 