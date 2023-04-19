
CREATE TABLE [API].[TouchPadErrmsg](
	[Message_ID] [int] NOT NULL,
	[Lang_Code] [nvarchar](3) NOT NULL,
   [Message_Type] [nvarchar](3) NOT NULL,
	[Message_Text] [nvarchar](4000) NOT NULL,
   [EventType] [int] NOT NULL
 CONSTRAINT [PK_TouchPadErrmsg] PRIMARY KEY CLUSTERED 
(
	[Message_ID] ASC,
	[Lang_Code] ASC,
   [Message_Type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] 
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON [API].[TouchPadErrmsg] to NSQL
GO

ALTER TABLE [API].[TouchPadErrmsg] ADD  CONSTRAINT [DF_TouchPadErrmsg_Lang_Code]  DEFAULT ('') FOR [Lang_Code]
GO

ALTER TABLE [API].[TouchPadErrmsg] ADD  CONSTRAINT [DF_TouchPadErrmsg_Message_Type]  DEFAULT ('') FOR [Message_Type]
GO

ALTER TABLE [API].[TouchPadErrmsg] ADD  CONSTRAINT [DF_TouchPadErrmsg_Message_Text]  DEFAULT ('') FOR [Message_Text]
GO

ALTER TABLE [API].[TouchPadErrmsg] ADD  CONSTRAINT [DF_TouchPadErrmsg_EventType]  DEFAULT ('') FOR [EventType]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Language Code' , @level0type=N'SCHEMA',@level0name=N'API', @level1type=N'TABLE',@level1name=N'TouchPadErrmsg', @level2type=N'COLUMN',@level2name=N'Lang_Code'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Error Message Type' , @level0type=N'SCHEMA',@level0name=N'API', @level1type=N'TABLE',@level1name=N'TouchPadErrmsg', @level2type=N'COLUMN',@level2name=N'Message_Type'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Error Message Text' , @level0type=N'SCHEMA',@level0name=N'API', @level1type=N'TABLE',@level1name=N'TouchPadErrmsg', @level2type=N'COLUMN',@level2name=N'Message_Text'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Event Type' , @level0type=N'SCHEMA',@level0name=N'API', @level1type=N'TABLE',@level1name=N'TouchPadErrmsg', @level2type=N'COLUMN',@level2name=N'EventType'
GO

