CREATE TABLE [dbo].[VITALLOG]
(
[VitalLogKey] [int] NOT NULL IDENTITY(1, 1),
[Tablename] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VITALLOG_Tablename] DEFAULT (' '),
[Key1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VITALLOG_Key1] DEFAULT (' '),
[Key2] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VITALLOG_Key2] DEFAULT (' '),
[Key3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VITALLOG_Key3] DEFAULT (' '),
[Transmitflag] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VITALLOG_Transmitflag] DEFAULT ('0'),
[Transmitbatch] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VITALLOG_Transmitbatch] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_VITALLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VITALLOG_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_VITALLOG_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VITALLOG_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrVITALLogUpdate                                           */
/* Creation Date: 30-Jun-2008                                           */
/* Copyright: IDS                                                       */
/* Written by: YokeBeen                                                 */
/*                                                                      */
/* Purpose: Update EditWho & EditDate in VITALLog table.                */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By:  Exceed                                                   */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications: Made a copy from ntrVITALLOGUpdate.              */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 6Jan2008     TLTING    1.1   @@TRANCOUNT >= @n_starttcnt to rollback */
/*                              (tlting01)                              */
/* 28-Oct-2013  TLTING    1.2   Review Editdate column update           */
/*                                                                      */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrVITALLogUpdate]
ON  [dbo].[VITALLOG]
FOR UPDATE
AS
BEGIN 
 	IF @@ROWCOUNT = 0
 	BEGIN
 		RETURN
 	END

	SET NOCOUNT ON          -- SQL 2005 Standard
	SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_debug int
   SET @b_debug = 0

   DECLARE   
     @b_Success            int       
   , @n_err                int       
   , @c_errmsg             NVARCHAR(250) 
   , @n_continue           int
   , @n_starttcnt          int
   , @n_cnt                int      

   SET @n_continue = 1 
   SET @n_starttcnt = @@TRANCOUNT
   SET @b_success = 0 

   IF UPDATE(ArchiveCop)
   BEGIN
   	SET @n_continue = 4 
   END
 	
   IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
	BEGIN 	
	 	UPDATE VITALLOG WITH (ROWLOCK) 
    	   SET EditDate = GETDATE(),
     	       EditWho = SUSER_SNAME(),
     	       Trafficcop = NULL
        FROM VITALLOG, INSERTED
       WHERE VITALLOG.VITALLOGKey = INSERTED.VITALLOGKey

      SET @n_err = @@ERROR
      SET @n_cnt = @@ROWCOUNT

	 	IF @n_err <> 0
    	BEGIN
   	   SET @n_continue = 3
   	   SET @n_err = 68000  
    	   SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0)) + 
                         ': Update Failed On Table VITALLOG. (ntrVITALLogUpdate)' + 
                         ' ( ' + ' SQLSvr MESSAGE = ' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '
    	END
	END

   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt     -- tlting01    -- @@TRANCOUNT > @n_starttcnt
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
      EXECUTE dbo.nsp_logerror @n_err, @c_errmsg, 'ntrVITALLogUpdate'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
ALTER TABLE [dbo].[VITALLOG] ADD CONSTRAINT [PKVITALLOG] PRIMARY KEY NONCLUSTERED ([VitalLogKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_VITALLOG_CIdx] ON [dbo].[VITALLOG] ([Tablename], [Key1], [Key2], [Key3]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[VITALLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[VITALLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[VITALLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[VITALLOG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'VITALLOG', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'VITALLOG', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'VITALLOG', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'VITALLOG', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'VITALLOG', 'COLUMN', N'TrafficCop'
GO
