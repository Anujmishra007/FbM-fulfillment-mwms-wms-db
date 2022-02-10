-- screen 2440 - 2449
-- screen 3920 - 3929

-- 2440 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2440 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2440, 'ENG',
    @cLine01 = '%20d05'
   ,@cLine03 = 'PICKTYPE: %10d04'
   ,@cLine04 = 'TO PALLET ID:'
   ,@cLine05 = '%18i09'
   ,@cLine14 = '%e'
   ,@nFunc = 1761
 
-- 2441 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2441 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2441, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine03 = 'PICKTYPE: %10d02'
   ,@cLine04 = 'TO PALLET ID:'
   ,@cLine05 = '%18d03'
   ,@cLine06 = 'FROM LOC:'
   ,@cLine07 = '%10d04'
   ,@cLine08 = '%10i05'
   ,@cLine14 = '%e'
   ,@nFunc = 1761

-- 2442 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2442 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2442, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine03 = 'PICKTYPE: %10d02'
   ,@cLine04 = 'TO PALLET ID:'
   ,@cLine05 = '%18d03'
   ,@cLine06 = 'FROM LOC:'
   ,@cLine07 = '%10d04'
   ,@cLine08 = 'FROM PALLET ID:'
   ,@cLine09 = '%18d05'
   ,@cLine10 = '%18i06'
   ,@cLine14 = '%e'
   ,@nFunc = 1761

-- 2443 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2443 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2443, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine03 = 'FROM PALLET ID:'
   ,@cLine04 = '%18d02'
   ,@cLine05 = 'SKU/UPC:'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = '%20i06'
   ,@cLine10 = 'UOM: %05d07'
   ,@cLine11 = 'QTY AVL: %05d10'
   ,@cLine12 = 'QTY: %05d08 / %05d09'
   ,@cLine14 = '%e'
   ,@nFunc = 1761

-- 2444 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2444 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2444, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine03 = 'FROM PALLET ID:'
   ,@cLine04 = '%18d02'
   ,@cLine05 = 'SKU/UPC:'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = 'UOM: %05d06'
   ,@cLine10 = 'QTY AVL: %05d10'
   ,@cLine11 = 'QTY: %05d07 / %05d08'
   ,@cLine12 = 'CASE ID:'
   ,@cLine13 = '%10i09'
   ,@cLine14 = '%e'
   ,@nFunc = 1761

-- 2445 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2445 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2445, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine03 = '1 = CONT NEXT TASK'
   ,@cLine04 = '9 = CLOSE PALLET'
   ,@cLine06 = 'Option: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1761

-- 2446 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2446 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2446, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine03 = '1 = SHORT PICK'
   ,@cLine04 = '9 = CLOSE PALLET'
   ,@cLine06 = 'Option: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1761

-- 2447 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2447 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2447, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine03 = 'FROM LOC:'
   ,@cLine04 = '%10d02'
   ,@cLine05 = 'TO PALLET ID:'
   ,@cLine06 = '%18d03'
   ,@cLine07 = 'TO LOC:'
   ,@cLine08 = '%10i04'
   ,@cLine14 = '%e'
   ,@nFunc = 1761

-- 2448 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2448 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2448, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine03 = 'Pallet is Closed and'
   ,@cLine04 = 'Moved'
   ,@cLine08 = 'ENTER = Next Task'
   ,@cLine09 = 'ESC   = Exit TM'
   ,@cLine14 = '%e'
   ,@nFunc = 1761

-- 2449 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2449 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2449, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine03 = 'FROM PALLET ID:'
   ,@cLine04 = '%18d02'
   ,@cLine05 = 'SKU/UPC:'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = 'UOM: %05d06'
   ,@cLine10 = 'QtyAvl : %05d09'
   ,@cLine11 = 'SUGGQTY: %05d07'
   ,@cLine12 = 'QTY: %11i08'
   ,@cLine13 = 'To Tote: %08i10' -- SOS315989
   ,@cLine14 = '%e'
   ,@nFunc = 1761 

-- 3920 = ?? screen
DELETE rdt.rdtscn Where Scn = 3920 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3920, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine03 = 'OLD TOTE ID:' 
   ,@cLine04 = '%20d02'
   ,@cLine05 = 'NEW TOTE ID:'
   ,@cLine06 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1761