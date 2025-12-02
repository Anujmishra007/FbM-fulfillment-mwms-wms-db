-- rdt_1764SwapUCC12
--252551 - 252600

exec rdt.rdtDropMsg 252551, 252600

execute rdt.rdtAddMsg 252551, 10, '252551UCC scanned   ', 'us_english', 1764
execute rdt.rdtAddMsg 252552, 10, '252552BadTaskDtlKey ', 'us_english', 1764
execute rdt.rdtAddMsg 252553, 10, '252553Not an UCC    ', 'us_english', 1764
execute rdt.rdtAddMsg 252554, 10, '252554Multi SKU UCC ', 'us_english', 1764
execute rdt.rdtAddMsg 252555, 10, '252555Bad UCC Status', 'us_english', 1764
execute rdt.rdtAddMsg 252556, 10, '252556UCCLOCNotMatch', 'us_english', 1764
execute rdt.rdtAddMsg 252557, 10, '252557UCCIDNotMatch ', 'us_english', 1764
execute rdt.rdtAddMsg 252558, 10, '252558UCCSKUNotMatch', 'us_english', 1764
execute rdt.rdtAddMsg 252559, 10, '252559UCCQTYNotMatch', 'us_english', 1764
execute rdt.rdtAddMsg 252560, 10, '252560Not match L   ', 'us_english', 1764
execute rdt.rdtAddMsg 252561, 10, '252561UCCTookByOther', 'us_english', 1764
execute rdt.rdtAddMsg 252562, 10, '252562UCCHasTask    ', 'us_english', 1764
execute rdt.rdtAddMsg 252563, 10, '252563UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 252564, 10, '252564ActUCCTypeFail', 'us_english', 1764
execute rdt.rdtAddMsg 252565, 10, '252565UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 252566, 10, '252566PKDtl changed ', 'us_english', 1764
execute rdt.rdtAddMsg 252567, 10, '252567UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 252568, 10, '252568UPDPackFail   ', 'us_english', 1764
execute rdt.rdtAddMsg 252569, 10, '252569DupPackDtl    ', 'us_english', 1764
execute rdt.rdtAddMsg 252570, 10, '252570UPD UCC Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 252571, 10, '252571UPD UCC Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 252572, 10, '252572UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 252573, 10, '252573UPDLLIFail    ', 'us_english', 1764
execute rdt.rdtAddMsg 252574, 10, '252574UPDLLIFail    ', 'us_english', 1764
execute rdt.rdtAddMsg 252575, 10, '252575CanntSwap     ', 'us_english', 1764
execute rdt.rdtAddMsg 252576, 10, '252576UCCTookByOther', 'us_english', 1764



select * from rdt.rdtmsg (nolock) where message_id between 252551 and 252600