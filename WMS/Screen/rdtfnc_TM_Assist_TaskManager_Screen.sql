IF NOT EXISTS( SELECT 1 FROM rdt.rdtmsg WITH (NOLOCK) WHERE Message_ID = 1814 AND Message_Type = 'FNC')
   INSERT INTO rdt.rdtMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType) 
   VALUES (1814, 'ENG', 'FNC', 'TM Assisted', 'rdtfnc_TM_Assist_TaskManager', 0)
GO

-- 4060 = ID screen
DELETE rdt.RDTScn WHERE Scn = 4060 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4060, 'ENG'
    ,@cLine01 = 'TASK MGR ASSISTED'
    ,@cLine02 = ''
    ,@cLine03 = 'PALLET ID:' 
    ,@cLine04 = '%18i01'
    ,@cLine05 = ''
    ,@cLine06 = 'OR'
    ,@cLine07 = ''
    ,@cLine08 = 'CASE ID:'
    ,@cLine09 = '%20i02'
    ,@cLine14 = '%e'
    ,@nFunc = 1814