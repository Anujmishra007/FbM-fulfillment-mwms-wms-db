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