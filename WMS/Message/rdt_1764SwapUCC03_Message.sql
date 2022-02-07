-- rdt_1764SwapUCC03
exec rdt.rdtDropMsg 154151 , 154200

execute rdt.rdtAddMsg 154151, 10, '54151^UCC scanned',      'us_english', 1764
execute rdt.rdtAddMsg 154152, 10, '54152^BadTaskDtlKey',    'us_english', 1764
execute rdt.rdtAddMsg 154153, 10, '54153^InsPackDtlFail',   'us_english', 1764
execute rdt.rdtAddMsg 154154, 10, '54154^Multi SKU UCC',    'us_english', 1764
execute rdt.rdtAddMsg 154155, 10, '54155^Bad UCC Status',   'us_english', 1764
execute rdt.rdtAddMsg 154156, 10, '54156^UCCLOCNotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 154157, 10, '54157^UCCIDNotMatch',    'us_english', 1764
execute rdt.rdtAddMsg 154158, 10, '54158^UCCSKUNotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 154159, 10, '54159^UCCQTYNotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 154160, 10, '54160^UCCL02NotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 154161, 10, '54161^UCCL03NotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 154162, 10, '54162^UCCL04NotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 154163, 10, '54163^UCCL07NotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 154164, 10, '54164^UCCL10NotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 154165, 10, '54165^UCCTookByOther',   'us_english', 1764
execute rdt.rdtAddMsg 154166, 10, '54166^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 154167, 10, '54167^PKDtl changed',    'us_english', 1764
execute rdt.rdtAddMsg 154168, 10, '54168^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 154169, 10, '54169^UPD UCC Fail',     'us_english', 1764
execute rdt.rdtAddMsg 154170, 10, '54170^UPD UCC Fail',     'us_english', 1764
execute rdt.rdtAddMsg 154171, 10, '54171^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 154172, 10, '54172^UPDPackDtlFail',   'us_english', 1764
execute rdt.rdtAddMsg 154173, 10, '54173^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 154174, 10, '54174^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 154175, 10, '54175^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 154176, 10, '54176^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 154177, 10, '54177^UPDPackDtlFail',   'us_english', 1764
execute rdt.rdtAddMsg 154178, 10, '54178^UPDPackDtlFail',   'us_english', 1764
execute rdt.rdtAddMsg 154179, 10, '54179^No PKDtl Found',   'us_english', 1764


SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 154151 AND 154200


