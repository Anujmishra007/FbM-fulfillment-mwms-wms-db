-- 5650 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5650 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5650, 'ENG'
   ,@cLine01 = N'PSNO: %10i01'
   ,@cLine14 = N'%e'

-- 5651 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5651 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5651, 'ENG'
   ,@cLine01 = N'PSNO: %10d01'
   ,@cLine02 = N''
   ,@cLine03 = N'PKZONE: %10i02'
   ,@cLine14 = N'%e'
 
-- 5652 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5652 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5652, 'ENG'
   ,@cLine01 = N'DROPID:'
   ,@cLine02 = N'%20i03'
   ,@cLine14 = N'%e'
 
-- 5653 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5653 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5653, 'ENG'
   ,@cLine01 = N'LOC: %10d01'
   ,@cLine02 = N'%20d02'
   ,@cLine03 = N'%20d03'
   ,@cLine04 = N'%20d04'
   ,@cLine05 = N'SKU/UPC:'
   ,@cLine06 = N'%30i05'
   ,@cLine07 = N'%20d08'
   ,@cLine08 = N'%20d09'
   ,@cLine09 = N'%20d10'
   ,@cLine10 = N'%20d11'
   ,@cLine11 = N'PICK QTY: %05d06'
   ,@cLine12 = N'ACT  QTY: %05i07'
   ,@cLine13 = N'%20d12'
   ,@cLine14 = N'%e'
 
-- 5654 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5654 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5654, 'ENG'
   ,@cLine01 = N''
   ,@cLine02 = N'No more task in LOC'
   ,@cLine04 = N''
   ,@cLine05 = N'Press ENTER or ESC'
   ,@cLine06 = N'to continue'
   ,@cLine14 = N'%e'
 
-- 5655 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5655 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5655, 'ENG'
   ,@cLine01 = N''
   ,@cLine02 = N'CONFIRM SHORT PICK?'
   ,@cLine03 = N''
   ,@cLine04 = N'1 = YES'
   ,@cLine05 = N'2 = NO'
   ,@cLine06 = N'3 = CLOSE TOTE'
   ,@cLine08 = N'OPTION: %01i01'
   ,@cLine14 = N'%e'
 
-- 5656 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5656 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5656, 'ENG'
   ,@cLine01 = N''
   ,@cLine02 = N'SKIP LOC?'
   ,@cLine03 = N''
   ,@cLine04 = N'1 = YES'
   ,@cLine05 = N'2 = NO'
   ,@cLine06 = N''
   ,@cLine07 = N'OPTION: %01i01'
   ,@cLine14 = N'%e'
 
-- 5657 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5657 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5657, 'ENG'
   ,@cLine01 = N'LOC: %10d01'
   ,@cLine02 = N'LOC: %10i02'
   ,@cLine14 = N'%e'
 
-- 5658 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5658 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5658, 'ENG'
   ,@cLine01 = N''
   ,@cLine02 = N'ABORT PICKING?'
   ,@cLine03 = N''
   ,@cLine04 = N'1 = YES'
   ,@cLine05 = N'2 = NO'
   ,@cLine06 = N''
   ,@cLine07 = N'OPTION: %01i01'
   ,@cLine14 = N'%e'
 
