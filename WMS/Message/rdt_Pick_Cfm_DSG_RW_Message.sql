-- rdt_Pick_Cfm_DSG_RM_Message
exec rdt.rdtDropMsg 91801, 91850

execute rdt.rdtAddMsg 91801, 10, '91801^Invalid ID    ', 'us_english', 862
execute rdt.rdtAddMsg 91802, 10, '91802^IDMultiLOT/LOC', 'us_english', 862
execute rdt.rdtAddMsg 91803, 10, '91803^LOC not match ', 'us_english', 862
execute rdt.rdtAddMsg 91804, 10, '91804^SKU not match ', 'us_english', 862
execute rdt.rdtAddMsg 91805, 10, '91805^ID Picked     ', 'us_english', 862
execute rdt.rdtAddMsg 91806, 10, '91806^PKDtl changed ', 'us_english', 862
execute rdt.rdtAddMsg 91807, 10, '91807^QTY not match ', 'us_english', 862
execute rdt.rdtAddMsg 91808, 10, '91808^IDNotFullAlloc', 'us_english', 862
execute rdt.rdtAddMsg 91809, 10, '91809^L01 not match ', 'us_english', 862
execute rdt.rdtAddMsg 91810, 10, '91810^L04 not match ', 'us_english', 862
execute rdt.rdtAddMsg 91811, 10, '91811^PKDtl changed ', 'us_english', 862
execute rdt.rdtAddMsg 91812, 10, '91812^QTY is over   ', 'us_english', 862
execute rdt.rdtAddMsg 91813, 10, '91813^QTY is over   ', 'us_english', 862
execute rdt.rdtAddMsg 91814, 10, '91814^Multi PKDtl   ', 'us_english', 862
execute rdt.rdtAddMsg 91815, 10, '91815^FG NeedConsoPS', 'us_english', 862
execute rdt.rdtAddMsg 91816, 10, '91816^RM NeedOrderPS', 'us_english', 862
