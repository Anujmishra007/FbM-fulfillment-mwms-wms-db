-- rdt_521ExtValid04
execute rdt.rdtDropMsg 173901 , 173950

execute rdt.rdtAddMsg 173901, 10,'173901 Mix SKU UCC ', 'us_english', 521

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 173901 AND 173950

