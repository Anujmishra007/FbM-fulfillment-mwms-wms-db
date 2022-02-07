--rdt_840ExtValid09
execute rdt.rdtDropMsg 154601 , 154650

execute rdt.rdtAddMsg 154601, 10, '54601^HEAVY BOX',        'us_english', 840
execute rdt.rdtAddMsg 154602, 10, '54602^OVER WEIGHT',      'us_english', 840
execute rdt.rdtAddMsg 154603, 10, '54603^LABEL NOT RCVD',   'us_english', 840

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 154601 AND 154650