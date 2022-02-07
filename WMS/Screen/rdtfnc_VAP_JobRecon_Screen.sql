--rdtfnc_VAP_JobRecon
--4450 - 4459

if not exists ( select 1 from rdt.rdtmsg (nolock) where message_id = 1155 and message_type = 'fnc')
begin
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('1155', 'ENG', 'FNC', 'JOB RECON', 'rdtfnc_VAP_JobRecon', '9')
end

-- Screen 1
-- Scn = 4450 
DELETE rdt.RDTScn WHERE Scn = 4450 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4450, 'ENG', 
   @cLine01 = 'JOB RECON',
   @cLine03 = 'RECONCILIATION TYPE:',
   @cLine04 = '%20i01',
   @cLine14 = '%e',
   @nFunc = 1155

-- Screen 2
-- Scn = 4451 
DELETE rdt.RDTScn WHERE Scn = 4451 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4451, 'ENG', 
   @cLine01 = 'JOB RECON',
   @cLine03 = 'WORKORDER KEY:',
   @cLine04 = '%10i01',
   @cLine05 = 'JOB KEY:',
   @cLine06 = '%10i02',
   @cLine07 = 'JOB LINE NO:',
   @cLine08 = '%05i03',
   @cLine14 = '%e',
   @nFunc = 1155

-- Screen 3
-- Scn = 4452 
DELETE rdt.RDTScn WHERE Scn = 4452 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4452, 'ENG', 
   @cLine01 = 'JOB RECON',
   @cLine03 = 'WO#: %10d01 JOB ID: %10d02 JOB LINE #: %05d03',
   @cLine05 = 'SKU:',
   @cLine06 = '%20d04',
   @cLine07 = 'QTY:',
   @cLine08 = '%10i05',
   @cLine09 = 'REASON CODE:',
   @cLine10 = '%10i06',
   @cLine14 = '%e',
   @nFunc = 1155

update rdt.rdtscndetail set coltype = 'ddlb', colvalue = '', collookupview = 'isp_GetJobReconType01' where scn = 4450 and fieldno = '01'
update rdt.rdtscndetail set coltype = 'ddlb', colvalue = '', collookupview = 'isp_GetJobReconRsn01' where scn = 4452 and fieldno = '06'