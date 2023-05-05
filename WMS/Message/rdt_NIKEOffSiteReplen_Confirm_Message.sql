-- rdt_NIKEOffSiteReplen_Confirm
execute rdt.rdtdropmsg 200001, 200050

execute rdt.rdtAddMsg 200001, 10, '200001No swap task  ', 'us_english', 1764
execute rdt.rdtAddMsg 200002, 10, '200002PickExactUCC  ', 'us_english', 1764
execute rdt.rdtAddMsg 200003, 10, '200003UpdTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg 200004, 10, '200004INS RPFLogFail', 'us_english', 1764
execute rdt.rdtAddMsg 200005, 10, '200005UpdTaskdetFail', 'us_english', 1764
