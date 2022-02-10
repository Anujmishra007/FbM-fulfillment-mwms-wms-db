-- 920 = ID, STORER, SKU, FROMLOC
DELETE rdt.RDTScn WHERE Scn = 920 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 920, 'ENG' 
   ,@cLine01 = 'ID:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'STORER:'
   ,@cLine05 = '%15d02'
   ,@cLine06 = ''
   ,@cLine07 = 'SKU/UPC:'
   ,@cLine08 = '%32i03'
   ,@cLine09 = ''
   ,@cLine10 = 'FROM LOC:'
   ,@cLine11 = '%10i04'
--   ,@cLine10 = 'ENTER TO PROCEED'
   ,@cLine14 = '%e'
   ,@nFunc = 520
 
-- 921 = QTY
DELETE rdt.RDTScn WHERE Scn = 921 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 921, 'ENG' 
   ,@cLine01 = 'ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'STORER:'
   ,@cLine04 = '%15d02'
   ,@cLine05 = 'SKU:'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = '%08d06 %05d07 %05d08'
   ,@cLine10 = 'QTY PWY: %05d09 %05d10'
   ,@cLine11 = 'QTY ACT: %05i11 %05i12'
   ,@cLine12 = 'FROM LOC:'
   ,@cLine13 = '%10d13'
   ,@cLine14 = '%e'
   ,@nFunc = 520

-- 922 = Suggested LOC, TOLOC
DELETE rdt.RDTScn WHERE Scn = 922 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 922, 'ENG' 
   ,@cLine01 = 'SUGGESTED LOC:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'FINAL LOC:'
   ,@cLine05 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 520
   
-- 923 = Message screen
DELETE rdt.RDTScn WHERE Scn = 923 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 923, 'ENG' 
   ,@cLine02 = 'Successful putaway'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER to'
   ,@cLine06 = 'putaway next item'
   ,@cLine14 = '%e'
   ,@nFunc = 520