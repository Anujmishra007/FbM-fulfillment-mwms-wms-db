-- rdt_UCCMergePalletChk
exec rdt.rdtDropMsg 77101, 77150

execute rdt.rdtAddMsg 77101, 10, '77101^FrIDNotClosePL', 'us_english', 528
execute rdt.rdtAddMsg 77102, 10, '77102^ToIDNotClosePL', 'us_english', 528
execute rdt.rdtAddMsg 77103, 10, '77103^FrID MixSKUUCC', 'us_english', 528
execute rdt.rdtAddMsg 77104, 10, '77104^ToID MixSKUUCC', 'us_english', 528
execute rdt.rdtAddMsg 77105, 10, '77105^MultipleUCCQty', 'us_english', 528
execute rdt.rdtAddMsg 77106, 10, '77106^MultipleUCCQty', 'us_english', 528
execute rdt.rdtAddMsg 77107, 10, '77107^GetKey Fail   ', 'us_english', 528
execute rdt.rdtAddMsg 77108, 10, '77108^InsTaskDetFail', 'us_english', 528
