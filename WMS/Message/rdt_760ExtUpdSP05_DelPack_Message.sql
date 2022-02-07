-- rdt_760ExtUpdSP05_DelPack
exec rdt.rdtDropMsg 126851, 126900

execute rdt.rdtAddMsg 126851, 10, '126851DELPackDtlFail', 'us_english', 760
execute rdt.rdtAddMsg 126852, 10, '126852INSPackDtlFail', 'us_english', 760
