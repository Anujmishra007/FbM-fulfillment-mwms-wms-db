--rdt_868ExtUpd07
execute rdt.rdtDropMsg 169401, 169450

execute rdt.rdtAddMsg 169401, 10, '69401^UPD Order Fail', 'us_english', 868
execute rdt.rdtAddMsg 169402, 10, '69402^ConfPackFail', 'us_english', 868

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 169401 AND 169450	