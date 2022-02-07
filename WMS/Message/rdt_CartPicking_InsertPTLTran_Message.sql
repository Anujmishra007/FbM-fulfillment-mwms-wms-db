--rdt_CartPicking_InsertPTLTran
--execute rdt.rdtDropMsg 84651 , 84700

execute rdt.rdtAddMsg 84651, 10, '84651^UpdDPfileFail',  'us_english'
execute rdt.rdtAddMsg 84652, 10, '84652^UpdDPfileLFail', 'us_english'
execute rdt.rdtAddMsg 84653, 10, '84653^InsPTLTranFail', 'us_english'
execute rdt.rdtAddMsg 84654, 10, '84654^InsPTLTranFail', 'us_english'
execute rdt.rdtAddMsg 84655, 10, '84655^UpdPTLTranFail', 'us_english'
execute rdt.rdtAddMsg 84656, 10, '84656^UpdDropIDFail',  'us_english'
execute rdt.rdtAddMsg 84657, 10, '84657^NoPickTask',     'us_english' -- (ChewKP01)
