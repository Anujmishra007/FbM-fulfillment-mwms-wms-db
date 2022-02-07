--rdtfnc_VAP_Uncasing
--4420 - 4429

if not exists ( select 1 from rdt.rdtmsg (nolock) where message_id = 1152 and message_type = 'fnc')
begin
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('1152', 'ENG', 'FNC', 'BEGIN PRODUCTION', 'rdtfnc_VAP_Production', '9')
end

-- Screen 1
-- Scn = 4420 
DELETE rdt.RDTScn WHERE Scn = 4420 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4420, 'ENG', 
   @cLine01 = 'BEGIN PRODUCTION',
   @cLine03 = 'WORKSTATION ID:',
   @cLine04 = '%20i01',
   @cLine06 = 'JOB ID:',
   @cLine07 = '%10i02',
   @cLine09 = 'WORKORDER #:',
   @cLine10 = '%10i03',
   @cLine14 = '%e',
   @nFunc = 1152

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 4421 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4421, 'ENG', 
   @cLine01 = 'BEGIN PRODUCTION',
   @cLine02 = 'WRKSN ID: %10d01',
   @cLine03 = 'JOB ID: %10d02',
   @cLine04 = 'WO #: %10d03',
   @cLine05 = 'STEP:',
   @cLine06 = '%60d04',
   @cLine07 = '%60d05',
   @cLine08 = '%60d06',
   @cLine09 = 'QTY TOTAL: %07d07',
   @cLine10 = 'QTY COMPLETE: %07d08',
   @cLine11 = 'QTY REMAINING: %07d09',
   @cLine12 = 'IN-LOC : %10i10',
   @cLine13 = 'OUT-LOC: %10i11',
   @cLine14 = '%e'   
