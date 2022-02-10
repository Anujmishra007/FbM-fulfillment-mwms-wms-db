-- rdt_PickSKU_Confirm
execute rdt.rdtDropMsg 102001, 102050

execute rdt.rdtAddMsg 102001, 10, '102001UPD PKDtl Fail', 'us_english', 830
execute rdt.rdtAddMsg 102002, 10, '102002UPD PKDtl Fail', 'us_english', 830
execute rdt.rdtAddMsg 102003, 10, '102003UPD PKDtl Fail', 'us_english', 830
execute rdt.rdtAddMsg 102004, 10, '102004nspg_GetKey   ', 'us_english', 830
execute rdt.rdtAddMsg 102005, 10, '102005INS PKDtl Fail', 'us_english', 830
execute rdt.rdtAddMsg 102006, 10, '102006INS RefKeyFail', 'us_english', 830
execute rdt.rdtAddMsg 102007, 10, '102007UPD PKDtl Fail', 'us_english', 830
execute rdt.rdtAddMsg 102008, 10, '102008UPD PKDtl Fail', 'us_english', 830
execute rdt.rdtAddMsg 102009, 10, '102009GetKey Fail   ', 'us_english', 830
