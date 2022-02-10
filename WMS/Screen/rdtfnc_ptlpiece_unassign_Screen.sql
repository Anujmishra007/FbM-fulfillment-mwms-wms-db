
IF NOT EXISTS (SELECT 1 FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID=1851 AND Message_Type='FNC')
BEGIN
   insert into rdt.rdtmsg (message_id,lang_code,message_type,message_text,storedprocname)
   values('1851','eng','FNC','Unassign PTL Piece','rdtfnc_ptlpiece_unassign')
END

-- 5870 = ?? screen
-- PTLStation, method
DELETE rdt.RDTScn WHERE Scn = 5870 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5870, 'ENG'
   ,@cLine01 = 'PTL STATIONS:'
   ,@cLine02 = '%10i01'
   ,@cLine07 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1851
 