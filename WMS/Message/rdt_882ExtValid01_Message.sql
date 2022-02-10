-- rdt_882ExtValid01
execute rdt.rdtDropMsg 151651, 151700

execute rdt.rdtAddMsg 151651, 10, '51651^UCC Not Sorted' ,     'us_english', 882
execute rdt.rdtAddMsg 151652, 10, '51652^UCC Not On ID',       'us_english', 882

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 151651 AND 151700
