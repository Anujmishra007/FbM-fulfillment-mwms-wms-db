--rdt_839Confirm05
execute rdt.rdtDropMsg 143201, 143250

execute rdt.rdtAddMsg 143201, 10, '43201^UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 143202, 10, '43202^UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 143203, 10, '43203^UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 143204, 10, '43204^nspg_GetKey   ', 'us_english', 839
execute rdt.rdtAddMsg 143205, 10, '43205^INS PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 143206, 10, '43206^INS RefKeyFail', 'us_english', 839
execute rdt.rdtAddMsg 143207, 10, '43207^UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 143208, 10, '43208^UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 143209, 10, '43209^UPD PKDtl Fail', 'us_english', 839

--WMS-18027
execute rdt.rdtAddMsg 143210, 10, '43210^UPD ORDDtl Err', 'us_english', 839
execute rdt.rdtAddMsg 143211, 10, '43211^UPD ORDHdr Err', 'us_english', 839

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 143201 AND 143250
