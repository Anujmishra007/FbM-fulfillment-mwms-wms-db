--rdt_839Confirm11
execute rdt.rdtdropmsg 186201 , 186250

execute rdt.rdtAddMsg 1862001, 10, '1862001UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 1862002, 10, '1862002UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 1862003, 10, '1862003UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 1862004, 10, '1862004nspg_GetKey   ', 'us_english', 839
execute rdt.rdtAddMsg 1862005, 10, '1862005INS PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 1862006, 10, '1862006INS RefKeyFail', 'us_english', 839
execute rdt.rdtAddMsg 1862007, 10, '1862007UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 1862008, 10, '1862008UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 1862009, 10, '1862009UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 1862010, 10, '1862010SKU Overpacked', 'us_english', 839
execute rdt.rdtAddMsg 1862011, 10, '1862011INS PKHdr Fail', 'us_english', 839
execute rdt.rdtAddMsg 1862012, 10, '1862012GEN Label Fail', 'us_english', 839
execute rdt.rdtAddMsg 1862013, 10, '1862013INS PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 1862014, 10, '1862014INS PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 1862015, 10, '1862015UPD PKDtl Fail', 'us_english', 839
execute rdt.rdtAddMsg 1862016, 10, '1862016 PackCfm Fail ', 'us_english', 839

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 171001 AND 171050




