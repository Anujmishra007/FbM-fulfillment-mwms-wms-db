--rdtfnc_UCC_SortAndMove
-- 5030 - 5039


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('624', 'ENG', 'FNC', 'UCC Sort And Move', 'rdtfnc_UCC_SortAndMove', '0')


DELETE rdt.RDTScn WHERE Scn = 5030 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5030, 'ENG', 
   @cLine01 = 'UCC SORT AND MOVE', 
   @cLine03 = 'UCC NO:', 
   @cLine04 = '%20i01', 
   @cLine14 = '%e'

-- 809 = Move from
DELETE rdt.RDTScn WHERE Scn = 5031 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5031, 'ENG', 
   @cLine01 = 'UCC SORT AND MOVE', 
   @cLine02 = '', 
   @cLine03 = '%20d01', 
   @cLine04 = '%20d02', 
   @cLine06 = 'TO ID:', 
   @cLine07 = '%18i03', 
   @cLine09 = 'TO LOC:', 
   @cLine10 = '%10i04', 
   @cLine14 = '%e'

-- 810 = Message
DELETE rdt.RDTScn WHERE Scn = 5032 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5032, 'ENG', 
   @cLine01 = '', 
   @cLine02 = 'UCC successfully', 
   @cLine03 = 'moved', 
   @cLine04 = '', 
   @cLine05 = 'Press ENTER or ESC', 
   @cLine06 = 'to continue', 
   @cLine14 = '%e'

      
UPDATE RDT.RDTScn SET Func = 624 WHERE Scn Between 5030 AND 5039
UPDATE RDT.RDTScnDetail SET Func = 624 WHERE Scn Between 5030 AND 5039 