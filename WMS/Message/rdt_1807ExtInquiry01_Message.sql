--rdt_1807ExtInquiry01
exec rdt.rdtDropMsg 172851, 172900

execute rdt.rdtAddMsg 172851, 10, '172851Invalid Carton', 'us_english', 1807

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 172851 AND 172900



