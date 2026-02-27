--rdt_869ExtScn01
--FCR-6730

EXECUTE rdt.rdtdropmsg 245551, 245600

EXECUTE rdt.rdtAddMsg 245551, 10, '245551 Need Value',            'us_english', 869, 0, '245551 Need Value'
EXECUTE rdt.rdtAddMsg 245552, 10, '245552 Key-in OneOnly',        'us_english', 869, 0, '245552 Key-in OneOnly'
EXECUTE rdt.rdtAddMsg 245553, 10, '245553 InvalidWaveKey',        'us_english', 869, 0, '245553 Invalid WaveKey'
EXECUTE rdt.rdtAddMsg 245554, 10, '245554 NotFinishPick',         'us_english', 869, 0, '245554 Pick is not finished'
EXECUTE rdt.rdtAddMsg 245555, 10, '245555 InvalidLoadKey',        'us_english', 869, 0, '245555 Invalid LoadKey'
EXECUTE rdt.rdtAddMsg 245556, 10, '245556 NotFinishPick',         'us_english', 869, 0, '245556 Pick is not finished'
EXECUTE rdt.rdtAddMsg 245557, 10, '245557 InvalidOrderKey',       'us_english', 869, 0, '245557 Invalid Order Key'
EXECUTE rdt.rdtAddMsg 245558, 10, '245558 NotFinishPick',         'us_english', 869, 0, '245558 Pick is not finished'
EXECUTE rdt.rdtAddMsg 245559, 10, '245559 Need Wavekey',          'us_english', 869, 0, '245559 Need WaveKey'
EXECUTE rdt.rdtAddMsg 245560, 10, '245560 InvalidShipRef',        'us_english', 869, 0, '245560 Invalid Ship Ref'
EXECUTE rdt.rdtAddMsg 245561, 10, '245561 NoPickFound',           'us_english', 869, 0, '245561 No pick data found'
EXECUTE rdt.rdtAddMsg 245562, 10, '245562 NotFinishPick',         'us_english', 869, 0, '245562 Pick is not finished'
EXECUTE rdt.rdtAddMsg 245563, 10, '245563 NoShortPick',           'us_english', 869, 0, '245563 No Short Pick'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 245551 AND 245600
