--rdt_1836SwapTask01
execute rdt.rdtdropmsg 163351, 163400

execute rdt.rdtAddMsg 163351, 10, '63351^SwapTask Fail ', 'us_english', 1836
execute rdt.rdtAddMsg 163352, 10, '63352^SwapTask Fail ', 'us_english', 1836
execute rdt.rdtAddMsg 163353, 10, '63353^UpdMOBREC Fail', 'us_english', 1836


SELECT * FROM RD.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 163351 AND 163400
