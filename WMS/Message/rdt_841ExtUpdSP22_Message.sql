--rdt_841ExtUpdSP22
rdt.rdtDropMsg 172001, 172050

execute rdt.rdtAddMsg 172001, 10, '172001GetPKSlip#Fail',   'us_english', 841
execute rdt.rdtAddMsg 172002, 10, '172002InstPKHdrFail',    'us_english', 841
execute rdt.rdtAddMsg 172003, 10, '172002-Scan In Fail',    'us_english', 841
execute rdt.rdtAddMsg 172004, 10, '172003InsPackHDRFail',   'us_english', 841
execute rdt.rdtAddMsg 172005, 10, '172004UPDPKDET Failed',  'us_english', 841
execute rdt.rdtAddMsg 172006, 10, '172005Get Label Fail',   'us_english', 841
execute rdt.rdtAddMsg 172007, 10, '172006Ins PKDET Fail',   'us_english', 841
execute rdt.rdtAddMsg 172008, 10, '172007Ins PKDET Fail',   'us_english', 841
execute rdt.rdtAddMsg 172009, 10, '172008InsPInfoFail',     'us_english', 841
execute rdt.rdtAddMsg 172010, 10, '172010Upd Ecomm Fail',   'us_english', 841
execute rdt.rdtAddMsg 172011, 10, '172011Upd Caseid Fail',  'us_english', 841
execute rdt.rdtAddMsg 172012, 10, '172012GetRightFail',     'us_english', 841
execute rdt.rdtAddMsg 172013, 10, '172013AutoMBOLPack',     'us_english', 841
execute rdt.rdtAddMsg 172014, 10, '172014Pack Cfm Fail',    'us_english', 841
execute rdt.rdtAddMsg 172015, 10, '172015UpdEcommFail',     'us_english', 841
execute rdt.rdtAddMsg 172016, 10, '172016UpdPackInfoFail',  'us_english', 841
execute rdt.rdtAddMsg 172017, 10, '172017SKuNotIntote  ',  'us_english', 841
execute rdt.rdtAddMsg 172018, 10, '172018SKuNotIntote  ',  'us_english', 841
execute rdt.rdtAddMsg 172019, 10, '172019QtyExceeded   ',  'us_english', 841

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 172001 AND 172050