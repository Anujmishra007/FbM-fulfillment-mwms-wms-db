
DELETE RDT.RDTMsg WHERE Message_ID = 1863 AND Lang_Code = 'ENG' AND Message_Type = 'FNC'
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1863, 'ENG', 'FNC', 'CARTON TO MBOL', 'rdtfnc_CartonToMBOL', '9')

-- 6240 = MBOL screen
DELETE rdt.RDTScn WHERE Scn = 6240 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6240, 'ENG'
   ,@cLine01 = 'MBOLKEY:'
   ,@cLine02 = '%10i01'
   ,@cLine03 = ''
   ,@cLine04 = 'REFNO:'
   ,@cLine05 = '%20i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"]}'
   ,@nFunc = 1863

-- 6241 = Capture info screen
DELETE rdt.RDTScn WHERE Scn = 6241 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6241, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%20i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20i08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%20i10'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"],"4":["7","8"],"5":["9","10"]}'
   ,@nFunc = 1863   

-- 6242 = Carton ID screen
DELETE rdt.RDTScn WHERE Scn = 6242 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6242, 'ENG'
   ,@cLine01 = 'MBOLKEY:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'CARTON ID:'
   ,@cLine05 = '%20i02'
   ,@cLine06 = ''
   ,@cLine07 = 'SCANNED: %05d03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"],"3":["7"]}'
   ,@nFunc = 1863

-- 6243 = Close MBOL screen
DELETE rdt.RDTScn WHERE Scn = 6243 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6243, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'MBOLKEY: %10d01'
   ,@cLine03 = 'CLOSE MBOL?'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %02i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1863

-- 6244 = Pack info screen
DELETE rdt.RDTScn WHERE Scn = 6244 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6244, 'ENG'
   ,@cLine01 = 'CARTON: %10i01^DT:INT'
   ,@cLine02 = 'WEIGHT: %10i02^DT:INT'
   ,@cLine03 = 'CUBE:   %10i03^DT:INT'
   ,@cLine04 = 'REF NO:'
   ,@cLine05 = '%20i04'
   ,@cLine06 = 'LENGTH: %10i05^DT:INT'  -- WMS-15989
   ,@cLine07 = 'WIDTH:  %10i06^DT:INT'  -- WMS-15989
   ,@cLine08 = 'HEIGHT: %10i07^DT:INT'  -- WMS-15989
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3"],"3":["4","5"],"4":["6","7","8"]}'
   ,@nFunc = 1863