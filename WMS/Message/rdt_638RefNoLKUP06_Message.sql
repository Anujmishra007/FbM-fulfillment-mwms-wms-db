--rdt_638RefNoLKUP06
exec rdt.rdtDropMsg 165451 , 165500

execute rdt.rdtAddMsg 165451, 10, '65451^Invalid Column',   'us_english', 638
execute rdt.rdtAddMsg 165452, 10, '65452^ColumnNoIndex',    'us_english', 638
execute rdt.rdtAddMsg 165453, 10, 'Ref No: ',               'us_english', 638
execute rdt.rdtAddMsg 165454, 10, 'Ttl ASN: ',              'us_english', 638
execute rdt.rdtAddMsg 165455, 10, 'Ttl Qty: ',              'us_english', 638
execute rdt.rdtAddMsg 165456, 10, '65456^No RefNoSKU',      'us_english', 638

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 165451 AND 165500


