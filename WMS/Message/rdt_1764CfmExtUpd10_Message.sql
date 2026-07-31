--rdt_1764CfmExtUpd10
execute rdt.rdtdropmsg 91001, 91009

execute rdt.rdtAddMsg 91001, 10, '91001ReadTaskFail   ', 'us_english', 1764
execute rdt.rdtAddMsg 91002, 10, '91002CCMsgFail      ', 'us_english', 1764
execute rdt.rdtAddMsg 91003, 10, '91003HoldLocFail    ', 'us_english', 1764
execute rdt.rdtAddMsg 91004, 10, '91004HoldLocExecFail', 'us_english', 1764
execute rdt.rdtAddMsg 91005, 10, '91005PickDetailFail ', 'us_english', 1764
execute rdt.rdtAddMsg 91006, 10, '91006LLIFail        ', 'us_english', 1764
execute rdt.rdtAddMsg 91007, 10, '91007ReallocFail    ', 'us_english', 1764
execute rdt.rdtAddMsg 91008, 10, '91008ReallocExecFail', 'us_english', 1764
execute rdt.rdtAddMsg 91009, 10, '91009DataError      ', 'us_english', 1764
