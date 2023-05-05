
IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 656)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (656, 'ENG', 'FNC', 'OFFSITE REPLEN', 'rdtfnc_NIKEOffSiteReplen', '9')
END

-- 6250 = Wave
DELETE rdt.RDTScn WHERE Scn = 6250 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6250, 'ENG', 
   @cLine01 = '',
   @cLine02 = 'WAVEKEY:  %10i01',
   @cLine03 = '', 
   @cLine04 = 'PICKZONE: %10i02', 
   @cLine05 = '', 
   @cLine06 = 'TO AREA:  %10i03', 
   @cLine14 = '%e', 
   @nFunc = 656

-- 6251 = Drop ID
DELETE rdt.RDTScn WHERE Scn = 6251 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6251, 'ENG', 
   @cLine01 = 'WAVEKEY:  %10d01', 
   @cLine02 = 'PICKZONE: %10d02', 
   @cLine03 = 'TO AREA:  %10d03', 
   @cLine04 = '', 
   @cLine05 = 'DROP ID:', 
   @cLine06 = '%18i04', 
   @cLine07 = '', 
   @cLine14 = '%e', 
   @nFunc = 656

-- 6252 = UCC
DELETE rdt.RDTScn WHERE Scn = 6252 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6252, 'ENG', 
   @cLine01 = 'DROP ID:', 
   @cLine02 = '%20d01', 
   @cLine03 = '', 
   @cLine04 = 'UCC:', 
   @cLine05 = '%20i02', 
   @cLine06 = '', 
   @cLine14 = '%e', 
   @nFunc = 656

-- 6253 = Close pallet
DELETE rdt.RDTScn WHERE Scn = 6253 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6253, 'ENG', 
   @cLine01 = 'WAVEKEY:  %10d01', 
   @cLine02 = 'PICKZONE: %10d02', 
   @cLine03 = 'TO AREA:  %10d03', 
   @cLine04 = '', 
   @cLine05 = 'CLOSE PALLET?', 
   @cLine06 = '', 
   @cLine07 = '1 = YES', 
   @cLine08 = '9 = NO', 
   @cLine09 = '', 
   @cLine10 = 'OPTION: %02i04', 
   @cLine11 = '', 
   @cLine12 = 'TOTAL UCC: %05d05', 
   @cLine14 = '%e'
