--5830-5839,@nFunc = 1847

-- 5830 = destination ----WMS-16798
DELETE rdt.RDTScn WHERE Scn = 5830 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5830, 'ENG'
   ,@cLine02 = '1. SF PRE_SALE'
   ,@cLine03 = '2. LF PRE_SALE'
   ,@cLine04 = '3. SF PRE_SALE RETURN'
   ,@cLine05 = ''
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1847
   
-- 5831 = LF_PreSales_Destination
DELETE rdt.RDTScn WHERE Scn = 5831 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5831, 'ENG'
   ,@cLine01 = 'DESTINATION:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'VEHICLE NUMBER'
   ,@cLine05 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1847

-- 5832 = LF_PreSales_TrackingNo
DELETE rdt.RDTScn WHERE Scn = 5832 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5832, 'ENG'
   ,@cLine01 = 'TRACKING NO:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'MBOL KEY:'
   ,@cLine05 = '%20i02'
   ,@cLine06 = ''
   ,@cLine07 = 'TOTAL QTY:'
   ,@cLine08 = '%20d03'
   ,@cLine14 = '%e'
   ,@nFunc = 1847
   
-- 5833 = continue?
DELETE rdt.RDTScn WHERE Scn = 5833 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5833, 'ENG'
   ,@cLine01 = 'CONINUE LOADING:'
   ,@cLine02 = '1. YES'
   ,@cLine03 = '2. NO'
   ,@cLine04 = ''
   ,@cLine05 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1847


--WMS-16798
-- 5834 = SF_PreSales
DELETE rdt.RDTScn WHERE Scn = 5834 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5834, 'ENG'
   ,@cLine01 = 'PALLET ID:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'CARTON TYPE:'
   ,@cLine05 = '%20i02'
   ,@cLine06 = ''
   ,@cLine07 = 'TRACKING NO:'
   ,@cLine08 = '%20i03'
   ,@cLine13 = 'COUNT: %05d04'
   ,@cLine14 = '%e'
   ,@nFunc = 1847
 
--WMS-17147   
-- 5835 = SF_return
DELETE rdt.RDTScn WHERE Scn = 5835 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5835, 'ENG'
   ,@cLine01 = 'PALLET ID:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'TRACKING NO:'
   ,@cLine05 = '%20i02'
   ,@cLine13 = 'COUNT: %05d03'
   ,@cLine14 = '%e'
   ,@nFunc = 1847
   
SELECT * FROM rdt.rdtscn (NOLOCK) WHERE scn BETWEEN 5830 AND 5839
SELECT * FROM rdt.rdtscnDetail (NOLOCK) WHERE scn BETWEEN 5830 AND 5839