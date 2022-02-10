
-- rdt_Trolley_Putaway_Confirm
execute rdt.rdtDropMsg 79151, 79200

execute rdt.rdtAddMsg 79151, 10, '79151^LockOrderFail ', 'us_english', 741
execute rdt.rdtAddMsg 79152, 10, '79152^DEL Log Fail  ', 'us_english', 741
execute rdt.rdtAddMsg 79153, 10, '79153^UCC no TaskKey', 'us_english', 741
