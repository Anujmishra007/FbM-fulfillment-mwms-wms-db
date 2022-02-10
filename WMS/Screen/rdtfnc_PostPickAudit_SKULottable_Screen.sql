--  SCN 2610 - 2619

-- 2610 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2610 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2610, 'ENG',
    @cLine01 = 'POST PICK AUDIT'
   ,@cLine03 = 'REFNO:   %10i01'
   ,@cLine05 = 'PSNO:    %10i02'
   ,@cLine07 = 'LOADKEY: %10i03'
   ,@cLine09 = 'ORDERKEY:%10i04'
   ,@cLine11 = 'CARTON ID:'
   ,@cLine12 = '%18i05'
   ,@cLine14 = '%e'
 

 
-- 2611 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 2611 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2611, 'ENG',
    @cLine01 = 'REFNO:   %10d01'
   ,@cLine02 = 'PSNO:    %10d02'
   ,@cLine03 = 'LOADKEY: %10d03'
   ,@cLine04 = 'ORDERKEY:%10d04'
   ,@cLine05 = 'CARTON ID: '
   ,@cLine06 = '%10d05'
   ,@cLine08 = 'SKU:'
   ,@cLine09 = '%60i06' -- SOS374911
   ,@cLine14 = '%e'

-- Scn = 2612 . Lottables
DELETE rdt.RDTScn WHERE Scn = 2612 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2612, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine02 = '%18i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%18i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%18i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%10i08'
   ,@cLine14 = '%e'   

   
-- Scn = 2613 . QTY
DELETE rdt.RDTScn WHERE Scn = 2613 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2613, 'ENG',
   @cLine01 = 'SKU:',
   @cLine02 = '%20d01',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = 'LOTTABLE 1/2/3/4',
   @cLine06 = '1 %18d04',
   @cLine07 = '2 %18d05',
   @cLine08 = '3 %18d06',
   @cLine09 = '4 %18d07',
   @cLine11 = '%04d08     %05d09 %05d10', 
   @cLine12 = 'QTY CHK: %05i11 %05i12', 
   @cLine14 = '%e'
 

-- 2614 = ReasonCode screen
DELETE rdt.RDTScn WHERE Scn = 2614 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2614, 'ENG',
    @cLine01 = 'CHECK QTY DIFFERENT'
   ,@cLine02 = 'THEN PICK QTY'
   ,@cLine04 = 'REASON CODE:'   
   ,@cLine05 = '%02i01'
   ,@cLine14 = '%e'
 
-- 2615 = Info Screen
DELETE rdt.RDTScn WHERE Scn = 2615 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2615, 'ENG',
   @cLine01 = 'REFNO:    %10d01'
   ,@cLine02 = 'PSNO:    %10d02'
   ,@cLine03 = 'LOADKEY: %10d03'
   ,@cLine04 = 'ORDERKEY:%10d04'
   ,@cLine05 = 'CARTON ID:'
   ,@cLine06 = '%18d05'
   ,@cLine08 = '        CHK   /TOTAL'
   ,@cLine09 = 'SKU CHK:%05d06 /%05d07'
   ,@cLine10 = 'QTY CHK:%05d08 /%05d09'
   ,@cLine11 = 'STATUS:%10d10'
   ,@cLine14 = '%e'

 

-- update rdt.rdtscn with function id   
UPDATE RDT.RDTSCN SET FUNC = 904 WHERE SCN BETWEEN 2610 AND 2619