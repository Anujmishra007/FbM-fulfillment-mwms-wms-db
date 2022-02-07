-- rdt_521ExtValid03
execute rdt.rdtDropMsg 173851 , 173900

execute rdt.rdtAddMsg 173851, 10,'173851 Mix SKU UCC ', 'us_english', 521
execute rdt.rdtAddMsg 173852, 10,'173852 Mix SKU LOT ', 'us_english', 521

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 173851 AND 173900

