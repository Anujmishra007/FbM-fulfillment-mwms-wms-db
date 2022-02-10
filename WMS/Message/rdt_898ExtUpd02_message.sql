-- rdt_898ExtUpd02
execute rdt.rdtDropMsg 81451, 81500

execute rdt.rdtAddMsg 81451, 10, '81451^Need CustPO   ', 'us_english', 898
execute rdt.rdtAddMsg 81452, 10, '81452^CustPONotFound', 'us_english', 898
execute rdt.rdtAddMsg 81453, 10, '81452^UPD UCC fail  ', 'us_english', 898
