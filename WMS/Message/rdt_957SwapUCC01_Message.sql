-- rdt_957SwapUCC01
-- FCR-7106
execute rdt.rdtDropMsg 243301, 243350

execute rdt.rdtAddMsg 243301, 10, '243301 BadPickTask',           'us_english', 957
execute rdt.rdtAddMsg 243302, 10, '243302 InvalidUCC',            'us_english', 957, 0, '243302 UCC is invalid'
execute rdt.rdtAddMsg 243303, 10, '243303 UPD PKDtl Fail',        'us_english', 957, 0, '243303 Update PickDetail Fail'
execute rdt.rdtAddMsg 243304, 10, '243304 UPD PKDtl Fail',        'us_english', 957, 0, '243304 Update PickDetail Fail'
execute rdt.rdtAddMsg 243305, 10, '243305 UPD PKDtl Fail',        'us_english', 957, 0, '243305 Update PickDetail Fail'
execute rdt.rdtAddMsg 243306, 10, '243306 UPD UCC Fail',          'us_english', 957, 0, '243306 Update UCC Fail'
execute rdt.rdtAddMsg 243307, 10, '243307 UPD UCC Fail',          'us_english', 957, 0, '243307 Update UCC Fail'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 243301 AND 243350