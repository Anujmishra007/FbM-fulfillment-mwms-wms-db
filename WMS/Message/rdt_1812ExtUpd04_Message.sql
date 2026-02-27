-- rdt_1812ExtUpd04
-- 239751 - 239800

execute rdt.rdtDropMsg 239751, 239751

execute rdt.rdtAddMsg 239751, 10, '239751^UpdTaskFail',     'us_english', 1812, 0, '239751: Update TaskDetail Fails'
execute rdt.rdtAddMsg 239752, 10, '239752^UpdTaskFail',     'us_english', 1812, 0, '239752: Update TaskDetail Fails'
execute rdt.rdtAddMsg 239753, 10, '239753^UpdInvHoldFail',  'us_english', 1812, 0, '239753: Update InventoryHold Fails'


SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 239751 and 239751
