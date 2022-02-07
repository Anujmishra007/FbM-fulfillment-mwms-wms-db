-- ntrRFPutawayAdd (range 82151 - 82200)

-- delete from rdt.rdtMsg where message_id between 82151 and 82200
-- execute rdt.rdtDropMsg 82151, 82200

-- ntrRFPutawayAdd
execute rdt.rdtAddMsg 82151, 10, '82151^OverMaxPallet',  'us_english'
execute rdt.rdtAddMsg 82152, 10, '82152^OverMaxPallet',  'us_english'
execute rdt.rdtAddMsg 82157, 10, '82157^OnlyAllow1SKU',  'us_english'
execute rdt.rdtAddMsg 82158, 10, '82158^EmptySKU',       'us_english'
execute rdt.rdtAddMsg 82159, 10, '82159^OnlyAllow1SKU',  'us_english'
execute rdt.rdtAddMsg 82160, 10, '82160^DiffSKUSize',    'us_english'

SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 82151 AND 82200
