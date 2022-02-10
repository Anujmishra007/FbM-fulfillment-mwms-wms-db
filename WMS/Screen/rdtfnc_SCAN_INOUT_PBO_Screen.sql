

IF NOT EXISTS (SELECT 1 FROM rdt.rdtmsg (NOLOCK) WHERE MESSAGE_ID='1652' and message_type='FNC')
  --insert function
  insert into rdt.rdtmsg (Message_ID,Lang_code,Message_Type,Message_Text,StoredProcName)          
  values(1652,'ENG','FNC','Scan IN and OUT PBO','rdtfnc_SCAN_INOUT_PBO')


-- Scan orderkey
DELETE rdt.RDTScn WHERE Scn = 5750 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5750, 'ENG',
   @cLine01 = 'WaveKey:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nfunc   =1652

-- 5611 = Capture Handover
DELETE rdt.RDTScn WHERE Scn = 5751 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5751, 'ENG'
   ,@cLine01 = 'WaveKey:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'User ID:'
   ,@cLine04 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1652