--rdt_598DecodeSP02

execute rdt.rdtDropMsg 141101, 141150

execute rdt.rdtAddMsg 141101, 10, '41101^Invalid SSCC',    'us_english', 598
execute rdt.rdtAddMsg 141102, 10, '41102^Double Scan',     'us_english', 598


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 141101 AND 141150 