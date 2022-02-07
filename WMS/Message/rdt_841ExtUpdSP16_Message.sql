--rdt_841ExtUpdSP16
rdt.rdtDropMsg 167101 , 167150	

execute rdt.rdtAddMsg 167101, 10, '167101GetPKSlip#Fail',   'us_english', 841
execute rdt.rdtAddMsg 167102, 10, '167102InstPKHdrFail',    'us_english', 841
execute rdt.rdtAddMsg 167103, 10, '167102-Scan In Fail',    'us_english', 841
execute rdt.rdtAddMsg 167104, 10, '167103InsPackHDRFail',   'us_english', 841
execute rdt.rdtAddMsg 167105, 10, '167104UPDPKDET Failed',  'us_english', 841
execute rdt.rdtAddMsg 167106, 10, '167105Get Label Fail',   'us_english', 841
execute rdt.rdtAddMsg 167107, 10, '167106Ins PKDET Fail',   'us_english', 841
execute rdt.rdtAddMsg 167108, 10, '167107Ins PKDET Fail',   'us_english', 841
execute rdt.rdtAddMsg 167109, 10, '167108InsPInfoFail',     'us_english', 841
execute rdt.rdtAddMsg 167110, 10, '167110Upd Ecomm Fail',   'us_english', 841
execute rdt.rdtAddMsg 167111, 10, '167111Upd Caseid Fail',  'us_english', 841
execute rdt.rdtAddMsg 167112, 10, '167112GetRightFail',     'us_english', 841
execute rdt.rdtAddMsg 167113, 10, '167113AutoMBOLPack',     'us_english', 841
execute rdt.rdtAddMsg 167114, 10, '167114Pack Cfm Fail',    'us_english', 841
execute rdt.rdtAddMsg 167115, 10, '167115UpdEcommFail',     'us_english', 841
execute rdt.rdtAddMsg 167116, 10, '167116UpdPackInfoFail',  'us_english', 841

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 167101 AND 167150