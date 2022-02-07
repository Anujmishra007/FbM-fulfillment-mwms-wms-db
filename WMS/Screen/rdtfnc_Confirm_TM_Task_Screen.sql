--rdtfnc_Confirm_TM_Task
--5530-5539

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1822)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1822, 'ENG', 'FNC', 'CONFIRM TM TASK', 'rdtfnc_Confirm_TM_Task', '3')
END

-- 5530 = Task GroupKey screen
DELETE rdt.RDTScn WHERE Scn = 5530 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5530, 'ENG'
   ,@cLine01 = 'Task GroupKey:'
   ,@cLine02 = '%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1822

-- 5531 = Task GroupKey screen
DELETE rdt.RDTScn WHERE Scn = 5531 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5531, 'ENG'
   ,@cLine01 = 'Task Confirmed'
   ,@cLine02 = 'Sucessfully.'
   ,@cLine14 = '%e'
   ,@nFunc = 1822