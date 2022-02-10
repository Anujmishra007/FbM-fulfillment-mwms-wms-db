-- rdt_898RcvCfm07
exec rdt.rdtDropMsg 158701, 158750

execute rdt.rdtAddMsg 158701, 10, '158701SNO received  ', 'us_english', 898
execute rdt.rdtAddMsg 158702, 10, '158702SNO picked    ', 'us_english', 898
execute rdt.rdtAddMsg 158703, 10, '158703SNO packed    ', 'us_english', 898
execute rdt.rdtAddMsg 158704, 10, '158704SNO shipped   ', 'us_english', 898
execute rdt.rdtAddMsg 158705, 10, '158705SNO bad status', 'us_english', 898
execute rdt.rdtAddMsg 158706, 10, '158706UCCNotTallySNO', 'us_english', 898
execute rdt.rdtAddMsg 158707, 10, '158707SKU SNOCap Off', 'us_english', 898
