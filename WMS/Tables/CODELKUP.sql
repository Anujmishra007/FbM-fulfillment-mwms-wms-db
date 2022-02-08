CREATE TABLE [dbo].[CODELKUP]
(
[LISTNAME] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Code] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Short] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Long] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_CODELKUP_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CODELKUP_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_CODELKUP_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CODELKUP_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL,
[Notes2] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Codelkup_Storerkey] DEFAULT (' '),
[UDF01] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Codelkup_UDF01] DEFAULT (' '),
[UDF02] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Codelkup_UDF02] DEFAULT (' '),
[UDF03] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Codelkup_UDF03] DEFAULT (' '),
[UDF04] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Codelkup_UDF04] DEFAULT (' '),
[UDF05] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Codelkup_UDF05] DEFAULT (' '),
[code2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Codelkup_code2] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/  
/* Trigger: ntrCodeLKUPAdd                                              */  
/* Creation Date:                                                       */  
/* Copyright: LFL                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:  Insert CodeLKUP.                                           */  
/*                                                                      */  
/* Return Status:                                                       */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Called By: When records Inserted                                     */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Modifications:                                                       */  
/* Date         Author   Ver  Purposes                                  */  
/* 26-Jun-2018  NJOW01   1.0  WMS-5221 disallow insert code PHYSICAL for*/
/*                            listname DCTYPE                           */
/* 12-Dec-2020  TLTING   1.1  Update Editdate column update             */ 
/************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrCodeLKUPAdd]  
ON  [dbo].[CODELKUP]   
FOR INSERT  
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
         , @n_err2 int             -- For Additional Error Detection  
         , @c_errmsg NVARCHAR(250)     -- Error message returned by stored procedure or this trigger  
         , @n_continue int                   
         , @n_starttcnt int        -- Holds the current transaction count  
         , @c_preprocess NVARCHAR(250) -- preprocess  
         , @c_pstprocess NVARCHAR(250) -- post process  
         , @n_cnt int                    
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  

   IF ( @n_continue = 1 OR @n_continue = 2  )   AND
      EXISTS ( SELECT 1 FROM  INSERTED  WHERE   editdate < dateadd( mi, -5, getdate() ) ) 
   BEGIN  
      UPDATE CodeLKUP  
         SET EditDate = GETDATE(),  
             EditWho = SUSER_SNAME(),  
             TrafficCop = NULL  
        FROM CodeLKUP, INSERTED  
       WHERE CodeLKUP.LISTNAME = INSERTED.LISTNAME
         AND CodeLKUP.Code     = INSERTED.Code
         AND CodeLKUP.Storerkey= INSERTED.Storerkey   -- KHLim01
         AND CodeLKUP.code2    = INSERTED.code2       -- KHLim02

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=85803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))  
                         +': Update Failed On Table CodeLKUP. (ntrCodeLKUPAdd)' + ' ( '   
                         +' SQLSvr MESSAGE=' + ISNULL(LTrim(RTrim(@c_errmsg)),'') + ' ) '  
      END  
   END


   IF ( @n_continue = 1 OR @n_continue = 2  ) --NJOW01
   BEGIN  
   	  IF EXISTS (SELECT 1 
   	             FROM INSERTED 
   	             WHERE Listname = 'DCTYPE'
   	             AND Code = 'PHYSICAL')   	   
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=85803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))  
                         +': PHYSICAL code is not allowed for listname DCTYPE. (ntrCodeLKUPAdd)' + ' ( '   
                         +' SQLSvr MESSAGE=' + ISNULL(LTrim(RTrim(@c_errmsg)),'') + ' ) '  
      END  
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
  
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrCodeLKUPAdd'  
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/* 14-Jul-2011  KHLim02    1.0   GetRight for Delete log                */
/* 19-Dec-2011  KHLim03    1.1   Additional PK: Storerkey               */
/* 13-Apr-2015  KHLim04    1.2   Additional PK: code2                   */

