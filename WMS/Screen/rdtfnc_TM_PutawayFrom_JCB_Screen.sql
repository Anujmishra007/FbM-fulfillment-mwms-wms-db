--FCR-3954
DELETE RDT.RDTMsg WHERE Message_ID = 1871 AND Lang_Code = 'ENG' AND Message_Type = 'FNC'
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1871, 'ENG', 'FNC', 'TM Putaway From JCB', 'rdtfnc_TM_PutawayFrom_JCB', '0')

-- 6590  = MHE screen
DELETE rdt.RDTScn WHERE Scn = 6590 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6590, 'ENG'
   ,@cLine01 = 'TM PUTAWAY FROM  PAF'
   ,@cLine02 = ''
   ,@cLine03 = 'Current MHE:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = ''
   ,@cLine06 = 'Provide New MHE:'
   ,@cLine07 = '%10i02'
   ,@cLine13 = '%20d15' 
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["3","4"],"3":["6","7"]}'
   ,@nFunc = 1871

-- 6591  = Area screen
DELETE rdt.RDTScn WHERE Scn = 6591 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6591, 'ENG'
   ,@cLine01 = 'TM PUTAWAY FROM  PAF'
   ,@cLine02 = ''
   ,@cLine03 = 'Area:'
   ,@cLine04 = '%20i01'
   ,@cLine05 = ''
   ,@cLine13 = '%20d15' 
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["3","4"]}'
   ,@nFunc = 1871

-- 6592  = ID screen
DELETE rdt.RDTScn WHERE Scn = 6592 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6592, 'ENG'
   ,@cLine01 = 'TM PUTAWAY FROM  PAF'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM LOC: %10d01'
   ,@cLine04 = ''
   ,@cLine05 = 'ID: '
   ,@cLine06 = '%18d02'
   ,@cLine07 = '%18i03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["3"],"2":["5","6","7"]}'
   ,@nFunc = 1871

-- 6593  = TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 6593 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6593, 'ENG',
    @cLine01 = 'TM PUTAWAY FROM  PAF'
   ,@cLine02 = 'ID: '
   ,@cLine03 = '%18d01'
   ,@cLine04 = 'TO LOC:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20i03'
   ,@cLine07 = 'SUGGESTED LOC:'
   ,@cLine08 = '%10d04'
   ,@cLine09 = '%10d05'
   ,@cLine10 = '%10d06'
   ,@cLine11 = '%10d07'
   ,@cLine12 = '%10d08'
   ,@cLine13 = '%20d15'    -- WMS-11394 ExtendedInfoSP
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["2","3"],"2":["4","5","6"],"3":["7","8","9","10","11","12"],"4":["13"]}'
   ,@nFunc = 1871

-- 6594  = Msg screen
DELETE rdt.RDTScn WHERE Scn = 6594 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6594, 'ENG'
   ,@cLine01 = 'TM PUTAWAY FROM  PAF'
   ,@cLine02 = ''
   ,@cLine03 = 'SUCCESSFUL PUTAWAY'
   ,@cLine04 = ''
   ,@cLine06 = 'ENTER = Next Task'
   ,@cLine07 = 'ESC   = Back to TM'
   ,@cLine14 = '%e'
   ,@nFunc = 1871

-- 6595  = Reason Code screen
DELETE rdt.RDTScn WHERE Scn = 6595 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6595, 'ENG',
    @cLine01 = 'TASK MANAGER'
   ,@cLine03 = 'REASON CODE: '
   ,@cLine04 = '%10i01'
   ,@cLine14 = '%e'
