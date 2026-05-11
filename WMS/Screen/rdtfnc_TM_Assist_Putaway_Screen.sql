IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1815)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1815, 'ENG', 'FNC', 'TM Assist Putaway', 'rdtfnc_TM_Assist_Putaway', '7')
END

-- 4070 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4070 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4070, 'ENG'
   ,@cLine01 = 'TM PUTAWAY     ASTPA'
   ,@cLine02 = ''
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = ''
   ,@cLine06 = 'SUGGESTED LOC: '
   ,@cLine07 = '%10d02'
   ,@cLine08 = ''
   ,@cLine09 = 'FINAL LOC: '
   ,@cLine10 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1815
 
-- 4071 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4071 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4071, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'LOC NOT MATCH.'
   ,@cLine03 = 'PROCEED?'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1815
   
-- 4072 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4072 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4072, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CURRENT TASK COMPLETE'
   ,@cLine03 = ''
   ,@cLine04 = 'NEXT TASK TYPE:'
   ,@cLine05 = '%10d01'
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = 'ENTER = NEXT TASK'
   ,@cLine09 = 'ESC   = EXIT'
   ,@cLine14 = '%e'
   ,@nFunc = 1815
   
-- 4073 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4073 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4073, 'ENG'
   ,@cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%18d02'
   ,@cLine04 = ''
   ,@cLine05 = 'SKU/UPC:'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%60i04'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1815
   
-- 4074 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4074 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4074, 'ENG'
   ,@cLine01 = 'SKU:        PPK: %03d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20d06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20d08'
   ,@cLine09 = '%08d09 %05d10 %05d13'
   ,@cLine10 = 'QTY PWY: %05d11 %05d14'
   ,@cLine11 = 'QTY ACT: %05i12 %05i15'
   ,@cLine14 = '%e'
   ,@nFunc = 1815
   
-- 4075 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4075 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4075, 'ENG'
   ,@cLine01 = 'SUGGESTED LOC:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'SUGGESTED ID:'
   ,@cLine05 = '%18d02'
   ,@cLine06 = '%18i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1815
   
-- 4076 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4076 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4076, 'ENG'
   ,@cLine01 = 'SUGGESTED LOC:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'QTY AVAIL: %05d02'
   ,@cLine05 = 'QTY ALLOC: %05d03'
   ,@cLine06 = 'QTY MOVIN: %05d04'
   ,@cLine07 = ''
   ,@cLine08 = 'FINAL LOC:'
   ,@cLine09 = '%10i05'
   ,@cLine10 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1815
   
-- 4077 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4077 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4077, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'LOC NOT MATCH.'
   ,@cLine03 = 'PROCEED?'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1815
