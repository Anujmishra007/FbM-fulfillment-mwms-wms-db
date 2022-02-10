-- rdt_838ConfirmSP01
execute rdt.rdtDropMsg 110001, 110050

execute rdt.rdtAddMsg 110001, 10, '110001InsPHdrFail   ', 'us_english', 838
execute rdt.rdtAddMsg 110002, 10, '110002GenLabelNoFail', 'us_english', 838
execute rdt.rdtAddMsg 110003, 10, '110003GenLabelNoFail', 'us_english', 838
execute rdt.rdtAddMsg 110004, 10, '110004InsPackDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 110005, 10, '110005UpdPackDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 110006, 10, '110006INSPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 110007, 10, '110007UPDPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 110008, 10, '110008UPD UCC Fail  ', 'us_english', 838
execute rdt.rdtAddMsg 110009, 10, '110009INS RDSNo Fail', 'us_english', 838
execute rdt.rdtAddMsg 110010, 10, '110010SNO ady scan  ', 'us_english', 838
