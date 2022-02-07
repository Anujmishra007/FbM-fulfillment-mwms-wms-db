--rdtfnc_PTL_CartInquiry
-- 3450 - 3459


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('813', 'ENG', 'FNC', 'SC - INQUIRY', 'rdtfnc_PTL_CartInquiry', '0')

-- Screen 1
-- Scn = 3450 
DELETE rdt.RDTScn WHERE Scn = 3480 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3480, 'ENG', 
   @cLine01 = 'SC - INQUIRY',
   @cLine03 = 'CART ID:',
   @cLine04 = '%10i01',
   @cLine06 = 'OR',
   @cLine08 = 'TOTE ID:',
   @cLine09 = '%10i02',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 3481 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3481, 'ENG', 
   @cLine01 = 'SC - INQUIRY',
   @cLine03 = 'CART ID: %10d01',
   @cLine04 = 'CART STATUS:',
   @cLine05 = '%10d02',
   @cLine06 = 'LAST CART USER:',
   @cLine07 = '%18d03',
   @cLine08 = 'NO OF ORDERS: %05d04',
   @cLine13 = '%20d05',       -- SOS303322 Extended info
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 3482 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3482, 'ENG', 
   @cLine01 = 'SC - INQUIRY',
   @cLine03 = 'CART ID: %10d01',
   @cLine04 = 'POS  ORDER       STATUS',
   @cLine05 = '%20d02',
   @cLine06 = '%20d03',
   @cLine07 = '%20d04',
   @cLine08 = '%20d05',
   @cLine09 = '%20d06',
   @cLine10 = '%20d07',
   @cLine11 = '%20d08',
   @cLine12 = '%20d09',
   @cLine13 = 'ENTER FOR NEXT RECORD',    -- SOS303322 Support 20 positions
   @cLine14 = '%e'
   
-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 3483 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3483, 'ENG', 
   @cLine01 = 'SC - TOTE INQUIRY',
   @cLine03 = 'CART ID: %10d01',
   @cLine04 = 'TOTE ID:',
   @cLine05 = '%20d02',
   @cLine06 = 'ORDERKEY: %10d03',
   @cLine07 = 'EXTERNORDERKEY:',
   @cLine08 = '%20d04',
   @cLine09 = 'ORDER STATUS: %05d05',
   @cLine10 = 'TOTE POSITION: %05d06',
   @cLine11 = 'SKUs: %20d07',
   @cLine12 = 'Qty: %20d08', -- YELLOW
   @cLine14 = '%e'

-- Screen 5
DELETE rdt.RDTScn WHERE Scn = 3484 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3484, 'ENG', 
   @cLine01 = 'SC - TOTE INQUIRY',
   @cLine02 = 'TOTE ID:',
   @cLine03 = '%20d02',
   @cLine04 = 'SKU: %20d09',
   @cLine05 = 'L2: %20d10',
   @cLine07 = 'SKU:',
   @cLine08 = '%20d11',           -- YELLOW
   @cLine09 = 'QTY: %20d12',      -- YELLOW
   @cLine10 = 'LOTTABLES:',
   @cLine11 = '2. %18d13',
   @cLine12 = '4. %10d14',
   @cLine13 = 'PICK LOC: %10d15', -- GREEN
   @cLine14 = '%e'
      
UPDATE RDT.RDTScn SET Func = 813 WHERE Scn Between 3480 AND 3489 