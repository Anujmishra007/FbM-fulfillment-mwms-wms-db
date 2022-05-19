-- rdtfnc_UCCReceive
execute rdt.rdtDropMsg 63116, 63200

execute rdt.rdtAddMsg 63116, 10, '63116^ASN or PO req',   'us_english', 898
execute rdt.rdtAddMsg 63117, 10, '63117^Invalid ASN/PO',  'us_english', 898
execute rdt.rdtAddMsg 63118, 10, '63118^ASN not exists',  'us_english', 898
execute rdt.rdtAddMsg 63119, 10, '63119^PO needed',       'us_english', 898
execute rdt.rdtAddMsg 63120, 10, '63120^PO not exists',   'us_english', 898
execute rdt.rdtAddMsg 63121, 10, '63121^ASN needed',      'us_english', 898
execute rdt.rdtAddMsg 63122, 10, '63122^Diff facility',   'us_english', 898
execute rdt.rdtAddMsg 63123, 10, '63123^Diff storer',     'us_english', 898
execute rdt.rdtAddMsg 63124, 10, '63124^TradeReturnASN',  'us_english', 898
execute rdt.rdtAddMsg 63125, 10, '63125^ASN closed',      'us_english', 898
execute rdt.rdtAddMsg 63126, 10, '63126^ASN closed',      'us_english', 898
execute rdt.rdtAddMsg 63127, 10, '63127^ASN cancelled',   'us_english', 898
execute rdt.rdtAddMsg 63128, 10, '63128^TO LOC needed',   'us_english', 898
execute rdt.rdtAddMsg 63129, 10, '63129^Diff facility',   'us_english', 898
execute rdt.rdtAddMsg 63130, 10, '63130^TO ID needed',    'us_english', 898
execute rdt.rdtAddMsg 63131, 10, '63131^nspGetRight',     'us_english', 898
execute rdt.rdtAddMsg 63132, 10, '63132^Duplicate ID',    'us_english', 898
execute rdt.rdtAddMsg 63133, 10, '63133^QTY needed',      'us_english', 898
execute rdt.rdtAddMsg 63134, 10, '63134^Invalid QTY',     'us_english', 898
execute rdt.rdtAddMsg 63135, 10, '63135^Max No of CTN',   'us_english', 898
execute rdt.rdtAddMsg 63136, 10, '63136^UCC Required',    'us_english', 898
execute rdt.rdtAddMsg 63137, 10, '63137^Multi SKU/UCC',   'us_english', 898
execute rdt.rdtAddMsg 63138, 10, '63138^UCC Received',    'us_english', 898
execute rdt.rdtAddMsg 63139, 10, '63139^UCC Not Found',   'us_english', 898
execute rdt.rdtAddMsg 63140, 10, '63140^Invalid UCCQTY',  'us_english', 898
execute rdt.rdtAddMsg 63141, 10, '63141^Need Lottable',   'us_english', 898
execute rdt.rdtAddMsg 63142, 10, '63142^Invalid Option',  'us_english', 898
execute rdt.rdtAddMsg 63143, 10, '63143^SKU required',    'us_english', 898
execute rdt.rdtAddMsg 63144, 10, '63144^Invalid Sku',     'us_english', 898
execute rdt.rdtAddMsg 63145, 10, '63145^QTY required',    'us_english', 898
execute rdt.rdtAddMsg 63146, 10, '63146^Invalid Qty',     'us_english', 898
execute rdt.rdtAddMsg 63147, 10, '63147^CaseCnt Diff',    'us_english', 898
execute rdt.rdtAddMsg 63148, 10, '63148^Invalid Option',  'us_english', 898
execute rdt.rdtAddMsg 63149, 10, '63149^Invalid Date',    'us_english', 898
execute rdt.rdtAddMsg 63150, 10, '63150^Invalid Qty',     'us_english', 898
execute rdt.rdtAddMsg 63151, 10, '63151^Lottable01 req',  'us_english', 898
execute rdt.rdtAddMsg 63152, 10, '63152^Lottable02 req',  'us_english', 898
execute rdt.rdtAddMsg 63153, 10, '63153^Lottable03 req',  'us_english', 898
execute rdt.rdtAddMsg 63154, 10, '63154^Lottable04 req',  'us_english', 898
execute rdt.rdtAddMsg 63155, 10, '63155^Lottable01 req',  'us_english', 898
execute rdt.rdtAddMsg 63156, 10, '63156^Lottable02 req',  'us_english', 898
execute rdt.rdtAddMsg 63157, 10, '63157^Lottable03 req',  'us_english', 898
execute rdt.rdtAddMsg 63158, 10, '63158^Lottable04 req',  'us_english', 898
execute rdt.rdtAddMsg 63159, 10, '63159^Option required', 'us_english', 898
execute rdt.rdtAddMsg 63160, 10, '63160^Option required', 'us_english', 898
execute rdt.rdtAddMsg 63161, 10, '63161^Invalid TO LOC',  'us_english', 898
execute rdt.rdtAddMsg 63162, 10, '63162^Wrong count',     'us_english', 898
execute rdt.rdtAddMsg 63163, 10, '63163^SameBarCodeSKU',  'us_english', 898
execute rdt.rdtAddMsg 63164, 10, '63164^Invalid Format',  'us_english', 898
execute rdt.rdtAddMsg 63165, 10, '63165^ASN needed',      'us_english', 898
execute rdt.rdtAddMsg 63166, 10, '63166^Option required', 'us_english', 898
execute rdt.rdtAddMsg 63167, 10, '63167^Invalid option',  'us_english', 898
execute rdt.rdtAddMsg 63168, 10, '63168^UPD DID Fail',    'us_english', 898
execute rdt.rdtAddMsg 63169, 10, '63169^Different SKU',   'us_english', 898

--(ChewKP03) 
execute rdt.rdtAddMsg 63170, 10, '63170^Invalid Format',   'us_english', 898
execute rdt.rdtAddMsg 63171, 10, '63171^Invalid Format',   'us_english', 898
execute rdt.rdtAddMsg 63172, 10, '63172^Invalid Format',   'us_english', 898

-- WMS-19453
execute rdt.rdtAddMsg 63173, 10, '63173^Invalid Format',   'us_english', 898