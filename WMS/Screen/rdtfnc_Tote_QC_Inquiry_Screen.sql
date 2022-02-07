-- 2560 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2560 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2560, 'ENG',
    @cLine01 = 'QC TOTE/CASE INQUIRY'
   ,@cLine03 = '1 = SCAN TOTE NO'
   ,@cLine05 = '9 = SCAN CASE ID'
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1646
 
-- 2561 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2561 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2561, 'ENG',
    @cLine01 = 'QC TOTE/CASE INQUIRY'
   ,@cLine03 = 'TOTE NO/CASE ID:'
   ,@cLine04 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1646

-- 2562 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2562 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2562, 'ENG',
    @cLine01 = 'QC TOTE/CASE INQUIRY'
   ,@cLine02 = 'TYPE:%07d09'
   ,@cLine03 = 'TOTE/CASE ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'PRINTED : %01d02'
   ,@cLine06 = 'SHIPPED : %01d03'
   ,@cLine07 = 'BY      : %18d04'
   ,@cLine08 = ''
   ,@cLine09 = 'LAST  ZN: %05d05'
   ,@cLine10 = 'NEXT  ZN: %05d06'
   ,@cLine11 = 'FINAL ZN: %05d07'
   ,@cLine12 = 'TM RSN  : %20d08'
   ,@cLine13 = '<ENTER> NEXT SCRN'
   ,@cLine14 = '%e'
   ,@nFunc = 1646
 
-- 2563 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2563 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2563, 'ENG',
    @cLine01 = '%07d01    REC:%02d02'
   ,@cLine02 = 'ORDER : %10d03'
   ,@cLine03 = 'PK/ORD: %03d05 / %03d04'
   ,@cLine04 = 'SORTED: %03d14'
   ,@cLine05 = 'TM RSN: %02d06 SP Qty:%02d07'
   ,@cLine06 = '           REC:%05d08'
   ,@cLine07 = '%20d09'
   ,@cLine08 = 'LOC     :%10d10'
   ,@cLine09 = 'SOH QTY :%05d11'
   ,@cLine10 = 'OTH LOCS:%03d12'
   ,@cLine11 = '<1> ALT LOCS'
   ,@cLine12 = '<9> RESOLVE SP'
   ,@cLine13 = '<ENTER> NEXT      %01i13'
   ,@cLine14 = '%e'
   ,@nFunc = 1646
 
-- 2564 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2564 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2564, 'ENG',
    @cLine01 = 'QC TOTE/CASE INQUIRY'
   ,@cLine03 = 'TOTE: %10d07'
   ,@cLine04 = '%08i01'
   ,@cLine05 = 'LOC : %10d08'
   ,@cLine06 = '%10i02'
   ,@cLine07 = 'SKU'
   ,@cLine08 = '%20d03'
   ,@cLine09 = '%20i04'
   ,@cLine10 = '%05d05'
   ,@cLine11 = '<1> CONFIRM PICK'
   ,@cLine12 = '<5> ALT LOCS'
   ,@cLine13 = '<9> CONFIRM SP     %01i06'
   ,@cLine14 = '%e'
   ,@nFunc = 1646
 
-- 2565 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2565 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2565, 'ENG',
    @cLine01 = 'QC TOTE/CASE INQUIRY'
   ,@cLine03 = 'Product Successfully'
   ,@cLine04 = 'Picked'
   ,@cLine06 = 'Press ENTER To'
   ,@cLine07 = 'Continue With Next'
   ,@cLine08 = 'Tote/Case'
   ,@cLine14 = '%e'
   ,@nFunc = 1646
 
-- 2566 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2566 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2566, 'ENG',
    @cLine01 = 'QC TOTE/CASE INQUIRY'
   ,@cLine03 = 'New Tote/Case'
   ,@cLine04 = 'Scanned'
   ,@cLine06 = 'Press ENTER To'
   ,@cLine07 = 'Continue'
   ,@cLine08 = 'or'
   ,@cLine09 = 'Press ESC To'
   ,@cLine10 = 'Go Back'
   ,@cLine14 = '%e'
   ,@nFunc = 1646
 
-- 2567 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2567 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2567, 'ENG',
    @cLine01 = 'QC TOTE/CASE INQUIRY'
   ,@cLine03 = 'Confirm Short Pick'
   ,@cLine05 = 'SKU'
   ,@cLine06 = '%20d01'
   ,@cLine07 = 'Short Pick Qty:%05d02'
   ,@cLine09 = 'Press ESC To Go Back'
   ,@cLine10 = 'Or'
   ,@cLine11 = 'Confirm Short Pick'
   ,@cLine13 = 'Opt 9 %01i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1646
 
-- 2568 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2568 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2568, 'ENG',
    @cLine01 = 'SKU:        %20d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = 'LOC: %10d05'
   ,@cLine06 = 'ID: %18d06'
   ,@cLine07 = '         %11d07'
   ,@cLine08 = 'QTY TTL: %11d08'
   ,@cLine09 = 'QTY HLD: %11d09'
   ,@cLine10 = 'QTY ALC: %11d10'
   ,@cLine11 = 'QTY PCK: %11d11'
   ,@cLine12 = 'QTY RPL: %11d12'
   ,@cLine13 = 'QTY AVL: %11d13'
   ,@cLine14 = '%e'
   ,@nFunc = 1646
 
-- 2569 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2569 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2569, 'ENG',
    @cLine01 = 'Lottable:'
   ,@cLine02 = '1 %18d01'
   ,@cLine03 = '2 %18d02'
   ,@cLine04 = '3 %18d03'
   ,@cLine05 = '4 %16d04'
   ,@cLine06 = '5 %16d05'
   ,@cLine14 = '%e'
   ,@nFunc = 1646
 
-- 2570 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2570 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2570, 'ENG',
    @cLine01 = 'QC TOTE/CASE INQUIRY'
   ,@cLine03 = 'Product Successfully'
   ,@cLine04 = 'Short Picked'
   ,@cLine06 = 'Press ENTER To'
   ,@cLine07 = 'Continue With Next'
   ,@cLine08 = 'Tote/Case'
   ,@cLine14 = '%e'
   ,@nFunc = 1646
 
-- 2571 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2571 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2571, 'ENG',
    @cLine01 = '%07d01     REC:%02d02'
   ,@cLine03 = 'CASE    : %10d03'
   ,@cLine04 = 'BY      : %18d04'
   ,@cLine05 = 'LAST  ZN: %05d05'
   ,@cLine06 = 'NEXT  ZN: %05d06'
   ,@cLine07 = 'FINAL ZN: %05d07'
   ,@cLine08 = 'LOC     : %10d08'
   ,@cLine09 = 'PA QTY  : %05d09'
   ,@cLine14 = '%e'
   ,@nFunc = 1646