CREATE TRIGGER [dbo].[ntrCODELKUPDelete]
ON [dbo].[CODELKUP]
FOR DELETE
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

   DECLARE  @b_Success     int,       -- Populated by calls to stored procedures - was the proc successful?
            @n_err         int,       -- Error number returned by stored procedure or this trigger
            @c_errmsg      NVARCHAR(250), -- Error message returned by stored procedure or this trigger
            @n_continue    int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
            @n_starttcnt   int,       -- Holds the current transaction count
            @n_cnt         int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
           ,@c_authority   NVARCHAR(1)  -- KHLim02
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
-- if (select count(*) from DELETED) =
-- (select count(*) from DELETED where DELETED.ArchiveCop = '9')
-- BEGIN
--    SELECT @n_continue = 4
-- END
      /* #INCLUDE <TRCONHD1.SQL> */     
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      SELECT @b_success = 0         --    Start (KHLim02)
      EXECUTE nspGetRight  NULL,             -- facility  
                           NULL,             -- Storerkey  
                           NULL,             -- Sku  
                           'DataMartDELLOG', -- Configkey  
                           @b_success     OUTPUT, 
                           @c_authority   OUTPUT, 
                           @n_err         OUTPUT, 
                           @c_errmsg      OUTPUT  
      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3
               ,@c_errmsg = 'ntrCODELKUPDelete' + RTRIM(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.CODELKUP_DELLOG ( LISTNAME, Code, Storerkey, code2 )  -- KHLim03
         SELECT LISTNAME, Code, Storerkey, code2 FROM DELETED                  -- KHLim04

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table CODELKUP Failed. (ntrCODELKUPDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

      /* #INCLUDE <TRCOND2.SQL> */
   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
      IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrCODELKUPDelete'
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/  
/* Trigger: ntrCodeLKUPUpdate                                           */  
/* Creation Date:                                                       */  
/* Copyright: IDS                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:  Update CodeLKUP.                                           */  
/*                                                                      */  
/* Return Status:                                                       */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Called By: When records Updated                                      */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Modifications:                                                       */  
/* Date         Author   Ver  Purposes                                  */  
/* 2011-Dec-19  KHLim01  1.1  additional PK                             */ 
/* 28-Oct-2013  TLTING   1.2  Review Editdate column update             */ 
/* 14-Apr-2015  KHLim02  1.3  additional PK code2                       */ 
/************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrCodeLKUPUpdate]  
ON  [dbo].[CODELKUP]   
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
         , @n_err2 int             -- For Additional Error Detection  
         , @c_errmsg NVARCHAR(250)     -- Error message returned by stored procedure or this trigger  
         , @n_continue int                   
         , @n_starttcnt int        -- Holds the current transaction count  
         , @c_preprocess NVARCHAR(250) -- preprocess  
         , @c_pstprocess NVARCHAR(250) -- post process  
         , @n_cnt int                    
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  

   IF ( @n_continue = 1 OR @n_continue = 2  ) AND NOT UPDATE(EditDate) 
   BEGIN  
      UPDATE CodeLKUP  
         SET EditDate = GETDATE(),  
             EditWho = SUSER_SNAME(),  
             TrafficCop = NULL  
        FROM CodeLKUP, INSERTED  
       WHERE CodeLKUP.LISTNAME = INSERTED.LISTNAME
         AND CodeLKUP.Code     = INSERTED.Code
         AND CodeLKUP.Storerkey= INSERTED.Storerkey   -- KHLim01
         AND CodeLKUP.code2    = INSERTED.code2       -- KHLim02

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=85803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))  
                         +': Update Failed On Table CodeLKUP. (ntrCodeLKUPUpdate)' + ' ( '   
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
  
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrCodeLKUPUpdate'  
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
ALTER TABLE [dbo].[CODELKUP] ADD CONSTRAINT [PKCODELKUP] PRIMARY KEY CLUSTERED ([LISTNAME], [Code], [Storerkey], [code2]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CODELKUP_SHORT] ON [dbo].[CODELKUP] ([Short], [LISTNAME], [UDF01]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CODELKUP_STORERKEY] ON [dbo].[CODELKUP] ([Storerkey], [LISTNAME], [Short]) INCLUDE ([Description]) WITH (FILLFACTOR=85) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CODELKUP] WITH NOCHECK ADD CONSTRAINT [FK_CODELKUP_LISTNAME_01] FOREIGN KEY ([LISTNAME]) REFERENCES [dbo].[CODELIST] ([LISTNAME])
GO
GRANT SELECT ON  [dbo].[CODELKUP] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[CODELKUP] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CODELKUP] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CODELKUP] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CODELKUP] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of listname.', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information regarding code lookup.', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information regarding code lookup.', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'Notes2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'TrafficCop'
GO
