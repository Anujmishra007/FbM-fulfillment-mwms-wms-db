--rdtfnc_PalletConsolidate_SSCC
execute rdt.rdtdropmsg 97751 , 97800
execute rdt.rdtdropmsg 102251 , 102300

execute rdt.rdtAddMsg 97751, 10, '97751^PALLET ID REQ',  'us_english', 1723
execute rdt.rdtAddMsg 97752, 10, '97752^INVALID FORMAT', 'us_english', 1723
execute rdt.rdtAddMsg 97753, 10, '97753^INVALID ID',     'us_english', 1723
execute rdt.rdtAddMsg 97754, 10, '97754^NotInStorerGrp', 'us_english', 1723
execute rdt.rdtAddMsg 97755, 10, '97755^ID IS SHIPPED',  'us_english', 1723
execute rdt.rdtAddMsg 97756, 10, '97756^PLT NOT STAGED', 'us_english', 1723
execute rdt.rdtAddMsg 97757, 10, '97757^OPTION REQ',     'us_english', 1723
execute rdt.rdtAddMsg 97758, 10, '97758^INVALID OPTION', 'us_english', 1723
execute rdt.rdtAddMsg 97759, 10, '97759^SSCC REQUIRED',  'us_english', 1723
execute rdt.rdtAddMsg 97760, 10, '97760^LabelPrnterReq', 'us_english', 1723
execute rdt.rdtAddMsg 97761, 10, '97761^DW NOT SETUP',   'us_english', 1723
execute rdt.rdtAddMsg 97762, 10, '97762^TGETDB NOT SET', 'us_english', 1723
execute rdt.rdtAddMsg 97763, 10, '97763^PALLET ID REQ',  'us_english', 1723
execute rdt.rdtAddMsg 97764, 10, '97764^INVALID FORMAT', 'us_english', 1723
execute rdt.rdtAddMsg 97765, 10, '97765^NO SUGGEST SKU', 'us_english', 1723
execute rdt.rdtAddMsg 97766, 10, '97766^NO MORE SKU',    'us_english', 1723
execute rdt.rdtAddMsg 97767, 10, '97767^INVALID OPTION', 'us_english', 1723
execute rdt.rdtAddMsg 97768, 10, '97768^QtyAvl NotEnuf', 'us_english', 1723
execute rdt.rdtAddMsg 97769, 10, '97769^QtyAlc NotEnuf', 'us_english', 1723
execute rdt.rdtAddMsg 97770, 10, '97770^QtyPCK NotEnuf', 'us_english', 1723
execute rdt.rdtAddMsg 97771, 10, '97771^LabelPrnterReq', 'us_english', 1723
execute rdt.rdtAddMsg 97772, 10, '97772^DW NOT SETUP',   'us_english', 1723
execute rdt.rdtAddMsg 97773, 10, '97773^TGETDB NOT SET', 'us_english', 1723
execute rdt.rdtAddMsg 97774, 10, '97774^GEN SSCC# FAIL', 'us_english', 1723
execute rdt.rdtAddMsg 97775, 10, '97775^CARTON ID REQ',  'us_english', 1723
execute rdt.rdtAddMsg 97776, 10, '97776^INV PREFER QTY', 'us_english', 1723
execute rdt.rdtAddMsg 97777, 10, '97777^INV MASTER QTY', 'us_english', 1723
execute rdt.rdtAddMsg 97778, 10, '97778^INVALID QTY',    'us_english', 1723
execute rdt.rdtAddMsg 97779, 10, '97779^QTYAVL NotEnuf', 'us_english', 1723
execute rdt.rdtAddMsg 97780, 10, '97780^MV QTY IN CASE', 'us_english', 1723
execute rdt.rdtAddMsg 97781, 10, '97781^ID > 1 ORDERS',  'us_english', 1723
execute rdt.rdtAddMsg 97782, 10, '97782^ID NOT IN MBOL', 'us_english', 1723
execute rdt.rdtAddMsg 97783, 10, '97783^NO MORE SKU',    'us_english', 1723
execute rdt.rdtAddMsg 97784, 10, '97784^INVALID OPTION', 'us_english', 1723
execute rdt.rdtAddMsg 97785, 10, '97785^NO MORE SKU',    'us_english', 1723
execute rdt.rdtAddMsg 97786, 10, '97786^NO MORE CASE',   'us_english', 1723
execute rdt.rdtAddMsg 97787, 10, '97787^PLT MIX MBOL',   'us_english', 1723
execute rdt.rdtAddMsg 97788, 10, '97788^PLT CONSOLED',   'us_english', 1723
execute rdt.rdtAddMsg 97789, 10, '97789^PLT CONSOLED',   'us_english', 1723
execute rdt.rdtAddMsg 97790, 10, '97790^SAME PALLET ',   'us_english', 1723
execute rdt.rdtAddMsg 97791, 10, '97791^INV ASRS PLT',   'us_english', 1723
execute rdt.rdtAddMsg 97792, 10, '97792^SKU REQUIRED',   'us_english', 1723
execute rdt.rdtAddMsg 97793, 10, '97793^WRONG SKU',      'us_english', 1723
execute rdt.rdtAddMsg 97794, 10, '97794^MultiBarcodSKU', 'us_english', 1723
execute rdt.rdtAddMsg 97795, 10, '97795^WRONG UPC',      'us_english', 1723
execute rdt.rdtAddMsg 97796, 10, '97796^SKU REQUIRED',   'us_english', 1723
execute rdt.rdtAddMsg 97797, 10, '97797^WRONG SKU',      'us_english', 1723
execute rdt.rdtAddMsg 97798, 10, '97798^MultiBarcodSKU', 'us_english', 1723
execute rdt.rdtAddMsg 97799, 10, '97799^WRONG UPC',      'us_english', 1723

-- (james03)
execute rdt.rdtAddMsg 97800, 10, '97800^INVALID COUNT',  'us_english', 1723
execute rdt.rdtAddMsg 102251, 10, '02251^NO CASE COUNT', 'us_english', 1723
execute rdt.rdtAddMsg 102252, 10, '02252^#CNT NOT MATCH','us_english', 1723

-- (james03)
execute rdt.rdtAddMsg 102253, 10, '02253^SSCC REQUIRED', 'us_english', 1723
execute rdt.rdtAddMsg 102254, 10, '02254^INVALID SSCC',  'us_english', 1723
execute rdt.rdtAddMsg 102255, 10, '02255^INVALID SKU',   'us_english', 1723
execute rdt.rdtAddMsg 102256, 10, '02256^INVALID SKU',   'us_english', 1723

-- (james04)
execute rdt.rdtAddMsg 102257, 10, '02257^CANNOT MIX ORD','us_english', 1723

-- WMS-5526
execute rdt.rdtAddMsg 102258, 10, '02258^INVALID QTY',   'us_english', 1723
execute rdt.rdtAddMsg 102259, 10, '02259^SKU NOT MATCH', 'us_english', 1723
execute rdt.rdtAddMsg 102260, 10, '02260^SKU NOT MATCH', 'us_english', 1723

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 97751 AND 97800
SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 102251 AND 102300








