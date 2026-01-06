
--rdt_1812SwapID05
--239901 - 239950

execute rdt.rdtDropMsg 239901 ,239950

execute rdt.rdtAddMsg 239901, 10, '239901^NeedID',              'us_english', 1812, 0, '239901: Need ID'
execute rdt.rdtAddMsg 239902, 10, '239902^BadTaskKey',          'us_english', 1812, 0, '239902: Invalid task key'
execute rdt.rdtAddMsg 239903, 10, '239903^CannotSwapID',        'us_english', 1812, 0, '239903: Cannot swap id for partial picking'
execute rdt.rdtAddMsg 239904, 10, '239904^CannotSwapID',        'us_english', 1812, 0, '239904: Cannot swap id'
execute rdt.rdtAddMsg 239905, 10, '239905^IDHasTask',           'us_english', 1812, 0, '239905: ID has a open task'
execute rdt.rdtAddMsg 239906, 10, '239906^IDOnHold',            'us_english', 1812, 0, '239906: ID is on hold'
execute rdt.rdtAddMsg 239907, 10, '239907^MixSKUID',            'us_english', 1812, 0, '239907: Cannot swap ID'
execute rdt.rdtAddMsg 239908, 10, '239908^IDOccupied',          'us_english', 1812, 0, '239908: ID is occupied'
execute rdt.rdtAddMsg 239909, 10, '239909^SKUNotMatch',         'us_english', 1812, 0, '239909: SKU not match'
execute rdt.rdtAddMsg 239910, 10, '239910^SKUNotMatch',         'us_english', 1812, 0, '239910: Qty not match'
execute rdt.rdtAddMsg 239911, 10, '239911^FromIDNotFound',      'us_english', 1812, 0, '239911: FromID not found'
execute rdt.rdtAddMsg 239912, 10, '239912^MustSameLocCate',     'us_english', 1812, 0, '239912: ID is not from same LOC category'
execute rdt.rdtAddMsg 239913, 10, '239913^NoEnoughLot',         'us_english', 1812, 0, '239913: No enough lot qty to swap ID'
execute rdt.rdtAddMsg 239914, 10, '239914^GetPKDKeyFail',       'us_english', 1812, 0, '239914: Get PickDetailKey Fail'
execute rdt.rdtAddMsg 239915, 10, '239915^GetPKDKeyFail',       'us_english', 1812, 0, '239915: Get PickDetailKey Fail'
execute rdt.rdtAddMsg 239916, 10, '239916^UpdPKDFail',          'us_english', 1812, 0, '239916: Update PickDetail Fail'
execute rdt.rdtAddMsg 239917, 10, '239917^UpdPKDFail',          'us_english', 1812, 0, '239917: Update PickDetail Fail'
execute rdt.rdtAddMsg 239918, 10, '239918^InsPKDFail',          'us_english', 1812, 0, '239918: Generate PickDetail Fail'
execute rdt.rdtAddMsg 239919, 10, '239919^UpdTaskFail',         'us_english', 1812, 0, '239919: Update Task Fail'


SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 239901 and 239950