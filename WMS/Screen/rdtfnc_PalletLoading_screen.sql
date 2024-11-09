-- 6420 = Chose 1 or 2
DELETE rdt.RDTScn WHERE Scn = 6420 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6420, 'ENG'
   ,@cLine01 = '1. Scan Order Number'
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1668

-- 6421 = Order Number
DELETE rdt.RDTScn WHERE Scn = 6421 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6421, 'ENG'
   ,@cLine01 = 'Order Number:'
   ,@cLine02 = '%20i01'
   ,@cLine08 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1668

-- 6422 = Chose Pallets
DELETE rdt.RDTScn WHERE Scn = 6422 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6422, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine08 = 'OPTION: %01i06'
   ,@cLine14 = '%e'
   ,@nFunc = 1668

-- 6423 = Enter Quantity
DELETE rdt.RDTScn WHERE Scn = 6423 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6423, 'ENG'
   ,@cLine01 = 'PALLET TYPE %20d01'
   ,@cLine02 = 'Quantity: %20i02'''
   ,@cLine08 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1668

-- 6424 = Scan Order
DELETE rdt.RDTScn WHERE Scn = 6424 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6424, 'ENG'
   ,@cLine01 = 'PALLET Loading'
   ,@cLine03 = 'Scan Order:'
   ,@cLine04 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1668

-- 6425 = Pallet Type
DELETE rdt.RDTScn WHERE Scn = 6425 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6425, 'ENG'
   ,@cLine01 = 'PALLET Type'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine08 = 'OPTION: %01i06'
   ,@cLine14 = '%e'
   ,@nFunc = 1668

-- 6426 = Enter Quantity
DELETE rdt.RDTScn WHERE Scn = 6426 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6426, 'ENG'
   ,@cLine03 = 'Enter the quantity'
   ,@cLine04 = 'of pallets to load'
   ,@cLine06 = 'Qty:'
   ,@cLine07 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1668

-- 6427 = Scan Order
DELETE rdt.RDTScn WHERE Scn = 6427 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6427, 'ENG'
   ,@cLine02 = '%20d01 %20d02'
   ,@cLine03 = 'pallet(s) will be'
   ,@cLine04 = 'added to'
   ,@cLine05 = '%20d03'
   ,@cLine07 = '1. YES'
   ,@cLine08 = '9. NO'
   ,@cLine10 = 'Option:%01i04'
   ,@cLine14 = '%e'
   ,@nFunc = 1668

-- 6428 = Scan Order
DELETE rdt.RDTScn WHERE Scn = 6428 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6428, 'ENG'
   ,@cLine01 = '%05d01 %20d02'
   ,@cLine02 = 'pallet(s) already'
   ,@cLine03 = 'available in'
   ,@cLine04 = '%20d03'
   ,@cLine06 = 'Would you like to'
   ,@cLine07 = 'add more %07d02 pallets?'
   ,@cLine09 = '1. YES'
   ,@cLine10 = '9. NO'
   ,@cLine11 = 'Option:%01i04'   
   ,@cLine14 = '%e'
   ,@nFunc = 1668