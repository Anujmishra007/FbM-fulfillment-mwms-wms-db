--rdt_MbolCreation
rdt.rdtDropMsg 172151 , 172200	

execute rdt.rdtAddMsg 172151, 10, '172151ORDERS IN MBOL',   'us_english', 1856
execute rdt.rdtAddMsg 172152, 10, '172152 nspg_getkey  ',   'us_english', 1856
execute rdt.rdtAddMsg 172153, 10, '172153INS MBOL Err  ',   'us_english', 1856
execute rdt.rdtAddMsg 172154, 10, '172154INS MBODtl Err',   'us_english', 1856

--WMS-20213
execute rdt.rdtAddMsg 172155, 10, '172155 NO ORDERS ADD',   'us_english', 1856

--WMS-21114
execute rdt.rdtAddMsg 172156, 10, '172156UPDCTNCOUNT ER',   'us_english', 1856

--WMS-21350
execute rdt.rdtAddMsg 172157, 10, '172157 nspg_getkey  ',   'us_english', 1856
execute rdt.rdtAddMsg 172158, 10, '172158 INS MBOL Err ',   'us_english', 1856

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 172151 AND 172200	