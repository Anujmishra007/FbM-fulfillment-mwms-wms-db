--rdtfnc_TM_Replen
execute rdt.rdtdropmsg 72266, 72365

execute rdt.rdtAddMsg '72266', 10, '72266^DropID needed ', 'us_english', 1764
execute rdt.rdtAddMsg '72267', 10, '72267^DropID in used', 'us_english', 1764
execute rdt.rdtAddMsg '72268', 10, '72268^DropID in used', 'us_english', 1764
execute rdt.rdtAddMsg '72269', 10, '72269^QTYAVLNotEnuf ', 'us_english', 1764
execute rdt.rdtAddMsg '72270', 10, '72270^DelDropIDFail ', 'us_english', 1764
execute rdt.rdtAddMsg '72271', 10, '72271^DelDropIDFail ', 'us_english', 1764
execute rdt.rdtAddMsg '72272', 10, '72272^FromLOC needed', 'us_english', 1764
execute rdt.rdtAddMsg '72273', 10, '72273^FromLOC Diff  ', 'us_english', 1764
execute rdt.rdtAddMsg '72274', 10, '72274^FROM ID needed', 'us_english', 1764
execute rdt.rdtAddMsg '72275', 10, '72275^ID not match  ', 'us_english', 1764
execute rdt.rdtAddMsg '72276', 10, '72276^Need SKU      ', 'us_english', 1764
execute rdt.rdtAddMsg '72277', 10, '72277^Invalid SKU   ', 'us_english', 1764
execute rdt.rdtAddMsg '72278', 10, '72278^MultiSKUBarCod', 'us_english', 1764
execute rdt.rdtAddMsg '72279', 10, '72279^Different SKU ', 'us_english', 1764
execute rdt.rdtAddMsg '72280', 10, '72280^Invalid QTY   ', 'us_english', 1764
execute rdt.rdtAddMsg '72281', 10, '72281^Invalid QTY   ', 'us_english', 1764
execute rdt.rdtAddMsg '72282', 10, '72282^Option needed ', 'us_english', 1764
execute rdt.rdtAddMsg '72283', 10, '72283^Invalid Option', 'us_english', 1764
execute rdt.rdtAddMsg '72284', 10, '72284^UpdTaskDtlFail', 'us_english', 1764
execute rdt.rdtAddMsg '72285', 10, '72285^ToLOC needed  ', 'us_english', 1764
execute rdt.rdtAddMsg '72286', 10, '72286^ToLOC Diff    ', 'us_english', 1764
execute rdt.rdtAddMsg '72287', 10, '72287^NextTaskFncErr', 'us_english', 1764
execute rdt.rdtAddMsg '72288', 10, '72288^NextTaskScnErr', 'us_english', 1764
execute rdt.rdtAddMsg '72289', 10, '72289^UpdTaskDtlFail', 'us_english', 1764
execute rdt.rdtAddMsg '72290', 10, '72290^Option needed ', 'us_english', 1764
execute rdt.rdtAddMsg '72291', 10, '72291^Invalid Option', 'us_english', 1764
execute rdt.rdtAddMsg '72292', 10, '72292^Reason needed ', 'us_english', 1764
execute rdt.rdtAddMsg '72293', 10, '72293^InsSkipTskFail', 'us_english', 1764
execute rdt.rdtAddMsg '72294', 10, '72294^UpdTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg '72295', 10, '72295^UpdTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg '72296', 10, '72296^DelRPFLogFail ', 'us_english', 1764
execute rdt.rdtAddMsg '72297', 10, '72297^QTYALC/QTYRPL ', 'us_english', 1764
execute rdt.rdtAddMsg '72298', 10, '72298^INS RPFLogFail', 'us_english', 1764
execute rdt.rdtAddMsg '72299', 10, '72299^Invalid Reason', 'us_english', 1764
execute rdt.rdtAddMsg '72300', 10, '72300^DropID used   ', 'us_english', 1764
execute rdt.rdtAddMsg '72301', 10, '72301^Over replenish', 'us_english', 1764
execute rdt.rdtAddMsg '72302', 10, '72302^FullShortNoQTY', 'us_english', 1764
execute rdt.rdtAddMsg '72303', 10, '72303^DropID TooLong', 'us_english', 1764

--WMS-17383
execute rdt.rdtAddMsg '72304', 10, '72304^GenDropIDFail ', 'us_english', 1764

--FCR-7730
execute rdt.rdtAddMsg '72305', 10, '72305^Invalid LOC   ', 'us_english', 1764

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 72266 and 72365 
