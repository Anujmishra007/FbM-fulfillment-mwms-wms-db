--rdt_1841ExtValid03
exec rdt.rdtDropMsg 177801, 177850

execute rdt.rdtAddMsg 177801, 10, '177801 Invalid UCC  ',   'us_english', 1841
execute rdt.rdtAddMsg 177802, 10, '177802NeedCloseByID ',   'us_english', 1841
execute rdt.rdtAddMsg 177803, 10, '177803InvalidCond   ',   'us_english', 1841
execute rdt.rdtAddMsg 177804, 10, '177804 UCC > 1 SKU  ',   'us_english', 1841
execute rdt.rdtAddMsg 177805, 10, '177805 UCC > 1 SKU  ',   'us_english', 1841
execute rdt.rdtAddMsg 177806, 10, '177806 Insp Not Done',   'us_english', 1841



SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 177801 AND 177850


