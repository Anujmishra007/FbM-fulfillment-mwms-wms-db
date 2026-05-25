EXECUTE rdt.rdtAddMsg 218279, 10, '218279 Mix Not Allowed', 'us_english', 573
GO

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID = 218279
GO
