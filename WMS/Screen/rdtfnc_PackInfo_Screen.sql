IF NOT EXISTS( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 921 AND Lang_Code = 'ENG' AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('921', 'ENG', 'FNC', 'Pack Info', 'rdtfnc_PackInfo', '0')

-- 3030 = DropID/LabelNo/OrderKey screen 
DELETE rdt.RDTScn WHERE Scn = 3030 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3030, 'ENG', 
   @cLine01 = 'DROPID:',
   @cLine02 = '%20i01', 
   @cLine03 = '', 
   @cLine04 = 'OR',
   @cLine05 = '', 
   @cLine06 = 'LABELNO:',   
   @cLine07 = '%20i02',   
   @cLine08 = '', 
   @cLine09 = 'OR',
   @cLine10 = '', 
   @cLine11 = 'ORDERKEY: %10i03',
   @cLine12 = 'CARTONNO: %05i04',    
   @cLine14 = '%e', 
   @nFunc = 921

-- 3031 = Capture info screen
DELETE rdt.RDTScn WHERE Scn = 3031 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3031, 'ENG', 
   @cLine01 = '%20d01',   
   @cLine02 = 'PKSLIPNO: %10d02',  
   @cLine03 = 'CARTONNO: %04d03',  
   @cLine04 = 'SKU-QTY:  %10d04',
   @cLine05 = 'SCAN/TOTAL: %10d05',
   @cLine06 = '',
   @cLine07 = 'CTN TYPE: %10i06', 
   @cLine08 = 'CUBE:     %10i07', 
   @cLine09 = 'WEIGHT:   %10i08', 
   @cLine10 = 'L:        %10i09', 
   @cLine11 = 'W:        %10i10', 
   @cLine12 = 'H:        %10i11', 
   @cLine13 = '%20i12', 
   @cLine14 = '%e', 
   @nFunc = 921

-- 3032 = Print label screen
DELETE rdt.RDTScn WHERE Scn = 3032 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3032, 'ENG', 
   @cLine01 = '',   
   @cLine02 = 'PRINT LABEL?', 
   @cLine03 = '',   
   @cLine04 = '1 = YES',   
   @cLine05 = '2 = NO', 
   @cLine06 = '', 
   @cLine07 = 'OPTION: %01i01',   
   @cLine14 = '%e', 
   @nFunc = 921
