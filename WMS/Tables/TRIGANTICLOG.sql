CREATE TABLE [dbo].[TRIGANTICLOG]
(
[TriganticlogKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tablename] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRIGANTICLOG_tablename] DEFAULT (' '),
[key1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRIGANTICLOG_key1] DEFAULT (' '),
[key2] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRIGANTICLOG_key2] DEFAULT (' '),
[key3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRIGANTICLOG_key3] DEFAULT (' '),
[transmitflag] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRIGANTICLOG_transmitflag] DEFAULT ('0'),
[transmitbatch] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRIGANTICLOG_transmitbatch] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TRIGANTICLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRIGANTICLOG_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TRIGANTICLOG_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRIGANTICLOG_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/* 17-Mar-2009  TLTING     Change user_name() to SUSER_SNAME()          */
/* 28-Oct-2013  TLTING     Review Editdate column update                */

CREATE TRIGGER [dbo].[ntrTRIGANTICLOGUpdate]
ON [dbo].[TRIGANTICLOG]
FOR UPDATE 
AS 
BEGIN
 IF @@ROWCOUNT = 0
 BEGIN
 RETURN
 END 
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
	SET CONCAT_NULL_YIELDS_NULL OFF
	
   DECLARE @b_debug int
   SELECT @b_debug = 0
   DECLARE   
   @b_Success            int       
   ,         @n_err                int       
   ,         @n_err2               int       
   ,         @c_errmsg             NVARCHAR(250) 
   ,         @n_continue int
   ,         @n_starttcnt          int
   ,         @c_preprocess         NVARCHAR(250) 
   ,         @c_pstprocess         NVARCHAR(250) 
   ,         @n_cnt                int      

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   IF UPDATE(ArchiveCop)
   BEGIN
   	SELECT @n_continue = 4 
   END

   IF ( @n_continue = 1 or @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE TRIGANTICLOG
         SET EditDate = GetDate(),
             EditWho = SUSER_SNAME()
      FROM INSERTED, DELETED 
      WHERE INSERTED.TriganticlogKey = TRIGANTICLOG.TriganticlogKey
      AND   DELETED.TriganticlogKey = TRIGANTICLOG.TriganticlogKey
   END 

END
GO
ALTER TABLE [dbo].[TRIGANTICLOG] ADD CONSTRAINT [PKTRIGANTICLOG] PRIMARY KEY CLUSTERED ([TriganticlogKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TRIGANTICLOG_CIdx] ON [dbo].[TRIGANTICLOG] ([tablename], [key1], [key2], [key3]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TRIGANTICLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TRIGANTICLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TRIGANTICLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TRIGANTICLOG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TRIGANTICLOG', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TRIGANTICLOG', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TRIGANTICLOG', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TRIGANTICLOG', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TRIGANTICLOG', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Trigantic Log.', 'SCHEMA', N'dbo', 'TABLE', N'TRIGANTICLOG', 'COLUMN', N'TriganticlogKey'
GO
