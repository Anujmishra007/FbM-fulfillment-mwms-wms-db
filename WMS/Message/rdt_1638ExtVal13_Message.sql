--rdt_1638ExtVal13
exec rdt.rdtDropMsg 167501, 167550

execute rdt.rdtAddMsg 167501, 10, '167501 Diff UDF02', 'us_english', 838

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 167501 AND 167550



