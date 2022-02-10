-- 2430 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2430 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2430, 'ENG',
    @cLine01 = 'PICKING        %03d09'
   ,@cLine03 = 'PICKTYPE: %10d04'
   ,@cLine04 = 'TOTE NO:'
   ,@cLine05 = '%08i05'
   ,@cLine14 = '%e'
   ,@nFunc   = 1760

-- 2431 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2431 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2431, 'ENG',
    @cLine01 = 'PICKING        %03d05'
   ,@cLine03 = 'PICKTYPE: %10d01'
   ,@cLine04 = 'TOTE NO:'
   ,@cLine05 = '%18d02'
   ,@cLine06 = 'FROM LOC'
   ,@cLine07 = '%10d03'
   ,@cLine08 = '%10i04'
   ,@cLine14 = '%e'
   ,@nFunc   = 1760

-- 2432 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2432 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2432, 'ENG',
    @cLine01 = 'PICKING        %10d10'
   ,@cLine03 = 'TOTE NO:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'FROMLOC:'
   ,@cLine06 = '%10d09'
   ,@cLine07 = 'SKU/UPC'
   ,@cLine08 = '%20d02'
   ,@cLine09 = '%20d03'
   ,@cLine10 = '%20d04'
   ,@cLine11 = '%20i05'
   ,@cLine12 = '%10d06'
   ,@cLine13 = '%05d07 / %05d08'
   ,@cLine14 = '%e'
   ,@nFunc   = 1760

-- 2433 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2433 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2433, 'ENG',
    @cLine01 = 'PICKING        %03d02'
   ,@cLine03 = '1 = SHORT PICK'
   ,@cLine04 = '5 = ALT LOCS' -- SOS326618
   ,@cLine05 = '9 = CLOSE TOTE'
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc   = 1760

-- 2434 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2434 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2434, 'ENG',
    @cLine01 = 'PICKING        %03d02'
   ,@cLine03 = 'Tote is Closed'
   ,@cLine05 = 'ENTER = Next Task'
   ,@cLine06 = 'ESC   = Exit TM'
   ,@cLine14 = '%e'
   ,@nFunc   = 1760

-- 2435 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2435 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2435, 'ENG',
    @cLine01 = 'PICKING        %03d01'
   ,@cLine03 = 'Order needs to be'
   ,@cLine04 = 'fulfilled by Other'
   ,@cLine05 = 'Pickers'
   ,@cLine07 = 'ENTER = Next Task'
   ,@cLine08 = 'ESC   = Exit TM'
   ,@cLine14 = '%e'
   ,@nFunc   = 1760

-- 2436 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2436 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2436, 'ENG',
    @cLine01 = 'PICKING        %03d06'
   ,@cLine03 = 'PICKTYPE: %10d04'
   ,@cLine04 = 'TOTE NO:'
   ,@cLine05 = '%18d03'
   ,@cLine06 = '%08i05'
   ,@cLine14 = '%e'
   ,@nFunc   = 1760

-- 2437 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2437 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2437, 'ENG',
    @cLine01 = 'PICKING        %03d02'
   ,@cLine03 = 'No More Task'
   ,@cLine04 = 'For This Tote'
   ,@cLine05 = '%20d01'
   ,@cLine07 = 'ENTER = Next Task'
   ,@cLine08 = 'ESC   = Exit TM'
   ,@cLine14 = '%e'
   ,@nFunc   = 1760

-- 2438 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2438 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2438, 'ENG',
    @cLine01 = 'PICKING        %03d01'
   ,@cLine04 = 'ENTER = Next Task'
   ,@cLine05 = 'ESC   = Exit TM'
   ,@cLine14 = '%e'
   ,@nFunc   = 1760

-- 2439 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2439 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2439, 'ENG',
    @cLine01 = 'PICKING        %03d03'
   ,@cLine03 = 'Different Tote?'
   ,@cLine04 = 'Old Tote: %08d01'
   ,@cLine05 = 'New Tote: %08d02'
   ,@cLine08 = 'ENTER = Confirm'
   ,@cLine09 = 'ESC   = Cancel'
   ,@cLine14 = '%e'
   ,@nFunc   = 1760 

-- 2790 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2790 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2790, 'ENG',
    @cLine01 = 'PICKING        %03d09'
   ,@cLine03 = 'TOTE : %08d01'
   ,@cLine04 = 'SAME WITH '
   ,@cLine05 = 'SKU:   %08d02'
   ,@cLine07 = 'PROCEED ??'
   ,@cLine08 = '1 = YES'
   ,@cLine09 = '9 = NO'
   ,@cLine10 = 'Option: %01i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1760 

-- 2791 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2791 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2791, 'ENG',
    @cLine01 = 'PICKING        %03d09'
   ,@cLine03 = 'TOTE: %08d01'
   ,@cLine04 = 'CUR LOC: %10d02'
   ,@cLine05 = 'ALT LOC: %10d03'
   ,@cLine06 = 'AVAIL QTY: %05d04'
   ,@cLine08 = 'CONFIRM LOC: '
   ,@cLine09 = '%10i05'
   ,@cLine14 = '%e'
   ,@nFunc = 1760 

