-- Scn range 5910 - 5919 (rdtfnc_PickPallet)

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1854 AND Lang_Code = 'ENG' AND Message_Type = 'FNC')
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1854, 'ENG', 'FNC', 'PickPallet v7', 'rdtfnc_PickPallet', '4')
END

-- 5910 = PickSlipNo screen
DELETE rdt.RDTScn WHERE Scn = 5910 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5910, 'ENG',
   @cLine01 = 'PSNO: %10i01',
   @cLine14 = '%e'

-- 5911 = LOC, Option screen
DELETE rdt.RDTScn WHERE Scn = 5911 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5911, 'ENG',
   @cLine01 = 'PSNO: %10d01',
   @cLine02 = '', 
   @cLine03 = 'LOC: %10d02',
   @cLine04 = 'LOC: %10i03',
   @cLine05 = '', 
   @cLine06 = 'DROP ID:',
   @cLine07 = '%40i04',
   @cLine14 = '%e',
   @nFunc = 1854
   
-- 5912 = ID screen
DELETE rdt.RDTScn WHERE Scn = 5912 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5912, 'ENG',
   @cLine01 = 'ID%18d02',
   @cLine02 = 'SKU:',
   @cLine03 = '%20d03',
   @cLine04 = '%20d04',
   @cLine05 = '%20d05',
   @cLine06 = '%20d06',
   @cLine07 = '%20d07',
   @cLine08 = '%20d08',
   @cLine09 = '%20d09',
   @cLine10 = '         %05d10 %05d12', 
   @cLine11 = 'QTY:     %05d11 %05d13', 
   @cLine12 = 'ID%18i14',
   @cLine13 = '%20d01',
   @cLine14 = '%e',
   @nFunc = 1854
 
-- 5913 = SkipTask Option screen
DELETE rdt.RDTScn WHERE Scn = 5913 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5913, 'ENG',
   @cLine01 = '',
   @cLine02 = 'Skip Current Task?',
   @cLine03 = '',
   @cLine04 = '1 = Yes',
   @cLine05 = '2 = No',
   @cLine06 = '',
   @cLine07 = '',
   @cLine08 = 'Option: %01i01',
   @cLine14 = '%e',
   @nFunc = 1854

-- 5914 = No More task screen
DELETE rdt.RDTScn WHERE Scn = 5914 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5914, 'ENG',
   @cLine01 = '',
   @cLine02 = 'No more task(s) in LOC',
   @cLine03 = '%10d01',
   @cLine04 = '',
   @cLine05 = 'Press ENTER or ESC',
   @cLine06 = 'to continue',
   @cLine14 = '%e',
   @nFunc = 1854

-- 5915 = Full/partial Pallet Option screen
DELETE rdt.RDTScn WHERE Scn = 5915 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5915, 'ENG',
   @cLine01 = '',
   @cLine02 = '1 = Full Pallet',
   @cLine03 = '3 = Partial Pallet',
   @cLine04 = '',
   @cLine05 = 'Option: %01i01',
   @cLine14 = '%e',
   @nFunc = 1854

-- 5916 = Confirm Option screen
DELETE rdt.RDTScn WHERE Scn = 5916 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5916, 'ENG',
   @cLine01 = 'LOC NOT MATCH',
   @cLine02 = 'PROCEED?',
   @cLine03 = '',
   @cLine05 = '1 = YES',
   @cLine06 = '2 = NO',
   @cLine07 = '',
   @cLine08 = 'OPTION: %01i01',
   @cLine14 = '%e',
   @nFunc = 1854

-- 5917 = Summary screen 
DELETE rdt.RDTScn WHERE Scn = 5917 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5917, 'ENG',
   @cLine01 = '%20d01',
   @cLine02 = '%20d02',
   @cLine03 = '%20d03',
   @cLine04 = '%20d04',
   @cLine05 = '%20d05',
   @cLine06 = '%20d06',
   @cLine07 = '%20d07',
   @cLine08 = '%20d08',
   @cLine09 = '%20d09',
   @cLine10 = '%20d10',
   @cLine11 = '%20d11',
   @cLine12 = '%20d12',
   @cLine13 = '%20d13',
   @cLine14 = '%e',
   @nFunc = 1854
   
SELECT * FROM rdt.rdtscn (NOLOCK) WHERE scn BETWEEN 5910 and 5919
SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID = '1854'