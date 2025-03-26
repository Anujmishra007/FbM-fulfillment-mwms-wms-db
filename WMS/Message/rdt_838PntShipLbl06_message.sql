--rdt_1580DecodeSN03
exec rdt.rdtDropMsg 219951, 219958

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType, Func, URL, Message_Text_Long)
VALUES (219951, 'ENG', 'DSP', '219951^UpdatePkdFail', '', 0, 838, '', '')
GO
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType, Func, URL, Message_Text_Long)
VALUES (219952, 'ENG', 'DSP', '219952^DelPickFail', '', 0, 838, '', '')
GO
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType, Func, URL, Message_Text_Long)
VALUES (219953, 'ENG', 'DSP', '219953^MergePickFail', '', 0, 838, '', '')
GO
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType, Func, URL, Message_Text_Long)
VALUES (219954, 'ENG', 'DSP', '219954 OVER PACK', '', 0, 838, '', '')
GO
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType, Func, URL, Message_Text_Long)
VALUES (219955, 'ENG', 'DSP', '219955^PalletQtyNotSe', '', 0, 600, '', '')
GO
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType, Func, URL, Message_Text_Long)
VALUES (219956, 'ENG', 'DSP', '219956^Qty>PalletQty', '', 0, 600, '', '')
GO
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType, Func, URL, Message_Text_Long)
VALUES (219957, 'ENG', 'DSP', '219957^MultipleSKU', '', 0, 600, '', '')
GO
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType, Func, URL, Message_Text_Long)
VALUES (219958, 'ENG', 'DSP', '219958^MultipleBatch', '', 0, 600, '', '')
GO
