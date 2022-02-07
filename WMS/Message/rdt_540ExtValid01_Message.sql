-- rdt_540ExtValid01
exec rdt.rdtDropMsg 121901 , 121950

execute rdt.rdtAddMsg 121901, 10, '21901^Invalid Lbl No', 'us_english', 540
execute rdt.rdtAddMsg 121902, 10, '21902^SKU Different',  'us_english', 540

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 121901 AND 121950

