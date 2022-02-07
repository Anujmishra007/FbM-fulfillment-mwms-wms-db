-- rdt_1829ExtValid02
exec rdt.rdtDropMsg 118501 , 118550

execute rdt.rdtAddMsg 118501, 10, '18501^Need ASN',         'us_english', 1829
execute rdt.rdtAddMsg 118502, 10, '18502^Invalid ASN',      'us_english', 1829
execute rdt.rdtAddMsg 118503, 10, '18503^UCC Not Exists',   'us_english', 1829
execute rdt.rdtAddMsg 118504, 10, '18504^X SAFETY STOCK',   'us_english', 1829

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 118501 AND 118550