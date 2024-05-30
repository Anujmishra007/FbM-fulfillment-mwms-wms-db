/********************************************************
rdtfnc_TM_CycleCount_ID_Screen
2950 - 2959
********************************************************/

IF NOT EXISTS ( SELECT 1 FROM rdt.rdtMsg WITH (NOLOCK) WHERE Message_ID = 1769 AND Message_Type = 'FNC')
BEGIN
   INSERT INTO rdt.rdtMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('1769', 'ENG', 'FNC', 'TM CycleCount ID', 'rdtfnc_TM_CycleCount_ID', '8')
END

-- 2950. Carton Count
DELETE rdt.RDTScn WHERE Scn = 2950 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2950, 'ENG',
   @cLine01 = 'ID'
  ,@cLine02 = '%18d01'
  ,@cLine03 = 'Carton Count %05i02'
  ,@cLine05 = 'PUT 0 FOR EMPTY LOC'
  ,@cLine14 = '%e'
  ,@nFunc = 1769
