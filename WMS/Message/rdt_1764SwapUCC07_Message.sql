-- rdt_1764SwapUCC07
exec rdt.rdtDropMsg 166401, 166450

execute rdt.rdtAddMsg 166401, 10, '166401UCC scanned   ', 'us_english', 1764
execute rdt.rdtAddMsg 166402, 10, '166402BadTaskDtlKey ', 'us_english', 1764
execute rdt.rdtAddMsg 166403, 10, '166403Not an UCC    ', 'us_english', 1764
execute rdt.rdtAddMsg 166404, 10, '166404Multi SKU UCC ', 'us_english', 1764
execute rdt.rdtAddMsg 166405, 10, '166405Bad UCC Status', 'us_english', 1764
execute rdt.rdtAddMsg 166406, 10, '166406UCCLOCNotMatch', 'us_english', 1764
execute rdt.rdtAddMsg 166407, 10, '166407UCCIDNotMatch ', 'us_english', 1764
execute rdt.rdtAddMsg 166408, 10, '166408UCCSKUNotMatch', 'us_english', 1764
execute rdt.rdtAddMsg 166409, 10, '166409UCCQTYNotMatch', 'us_english', 1764
execute rdt.rdtAddMsg 166410, 10, '166410Not match L   ', 'us_english', 1764
execute rdt.rdtAddMsg 166411, 10, '166411UCCTookByOther', 'us_english', 1764
execute rdt.rdtAddMsg 166412, 10, '166412UCCTookByOther', 'us_english', 1764
execute rdt.rdtAddMsg 166413, 10, '166413UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166414, 10, '166414ActUCCTypeFail', 'us_english', 1764
execute rdt.rdtAddMsg 166415, 10, '166415UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166416, 10, '166416UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166417, 10, '166417UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166418, 10, '166418PKDtl changed ', 'us_english', 1764
execute rdt.rdtAddMsg 166419, 10, '166419UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166420, 10, '166420UPD UCC Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 166421, 10, '166421UPD UCC Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 166422, 10, '166422UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166423, 10, '166423UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166424, 10, '166424PKDtl changed ', 'us_english', 1764
execute rdt.rdtAddMsg 166425, 10, '166425UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166426, 10, '166426UPD UCC Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 166427, 10, '166427UPD UCC Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 166428, 10, '166428UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166429, 10, '166429PKDtl changed ', 'us_english', 1764
execute rdt.rdtAddMsg 166430, 10, '166430UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166431, 10, '166431UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166432, 10, '166432UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166433, 10, '166433PKDtl changed ', 'us_english', 1764
execute rdt.rdtAddMsg 166434, 10, '166434PKDtl changed ', 'us_english', 1764
execute rdt.rdtAddMsg 166435, 10, '166435UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166436, 10, '166436UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166437, 10, '166437UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166438, 10, '166438UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166439, 10, '166439Data error    ', 'us_english', 1764
execute rdt.rdtAddMsg 166440, 10, '166440UPD UCC Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 166441, 10, '166441UPD UCC Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 166442, 10, '166442MissingPackDtl', 'us_english', 1764
execute rdt.rdtAddMsg 166443, 10, '166443DUP PackDtl   ', 'us_english', 1764
execute rdt.rdtAddMsg 166444, 10, '166444MissingPackDtl', 'us_english', 1764
execute rdt.rdtAddMsg 166445, 10, '166445DUP PackDtl   ', 'us_english', 1764
execute rdt.rdtAddMsg 166446, 10, '166446MissingPackDtl', 'us_english', 1764
execute rdt.rdtAddMsg 166447, 10, '166447DUP PackDtl   ', 'us_english', 1764
execute rdt.rdtAddMsg 166448, 10, '166448MissingPackDtl', 'us_english', 1764
execute rdt.rdtAddMsg 166449, 10, '166449DUP PackDtl   ', 'us_english', 1764
execute rdt.rdtAddMsg 166450, 10, '166450MissingPackDtl', 'us_english', 1764


select * from rdt.rdtMsg (nolock) where message_id between 166401 and 166450