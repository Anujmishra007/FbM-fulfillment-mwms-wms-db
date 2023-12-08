
--rdt_841ExtUpdSP37
rdt.rdtDropMsg 208451, 208500

execute rdt.rdtAddMsg 208451, 10, '208451GetPKSlip#Fail',   'us_english', 841
execute rdt.rdtAddMsg 208452, 10, '208452InstPKHdrFail',    'us_english', 841
execute rdt.rdtAddMsg 208453, 10, '208452-Scan In Fail',    'us_english', 841
execute rdt.rdtAddMsg 208454, 10, '208453InsPackHDRFail',   'us_english', 841
execute rdt.rdtAddMsg 208455, 10, '208454UPDPKDET Failed',  'us_english', 841
execute rdt.rdtAddMsg 208456, 10, '208455Get Label Fail',   'us_english', 841
execute rdt.rdtAddMsg 208457, 10, '208456Ins PKDET Fail',   'us_english', 841
execute rdt.rdtAddMsg 208458, 10, '208457Ins PKDET Fail',   'us_english', 841
execute rdt.rdtAddMsg 208459, 10, '208458InsPInfoFail',     'us_english', 841
execute rdt.rdtAddMsg 208460, 10, '208460Upd Ecomm Fail',   'us_english', 841
execute rdt.rdtAddMsg 208461, 10, '208461Upd Caseid Fail',  'us_english', 841
execute rdt.rdtAddMsg 208462, 10, '208462GetRightFail',     'us_english', 841
execute rdt.rdtAddMsg 208463, 10, '208463AutoMBOLPack',     'us_english', 841
execute rdt.rdtAddMsg 208464, 10, '208464Pack Cfm Fail',    'us_english', 841
execute rdt.rdtAddMsg 208465, 10, '208465UpdEcommFail',     'us_english', 841
execute rdt.rdtAddMsg 208466, 10, '208466UpdPackInfoFail',  'us_english', 841
execute rdt.rdtAddMsg 208467, 10, '208467SKuNotIntote  ',  'us_english', 841
execute rdt.rdtAddMsg 208468, 10, '208468SKuNotIntote  ',  'us_english', 841
execute rdt.rdtAddMsg 208469, 10, '208469QtyExceeded   ',  'us_english', 841

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 181651 AND 172050