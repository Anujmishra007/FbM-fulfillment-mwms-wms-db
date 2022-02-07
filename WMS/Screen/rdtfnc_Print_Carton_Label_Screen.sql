-- 2220  = PrinterID , DropID screen
DELETE rdt.RDTScn WHERE Scn = 2290 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2290, 'ENG',
    @cLine01 = 'LABELING'
   ,@cLine03 = 'LABEL NO:'
   ,@cLine04 = '%20i01' 
	,@cLine14 = '%e'
   
   
DELETE rdt.RDTScn WHERE Scn = 2291 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2291, 'ENG',
    @cLine01 = 'LABELING'
   ,@cLine03 = 'LABEL NO:'
   ,@cLine04 = '%20d01' 
	,@cLine06 = ''
   ,@cLine07 = 'Carton No: %10d02'
   ,@cLine09 = ''
   ,@cLine10 = '%10d03'
   ,@cLine14 = '%e'   


UPDATE rdt.RDTMENU WITH (ROWLOCK)
SET OP3 = '1774'
WHERE MenuNo = '100'


INSERT INTO rdt.rdtmsg ( Message_ID , Lang_Code , Message_Type, Message_Text , StoredProcName , EventType )
VALUES ( 1774 , 'ENG', 'FNC' , 'Print Carton Label' , 'rdtfnc_Print_Carton_Label', '3' ) 