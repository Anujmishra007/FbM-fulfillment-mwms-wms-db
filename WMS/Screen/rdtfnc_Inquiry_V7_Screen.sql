--rdtfnc_Inquiry_V7
-- 5140 - 5149

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 628)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('628', 'ENG', 'FNC', 'Inquiry V7', 'rdtfnc_Inquiry_V7', '0')
END

-- 5140 = LOC, ID screen
DELETE rdt.RDTScn WHERE Scn = 5140 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5140, 'ENG',
    @cLine01 = 'INQUIRY'
   ,@cLine02 = ''
   ,@cLine03 = 'LOC:'
   ,@cLine04 = '%10i01'
   ,@cLine05 = 'OR'
   ,@cLine06 = ''
   ,@cLine07 = 'ID:'
   ,@cLine08 = '%20i02'
   ,@cLine09 = 'OR'
   ,@cLine10 = ''
   ,@cLine11 = 'SKU:'
   ,@cLine12 = '%30i03'
   ,@cLine13 = ''
   ,@cLine14 = '%e'
 
-- 5141 = Result screen
DELETE rdt.RDTScn WHERE Scn = 5141 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5141, 'ENG',
    @cLine01 = 'SKU:        %20d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = 'LOC: %10d05'
   ,@cLine06 = 'ID: %18d06'
   ,@cLine07 = '         %11d07'
   ,@cLine08 = 'QTY TTL: %11d08'
   ,@cLine09 = 'QTY ALC: %11d09'
   ,@cLine10 = 'QTY PCK: %11d10'
   ,@cLine11 = 'QTY RPL: %11d11'
   ,@cLine12 = 'QTY PMV: %11d12' --WMS10415 Remove qty hold, add pending move in
   ,@cLine13 = 'QTY AVL: %11d13'
   ,@cLine14 = '%e'
 
-- 5142 = Result screen
DELETE rdt.RDTScn WHERE Scn = 5142 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5142, 'ENG',
    @cLine01 = 'Lottable:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20d08'
   ,@cLine10 = '%20d09'
   ,@cLine11 = '%20d10'
   ,@cLine14 = '%e'
 
