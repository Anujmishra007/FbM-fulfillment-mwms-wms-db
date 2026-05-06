--rdt_1878ExtUpd01
--execute rdt.rdtdropmsg 261301 - 261350
execute rdt.rdtDropMsg 261301, 261350

execute rdt.rdtAddMsg 261301 ,10, '261301^SUSRMissing',         'us_english', 1878, 0, '261301: SUSR value is missing'
execute rdt.rdtAddMsg 261302 ,10, '261302^ToIDNotExists',          'us_english', 1878, 0, '261302: ToID not exist'
execute rdt.rdtAddMsg 261303 ,10, '261303^NoLocFound',          'us_english', 1878, 0, '261303: No available location'
execute rdt.rdtAddMsg 261304 ,10, '261304^GenTaskKeyFail',      'us_english', 1878, 0, '261304: Generate TaskKey Fail'
execute rdt.rdtAddMsg 261305 ,10, '261305^InsTaskFail',         'us_english', 1878, 0, '261305: Insert TaskDetail fail'
execute rdt.rdtAddMsg 261306 ,10, '261306^FailToLockSuggLoc',   'us_english', 1878, 0, '261306: Failed to lock suggested loc'
execute rdt.rdtAddMsg 261307 ,10, '261307^PATaskExists',        'us_english', 1878, 0, '261307: PA Task already exist'

select * from rdt.rdtmsg (nolock) where message_id between 261301 and 261350