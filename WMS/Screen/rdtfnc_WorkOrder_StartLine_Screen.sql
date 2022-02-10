IF NOT EXISTS ( SELECT 1 FROM rdt.rdtmsg (nolock) where message_id = 1150 and message_type = 'FNC')
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1150, 'ENG', 'FNC', 'START LINE', 'rdtfnc_WorkOrder_StartLine', '9')
END

-- 4360 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4360 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4360, 'ENG',
    @cLine01 = 'WORKSTATION TIME'
   ,@cLine02 = 'START/END CAPTURE'
   ,@cLine04 = 'WORKSTATION: '
   ,@cLine05 = '%20i01'
   ,@cLine07 = 'JOB ID: '
   ,@cLine08 = '%10i02'
   ,@cLine10 = 'WORKORDER #: '
   ,@cLine11 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc   = 1150

-- 4361 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4361 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4361, 'ENG',
    @cLine01 = 'WORKSTATION:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'ASSIGNED: %05d02'
   ,@cLine04 = 'STATUS: %10d03'
   ,@cLine05 = 'REASON:  %10d04'
   ,@cLine06 = 'SUB RSN: %10d05'
   ,@cLine07 = 'START TIME:'
   ,@cLine08 = '%20d06'
   ,@cLine09 = 'END TIME:'
   ,@cLine10 = '%20d07'
   ,@cLine11 = 'CHANGE STATUS? (1/2)'
   ,@cLine12 = '1=ACTIVE ; 2=DOWN %01i08'
   ,@cLine14 = '%e'
   ,@nFunc   = 1150

-- 4362 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4362 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4362, 'ENG',
    @cLine01 = 'WORKSTATION:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'ASSIGNED: %05d02'
   ,@cLine04 = 'STATUS: %10d03'
   ,@cLine05 = 'NO # USER: %05i04'
   ,@cLine06 = 'REASON:'
   ,@cLine07 = '%10i05'   
   ,@cLine08 = 'SUB RSN:'
   ,@cLine09 = '%10i06'   
   ,@cLine10 = 'START TIME:'
   ,@cLine11 = '%20i07'
   ,@cLine12 = 'END TIME:'
   ,@cLine13 = '%20i08'
   ,@cLine14 = '%e'
   ,@nFunc   = 1150

--update rdt.rdtscndetail set coltype = 'ddlb', colvalue = '', collookupview = 'isp_GetWorkStationStatus01' where scn = 4362 and fieldno = '03'
update rdt.rdtscndetail set coltype = 'ddlb', colvalue = '', collookupview = 'isp_GetWorkStationRsn01' where scn = 4362 and fieldno = '05'
update rdt.rdtscndetail set coltype = 'ddlb', colvalue = '', collookupview = 'isp_GetWorkStationSubRsn01' where scn = 4362 and fieldno = '06'
