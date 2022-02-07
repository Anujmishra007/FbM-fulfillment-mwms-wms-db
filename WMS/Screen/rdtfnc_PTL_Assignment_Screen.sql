--rdtfnc_PTL_OrderAssignment
-- 3720 - 3729

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('815', 'ENG', 'FNC', 'PTL Assignment', 'rdtfnc_PTL_Assignment', '0')

-- Screen 1
-- Scn = 3720 
DELETE rdt.RDTScn WHERE Scn = 3720 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3720, 'ENG', 
   @cLine01 = 'PTL - ASSIGNMENT',
   @cLine03 = 'CART ID:',
   @cLine04 = '%20i01',
   @cLine06 = 'OR',
   @cLine08 = 'PTS ZONE:',
   @cLine09 = '%10i02',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 3721 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3721, 'ENG', 
   @cLine01 = 'PTL - ASSIGNMENT',
   @cLine03 = '%20d01',
   @cLine04 = '%20d02',
   @cLine05 = 'LIGHT POSITION:',
   @cLine06 = '%10d05',
   @cLine07 = '%10i03',
   @cLine08 = 'TOTE ID:',
   @cLine09 = '%20i04',
   @cLine11 = 'ENTER BLANK TO',
   @cLine12 = 'CONFIRM ASSIGNMENT',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 3722 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3722, 'ENG', 
   @cLine01 = 'PTL - ASSIGNMENT',
   @cLine03 = '%20d01',
   @cLine04 = '%20d02',
   @cLine05 = '',
   @cLine06 = 'TTL TOTE ASSIGNED:',
   @cLine07 = '%05d03',
   @cLine08 = '',
   @cLine09 = 'CONFIRM ASSIGNMENT?',
   @cLine10 = '1 = YES | 9 = NO',
   @cLine11 = 'OPTIONS: %01i04',
   @cLine14 = '%e'
   
-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 3723 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3723, 'ENG', 
   @cLine01 = 'PTL - ASSIGNMENT',
   @cLine03 = '%20d01',
   @cLine04 = '%20d02',
   @cLine05 = '',
   @cLine06 = 'SUCCESSFULLY ASSIGN',
   @cLine07 = '',
   @cLine08 = 'ENTER or ESC',
   @cLine09 = 'to continue',
   @cLine14 = '%e'

-- Screen 5
DELETE rdt.RDTScn WHERE Scn = 3724 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3724, 'ENG', 
   @cLine01 = 'PTL - ASSIGNMENT',
   @cLine03 = '%20d01',
   @cLine04 = '%20d02',
   @cLine05 = 'LIGHT POSITION %05d03',
   @cLine06 = 'ASSIGNED TOTE ID:',
   @cLine07 = '%20d04',
   @cLine08 = 'NEW TOTE ID:',
   @cLine09 = '%20d06',
   @cLine11 = 'OVERWRITE?',
   @cLine12 = '1 = YES | 9 = NO',
   @cLine13 = 'OPTIONS: %01i05',
   @cLine14 = '%e'   
   
-- Screen 6
DELETE rdt.RDTScn WHERE Scn = 3725 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3725, 'ENG', 
   @cLine01 = 'PTL - ASSIGNMENT',
   @cLine03 = '%20d01',
   @cLine04 = '%20d02',
   @cLine05 = '',
   @cLine06 = 'WAVEKEY:',
   @cLine07 = '%10i03',
   @cLine14 = '%e'  

-- Screen 7 (Chee03)
DELETE rdt.RDTScn WHERE Scn = 3726 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3726, 'ENG', 
   @cLine01 = 'PTL - ASSIGNMENT',
   @cLine03 = 'RESET DEVICE?',
   @cLine04 = '1 = YES',
   @cLine06 = 'OPTIONS: %01i01',
   @cLine14 = '%e'  

UPDATE RDT.RDTScn SET Func = 815 WHERE Scn Between 3720 AND 3729 
UPDATE RDT.RDTScnDetail SET Func = 815 WHERE Scn Between 3720 AND 3729 