--  SCN 2590 - 2599

-- 2589 = PickSlipNo
DELETE rdt.RDTScn WHERE Scn = 2590 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2590, 'ENG',
   @cLine01 = 'PSNO: %10i01',
   @cLine14 = '%e'

-- 2591 = LOC, Option
DELETE rdt.RDTScn WHERE Scn = 2591 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2591, 'ENG',
   @cLine01 = 'PSNO: %10d01',
   @cLine02 = 'LOC:  %10i02',
   @cLine03 = '',
   @cLine04 = 'DROP ID:',
   @cLine05 = '%20i03',
   @cLine14 = '%e'

-- 2592 = SKU/UPC
DELETE rdt.RDTScn WHERE Scn = 2592 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2592, 'ENG',
   @cLine01 = 'LOC: %10d01',
   @cLine02 = 'DROPID:',
   @cLine03 = '%20d02',
   @cLine05 = 'SKU:',
   @cLine06 = '%30i03',
   @cLine14 = '%e'
   
-- Scn = 2593 . Lottables
DELETE rdt.RDTScn WHERE Scn = 2593 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2593, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine02 = '%18i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%18i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%18i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%10i08'
   ,@cLine14 = '%e'
      
-- 2594 = QTY
DELETE rdt.RDTScn WHERE Scn = 2594 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2594, 'ENG',
   @cLine01 = 'SKU:',
   @cLine02 = '%20d01',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = 'LOTTABLE 1/2/3/4',
   @cLine06 = '1 %18d04',
   @cLine07 = '2 %18d05',
   @cLine08 = '3 %18d06',
   @cLine09 = '4 %18d07',
   @cLine11 = '%04d08 %05d09 %05d10', 
   @cLine12 = 'QTY: %05i11 %05i12', 
   @cLine14 = '%e'

-- 2595 = Message screen
DELETE rdt.RDTScn WHERE Scn = 2595 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2595, 'ENG',
   @cLine01 = '',
   @cLine02 = 'Confirm Short Pick?',
   @cLine04 = '',
   @cLine05 = '1 = Yes',
   @cLine06 = '2 = No',
   @cLine07 = '',
   @cLine08 = 'Option: %01i01',
   @cLine14 = '%e'

-- 2596 = Info Screen
DELETE rdt.RDTScn WHERE Scn = 2596 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2596, 'ENG',
     @cLine01 = 'PSNO: %10d01'
    ,@cLine03 = '     PK TOTAL'
    ,@cLine04 = 'SKU: %05d02 / %05d03'
    ,@cLine05 = 'QTY: %05d04 / %05d05'
    ,@cLine07 = 'STATUS:%13d06'
    ,@cLine14 = '%e'
    
    
-- update rdt.rdtscn with function id   
UPDATE RDT.RDTSCN SET FUNC = 866 WHERE SCN BETWEEN 2590 AND 2599

