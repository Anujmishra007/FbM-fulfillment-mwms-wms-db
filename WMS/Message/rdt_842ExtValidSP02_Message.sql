--rdt_842ExtValidSP02
exec rdt.rdtDropMsg 177051 , 177100	

execute rdt.rdtAddMsg 177051, 10, '177051 Inv Ecom Flag', 'us_english', 842
execute rdt.rdtAddMsg 177052, 10, '177052 Inv Ecom Flag', 'us_english', 842

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 177051 AND 177100