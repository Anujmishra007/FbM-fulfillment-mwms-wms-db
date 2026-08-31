-- IF NOT EXISTS( SELECT 1 FROM rdt.rdtTaskManagerConfig WITH (NOLOCK) WHERE TaskType = 'ASTTPA' AND Function_ID = 1876)
-- Insert into rdt.rdtTaskManagerConfig (TaskType, TaskDesc, Function_ID, Step)
-- Values ( 'ASTTPA', 'Trolley putaway', 1876 , '1' )

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG WITH (NOLOCK) WHERE MESSAGE_ID = 1876 AND LANG_CODE = 'ENG' AND MESSAGE_TYPE = 'FNC')
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1876', 'ENG', 'FNC', 'TM - Trolley ReplenTo', 'rdtfnc_TM_Trolley_ReplenTo', '0')

-- 6780 = Trolley ID
DELETE rdt.RDTScn WHERE Scn = 6780 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6780, 'ENG',
    @cLine01 = 'Trolley ID'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine14 = '%e'
   ,@nFunc   = 1876

-- 6781 = Carton ID
DELETE rdt.RDTScn WHERE Scn = 6781 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6781, 'ENG'
   ,@cLine01 = 'TROLLEY: %10d01'
   ,@cLine02 = 'Loc: %10d02'
   ,@cLine03 = 'Position: %10d03'
   ,@cLine04 = 'Carton: %10d04'
   ,@cLine05 = ''
   ,@cLine06 = 'Carton: '
   ,@cLine07 = '%10i05'
   ,@cLine14 = '%e'
   ,@nFunc = 1876



-- 6782 = Reason Code
DELETE rdt.RDTScn WHERE Scn = 6782 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6782, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'REASON CODE:'
   ,@cLine03 = '%30i01'
   ,@cLine04 = ''
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1876


-- 6783 = To LOC
DELETE rdt.RDTScn WHERE Scn = 6783 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6783, 'ENG'
   ,@cLine01 = 'TROLLEY: %10d01'
   ,@cLine02 = 'Loc: %10d02'
   ,@cLine03 = 'Position: %10d03'
   ,@cLine04 = 'Carton: %10d04'
   ,@cLine05 = ''
   ,@cLine06 = 'Location:'
   ,@cLine07 = '%10i05'
   ,@cLine14 = '%e'
   ,@nFunc = 1876


-- 6784 = QC location
DELETE rdt.RDTScn WHERE Scn = 6784 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6784, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Move skipped cartons to QC location'
   ,@cLine03 = ''
   ,@cLine04 = 'Location:'
   ,@cLine05 = '%30i01'
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1876


-- 6785 = Message screen
DELETE rdt.RDTScn WHERE Scn = 6785 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6785, 'ENG'
   ,@cLine01 = ''
   ,@cLine03 = 'Cartons '
   ,@cLine04 = 'successfully moved'
   ,@cLine06 = 'ENTER =  NEW TROLLEY'
   ,@cLine07 = 'ESC   = EXIT TM'
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1876

