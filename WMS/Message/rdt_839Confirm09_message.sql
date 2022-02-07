

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN '178151' AND '178200'


--rdt_839Confirm09
EXEC rdt.rdtDropMsg 178151, 178200

execute rdt.rdtAddMsg 178151, 10, '178151UPD PKDtl Fail',   'us_english', 839
execute rdt.rdtAddMsg 178152, 10, '178152UPD PKDtl Fail',   'us_english', 839
execute rdt.rdtAddMsg 178153, 10, '178153UPD PKDtl Fail',   'us_english', 839
execute rdt.rdtAddMsg 178154, 10, '178154nspg_GetKey   ',   'us_english', 839
execute rdt.rdtAddMsg 178155, 10, '178155INS PKDtl Fail',   'us_english', 839
execute rdt.rdtAddMsg 178156, 10, '178156INS RefKeyFail',   'us_english', 839
execute rdt.rdtAddMsg 178157, 10, '178157UPD PKDtl Fail',   'us_english', 839
execute rdt.rdtAddMsg 178158, 10, '178158UPD PKDtl Fail',   'us_english', 839
execute rdt.rdtAddMsg 178159, 10, '178159UPD PKDtl Fail',   'us_english', 839
execute rdt.rdtAddMsg 178160, 10, '178160SKU Overpacked',   'us_english', 839
execute rdt.rdtAddMsg 178161, 10, '178161INS PKHdr Fail',   'us_english', 839
execute rdt.rdtAddMsg 178162, 10, '178162GEN Label Fail',   'us_english', 839
execute rdt.rdtAddMsg 178163, 10, '178163INS PKDtl Fail',   'us_english', 839
execute rdt.rdtAddMsg 178164, 10, '178164INS PKDtl Fail',   'us_english', 839
execute rdt.rdtAddMsg 178165, 10, '178165UPD PKDtl Fail',   'us_english', 839
execute rdt.rdtAddMsg 178166, 10, '178166 PackCfm Fail ',   'us_english', 839
