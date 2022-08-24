--rdt_841ExtUpdSP27
rdt.rdtDropMsg 188251 , 188300

execute rdt.rdtAddMsg 188201, 10, '188201GetPKSlip#Fail',   'us_english', 841
execute rdt.rdtAddMsg 188202, 10, '188202InstPKHdrFail',    'us_english', 841
execute rdt.rdtAddMsg 188203, 10, '188202-Scan In Fail',    'us_english', 841
execute rdt.rdtAddMsg 188204, 10, '188203InsPackHDRFail',   'us_english', 841
execute rdt.rdtAddMsg 188205, 10, '188204UPDPKDET Failed',  'us_english', 841
execute rdt.rdtAddMsg 188206, 10, '188205Get Label Fail',   'us_english', 841
execute rdt.rdtAddMsg 188207, 10, '188206Ins PKDET Fail',   'us_english', 841
execute rdt.rdtAddMsg 188208, 10, '188207Ins PKDET Fail',   'us_english', 841
execute rdt.rdtAddMsg 188209, 10, '188208InsPInfoFail',     'us_english', 841
execute rdt.rdtAddMsg 188210, 10, '188210Upd Ecomm Fail',   'us_english', 841
execute rdt.rdtAddMsg 188211, 10, '188211Upd Caseid Fail',  'us_english', 841
execute rdt.rdtAddMsg 188212, 10, '188212GetRightFail',     'us_english', 841
execute rdt.rdtAddMsg 188213, 10, '188213AutoMBOLPack',     'us_english', 841
execute rdt.rdtAddMsg 188214, 10, '188214Pack Cfm Fail',    'us_english', 841
execute rdt.rdtAddMsg 188215, 10, '188215UpdEcommFail',     'us_english', 841
execute rdt.rdtAddMsg 188216, 10, '188216UpdPackInfoFail',  'us_english', 841
execute rdt.rdtAddMsg 188217, 10, '188217 SKuNotIntote ',   'us_english', 841
execute rdt.rdtAddMsg 188218, 10, '188218 SKuNotIntote ',   'us_english', 841
execute rdt.rdtAddMsg 188219, 10, '188219 QtyExceeded  ',   'us_english', 841
execute rdt.rdtAddMsg 188220, 10, '188220 Over Packed  ',   'us_english', 841
execute rdt.rdtAddMsg 188221, 10, '188221 PENDCANC     ',   'us_english', 841

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 188251 AND 188300