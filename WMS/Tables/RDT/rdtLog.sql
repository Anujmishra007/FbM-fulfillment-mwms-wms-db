IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES
               WHERE TABLE_SCHEMA = 'RDT' AND TABLE_NAME = 'rdtLog')
BEGIN
    CREATE TABLE [RDT].[rdtLog]
    (
        [RowRef]        [bigint]          NOT NULL IDENTITY(1, 1),
        [Mobile]        [int]             NOT NULL CONSTRAINT [DF_rdtLog_Mobile]        DEFAULT ((0)),
        [StorerKey]     [nvarchar] (15)   NOT NULL CONSTRAINT [DF_rdtLog_StorerKey]     DEFAULT (''),
        [Facility]      [nvarchar] (5)    NOT NULL CONSTRAINT [DF_rdtLog_Facility]      DEFAULT (''),
        [Func]          [int]             NOT NULL CONSTRAINT [DF_rdtLog_Func]          DEFAULT ((0)),
        [Step]          [int]             NOT NULL CONSTRAINT [DF_rdtLog_Step]          DEFAULT ((0)),
        [Scn]           [int]             NOT NULL CONSTRAINT [DF_rdtLog_Scn]           DEFAULT ((0)),
        [MsgType]       [nvarchar] (50)   NULL     CONSTRAINT [DF_rdtLog_MsgType]       DEFAULT (''),
        [ErrNo]         [int]             NULL     CONSTRAINT [DF_rdtLog_ErrNo]         DEFAULT ((0)),
        [MsgData]       [nvarchar] (4000) NULL     CONSTRAINT [DF_rdtLog_MsgData]       DEFAULT (''),
        [SPName]        [nvarchar] (100)  NULL     CONSTRAINT [DF_rdtLog_SPName]        DEFAULT (''),
        [SPLineNumber]  [int]             NULL     CONSTRAINT [DF_rdtLog_SPLineNumber]  DEFAULT ((0)),
        [UDF01]         [nvarchar] (100)  NULL     CONSTRAINT [DF_rdtLog_UDF01]         DEFAULT (''),
        [UDF02]         [nvarchar] (100)  NULL     CONSTRAINT [DF_rdtLog_UDF02]         DEFAULT (''),
        [UDF03]         [nvarchar] (100)  NULL     CONSTRAINT [DF_rdtLog_UDF03]         DEFAULT (''),
        [UDF04]         [nvarchar] (100)  NULL     CONSTRAINT [DF_rdtLog_UDF04]         DEFAULT (''),
        [UDF05]         [nvarchar] (100)  NULL     CONSTRAINT [DF_rdtLog_UDF05]         DEFAULT (''),
        [UDF06]         [nvarchar] (100)  NULL     CONSTRAINT [DF_rdtLog_UDF06]         DEFAULT (''),
        [UDF07]         [nvarchar] (100)  NULL     CONSTRAINT [DF_rdtLog_UDF07]         DEFAULT (''),
        [UDF08]         [nvarchar] (100)  NULL     CONSTRAINT [DF_rdtLog_UDF08]         DEFAULT (''),
        [UDF09]         [nvarchar] (100)  NULL     CONSTRAINT [DF_rdtLog_UDF09]         DEFAULT (''),
        [UDF10]         [nvarchar] (100)  NULL     CONSTRAINT [DF_rdtLog_UDF10]         DEFAULT (''),
        [TraceID]       [nvarchar] (100)  NULL     CONSTRAINT [DF_rdtLog_TraceID]       DEFAULT (''),
        [AddWho]        [nvarchar] (128)  NOT NULL CONSTRAINT [DF_rdtLog_AddWho]        DEFAULT (suser_sname()),
        [AddDate]       [datetime]        NOT NULL CONSTRAINT [DF_rdtLog_AddDate]       DEFAULT (getdate()),
        [TrafficCop]    [nvarchar] (1)    NULL,
        [ArchiveCop]    [nvarchar] (1)    NULL

    ) ON [PRIMARY]

    ALTER TABLE [RDT].[rdtLog] ADD CONSTRAINT [PKrdtLog]
        PRIMARY KEY CLUSTERED ([RowRef])
        WITH (FILLFACTOR=90) ON [PRIMARY]

    CREATE NONCLUSTERED INDEX [IDX_rdtLog_Mobile]
        ON [RDT].[rdtLog] ([Mobile])
        ON [PRIMARY]

    GRANT DELETE ON [RDT].[rdtLog] TO [NSQL]
    GRANT INSERT ON [RDT].[rdtLog] TO [NSQL]
    GRANT SELECT ON [RDT].[rdtLog] TO [NSQL]
    GRANT UPDATE ON [RDT].[rdtLog] TO [NSQL]

    EXEC sp_addextendedproperty N'MS_Description', 'Auto-increment primary key', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'RowRef'
    EXEC sp_addextendedproperty N'MS_Description', 'RDT mobile device number', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'Mobile'
    EXEC sp_addextendedproperty N'MS_Description', 'Storer/owner of the goods', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'StorerKey'
    EXEC sp_addextendedproperty N'MS_Description', 'Warehouse facility code', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'Facility'
    EXEC sp_addextendedproperty N'MS_Description', 'RDT function identifier', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'Func'
    EXEC sp_addextendedproperty N'MS_Description', 'Current step number', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'Step'
    EXEC sp_addextendedproperty N'MS_Description', 'Current screen number', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'Scn'
    EXEC sp_addextendedproperty N'MS_Description', 'Message type (e.g. INFO, ERROR, WARN)', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'MsgType'
    EXEC sp_addextendedproperty N'MS_Description', 'Error number', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'ErrNo'
    EXEC sp_addextendedproperty N'MS_Description', 'Message data or additional log details', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'MsgData'
    EXEC sp_addextendedproperty N'MS_Description', 'Name of the stored procedure that wrote this log', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'SPName'
    EXEC sp_addextendedproperty N'MS_Description', 'Line number within the stored procedure', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'SPLineNumber'
    EXEC sp_addextendedproperty N'MS_Description', 'User-defined field 01', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'UDF01'
    EXEC sp_addextendedproperty N'MS_Description', 'User-defined field 02', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'UDF02'
    EXEC sp_addextendedproperty N'MS_Description', 'User-defined field 03', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'UDF03'
    EXEC sp_addextendedproperty N'MS_Description', 'User-defined field 04', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'UDF04'
    EXEC sp_addextendedproperty N'MS_Description', 'User-defined field 05', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'UDF05'
    EXEC sp_addextendedproperty N'MS_Description', 'User-defined field 06', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'UDF06'
    EXEC sp_addextendedproperty N'MS_Description', 'User-defined field 07', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'UDF07'
    EXEC sp_addextendedproperty N'MS_Description', 'User-defined field 08', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'UDF08'
    EXEC sp_addextendedproperty N'MS_Description', 'User-defined field 09', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'UDF09'
    EXEC sp_addextendedproperty N'MS_Description', 'User-defined field 10', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'UDF10'
    EXEC sp_addextendedproperty N'MS_Description', 'Trace ID for correlating log entries across a single RDT session transaction', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'TraceID'
    EXEC sp_addextendedproperty N'MS_Description', 'User who created the record', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'AddWho'
    EXEC sp_addextendedproperty N'MS_Description', 'Date when the record was created', 'SCHEMA', N'RDT', 'TABLE', N'rdtLog', 'COLUMN', N'AddDate'
END
GO
