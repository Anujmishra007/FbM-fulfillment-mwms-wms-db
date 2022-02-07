-- rdtfnc_PreReceiveSort2
exec rdt.rdtDropMsg 112401 , 112450

execute rdt.rdtAddMsg 112401, 10, '12401^Param NotSetup', 'us_english', 1829
execute rdt.rdtAddMsg 112402, 10, '12402^UCC Required  ', 'us_english', 1829
execute rdt.rdtAddMsg 112403, 10, '12403^UCC Not Exists', 'us_english', 1829
execute rdt.rdtAddMsg 112404, 10, '12404^UCC Received  ', 'us_english', 1829
execute rdt.rdtAddMsg 112405, 10, '12405^SPROC NOTSETUP', 'us_english', 1829
execute rdt.rdtAddMsg 112406, 10, '12406^INVALID OPTION', 'us_english', 1829
execute rdt.rdtAddMsg 112407, 10, '12407^INVALID QTY   ', 'us_english', 1829
execute rdt.rdtAddMsg 112408, 10, '12408^DIFF VALUE    ', 'us_english', 1829
execute rdt.rdtAddMsg 112409, 10, '12409^INVALID OPTION', 'us_english', 1829

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 112401 AND 112450