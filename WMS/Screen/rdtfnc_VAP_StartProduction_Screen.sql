IF NOT EXISTS ( SELECT 1 FROM rdt.rdtmsg (nolock) where message_id = 1156 and message_type = 'FNC')
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1156, 'ENG', 'FNC', 'START LINE', 'rdtfnc_VAP_StartProduction', '9')
END

-- 4660 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4660 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4660, 'ENG',
    @cLine01 = 'WORKSTATION TIME'
   ,@cLine02 = 'START/END CAPTURE'
   ,@cLine04 = 'WORKSTATION: '
   ,@cLine05 = '%20i01'
   ,@cLine07 = 'JOB ID: '
   ,@cLine08 = '%10i02'
   ,@cLine10 = 'WORKORDER #: '
   ,@cLine11 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc   = 1156

-- 4661 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4661 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4661, 'ENG',
    @cLine01 = 'WORKSTATION:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'CUSTOMER WO#:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = 'SKU:'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = '%07d06  %05d07 %05d08'
   ,@cLine10 = 'EXP QTY: %05d09 %05d10'
   ,@cLine12 = 'CHANGE STATUS? (1/2/3)'
   ,@cLine13 = '1=ACT|2=END|3=STOP %01i11'
   ,@cLine14 = '%e'
   ,@nFunc   = 1156

-- 4662 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4662 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4662, 'ENG',
    @cLine01 = 'WORKSTATION:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'CUSTOMER WO#:'
   ,@cLine04 = '%20d02'
   ,@cLine06 = '%07d03  %05d04 %05d05'
   ,@cLine07 = 'EXP QTY: %05d06 %05d07'
   ,@cLine08 = 'CMP QTY: %05i08 %05i09'
   ,@cLine10 = '# OF USER %02i10'      
   ,@cLine12 = 'REASON: %10i11'
   ,@cLine14 = '%e'
   ,@nFunc   = 1156