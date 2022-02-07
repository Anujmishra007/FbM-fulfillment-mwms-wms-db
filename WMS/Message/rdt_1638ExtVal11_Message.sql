--rdt_1638ExtVal11
execute rdt.rdtDropMsg 161201 , 161250

execute rdt.rdtAddMsg 161201, 10, '61201^Mix Dest.',        'us_english',  1638
execute rdt.rdtAddMsg 161202, 10, '61202^Mix Order Type',   'us_english',  1638
execute rdt.rdtAddMsg 161203, 10, '61203^Mix Route Tool',   'us_english',  1638
execute rdt.rdtAddMsg 161204, 10, '61204^Mix Ord UDF10',    'us_english',  1638
execute rdt.rdtAddMsg 161205, 10, '61205^Mix Ord LOT01',    'us_english',  1638

SELECT * FROM RDT.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 161201 AND 161250