
--rdt_841ExtUpdSP25
rdt.rdtDropMsg 181651, 181700

execute rdt.rdtAddMsg 181651, 10, '181651GetPKSlip#Fail',   'us_english', 841
execute rdt.rdtAddMsg 181652, 10, '181652InstPKHdrFail',    'us_english', 841
execute rdt.rdtAddMsg 181653, 10, '181652-Scan In Fail',    'us_english', 841
execute rdt.rdtAddMsg 181654, 10, '181653InsPackHDRFail',   'us_english', 841
execute rdt.rdtAddMsg 181655, 10, '181654UPDPKDET Failed',  'us_english', 841
execute rdt.rdtAddMsg 181656, 10, '181655Get Label Fail',   'us_english', 841
execute rdt.rdtAddMsg 181657, 10, '181656Ins PKDET Fail',   'us_english', 841
execute rdt.rdtAddMsg 181658, 10, '181657Ins PKDET Fail',   'us_english', 841
execute rdt.rdtAddMsg 181659, 10, '181658InsPInfoFail',     'us_english', 841
execute rdt.rdtAddMsg 181660, 10, '181660Upd Ecomm Fail',   'us_english', 841
execute rdt.rdtAddMsg 181661, 10, '181661Upd Caseid Fail',  'us_english', 841
execute rdt.rdtAddMsg 181662, 10, '181662GetRightFail',     'us_english', 841
execute rdt.rdtAddMsg 181663, 10, '181663AutoMBOLPack',     'us_english', 841
execute rdt.rdtAddMsg 181664, 10, '181664Pack Cfm Fail',    'us_english', 841
execute rdt.rdtAddMsg 181665, 10, '181665UpdEcommFail',     'us_english', 841
execute rdt.rdtAddMsg 181666, 10, '181666UpdPackInfoFail',  'us_english', 841
execute rdt.rdtAddMsg 181667, 10, '181667SKuNotIntote  ',  'us_english', 841
execute rdt.rdtAddMsg 181668, 10, '181668SKuNotIntote  ',  'us_english', 841
execute rdt.rdtAddMsg 181669, 10, '181669QtyExceeded   ',  'us_english', 841

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 181651 AND 172050