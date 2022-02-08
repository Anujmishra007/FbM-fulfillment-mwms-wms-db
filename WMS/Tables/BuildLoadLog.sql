CREATE TABLE [dbo].[BuildLoadLog]
(
[BatchNo] [bigint] NOT NULL IDENTITY(1, 1),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_Facility] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_Storerkey] DEFAULT (''),
[BuildParmGroup] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_BuildParmGroup] DEFAULT (''),
[BuildParmCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_BuildParmCode] DEFAULT (''),
[BuildParmString] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_BuildParmString] DEFAULT (''),
[Duration] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_Duration] DEFAULT (''),
[TotalLoadCnt] [int] NOT NULL CONSTRAINT [DF_BuildLoadLog_TotalLoadCnt] DEFAULT ((0)),
[UDF01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_UDF01] DEFAULT (''),
[UDF02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_UDF02] DEFAULT (''),
[UDF03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_UDF03] DEFAULT (''),
[UDF04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_UDF04] DEFAULT (''),
[UDF05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_UDF05] DEFAULT (''),
[Status] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BuildLoadLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BuildLoadLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BuildLoadLog_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/  
/* Trigger: ntrBuildLoadLogUpdate                                       */  
/* Creation Date:                                                       */  
/* Copyright: LFL                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:  Update BuildLoadLog.                                       */  
/* Called By: When records Updated                                      */  
/* Modifications:                                                       */  
/* Date         Author   Ver  Purposes                                  */  
/************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrBuildLoadLogUpdate]  
ON  [dbo].[BuildLoadLog]   
FOR UPDATE  
AS  
BEGIN  
   IF @@ROWCOUNT = 0  
   BEGIN  
      RETURN  
   END  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET ANSI_WARNINGS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF   
   DECLARE @b_Success int          -- Populated by calls to stored procedures - was the proc successful?  
         , @n_err int              -- Error number returned by stored procedure or this trigger  
         , @c_errmsg NVARCHAR(250)     -- Error message returned by stored procedure or this trigger  
         , @n_continue int                   
         , @n_starttcnt int        -- Holds the current transaction count  
         , @c_preprocess NVARCHAR(250) -- preprocess  
         , @c_pstprocess NVARCHAR(250) -- post process  
         , @n_cnt int                    
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  

   IF UPDATE(ArchiveCop)  
   BEGIN  
      SELECT @n_continue = 4  
   END  

   IF ( @n_continue = 1 OR @n_continue = 2  ) AND NOT UPDATE(EditDate) 
   BEGIN  
      UPDATE BuildLoadLog  
         SET EditDate   = GETDATE(),  
             EditWho    = SUSER_SNAME(),  
             TrafficCop = NULL  
        FROM BuildLoadLog, INSERTED  
       WHERE BuildLoadLog.BatchNo = INSERTED.BatchNo

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=89721 
         SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))  
                         +': Update Failed On Table BuildLoadLog. (ntrBuildLoadLogUpdate)' + ' ( '   
                         +' SQLSvr MESSAGE=' + ISNULL(LTrim(RTrim(@c_errmsg)),'') + ' ) '  
      END  
   END  
  
   IF UPDATE(TrafficCop)  
   BEGIN  
      SELECT @n_continue = 4   
   END  
  
  
   /* #INCLUDE <TRPU_2.SQL> */  
   IF @n_continue=3  -- Error Occured - Process And Return  
   BEGIN  
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt  
      BEGIN  
         ROLLBACK TRAN  
      END  
      ELSE  
      BEGIN  
         WHILE @@TRANCOUNT > @n_starttcnt  
         BEGIN  
            COMMIT TRAN  
         END  
      END  
  
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrBuildLoadLogUpdate'  
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
      RETURN  
   END  
   ELSE  
   BEGIN  
      WHILE @@TRANCOUNT > @n_starttcnt  
      BEGIN  
         COMMIT TRAN  
      END  
      RETURN  
   END  
END   -- main
GO
ALTER TABLE [dbo].[BuildLoadLog] ADD CONSTRAINT [PK__BuildLoa__5D56EB970ADA8D4A] PRIMARY KEY CLUSTERED ([BatchNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_BuildLoadLog_Loadkey] ON [dbo].[BuildLoadLog] ([Facility], [Storerkey], [AddWho], [AddDate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BuildLoadLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BuildLoadLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BuildLoadLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BuildLoadLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Loadplan Log', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID creates the information.', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ArchiveCop purpose, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Batch No', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'BatchNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Load Plan Parameter Code', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'BuildParmCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Load Plan Parameter Group', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'BuildParmGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Load Plan Parameter SQL', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'BuildParmString'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Duration', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'Duration'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total Load Plan Count', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'TotalLoadCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 01', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'UDF01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 02', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'UDF02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 03', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'UDF03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 04', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'UDF04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 05', 'SCHEMA', N'dbo', 'TABLE', N'BuildLoadLog', 'COLUMN', N'UDF05'
GO
