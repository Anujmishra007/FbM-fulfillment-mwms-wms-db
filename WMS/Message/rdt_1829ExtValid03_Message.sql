-- rdt_1829ExtValid03
exec rdt.rdtDropMsg 119501 , 119550

execute rdt.rdtAddMsg 119501, 10, '19501^Invalid ASN',      'us_english', 1829
execute rdt.rdtAddMsg 119502, 10, '19502^ASN Finalized',    'us_english', 1829
execute rdt.rdtAddMsg 119503, 10, '19503^Inv Cont ID',      'us_english', 1829
execute rdt.rdtAddMsg 119504, 10, '19504^ASN Finalized',    'us_english', 1829
execute rdt.rdtAddMsg 119505, 10, '19505^UCC Not Exists',   'us_english', 1829
execute rdt.rdtAddMsg 119506, 10, '19506^UCC Received',     'us_english', 1829
execute rdt.rdtAddMsg 119507, 10, '19507^UCC Not In Use',   'us_english', 1829
execute rdt.rdtAddMsg 119508, 10, '19508^Value Needed',     'us_english', 1829

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 119501 AND 119550