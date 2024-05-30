/********************************************************
rdt_TM_CycleCount_UCC_ConfirmTask_Message

EXECUTE rdt.rdtDropMsg 74851 , 74900
********************************************************/

EXECUTE rdt.rdtAddMsg 74851 ,10, '74851^InsCCDetFail', 'us_english', 1767
EXECUTE rdt.rdtAddMsg 74852 ,10, '74852^UpdCCDetFail', 'us_english', 1767
EXECUTE rdt.rdtAddMsg 74853 ,10, '74853^UpdCCDetFail', 'us_english', 1767
EXECUTE rdt.rdtAddMsg 74854 ,10, '74854^InsCCDetFail', 'us_english', 1767
EXECUTE rdt.rdtAddMsg 74855 ,10, '74855^UpdCCDetFail', 'us_english', 1767
EXECUTE rdt.rdtAddMsg 74856 ,10, '74856^InsCCDetFail', 'us_english', 1767

EXECUTE rdt.rdtAddMsg 74857 ,10, '74857^UpdSKUFail', 'us_english', 1767
EXECUTE rdt.rdtAddMsg 74858 ,10, '74858^UpdLocFail', 'us_english', 1767

--WMS23249
EXECUTE rdt.rdtAddMsg 74859 ,10, '74859^InsCCDetFail', 'us_english', 1767

SELECT * FROM rdt.rdtMsg WITH (NOLOCK) WHERE Message_ID BETWEEN  74851 AND 74900
