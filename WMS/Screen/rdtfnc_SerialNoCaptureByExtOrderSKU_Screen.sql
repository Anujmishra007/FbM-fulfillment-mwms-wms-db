
IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 878)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName)
   VALUES (878, 'ENG', 'FNC', 'Serial No Capture', 'rdtfnc_SerialNoCaptureByExtOrderSKU')
END

-- 4530 = Extern Order, SKU screen
DELETE rdt.RDTScn WHERE Scn = 4530 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4530, 'ENG',
    @cLine01 = 'EXT ORDER KEY:'
   ,@cLine02 = '%50i01'
   ,@cLine14 = '%e'
   --,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 878

-- 4531 = Extern Order, SKU screen
DELETE rdt.RDTScn WHERE Scn = 4531 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4531, 'ENG',
    @cLine01 = 'EXT ORDER KEY:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%30i02'
   ,@cLine14 = '%e'
   --,@cWebGroup = '{"1":["1","2"],"2":["4","5"]}'
   ,@nFunc = 878
   
-- 4532 = Serial no screen
DELETE rdt.RDTScn WHERE Scn = 4532 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4532, 'ENG',
    @cLine01 = 'EXT ORDER KEY:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'SKU:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = ''
   ,@cLine09 = 'SERIAL NO:'
   ,@cLine10 = '%30i05' --WMS -24364 Extend to 30 chars
   ,@cLine11 = ''
   ,@cLine12 = 'EXP QTY: %05d07'
   ,@cLine13 = 'ACT QTY: %05d08'
   ,@cLine14 = '%e'
   --,@cWebGroup = '{"1":["1","2"],"2":["4","5","6","7"],"3":["9","10"],"4":["12","13"]}'
   ,@nFunc = 878
  
-- 4533 = Wrong format screen
DELETE rdt.RDTScn WHERE Scn = 4533 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4533, 'ENG',
    @cLine01 = 'SERIAL NO:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = ''
   ,@cLine05 = 'INVALID SERIAL NO'
   ,@cLine06 = 'CONFIRM?'
   ,@cLine07 = ''
   ,@cLine08 = '1 = YES'
   ,@cLine09 = '9 = NO'
   ,@cLine10 = ''
   ,@cLine11 = 'OPTION: %02i03'
   ,@cLine14 = '%e'
   --,@cWebGroup = '{"1":["1","2","3"],"2":["5","6","7","8","9"],"3":["11"]}'
   ,@nFunc = 878
