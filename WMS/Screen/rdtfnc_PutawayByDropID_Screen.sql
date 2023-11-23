IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1742 AND Lang_Code = 'ENG' AND Message_Type = 'FNC')
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1742, 'ENG', 'FNC', 'Putaway Drop ID', 'rdtfnc_PutawayByDropID', '9')
END

-- 6300 = From ID screen
DELETE rdt.RDTScn WHERE Scn = 6300 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6300, 'ENG'
   ,@cLine01 = 'DROP ID:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1742

-- 6301 = Final LOC screen
DELETE rdt.RDTScn WHERE Scn = 6301 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6301, 'ENG'
   ,@cLine01 = 'DROP ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'SUGGESTED LOC: '
   ,@cLine05 = '%10d02' 
   ,@cLine06 = ''
   ,@cLine07 = 'TO LOC: '    
   ,@cLine08 = '%10i03'
   ,@cLine09 = ''
   ,@cLine10 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1742

-- 6302 = Confirm overwrite suggested loc
DELETE rdt.RDTScn WHERE Scn = 6302 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6302, 'ENG', 
   @cLine01 = '',
   @cLine02 = 'LOC NOT MATCH.',
   @cLine03 = 'PROCEED?',
   @cLine04 = '',
   @cLine05 = '1 = YES',
   @cLine06 = '2 = NO',
   @cLine07 = '',
   @cLine08 = 'OPTION: %01i01',
   @cLine14 = '%e',     
   @nFunc   = 1742
   