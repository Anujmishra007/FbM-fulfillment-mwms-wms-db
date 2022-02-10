--rdt_839Confirm07
execute rdt.rdtdropmsg 171001, 171050

execute rdt.rdtAddMsg 171001, 10, '171001UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 171002, 10, '171002UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 171003, 10, '171003UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 171004, 10, '171004nspg_GetKey   ', 'us_english', 839
execute rdt.rdtAddMsg 171005, 10, '171005INS PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 171006, 10, '171006INS RefKeyFail', 'us_english', 839
execute rdt.rdtAddMsg 171007, 10, '171007UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 171008, 10, '171008UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 171009, 10, '171009UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 171010, 10, '171010SKU Overpacked', 'us_english', 839
execute rdt.rdtAddMsg 171011, 10, '171011INS PKHdr Fail', 'us_english', 839
execute rdt.rdtAddMsg 171012, 10, '171012GEN Label Fail', 'us_english', 839
execute rdt.rdtAddMsg 171013, 10, '171013INS PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 171014, 10, '171014INS PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 171015, 10, '171015UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 171016, 10, '171016 PackCfm Fail ', 'us_english', 839

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 171001 AND 171050




