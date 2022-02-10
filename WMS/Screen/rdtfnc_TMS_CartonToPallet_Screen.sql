--5160-5169

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1189', 'ENG', 'FNC', 'TMS - Carton To Pallet', 'rdtfnc_TMS_CartonToPallet', '0')


DELETE rdt.RDTScn WHERE Scn = 5160 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5160, 'ENG'
   ,@cLine01 = 'TMS CARTON TO PALLET'
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1189
 

DELETE rdt.RDTScn WHERE Scn = 5161 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5161, 'ENG'
   ,@cLine01 = 'TMS CARTON TO PALLET'
   ,@cLine02 = ''
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%20d01'
   ,@cLine06 = 'REFNO:' 
   ,@cLine07 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1189


DELETE rdt.RDTScn WHERE Scn = 5162 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5162, 'ENG'
   ,@cLine01 = 'TMS CARTON TO PALLET'
   ,@cLine02 = ''
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%20d01'
   ,@cLine06 = 'REFNO:' 
   ,@cLine07 = '%20d02'
   ,@cLine09 = 'TTL CARTON:' 
   ,@cLine10 = '%05d03' 
   ,@cLine11 = '%05i04'
   ,@cLine14 = '%e'
   ,@nFunc = 1189

DELETE rdt.RDTScn WHERE Scn = 5163 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5163, 'ENG'
   ,@cLine01 = 'TMS CARTON TO PALLET'
   ,@cLine02 = ''
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%20d01'
   ,@cLine06 = 'REFNO:' 
   ,@cLine07 = '%20d02'
   ,@cLine09 = 'CARTON NO:' 
   ,@cLine10 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1189   

DELETE rdt.RDTScn WHERE Scn = 5164 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5164, 'ENG'
   ,@cLine01 = 'TMS CARTON TO PALLET'
   ,@cLine02 = 'PALLET ID:'
   ,@cLine03 = '%20d01'
   ,@cLine04 = 'REFNO:' 
   ,@cLine05 = '%20d02'
   ,@cLine06 = 'TOTAL CARTON: %20d03' 
   ,@cLine07 = 'TOTAL SCAN  : %20d04'
   ,@cLine09 = '1 = CLOSE PLT'
   ,@cLine10 = '5 = SHORT-CLOSE PLT'
   ,@cLine11 = '9 = DELETE PALLET'
   ,@cLine12 = '0 = ADD ORDER'
   ,@cLine13 = 'OPTIONS  : %01i05'
   ,@cLine14 = '%e'
   ,@nFunc = 1189     