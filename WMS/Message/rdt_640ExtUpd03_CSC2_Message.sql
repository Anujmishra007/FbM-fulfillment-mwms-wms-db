-- 270751 - 270800

execute rdt.rdtDropMsg 270751 , 270800

execute rdt.rdtAddMsg 270751, 10, '270751^UPD PKDtl Fail',   'us_english', 640
execute rdt.rdtAddMsg 270752, 10, '270752^Upd PKDtl Err',    'us_english', 640
execute rdt.rdtAddMsg 270753, 10, '270753^Upd PKDtl Err',    'us_english', 640

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 270751 AND 270800


