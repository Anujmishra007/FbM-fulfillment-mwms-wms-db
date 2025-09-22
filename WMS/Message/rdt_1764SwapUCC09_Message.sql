-- rdt_1764SwapUCC09
--230351 - 230400
--230401 - 230450

exec rdt.rdtDropMsg 230351, 230450

execute rdt.rdtAddMsg 230351, 10, '230351UCC scanned   ', 'us_english', 1764
execute rdt.rdtAddMsg 230352, 10, '230352BadTaskDtlKey ', 'us_english', 1764
execute rdt.rdtAddMsg 230353, 10, '230353Not an UCC    ', 'us_english', 1764
execute rdt.rdtAddMsg 230354, 10, '230354Multi SKU UCC ', 'us_english', 1764
execute rdt.rdtAddMsg 230355, 10, '230355Bad UCC Status', 'us_english', 1764
execute rdt.rdtAddMsg 230356, 10, '230356UCCLOCNotMatch', 'us_english', 1764
execute rdt.rdtAddMsg 230357, 10, '230357UCCIDNotMatch ', 'us_english', 1764
execute rdt.rdtAddMsg 230358, 10, '230358UCCSKUNotMatch', 'us_english', 1764
execute rdt.rdtAddMsg 230359, 10, '230359UCCQTYNotMatch', 'us_english', 1764
--FCR-7730
execute rdt.rdtAddMsg 230360, 10, '230360Not match L   ', 'us_english', 1764
--execute rdt.rdtAddMsg 230361, 10, '166411UCCTookByOther', 'us_english', 1764
--execute rdt.rdtAddMsg 230362, 10, '166412UCCTookByOther', 'us_english', 1764

execute rdt.rdtAddMsg 230364, 10, '230364ActUCCTypeFail', 'us_english', 1764
execute rdt.rdtAddMsg 230365, 10, '230365UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 230366, 10, '230366UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 230367, 10, '230367UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 230368, 10, '230368PKDtl changed ', 'us_english', 1764
execute rdt.rdtAddMsg 230369, 10, '230369UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 230370, 10, '230370UPD UCC Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 230371, 10, '230371UPD UCC Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 230372, 10, '230372UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 230373, 10, '230373UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 230374, 10, '230374PKDtl changed ', 'us_english', 1764
execute rdt.rdtAddMsg 230375, 10, '230375UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 230376, 10, '230376UPD UCC Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 230377, 10, '230377UPD UCC Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 230378, 10, '230378UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 230379, 10, '230379PKDtl changed ', 'us_english', 1764
execute rdt.rdtAddMsg 230380, 10, '230380UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 230381, 10, '230381UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 230382, 10, '230382UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 230383, 10, '230383PKDtl changed ', 'us_english', 1764
execute rdt.rdtAddMsg 230384, 10, '230384PKDtl changed ', 'us_english', 1764
execute rdt.rdtAddMsg 230385, 10, '230385UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 230386, 10, '230386UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 230387, 10, '230387UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 230388, 10, '230388UPD TKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 230389, 10, '230389Data error    ', 'us_english', 1764
execute rdt.rdtAddMsg 230390, 10, '230390UPD UCC Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 230391, 10, '230391UPD UCC Fail  ', 'us_english', 1764
--execute rdt.rdtAddMsg 230392, 10, '166442MissingPackDtl', 'us_english', 1764
--execute rdt.rdtAddMsg 230393, 10, '166443DUP PackDtl   ', 'us_english', 1764
execute rdt.rdtAddMsg 230394, 10, '230394MissingPackDtl', 'us_english', 1764
execute rdt.rdtAddMsg 230395, 10, '230395DUP PackDtl   ', 'us_english', 1764
execute rdt.rdtAddMsg 230396, 10, '230396MissingPackDtl', 'us_english', 1764
execute rdt.rdtAddMsg 230397, 10, '230397DUP PackDtl   ', 'us_english', 1764
execute rdt.rdtAddMsg 230398, 10, '230398MissingPackDtl', 'us_english', 1764
execute rdt.rdtAddMsg 230399, 10, '230399DUP PackDtl   ', 'us_english', 1764
execute rdt.rdtAddMsg 230400, 10, '230400MissingPackDtl', 'us_english', 1764
--execute rdt.rdtAddMsg 230401, 10, '166451 Double Scan  ', 'us_english', 1764
--New added msg
execute rdt.rdtAddMsg 230363, 10, '230363UCCLotNotMatch', 'us_english', 1764
execute rdt.rdtAddMsg 230402, 10, '203402DUP PackDtl   ', 'us_english', 1764

select * from rdt.rdtMsg (nolock) where message_id between 230351 and 230450