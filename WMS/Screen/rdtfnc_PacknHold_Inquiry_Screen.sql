--rdtfnc_PacknHold_Inquiry
--860-869

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('526', 'ENG', 'FNC', 'Pack&Hold Inquiry', 'rdtfnc_PacknHold_Inquiry', '9')


-- 860 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 860 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 860, 'ENG',
    @cLine01 = 'PACK & HOLD INQUIRY'
   ,@cLine03 = 'LOC:'
   ,@cLine04 = '%10i01'
   ,@cLine14 = '%e'
   
-- 861 = DROPID STATUS screen
DELETE rdt.RDTScn WHERE Scn = 861 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 861, 'ENG',
    @cLine01 = 'PACK & HOLD INQUIRY'
   ,@cLine02 = '         %20d01'
   ,@cLine04 = 'DROP ID:'
   ,@cLine05 = '%20d02'
   ,@cLine07 = 'DROP ID STATUS:'
   ,@cLine08 = '%20d03'
   ,@cLine10 = 'CARTON COUNT:'
   ,@cLine11 = '%20d04'
   ,@cLine14 = '%e'

-- update rdt.rdtscn with function id   
UPDATE RDT.RDTSCN SET FUNC = 526 WHERE SCN BETWEEN 860 AND 869
   
