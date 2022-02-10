--rdt_841GetOrders02
execute rdt.rdtdropmsg 137251 , 137300

execute rdt.rdtAddMsg 137251, 10, '37251^SKU NotIn Load',   'us_english',841
execute rdt.rdtAddMsg 137252, 10, '37252^No Ord To Pick',   'us_english',841
execute rdt.rdtAddMsg 137253, 10, '37253^Ins Ecomm Fail',   'us_english',841

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 137251 AND 137300
