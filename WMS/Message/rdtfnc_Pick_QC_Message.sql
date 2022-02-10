--Message Range 158801 - 158850 (rdtfnc_Pick_QC)
execute rdt.rdtDropMsg 158801,158850

execute rdt.rdtAddMsg 158801, 10, '158801^Need PSNO', 'us_english',1848
execute rdt.rdtAddMsg 158802, 10, '158802^Invalid PSNO', 'us_english',1848
execute rdt.rdtAddMsg 158803, 10, '158803^Diff Storer', 'us_english',1848
execute rdt.rdtAddMsg 158804, 10, '158804^DiffFacility', 'us_english',1848
execute rdt.rdtAddMsg 158805, 10, '158805InvalidStatus', 'us_english',1848
execute rdt.rdtAddMsg 158806, 10, '158806NeedReasonCode', 'us_english',1848
execute rdt.rdtAddMsg 158807, 10, '158807^Invalid Code', 'us_english',1848
execute rdt.rdtAddMsg 158808, 10, '158808^Need SKU', 'us_english',1848
execute rdt.rdtAddMsg 158809, 10, '158809^Invalid SKU', 'us_english',1848
execute rdt.rdtAddMsg 158810, 10, '158810MultiSKUBarcod', 'us_english',1848
execute rdt.rdtAddMsg 158811, 10, '158811^Invalid SKU', 'us_english',1848
execute rdt.rdtAddMsg 158812, 10, '158812^OverShortPick', 'us_english',1848
execute rdt.rdtAddMsg 158813, 10, '158813^Option Req', 'us_english',1848
execute rdt.rdtAddMsg 158814, 10, '158814^InvalidOption', 'us_english',1848
execute rdt.rdtAddMsg 158815, 10, '158815^Need To Loc', 'us_english',1848
execute rdt.rdtAddMsg 158816, 10, '158816^Fail UPD PKD', 'us_english',1848

SELECT TOP 10 * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 158801 and 158850

--INSERT INTO rdt.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text,StoredProcName, EventType, Func, URL)
--VALUES (1848, 'ENG','FNC', 'Pick QC','rdtfnc_Pick_QC',9 ,0,'')

SELECT TOP 10 * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID = 1848



