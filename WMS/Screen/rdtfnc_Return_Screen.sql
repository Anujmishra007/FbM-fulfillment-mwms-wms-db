
-- Scn = 1450. ASN, PO
DELETE rdt.RDTScn WHERE Scn = 1450 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1450, 'ENG', 
   @cLine01 = 'ASN: %10i01',
   @cLine02 = 'PO : %10i02',
   @cLine14 = '%e'

-- Scn = 1451. ASN, PO, SKU, Desc 
DELETE rdt.RDTScn WHERE Scn = 1451 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1451, 'ENG', 
   @cLine01 = 'ASN: %10d01',
   @cLine02 = 'PO : %10d02',
   @cLine03 = 'SKU: ',
   @cLine04 = '%60i03',
   @cLine05 = '%20d04',
   @cLine06 = '%20d05',
   @cLine08 = 'ASN QTY: %10d06 %10d07', -- (ChewKP01)
   @cLine09 = 'RCV QTY: %10d08 %10d09', -- (ChewKP01)
   @cLine14 = '%e'

-- Scn = 1452. QTY, Condition Code
DELETE rdt.RDTScn WHERE Scn = 1452 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1452, 'ENG', 
   @cLine01 = 'SKU: ',
   @cLine02 = '%20d01',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = 'IVAS: ',
   @cLine06 = '%20d04',
   @cLine07 = '%08d05 %05d06 %05d07',
   @cLine08 = 'QTY RTN: %05i08 %05i09',
   @cLine10 = 'CONDITION CODE: ',
   @cLine11 = '%10i10',
   @cLine12 = '', 
   @cLine13 = '%20d11',
   @cLine14 = '%e'
   
-- Scn = 1453. Lottables
--FKLIM
DELETE rdt.RDTScn WHERE Scn = 1453 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1453, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine02 = '%18i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%60i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%18i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%10i08'
   ,@cLine14 = '%e'
 
   
-- Scn = 1454. Verify Serial No, SubReason
DELETE rdt.RDTScn WHERE Scn = 1454 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1454, 'ENG', 
   @cLine01 = 'SUBREASON:',
   @cLine02 = '%10i01',
   @cLine14 = '%e'

-- 1455. ID
DELETE rdt.RDTScn WHERE Scn = 1455 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1455, 'ENG', 
   @cLine01 = 'SKU: ',
   @cLine02 = '%20d01',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = 'LOTTABLE 2/3/4',
   @cLine06 = '2 %18d04',
   @cLine07 = '3 %18d05',
   @cLine08 = '4 %16d06',
   @cLine09 = '%08d07 %05d08 %05d09',
   @cLine10 = 'QTY RTN: %05d10 %05d11',
   @cLine11 = 'TO ID: ',
   @cLine12 = '%18i12',
   @cLine13 = '%20d13', -- Extended Info (james04)
   @cLine14 = '%e'

-- 1456. LOC
DELETE rdt.RDTScn WHERE Scn = 1456 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1456, 'ENG', 
   @cLine01 = 'SKU: ',
   @cLine02 = '%20d01',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = 'LOTTABLE 2/3/4',
   @cLine06 = '2 %18d04',
   @cLine07 = '3 %18d05',
   @cLine08 = '4 %16d06',
   @cLine09 = '%08d07 %05d08 %05d09',
   @cLine10 = 'QTY RTN: %05d10 %05d11',
   @cLine11 = 'TO ID: ',
   @cLine12 = '%18d12',
   @cLine13 = 'TO LOC: %10i13',
   @cLine14 = '%e'

-- 1457. Message
DELETE rdt.RDTScn WHERE Scn = 1457 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1457, 'ENG', 
   @cLine01 = 'SKU successfully',
   @cLine02 = 'received',
   @cLine04 = 'Press ENTER or ESC',
   @cLine05 = 'to continue',
   @cLine14 = '%e'

-- SOS173450
-- 1458. Option
DELETE rdt.RDTScn WHERE Scn = 1458 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1458, 'ENG', 
   @cLine01 = 'TO ID:',
   @cLine02 = '%18i01',
   @cLine04 = 'TO LOC:',
   @cLine05 = '%10i02',
   @cLine14 = '%e'

-- SOS317336
-- 1459 ZONE
DELETE rdt.RDTScn WHERE Scn = 1459 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1459, 'ENG', 
   @cLine01 = 'ZONE:',
   @cLine02 = '%10i01',
   @cLine14 = '%e', 
   @nFunc = 552