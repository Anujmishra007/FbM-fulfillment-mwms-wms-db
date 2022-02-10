--rdt_1764ExtUpd16
execute rdt.rdtdropmsg 176751, 176800

execute rdt.rdtAddMsg 176751, 10, '176751FoundExtraUCC ', 'us_english', 1764
execute rdt.rdtAddMsg 176752, 10, '176752UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 176753, 10, '176753UpdTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg 176754, 10, '176754Need DropID   ', 'us_english', 1764
execute rdt.rdtAddMsg 176755, 10, '176755UpdTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg 176756, 10, '176756Scan-in Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 176757, 10, '176757UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 176758, 10, '176758UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 176759, 10, '176759UPDTaskDtlFail', 'us_english', 1764
execute rdt.rdtAddMsg 176760, 10, '176760UPD PKDtl Fail', 'us_english', 1764

SELECT * FROM rdt.rdtmsg(NOLOCK) WHERE Message_ID BETWEEN 176751 and 176800
