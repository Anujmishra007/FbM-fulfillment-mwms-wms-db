-- isp_950DecodeLBLNo01
execute rdt.rdtDropMsg 51501, 51550

execute rdt.rdtAddMsg 51501, 10, '51501 ID is UCCNo   ', 'us_english', 1580
execute rdt.rdtAddMsg 51502, 10, '51502 ID is LabelNo ', 'us_english', 1580
execute rdt.rdtAddMsg 51503, 10, '51503 ID used in ASN', 'us_english', 1580
