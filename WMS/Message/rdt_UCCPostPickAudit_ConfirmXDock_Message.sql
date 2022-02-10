--rdtfnc_DynamicPick_UCCPickAndPack_ConfirmXDock
execute rdt.rdtdropmsg 87401, 87450

execute rdt.rdtAddMsg 87401, 10, '87401 Missing UCCLOT', 'us_english', 580  
execute rdt.rdtAddMsg 87402, 10, '87402 UCC Not Alloc ', 'us_english', 580  
execute rdt.rdtAddMsg 87403, 10, '87403 PKDtl no PSNO ', 'us_english', 580  
execute rdt.rdtAddMsg 87404, 10, '87404 InsPackHdrFail', 'us_english', 580  
execute rdt.rdtAddMsg 87405, 10, '87405 InsPKInfoFail ', 'us_english', 580  
execute rdt.rdtAddMsg 87406, 10, '87406 InsPackDtlFail', 'us_english', 580
