
execute rdt.rdtdropmsg 257621, 257640

execute rdt.rdtAddMsg 257621, 10, '257621:Only B2B',  'us_english',  1813, 0,  '257621: Only B2B'
execute rdt.rdtAddMsg 257622, 10, '257622:Only B2C',  'us_english',  1813, 0,  '257622: Only B2C'



SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 257621 AND 257640