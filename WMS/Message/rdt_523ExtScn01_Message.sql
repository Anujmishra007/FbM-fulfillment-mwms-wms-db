--rdt_523ExtScn01
--257201 - 257250



execute rdt.rdtdropmsg 257201, 257250

execute rdt.rdtAddMsg 257201, 10, '257201 PABySKULotOff', 'us_english', 523, 0, '257201: PABySKUAndLot config must be on'
execute rdt.rdtAddMsg 257202,  10, '257202^No more rec   ', 'us_english', 523
execute rdt.rdtAddMsg 257203, 10, '257203^No more rec   ', 'us_english', 523
execute rdt.rdtAddMsg 257204, 10, '257204^Invalid QTY   ', 'us_english', 523
execute rdt.rdtAddMsg 257205, 10, '257205^Invalid QTY   ', 'us_english', 523
execute rdt.rdtAddMsg 257206, 10, '257206^QTY needed    ', 'us_english', 523
execute rdt.rdtAddMsg 257207, 10, '257207^QTY NOT MATCH ', 'us_english', 523
execute rdt.rdtAddMsg 257208, 10, '257208^QTYPWY NotEnuf', 'us_english', 523
execute rdt.rdtAddMsg 257209, 10, '257209^NoSuitableLOC ', 'us_english', 523
execute rdt.rdtAddMsg 257210, 10, '257210^NoSuggestedLOC', 'us_english', 523
execute rdt.rdtAddMsg 257211, 10, '257211^OptionRequired', 'us_english', 523
execute rdt.rdtAddMsg 257212, 10, '257212^SuggLocNotLoseID', 'us_english', 523, 0, '257202: SuggestLoc must be lose ID'

select * from rdt.rdtmsg with (nolock) where message_id between 257201 and 257250