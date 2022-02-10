-- rdt_838ConfirmSP11
execute rdt.rdtDropMsg 180101, 180150

execute rdt.rdtAddMsg 180101, 10, '180101InsPHdrFail   ', 'us_english', 838
execute rdt.rdtAddMsg 180102, 10, '180102GenLabelNoFail', 'us_english', 838
execute rdt.rdtAddMsg 180103, 10, '180103GenLabelNoFail', 'us_english', 838
execute rdt.rdtAddMsg 180104, 10, '180104InsPackDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 180105, 10, '180105UpdPackDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 180106, 10, '180106INSPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 180107, 10, '180107UPDPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 180108, 10, '180108UPD UCC Fail  ', 'us_english', 838
execute rdt.rdtAddMsg 180109, 10, '180109INS RDSNo Fail', 'us_english', 838
execute rdt.rdtAddMsg 180110, 10, '180110SNO ady scan  ', 'us_english', 838
execute rdt.rdtAddMsg 180111, 10, '180111UpdPkDtInfFail', 'us_english', 838
execute rdt.rdtAddMsg 180112, 10, '180112INS PDInfoFail', 'us_english', 838
execute rdt.rdtAddMsg 180113, 10, '180113UPD PDInfoFail', 'us_english', 838

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 180101 and 180150
