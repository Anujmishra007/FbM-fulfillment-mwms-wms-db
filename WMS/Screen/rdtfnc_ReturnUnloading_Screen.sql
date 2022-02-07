--rdtfnc_ReturnUnloading
--5880 - 5889

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1852 AND Lang_Code = 'ENG' AND Message_Type = 'FNC')
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1852, 'ENG', 'FNC', 'Return Unloading', 'rdtfnc_ReturnUnloading', '2')
END

-- Scn = 5880. ApptNo
DELETE rdt.RDTScn WHERE Scn = 5880 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5880, 'ENG'
   ,@cLine01 = 'RETURNS UNLOADING'
   ,@cLine02 = ''
   ,@cLine03 = 'APPT NO: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1852

-- Scn = 5881 = SealNo
DELETE rdt.RDTScn WHERE Scn = 5881 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5881, 'ENG'
   ,@cLine01 = 'RETURNS UNLOADING'
   ,@cLine02 = ''
   ,@cLine03 = 'APPT NO: %10d01'
   ,@cLine04 = ''
   ,@cLine05 = 'SEAL NO:'
   ,@cLine06 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1852

-- Scn = 5882. Return Type Option
DELETE rdt.RDTScn WHERE Scn = 5882 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5882, 'ENG'
   ,@cLine01 = 'RETURNS UNLOADING'
   ,@cLine02 = ''
   ,@cLine03 = 'APPT NO: %10d01'
   ,@cLine04 = ''
   ,@cLine05 = 'SEAL NO:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = ''
   ,@cLine08 = 'RETURN TYPE:'
   ,@cLine09 = '1.DTO/MYNTRA'
   ,@cLine10 = '2.HM-RTO'
   ,@cLine11 = 'OPT: %1i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1852
 
-- Scn = 5883. BagNo,AWB
DELETE rdt.RDTScn WHERE Scn = 5883 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5883, 'ENG'
   ,@cLine01 = 'RETURNS UNLOADING'
   ,@cLine02 = ''
   ,@cLine03 = 'APPT NO: %10d01'
   ,@cLine04 = ''
   ,@cLine05 = 'SEAL NO:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = ''
   ,@cLine08 = 'BAG NO:'
   ,@cLine09 = '%20i03'
   ,@cLine10 = ''
   ,@cLine11 = 'AWB:'
   ,@cLine12 = '%20i04'
   ,@cLine13 = 'PARCEL QTY: %8d05'
   ,@cLine14 = '%e'
   ,@nFunc = 1852

-- Scn = 5884. Seal Complete
DELETE rdt.RDTScn WHERE Scn = 5884 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5884, 'ENG'
   ,@cLine01 = 'RETURNS UNLOADING'
   ,@cLine02 = ''
   ,@cLine03 = 'APPT NO: %10d01'
   ,@cLine04 = ''
   ,@cLine05 = 'SEAL NO:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = ''
   ,@cLine08 = 'SEAL NO COMPLETE?'
   ,@cLine09 = '1.YES'
   ,@cLine10 = '2.NO'
   ,@cLine11 = 'OPT: %1i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1852

-- Scn = 5885. BagNo,TrackingNo
DELETE rdt.RDTScn WHERE Scn = 5885 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5885, 'ENG'
   ,@cLine01 = 'RETURNS UNLOADING'
   ,@cLine02 = ''
   ,@cLine03 = 'APPT NO: %10d01'
   ,@cLine04 = ''
   ,@cLine05 = 'SEAL NO:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = ''
   ,@cLine08 = 'BAG NO:'
   ,@cLine09 = '%20i03'
   ,@cLine10 = ''
   ,@cLine11 = 'TRACKINGNO (HM-RTO):'
   ,@cLine12 = '%20i04'
   ,@cLine13 = 'PARCEL QTY: %8d05'
   ,@cLine14 = '%e'
   ,@nFunc = 1852
   
SELECT * FROM rdt.rdtscn (NOLOCK) WHERE scn BETWEEN 5880 and 5889
SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1852 AND Lang_Code = 'ENG' AND Message_Type = 'FNC'