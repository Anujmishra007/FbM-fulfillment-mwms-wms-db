
DELETE FROM RDT.RDTMsg
WHERE Message_ID = 218238 AND Lang_Code = 'ENG' AND Message_Type = 'DSP'
GO

DELETE FROM RDT.RDTMsg
WHERE Message_ID = 218239 AND Lang_Code = 'ENG' AND Message_Type = 'DSP'
GO

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType, Func, URL, Message_Text_Long)
VALUES (218238, 'ENG', 'DSP', 'Zone is not allowed', '', 0, 839, '', '218238^Zone is not allowed')
GO

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType, Func, URL, Message_Text_Long)
VALUES (218239, 'ENG', 'DSP', 'No stock Need replen', '', 0, 839, '', '218239^No stock Need replen')
GO
