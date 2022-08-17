-- rdt_877DecodeSP01_2DPallet_Confirm
execute rdt.rdtDropMsg 190051, 190100

execute rdt.rdtAddMsg 190051, 10, '190051NoSKUForCaseID', 'us_english', 877
execute rdt.rdtAddMsg 190052, 10, '190052Duplicate Case', 'us_english', 877
execute rdt.rdtAddMsg 190053, 10, '190053NoSKUForInner ', 'us_english', 877
execute rdt.rdtAddMsg 190054, 10, '190054DuplicateInner', 'us_english', 877
execute rdt.rdtAddMsg 190055, 10, '190055UPD PKDtl Fail', 'us_english', 877
execute rdt.rdtAddMsg 190056, 10, '190056UPD PKDtl Fail', 'us_english', 877
execute rdt.rdtAddMsg 190057, 10, '190057nspg_GetKey   ', 'us_english', 877
execute rdt.rdtAddMsg 190058, 10, '190058INS PKDtl Fail', 'us_english', 877
execute rdt.rdtAddMsg 190059, 10, '190059INS RefKeyFail', 'us_english', 877
execute rdt.rdtAddMsg 190060, 10, '190060UPD PKDtl Fail', 'us_english', 877
execute rdt.rdtAddMsg 190061, 10, '190061Offset error  ', 'us_english', 877
