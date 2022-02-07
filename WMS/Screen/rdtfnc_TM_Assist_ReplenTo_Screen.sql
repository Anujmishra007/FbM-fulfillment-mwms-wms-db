IF NOT EXISTS( SELECT 1 FROM rdt.rdtmsg WITH (NOLOCK) WHERE Message_ID = 1836 AND Message_Type = 'FNC' AND Lang_Code = 'ENG')
   INSERT INTO rdt.rdtMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType) 
   VALUES (1836, 'ENG', 'FNC', 'TM Assist ReplenTo', 'rdtfnc_TM_Assist_ReplenTo', 0)
GO

IF NOT EXISTS( SELECT 1 FROM rdt.rdtTaskManagerConfig WITH (NOLOCK) WHERE TaskType = 'ASTRPT' AND Function_ID = 1836)
   INSERT INTO rdt.rdtTaskManagerConfig (TaskType, TaskDesc, Function_ID, Step) 
   VALUES ('ASTRPT', 'TM Assist ReplenTo', 1836, 0)
GO

-- 5560 = Final LOC screen
DELETE rdt.RDTScn WHERE Scn = 5560 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5560, 'ENG'
   ,@cLine01 = 'TM Replen To  ASTRPT'
   ,@cLine02 = ''
   ,@cLine03 = 'CASE ID:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = ''
   ,@cLine06 = 'SUGGESTED LOC: '
   ,@cLine07 = '%10d02'       
   ,@cLine08 = '%10i03'    --(yeekung02)
   ,@cLine09 = ''  
   ,@cLine10 = 'FINAL LOC: '  
   ,@cLine11 = '%10d04'  --(yeekung02)
   ,@cLine12 = ''
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1836

-- 5561 = next task screen
DELETE rdt.RDTScn WHERE Scn = 5561 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5561, 'ENG'
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
   ,@nFunc = 1836

-- WMS-15659
-- 5562 = Case ID screen
DELETE rdt.RDTScn WHERE Scn = 5562 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5562, 'ENG'
   ,@cLine01 = 'TM Replen To  ASTRPT'
   ,@cLine02 = ''
   ,@cLine03 = 'CASE ID:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = '%20i02'
   ,@cLine07 = 'SUGGESTED LOC:'  
   ,@cLine08 = '%10d03'  
   ,@cLine10 = 'FINAL LOC:'  
   ,@cLine11 = '%10d04'  
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1836

-- 5563 = SKU/Qty screen
DELETE rdt.RDTScn WHERE Scn = 5563 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5563, 'ENG'
   ,@cLine01 = 'TM Replen To  ASTRPT'
   ,@cLine02 = ''
   ,@cLine03 = 'SKU: '  
   ,@cLine04 = '%20d01'  
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20i04'  
   ,@cLine08 = 'REPLEN QTY: %05d05' -- (james02)
   ,@cLine09 = 'QTY: %05i06'  
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1836
   