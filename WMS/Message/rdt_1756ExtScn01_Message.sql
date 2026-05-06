--FCR-5727
execute rdt.rdtDropMsg 239601, 239650

execute rdt.rdtAddMsg 239601, 10, '239601^MHE Needed',            'us_english', 1756
execute rdt.rdtAddMsg 239602, 10, '239602^Invalid MHE',           'us_english', 1756
execute rdt.rdtAddMsg 239603, 10, '239603^InvalidNewMHE',         'us_english', 1756, 0, '239603 Invalid New MHE'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 239601 AND 239650