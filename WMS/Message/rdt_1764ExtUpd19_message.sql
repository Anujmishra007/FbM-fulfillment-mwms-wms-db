--rdt_1764ExtUpd19
execute rdt.rdtdropmsg 208401, 208450

execute rdt.rdtAddMsg 208401, 10, '208401FoundExtraUCC ', 'us_english', 1764
execute rdt.rdtAddMsg 208402, 10, '208402UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 208403, 10, '208403UpdTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg 208404, 10, '208404Need DropID   ', 'us_english', 1764
execute rdt.rdtAddMsg 208405, 10, '208405UpdTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg 208406, 10, '208406Scan-in Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 208407, 10, '208407UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 208408, 10, '208408UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 208409, 10, '208409UPDTaskDtlFail', 'us_english', 1764
execute rdt.rdtAddMsg 208410, 10, '208410UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 208411, 10, '208411UPD PKDtl Fail', 'us_english', 1764

SELECT * FROM rdt.rdtmsg(NOLOCK) WHERE Message_ID BETWEEN 176751 and 176800
