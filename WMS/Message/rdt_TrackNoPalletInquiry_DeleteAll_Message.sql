-- rdt_TrackNoPalletInquiry_DeleteAll
exec rdt.rdtdropmsg 126401, 126450

execute rdt.rdtAddMsg 126401, 10, '126401UPD Pallet Fail', 'us_english', 1665
execute rdt.rdtAddMsg 126402, 10, '126402UPD PLDtl Fail ', 'us_english', 1665
execute rdt.rdtAddMsg 126403, 10, '126403DEL PLDtl Fail ', 'us_english', 1665
execute rdt.rdtAddMsg 126404, 10, '126404DEL MBDtl Fail ', 'us_english', 1665
execute rdt.rdtAddMsg 126405, 10, '126405DEL Pallet Fail', 'us_english', 1665
execute rdt.rdtAddMsg 126406, 10, '126406DEL MBOL Fail  ', 'us_english', 1665

