--rdt_523ExtValidSP10
exec rdt.rdtDropMsg 161501, 161550

execute rdt.rdtAddMsg 161501, 10, '61501^Qty Exceeded',  'us_english', 523

execute rdt.rdtAddMsg 161502, 10, '61502^Qty Exceeded',  'us_english', 523

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 161501 AND 161550


