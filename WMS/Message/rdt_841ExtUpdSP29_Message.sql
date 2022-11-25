-- rdt_841ExtUpdSP29
execute rdt.rdtDropMsg 190001 , 190050

execute rdt.rdtAddMsg 190001, 10, '190001UpdPackInfofail',  'us_english',841
execute rdt.rdtAddMsg 190002, 10, '190002GetPKSlip#Fail',   'us_english',841
execute rdt.rdtAddMsg 190003, 10, '190003InstPKHdrFail',    'us_english',841
execute rdt.rdtAddMsg 190004, 10, '190004ScanInFail',       'us_english',841
execute rdt.rdtAddMsg 190005, 10, '190005InsPackHDRFail',   'us_english',841
execute rdt.rdtAddMsg 190006, 10, '190006UPDPKDETFailed',   'us_english',841
execute rdt.rdtAddMsg 190007, 10, '190007GenLabelFail',     'us_english',841
execute rdt.rdtAddMsg 190008, 10, '190008InsPkDtlFail',     'us_english',841
execute rdt.rdtAddMsg 190009, 10, '190009InsPKDETFailed',   'us_english',841
execute rdt.rdtAddMsg 190010, 10, '190010InsPInfoFail',     'us_english',841
execute rdt.rdtAddMsg 190011, 10, '190011UpdEccomFail',     'us_english',841
execute rdt.rdtAddMsg 190012, 10, '190012UpdCaseIDFail',    'us_english',841
execute rdt.rdtAddMsg 190013, 10, '190013PackCfmFail',      'us_english',841
execute rdt.rdtAddMsg 190014, 10, '190014UpdEcommFail',     'us_english',841
execute rdt.rdtAddMsg 190015, 10, '190015GetRightFail',     'us_english',841
execute rdt.rdtAddMsg 190016, 10, '190016AutoMBOLPack',     'us_english',841
execute rdt.rdtAddMsg 190017, 10, '190017UpdPInfoFail',     'us_english',841
execute rdt.rdtAddMsg 190018, 10, '190018 Ins DropID Er',   'us_english',841

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 190001 AND 190050