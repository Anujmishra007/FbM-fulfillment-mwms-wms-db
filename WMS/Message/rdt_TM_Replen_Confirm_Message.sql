--rdt_TM_Replen_Confirm
execute rdt.rdtdropmsg 74251, 74300

execute rdt.rdtAddMsg '74251', 10, '74251^GetKey Fail   ', 'us_english', 1764
execute rdt.rdtAddMsg '74252', 10, '74252^InsTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg '74253', 10, '74253^UpdTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg '74254', 10, '74254^UpdTaskdetFail', 'us_english', 1764
