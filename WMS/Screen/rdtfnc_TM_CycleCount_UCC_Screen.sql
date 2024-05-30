/********************************************************
rdtfnc_TM_CycleCount_UCC_Screen
2930 - 2939
********************************************************/
IF NOT EXISTS ( SELECT 1 FROM rdt.rdtMsg WITH (NOLOCK) WHERE Message_ID = 1767 AND Message_Type = 'FNC')
BEGIN
   INSERT INTO rdt.rdtMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('1767', 'ENG', 'FNC', 'TM CycleCount UCC', 'rdtfnc_TM_CycleCount_UCC', '8')
END

DELETE rdt.RDTScn WHERE Scn = 2930 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2930, 'ENG',
   --@cLine01 = 'TM CC - UCC    %05d05',
   @cLine01 = 'TM CC - UCC    ',
   @cLine02 = '%20i01',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = '%20d04',
   @cLine06 = 'LOTTABLE 1/2/3/4/5:',
   @cLine07 = '1 %18d06',
   @cLine08 = '2 %18d07',
   @cLine09 = '3 %18d08',
   @cLine10 = '4 %18d09',
   @cLine11 = '5 %18d10',
   @cLine12 = 'OPT: %01i11        1=ADD',   --WMS-23249
   @cLine13 = '%20d15',  --WMS-16965
   @cLine14 = '%e'

DELETE rdt.RDTScn WHERE Scn = 2931 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2931, 'ENG',
   @cLine01 = 'TM CC - UCC',
   @cLine04 = '1 = END OF ID',
   @cLine05 = '2 = END OF LOC',
   @cLine06 = '3 = RECOUNT LOC',
   @cLine07 = '4 = CONTINUE',
   @cLine09 = 'OPTION %01i01',
   @cLine14 = '%e'


DELETE rdt.RDTScn WHERE Scn = 2932 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2932, 'ENG',
   @cLine01 = 'TM CC - UCC',
   @cLine03 = 'ALERT TO SUPERVISOR',
   @cLine04 = 'HAS BEEN SENT',
   @cLine14 = '%e'

-- WMS-23249
-- 2933. UCC - Add UCC
DELETE rdt.RDTScn WHERE Scn = 2933 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2933, 'ENG',
   @cLine01 = 'LOC: %10d01',
   @cLine02 = 'ID:',
   @cLine03 = '%18d02',
   @cLine05 = 'UCC:',
   @cLine06 = '%20i03',
   @cLine14 = '%e'

-- 2934. UCC - Add SKU & QTY
DELETE rdt.RDTScn WHERE Scn = 2934 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2934, 'ENG',
   @cLine01 = 'LOC: %10d01',
   @cLine02 = 'ID:',
   @cLine03 = '%18d02',
   @cLine05 = 'UCC:',
   @cLine06 = '%20d03',
   @cLine07 = 'SKU:      QTY: %05d07',
   @cLine08 = '%20d04',
   @cLine09 = '%20d05',
   @cLine10 = '%20d06',
   @cLine14 = '%e'

UPDATE RDT.RDTScn SET Func = 1767 WHERE Scn BETWEEN 2930 AND 2939
