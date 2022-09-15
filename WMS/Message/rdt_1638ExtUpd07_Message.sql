--rdt_1638ExtUpd07
execute rdt.rdtDropMsg 187501 , 187550

execute rdt.rdtAddMsg 187501, 10, '187501 No OrderKey  ',   'us_english', 1638
execute rdt.rdtAddMsg 187502, 10, '187502 NO ORDERKEY  ',   'us_english', 1638
execute rdt.rdtAddMsg 187503, 10, '187503 INS MBOL Fail',   'us_english', 1638
execute rdt.rdtAddMsg 187504, 10, '187504 MBOL shipped ',   'us_english', 1638
execute rdt.rdtAddMsg 187505, 10, '187505 MBOL FAC Diff',   'us_english', 1638
execute rdt.rdtAddMsg 187506, 10, '187506INS MBDtl Fail',   'us_english', 1638
execute rdt.rdtAddMsg 187507, 10, '187507UPD MBDtl Fail',   'us_english', 1638
execute rdt.rdtAddMsg 187508, 10, '187508UPD Order Fail',   'us_english', 1638
execute rdt.rdtAddMsg 187509, 10, '187509UPD PACKI Fail',   'us_english', 1638

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 187501 AND 187550

