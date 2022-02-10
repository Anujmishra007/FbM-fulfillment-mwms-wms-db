-- rdt_608RcvCfm04
exec rdt.rdtDropMsg 131201, 131250

execute rdt.rdtAddMsg 131201, 10, '31201^Get POKey Fail', 'us_english', 608
execute rdt.rdtAddMsg 131202, 10, '31202^INS PO Fail   ', 'us_english', 608
execute rdt.rdtAddMsg 131203, 10, '31203^INS PODtl Fail', 'us_english', 608
execute rdt.rdtAddMsg 131204, 10, '31204^UPD PODtl Fail', 'us_english', 608
execute rdt.rdtAddMsg 131205, 10, '31205^EXCESS STOCK: ', 'us_english', 608
execute rdt.rdtAddMsg 131206, 10, '31206^TO ID:        ', 'us_english', 608
execute rdt.rdtAddMsg 131207, 10, '31207^TO LOC:       ', 'us_english', 608

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 131201 AND 131250
