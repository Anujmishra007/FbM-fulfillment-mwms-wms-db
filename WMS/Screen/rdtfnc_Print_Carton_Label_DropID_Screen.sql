--2820 - 2829

-- 2820 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2820 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2820, 'ENG',
    @cLine01 = 'PRINTER ID:'
   ,@cLine02 = '%20i01'
   ,@cLine04 = 'DROP ID:'
   ,@cLine05 = '%18i02'
   ,@cLine06 = 'Press ENTER and Wait'
   ,@cLine07 = 'Till Printing Ends'
   ,@cLine09 = '%20d03'
   ,@cLine10 = '%20d04'
   ,@cLine11 = '%20d05'
   ,@cLine12 = 'LAST DROP ID:'
   ,@cLine13 = '%20d06'
   ,@cLine14 = '%e'

-- 2821 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2821 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2821, 'ENG',
    @cLine01 = 'Template ID Not'
   ,@cLine02 = 'setup:'
   ,@cLine04 = 'Apply generic.btw ?'
   ,@cLine06 = '1 - YES'
   ,@cLine07 = '2 - NO'
   ,@cLine09 = 'Option: %01i01'
   ,@cLine14 = '%e'

SELECT * FROM RDT.RDTSCN (NOLOCK) WHERE SCN between 2820 and 2821

INSERT INTO rdt.rdtmsg ( Message_ID , Lang_Code , Message_Type, Message_Text , StoredProcName , EventType )
VALUES ( 913 , 'ENG', 'FNC' , 'Print Label - DropID' , 'rdtfnc_Print_Carton_Label_DropID', '0' ) 