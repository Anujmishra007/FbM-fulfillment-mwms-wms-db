-- rdt_839ExtUpd09
--256101 - 256150

execute rdt.rdtDropMsg 256101, 256150

execute rdt.rdtAddMsg 256101, 10, '256101^HoldInvFail',     'us_english', 839, 0, '256101: Hold Inventory Fail'
execute rdt.rdtAddMsg 256102, 10, '256102^GenKeyFail',      'us_english', 839, 0, '256102: Generate CCKey Fail'
execute rdt.rdtAddMsg 256103, 10, '256103^GenKeyFail',      'us_english', 839, 0, '256103: Generate TaskKey Fail'
execute rdt.rdtAddMsg 256104, 10, '256104^InsTaskFail',     'us_english', 839, 0, '256104: Insert Task Fail'

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 256101 and 256150

