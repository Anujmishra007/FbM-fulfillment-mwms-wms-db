IF NOT EXISTS (SELECT 1 FROM rdt.rdtmsg (NOLOCK) WHERE MESSAGE_ID='1842' and message_type='FNC')
  --insert function
  insert into rdt.rdtmsg (Message_ID,Lang_code,Message_Type,Message_Text,StoredProcName)          
  values(1842,'ENG','FNC','Replenishment BY SKU','rdtfnc_SKU_Replenishment')


-- Scan SKU
DELETE rdt.RDTScn WHERE Scn = 5760 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5760, 'ENG',
   @cLine01 = 'SKU:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nfunc   =1842

DELETE rdt.RDTScn WHERE Scn = 5761 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5761, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'From LOC:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = 'FROM ID:'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20i04'
   ,@cLine14 = '%e'
   ,@nFunc = 1842

DELETE rdt.RDTScn WHERE Scn = 5762 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5762, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'From LOC:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = 'ID:'
   ,@cLine06 = '%20d04'
   ,@cLine08 = 'To LOC:'
   ,@cLine09 = '%20d05'
   ,@cLine10 = '%20i06'
   ,@cLine14 = '%e'
   ,@nFunc = 1842
