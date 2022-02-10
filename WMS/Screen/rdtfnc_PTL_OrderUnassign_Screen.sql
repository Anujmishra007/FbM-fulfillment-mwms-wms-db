--rdtfnc_PTL_OrderUnassign
-- 3470 - 3479


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('812', 'ENG', 'FNC', 'SC - UNASSIGN ORDERS', 'rdtfnc_PTL_OrderUnassign', '0')

-- Screen 1
-- Scn = 3470 
DELETE rdt.RDTScn WHERE Scn = 3470 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3470, 'ENG', 
   @cLine01 = 'SC - UNASSIGN ORDERS',
   @cLine03 = 'CART ID:',
   @cLine04 = '%10i01',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 3471 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3471, 'ENG', 
   @cLine01 = 'SC - UNASSIGN ORDERS',
   @cLine03 = 'CART ID: %10d01',
   @cLine05 = 'ORDERKEY:',
   @cLine06 = '%10i02',
   @cLine07 = 'OR',
   @cLine08 = 'CART POSITION:',
   @cLine09 = '%10i03',
   @cLine10 = 'OR',
   @cLine11 = 'EXTERNORDERKEY:',
   @cLine12 = '%20i04',
   @cLine13 = '%20d05',    -- SOS315448 Extended info
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 3472 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3472, 'ENG', 
   @cLine01 = 'SC - UNASSIGN ORDERS',
   @cLine03 = 'THE FOLLOWING ORDER',
   @cLine04 = 'WAS UNASSIGNED ! ',
   @cLine06 = 'CARTID: %10d01',
   @cLine07 = 'CART POSITION:',
   @cLine08 = '%10d02',
   @cLine09 = 'ORDERKEY:',
   @cLine10 = '%20d03',
   @cLine11 = 'EXTERNORDERKEY:',
   @cLine12 = '%20d04',
   @cLine14 = '%e'
   

      
UPDATE RDT.RDTScn SET Func = 812 WHERE Scn Between 3470 AND 3479 