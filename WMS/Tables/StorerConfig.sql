CREATE TABLE [dbo].[StorerConfig]
(
[StorerKey] [nvarchar] (15) NOT NULL,
[Facility] [nvarchar] (5) NOT NULL CONSTRAINT [DF_StorerConfig_Facility] DEFAULT (' '),
[ConfigKey] [nvarchar] (30) NOT NULL,
[ConfigDesc] [nvarchar] (120) NULL CONSTRAINT [DF_StorerConfig_ConfigDesc] DEFAULT (' '),
[SValue] [nvarchar] (30) NULL CONSTRAINT [DF_StorerConfig_SValue] DEFAULT (' '),
[AddDate] [datetime] NULL CONSTRAINT [DF_StorerConfig_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NULL CONSTRAINT [DF_StorerConfig_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_StorerConfig_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NULL CONSTRAINT [DF_StorerConfig_EditWho] DEFAULT (suser_sname()),
[OPTION1] [nvarchar] (50) NULL CONSTRAINT [DF_StorerConfig_OPTION1] DEFAULT (''),
[OPTION2] [nvarchar] (50) NULL CONSTRAINT [DF_StorerConfig_OPTION2] DEFAULT (''),
[OPTION3] [nvarchar] (50) NULL CONSTRAINT [DF_StorerConfig_OPTION3] DEFAULT (''),
[OPTION4] [nvarchar] (50) NULL CONSTRAINT [DF_StorerConfig_OPTION4] DEFAULT (''),
[OPTION5] [nvarchar] (4000) NULL CONSTRAINT [DF_StorerConfig_OPTION5] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/  
/* Trigger: ntrStorerConfigAdd                                          */  
/* Creation Date: 2021-11-26                                            */  
/* Copyright: LFL                                                       */  
/* Written by: Wan                                                      */  
/*                                                                      */  
/* Purpose:  Insert StorerConfig                                        */  
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
/* Date         Author  Ver   Purposes                                  */
/* 26-Nov-2021  Wan01   1.0   Created.                                  */
/* 26-Nov-2021  Wan01   1.0   WMS-18410 - [RG] Logitech Tote ID Packing */
/*                            Change Request                            */
/* 26-Nov-2021  Wan01   1.0   DevOps Conbine Script                     */
/************************************************************************/  
CREATE TRIGGER [dbo].[ntrStorerConfigAdd] ON [dbo].[StorerConfig] 
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @b_debug        int = 0   
 
   DECLARE @b_Success      int = 1        -- Populated by calls to stored procedures - was the proc successful?    
         , @n_err          int = 0        -- Error number returned by stored procedure or this trigger    
         , @n_err2         int = 0        -- For Additional Error Detection    
         , @c_errmsg       NVARCHAR(250) = '' -- Error message returned by stored procedure or this trigger    
         , @n_continue     int = 1                     
         , @n_starttcnt    int = @@TRANCOUNT  -- Holds the current transaction count    

   IF @n_continue=1 OR @n_continue=2 
   BEGIN
      IF EXISTS ( SELECT 1 FROM INSERTED 
                  WHERE INSERTED.Configkey = 'AdvancePackGenCartonNo'
                  AND INSERTED.SValue IN ('1')
                  AND INSERTED.Facility = ''
                  AND EXISTS (SELECT 1 FROM dbo.PackHeader AS ph WITH (NOLOCK) 
                              WHERE ph.Storerkey = INSERTED.Storerkey
                              AND ph.[Status] < '9' ) 
                  UNION  
                  SELECT 1 FROM INSERTED 
                  WHERE INSERTED.Configkey = 'AdvancePackGenCartonNo'
                  AND INSERTED.SValue IN ('1')
                  AND INSERTED.Facility <> ''
                  AND EXISTS (SELECT 1 FROM dbo.PackHeader AS ph WITH (NOLOCK) 
                              JOIN dbo.ORDERS AS o WITH (NOLOCK) ON ph.OrderKey = o.OrderKey AND ph.OrderKey <> ''
                              WHERE ph.Storerkey = INSERTED.Storerkey
                              AND o.Facility = INSERTED.Facility
                              AND ph.[Status] < '9')
                  UNION  
                  SELECT 1 FROM INSERTED 
                  WHERE INSERTED.Configkey = 'AdvancePackGenCartonNo'
                  AND INSERTED.SValue IN ('1')
                  AND INSERTED.Facility <> ''
                  AND EXISTS (SELECT 1 FROM dbo.PackHeader AS ph WITH (NOLOCK) 
                              JOIN dbo.LoadPlan AS lp WITH (NOLOCK) ON ph.Loadkey = lp.LoadKey AND ph.OrderKey = ''
                              WHERE ph.Storerkey = INSERTED.Storerkey
                              AND lp.Facility = INSERTED.Facility
                              AND ph.[Status] < '9')   )
      BEGIN
         SET @n_continue = 3
         SET @n_err=62501   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Disallow to change ''AdvancePackGenCartonNo'' setting. Pack Not confirm found. (ntrStorerConfigAdd).'
      END
   END

   /* #INCLUDE <TRRDA2.SQL> */    
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
      execute nsp_logerror @n_err, @c_errmsg, "ntrStorerConfigAdd"    
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
/* Trigger: ntrStorerConfigDelet                                        */  
/* Creation Date:                                                       */  
/* Copyright: LFL                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:  Insert StorerConfig                                        */  
/*                                                                      */  
/* Return Status:                                                       */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Called By: When records Inserted                                     */  
/*                                                                      */  
/* PVCS Version: 1.1                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Modifications:                                                       */  
/* Date         Author  Ver   Purposes                                  */
/* 28-Dec-2011  KHLim01 1.0   Initial creation                          */
/* 26-Nov-2021  Wan01   1.1   WMS-18410 - [RG] Logitech Tote ID Packing */
/*                            Change Request                            */
/* 26-Nov-2021  Wan01   1.1   DevOps Conbine Script                     */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrStorerConfigDelete]
ON [dbo].[StorerConfig]
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
           ,@c_authority   NVARCHAR(1)
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

      /* #INCLUDE <TRCONHD1.SQL> */  
   --(Wan01)  - START
   IF @n_continue=1 OR @n_continue=2 
   BEGIN
      IF EXISTS ( SELECT 1 FROM DELETED 
                  WHERE DELETED.Configkey = 'AdvancePackGenCartonNo'
                  AND DELETED.SValue NOT IN ('0','')
                  AND DELETED.Facility = ''
                  AND EXISTS (SELECT 1 FROM dbo.PackHeader AS ph WITH (NOLOCK) 
                              WHERE ph.Storerkey = DELETED.Storerkey
                              AND ph.[Status] < '9' ) 
                  UNION  
                  SELECT 1 FROM DELETED 
                  WHERE DELETED.Configkey = 'AdvancePackGenCartonNo'
                  AND DELETED.SValue NOT IN ('0','')
                  AND DELETED.Facility <> ''
                  AND EXISTS (SELECT 1 FROM dbo.PackHeader AS ph WITH (NOLOCK) 
                              JOIN dbo.ORDERS AS o WITH (NOLOCK) ON ph.OrderKey = o.OrderKey AND ph.OrderKey <> ''
                              WHERE ph.Storerkey = DELETED.Storerkey
                              AND o.Facility = DELETED.Facility
                              AND ph.[Status] < '9')
                  UNION  
                  SELECT 1 FROM DELETED 
                  WHERE DELETED.Configkey = 'AdvancePackGenCartonNo'
                  AND DELETED.SValue NOT IN ('0','')
                  AND DELETED.Facility <> ''
                  AND EXISTS (SELECT 1 FROM dbo.PackHeader AS ph WITH (NOLOCK) 
                              JOIN dbo.LoadPlan AS lp WITH (NOLOCK) ON ph.Loadkey = lp.LoadKey AND ph.OrderKey = ''
                              WHERE ph.Storerkey = DELETED.Storerkey
                              AND lp.Facility = DELETED.Facility
                              AND ph.[Status] < '9')   )
      BEGIN
         SET @n_continue = 3
         SET @n_err=62501   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Disallow to change ''AdvancePackGenCartonNo'' setting. Pack Not confirm found. (ntrStorerConfigDelete).'
      END
   END
   --(Wan01) - END
   --   
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      SELECT @b_success = 0
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
               ,@c_errmsg = 'ntrStorerConfigDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'
      BEGIN
         INSERT INTO dbo.StorerConfig_DELLOG ( Storerkey, Facility, ConfigKey )
         SELECT Storerkey, Facility, ConfigKey FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table StorerConfig Failed. (ntrStorerConfigDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrStorerConfigDelete'
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

/************************************************************************/
/* Trigger: ntrStorerConfigUpdate                                       */
/* Creation Date:                                                       */
/* Copyright: LF                                                        */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Return Status:                                                       */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When records updated                                      */
/*                                                                      */
/* PVCS Version: 1.4                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver   Purposes                                  */
/* 12-Dec-2008  TLTING  1.0   Revise Promary key - add facility         */
/* 17-Mar-2009  TLTING  1.1   Change user_name() to SUSER_SNAME()       */
/* 28-Oct-2013  TLTING  1.2   Review Editdate column update             */
/* 05-Feb-2015  NJOW01  1.3   330996-update log                         */
/* 2021-Nov-26  Wan01   1.4   WMS-18410 - [RG] Logitech Tote ID Packing */
/*                            Change Request                            */
/* 2021-Nov-26  Wan01   1.4   DevOps Conbine Script                     */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrStorerConfigUpdate]
ON  [dbo].[StorerConfig]
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

   DECLARE @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?
      ,         @n_err                int       -- Error number returned by stored procedure or this trigger
      ,         @n_err2 int              -- For Additional Error Detection
      ,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
      ,         @n_continue int                 
      ,         @n_starttcnt int                -- Holds the current transaction count
      ,         @c_preprocess NVARCHAR(250)         -- preprocess
      ,         @c_pstprocess NVARCHAR(250)         -- post process
      ,         @n_cnt int                  
   
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   
   /* #INCLUDE <TRPU_1.SQL> */  
   IF ( @n_continue = 1 or @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE StorerConfig
      SET EditDate = GETDATE(),
         EditWho = SUSER_SNAME()
      FROM StorerConfig, INSERTED
      WHERE StorerConfig.Storerkey = INSERTED.Storerkey
         AND StorerConfig.Facility = INSERTED.Facility         -- tlting01
         AND StorerConfig.ConfigKey = INSERTED.ConfigKey
   
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62501   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table StorerConfig. (ntrStorerConfigUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
      END
   END

   --NJOW01
   IF ( @n_continue = 1 or @n_continue = 2 ) AND UPDATE(Svalue)
   BEGIN    
      --(Wan01)  - START
      IF EXISTS ( SELECT 1 FROM INSERTED 
                                    JOIN DELETED ON  INSERTED.Storerkey = DELETED.Storerkey
                               AND INSERTED.Facility = DELETED.Facility
                               AND INSERTED.SValue <> DELETED.SValue
                  WHERE INSERTED.Configkey = 'AdvancePackGenCartonNo'
                  AND DELETED.Facility = ''
                  AND EXISTS (SELECT 1 FROM dbo.PackHeader AS ph WITH (NOLOCK) 
                              WHERE ph.Storerkey = INSERTED.Storerkey
                              AND ph.[Status] < '9' ) 
                  UNION  
                  SELECT 1 FROM INSERTED 
                  JOIN DELETED ON  INSERTED.Storerkey = DELETED.Storerkey
                               AND INSERTED.Facility = DELETED.Facility
                               AND INSERTED.SValue <> DELETED.SValue
                  WHERE INSERTED.Configkey = 'AdvancePackGenCartonNo'
                  AND DELETED.Facility <> ''
                  AND EXISTS (SELECT 1 FROM dbo.PackHeader AS ph WITH (NOLOCK) 
                              JOIN dbo.ORDERS AS o WITH (NOLOCK) ON ph.OrderKey = o.OrderKey AND ph.OrderKey <> ''
                              WHERE ph.Storerkey = INSERTED.Storerkey
                              AND o.Facility = INSERTED.Facility
                              AND ph.[Status] < '9')
                  UNION  
                  SELECT 1 FROM INSERTED 
                  JOIN DELETED ON  INSERTED.Storerkey = DELETED.Storerkey
                               AND INSERTED.Facility = DELETED.Facility
                               AND INSERTED.SValue <> DELETED.SValue
                  WHERE INSERTED.Configkey = 'AdvancePackGenCartonNo'
                  AND INSERTED.Facility <> ''
                  AND EXISTS (SELECT 1 FROM dbo.PackHeader AS ph WITH (NOLOCK) 
                              JOIN dbo.LoadPlan AS lp WITH (NOLOCK) ON ph.Loadkey = lp.LoadKey AND ph.OrderKey = ''
                              WHERE ph.Storerkey = INSERTED.Storerkey
                              AND lp.Facility = INSERTED.Facility
                              AND ph.[Status] < '9')   )
      BEGIN
         SET @n_continue = 3
         SET @n_err=62503   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Disallow to change ''AdvancePackGenCartonNo'' setting. Pack Not confirm found. (ntrStorerConfigUpdate).'
      END
      --(Wan01)  - END

      IF @n_continue IN ( 1, 2 )          --(Wan01)
      BEGIN
         INSERT INTO TableActionLog (TableName, Action, Description, Userdefine01, Userdefine02, SourceType)
         SELECT 'STORERCONFIG','UPDATE', 
               'Configkey:'+RTRIM(ISNULL(INSERTED.Configkey,'')) + 
               '  Field:SValue  Old Value:' + RTRIM(ISNULL(DELETED.Svalue,'')) + 
               '  New Value:' + RTRIM(ISNULL(INSERTED.Svalue,'')),
               'SValue',
               INSERTED.Configkey,
               'ntrStorerConfigUpdate'
         FROM INSERTED (NOLOCK)
         JOIN DELETED (NOLOCK) ON INSERTED.Configkey = DELETED.Configkey AND INSERTED.Storerkey = DELETED.Storerkey
                              AND INSERTED.Facility = DELETED.Facility 
      END                                 --(Wan01)
   END
      
   /* #INCLUDE <TRPU_2.SQL> */
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
      execute nsp_logerror @n_err, @c_errmsg, "ntrStorerConfigUpdate"
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
GRANT SELECT ON  [dbo].[StorerConfig] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[StorerConfig] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[StorerConfig] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[StorerConfig] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[StorerConfig] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of Configuration.', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'ConfigDesc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Configuration.', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'ConfigKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional Configuration Option 1', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'OPTION1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional Configuration Option 2', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'OPTION2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional Configuration Option 3', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'OPTION3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional Configuration Option 4', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'OPTION4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional Configuration Option 5', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'OPTION5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'StorerKey'
GO
