-- rdt_838ConfirmSP02
execute rdt.rdtDropMsg 110851, 110900

execute rdt.rdtAddMsg 110851, 10, '110851InsPHdrFail   ', 'us_english', 838
execute rdt.rdtAddMsg 110852, 10, '110852GenLabelNoFail', 'us_english', 838
execute rdt.rdtAddMsg 110853, 10, '110853GenLabelNoFail', 'us_english', 838
execute rdt.rdtAddMsg 110854, 10, '110854InsPackDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 110855, 10, '110855UpdPackDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 110856, 10, '110856INSPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 110857, 10, '110857UPDPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 110858, 10, '110858UPD UCC Fail  ', 'us_english', 838
execute rdt.rdtAddMsg 110859, 10, '110859INS RDSNo Fail', 'us_english', 838
execute rdt.rdtAddMsg 110860, 10, '110860SNO ady scan  ', 'us_english', 838
