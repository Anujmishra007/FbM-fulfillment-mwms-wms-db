--rdtfnc_PTLStation_CloseStation
--5150 - 5159

--802
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('802', 'ENG', 'FNC', 'PTL Close Station', 'rdtfnc_PTLStation_CloseStation', '0')


-- PTLStation, method
DELETE rdt.RDTScn WHERE Scn = 5150 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5150, 'ENG'
   ,@cLine01 = 'PTL STATIONS:'
   ,@cLine02 = '1. %10i01'
   ,@cLine03 = '2. %10i02'
   ,@cLine04 = '3. %10i03'
   ,@cLine05 = '4. %10i04'
   ,@cLine06 = '5. %10i05'
   ,@cLine07 = ''
   ,@cLine08 = 'METHOD:   %01i06'
   ,@cLine14 = '%e'
   ,@nFunc = 802

   
-- Unassign station
DELETE rdt.RDTScn WHERE Scn = 5151 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5151, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CONFIRM CLOSE?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES' 
   ,@cLine05 = '9 = NO' 
   ,@cLine06 = '' 
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 802
   