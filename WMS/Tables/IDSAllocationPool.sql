CREATE TABLE [dbo].[IDSAllocationPool]
(
[AllocPoolId] [uniqueidentifier] NOT NULL CONSTRAINT [DF_IDSAllocationPool_AllocPoolId] DEFAULT (newid()),
[SourceKey] [nvarchar] (15) NOT NULL,
[WinUserLogin] [nvarchar] (18) NOT NULL CONSTRAINT [DF_IDSAllocationPool_WinUserLogin] DEFAULT (' '),
[WinComputerName] [nvarchar] (18) NOT NULL,
[Priority] [int] NOT NULL CONSTRAINT [DF_IDSAllocationPool_Priority] DEFAULT ((9)),
[Status] [nvarchar] (5) NOT NULL CONSTRAINT [DF_IDSAllocationPool_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_IDSAllocationPool_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_IDSAllocationPool_AddWho] DEFAULT (suser_sname()),
[EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_IDSAllocationPool_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_IDSAllocationPool_EditDate] DEFAULT (getdate()),
[SourceType] [nvarchar] (10) NULL CONSTRAINT [DF_IDSAllocationPool_SourceType] DEFAULT ('L'),
[Remarks] [nvarchar] (60) NULL,
[MsgText] [nvarchar] (215) NULL,
[ExtendParms] [nvarchar] (250) NULL,
[Wavekey] [nvarchar] (10) NOT NULL CONSTRAINT [DF_IDSAllocationPool_Wavekey] DEFAULT (''),
[AllocateCmd] [nvarchar] (1024) NOT NULL CONSTRAINT [DF_IDSAllocationPool_AllocateCmd] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/* 17-Mar-2009  TLTING     Change user_name() to SUSER_SNAME()          */
/* 28-Oct-2013  TLTING    Review Editdate column update                 */

CREATE TRIGGER [dbo].[ntrIDSAllocationPoolUpdate] ON [dbo].[IDSAllocationPool] 
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

   DECLARE @b_Success int          -- Populated by calls to stored procedures - was the proc successful?  
         , @n_err int              -- Error number returned by stored procedure or this trigger  
         , @n_err2 int             -- For Additional Error Detection  
         , @c_errmsg NVARCHAR(250)     -- Error message returned by stored procedure or this trigger  
         , @n_continue int                   
         , @n_starttcnt int        -- Holds the current transaction count  
         , @c_preprocess NVARCHAR(250) -- preprocess  
         , @c_pstprocess NVARCHAR(250) -- post process  
         , @n_cnt int                    
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  

   IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN   	
       UPDATE IDSAllocationPool with (ROWLOCK)
             SET EditWho = SUSER_SNAME(),
                 EditDate = GetDate()
       FROM INSERTED
       WHERE INSERTED.AllocPoolID = IDSAllocationPool.AllocPoolID
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=85803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))  
                         +': Update Failed On Table IDSAllocationPool. (ntrIDSAllocationPoolUpdate)' + ' ( '   
                         +' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '  
      END  
   END  
   /* END Added */
  
  
  
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
  
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrIDSAllocationPoolUpdate'  
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
 END

GO
ALTER TABLE [dbo].[IDSAllocationPool] ADD CONSTRAINT [PK_IDSAllocationPool] PRIMARY KEY CLUSTERED ([AllocPoolId]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IDSAllocationPool] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[IDSAllocationPool] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[IDSAllocationPool] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[IDSAllocationPool] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Allocate Command', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'AllocateCmd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying IDS Allocation Pool.', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'AllocPoolId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priority of the task. (1-highest through 9-lowest)', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', 'sourcekey', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'SourceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Wavekey', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'Wavekey'
GO
