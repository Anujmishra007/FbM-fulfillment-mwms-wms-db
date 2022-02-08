CREATE TABLE [dbo].[CONTAINERDETAIL]
(
[ContainerKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ContainerLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PalletKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_CONTAINERDETAIL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_CONTAINERDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CONTAINERDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_CONTAINERDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CONTAINERDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ContainerDetail_Status] DEFAULT ('0'),
[Userdefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/  
/* Trigger: ntrContainerDetailAdd                                          */  
/* Creation Date:                                                          */  
/* Copyright: IDS                                                          */  
/* Written by:                                                             */  
/*                                                                         */  
/* Purpose:                                                                */  
/*                                                                         */  
/* Input Parameters: NONE                                                  */  
/*                                                                         */  
/* Output Parameters: NONE                                                 */  
/*                                                                         */  
/* Return Status: NONE                                                     */  
/*                                                                         */  
/* Usage:                                                                  */  
/*                                                                         */  
/* Local Variables:                                                        */  
/*                                                                         */  
/* Called By: When records added                                           */  
/*                                                                         */  
/* PVCS Version: 1.2                                                       */  
/*                                                                         */  
/* Version: 5.4                                                            */  
/*                                                                         */  
/* Data Modifications:                                                     */  
/*                                                                         */  
/* Updates:                                                                */  
/* Date         Author    Ver.  Purposes                                   */  
/* 17-Mar-2009  TLTING    1.1   Change user_name() to SUSER_SNAME()        */  
/* 05-Nov-2009  Vicky     1.2   System assign ContainerLineNumber to       */   
/*                              prevent same ContainerLineNumber           */
/*                              being assigned concurrently                */  
/*                              (Vicky01)                                  */  
/* 30-Mar-2020  kocy      1.3   Skip when data move from Archive (kocy01)  */
/* 13-Jan-2021  Shong     1.4   Comment the update for AddWho... Schema    */
/*                              Default already have this. Redundancy      */
/***************************************************************************/  
CREATE TRIGGER [dbo].[ntrContainerDetailAdd]
 ON  [dbo].[CONTAINERDETAIL]
 FOR INSERT
 AS
 BEGIN
    SET NOCOUNT ON
    SET ANSI_NULLS OFF
    SET QUOTED_IDENTIFIER OFF
 SET CONCAT_NULL_YIELDS_NULL OFF
 	
 DECLARE @b_debug int
 SELECT @b_debug = 0
 DECLARE
 @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?
 ,         @n_err                int       -- Error number returned by stored procedure or this trigger
 ,         @n_err2 int              -- For Additional Error Detection
 ,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
 ,         @n_continue int                 
 ,         @n_starttcnt int                -- Holds the current transaction count
 ,         @c_preprocess NVARCHAR(250)         -- preprocess
 ,         @c_pstprocess NVARCHAR(250)         -- post process
 ,         @n_cnt int               

 DECLARE @cLineNo NVARCHAR(5),     -- (Vicky01)
         @cMax_LineNo NVARCHAR(5)  -- (Vicky01)

 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
      /* #INCLUDE <TRCONDA1.SQL> */     
 
 -- kocy01(s)
 IF @n_continue=1 or @n_continue=2  
 BEGIN
    IF EXISTS (SELECT 1 FROM INSERTED WHERE ArchiveCop = "9")
    BEGIN
       SELECT @n_continue = 4
    END
 END
 --kocy01(e)

 IF @n_continue=1 or @n_continue=2
 BEGIN
     IF EXISTS (SELECT 1 FROM CONTAINER WITH (NOLOCK)
                JOIN INSERTED ON (CONTAINER.ContainerKey = INSERTED.ContainerKey)
                WHERE CONTAINER.Status = '9')
     BEGIN
         SELECT @n_continue = 3
         SELECT @n_err=68200
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': CONTAINER.Status = ''SHIPPED''. UPDATE rejected. (ntrContainerDetailAdd)'
     END
 END

 -- (Vicky01) - Start  
 IF EXISTS (SELECT 1 FROM INSERTED WITH (NOLOCK) WHERE ContainerLineNumber = '0')  
 BEGIN  
     SELECT @cMax_LineNo = MAX(CONTAINERDETAIL.ContainerLineNumber)  
     FROM CONTAINERDETAIL WITH (NOLOCK)  
     JOIN INSERTED WITH (NOLOCK) ON (CONTAINERDETAIL.ContainerKey = INSERTED.ContainerKey)

     SELECT @cLineNo = RIGHT( '00000' + CAST( CAST( IsNULL( @cMax_LineNo, '0') AS INT) + 1 AS NVARCHAR( 5)), 5)  

     UPDATE CONTAINERDETAIL WITH (ROWLOCK)
        SET ContainerLineNumber = @cLineNo -- (Vicky01)
     FROM INSERTED 
     WHERE CONTAINERDETAIL.ContainerKey = INSERTED.ContainerKey
     AND CONTAINERDETAIL.ContainerLineNumber = '0'
 END  
 -- (Vicky01) - End  
 
 --IF @n_continue=1 or @n_continue=2
 --BEGIN
 --    UPDATE CONTAINERDETAIL WITH (ROWLOCK)
 --       SET TrafficCop = NULL,
 --           AddDate = GETDATE(),
 --           AddWho = SUSER_SNAME(),
 --           EditDate = GETDATE(),
 --           EditWho = SUSER_SNAME()
 --    FROM CONTAINERDETAIL
 --    JOIN INSERTED ON (CONTAINERDETAIL.ContainerKey = INSERTED.ContainerKey AND
 --                      CONTAINERDETAIL.ContainerLineNumber = INSERTED.ContainerLineNumber)

 --   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 --   IF @n_err <> 0
 --   BEGIN
 --       SELECT @n_continue = 3
 --       SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=68202   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 --       SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert Failed On Table CONTAINERDETAIL. (ntrContainerDetailAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') + ' ) '
 --   END
 --END
 
  /* #INCLUDE <TRCONDA2.SQL> */
 IF @n_continue=3 -- Error Occured - Process And Return
 BEGIN
     IF @@TRANCOUNT=1
        AND @@TRANCOUNT>=@n_starttcnt
     BEGIN
         ROLLBACK TRAN
     END
     ELSE
     BEGIN
         WHILE @@TRANCOUNT>@n_starttcnt
         BEGIN
             COMMIT TRAN
         END
     END
     
     EXECUTE nsp_logerror @n_err,
          @c_errmsg,
          'ntrContainerDetailAdd'
     
     RAISERROR (@c_errmsg ,16 ,1) WITH SETERROR -- SQL2012
     RETURN
 END
 ELSE
 BEGIN
     WHILE @@TRANCOUNT>@n_starttcnt
     BEGIN
         COMMIT TRAN
     END
     RETURN
 END
END -- Procedure 

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/* 08-Oct-2012  KHLim      Insert Delete log (KH01)                          */
/* 22-Aug-2016  TLTING     add NOLOCK - deadlock                             */
/* 20-May-2020  TLTING02   Cursor loop by row - deadlock                     */

CREATE TRIGGER [dbo].[ntrContainerDetailDelete]
 ON [dbo].[CONTAINERDETAIL]
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

 DECLARE @b_Success       int,       -- Populated by calls to stored procedures - was the proc successful?
 @n_err              int,       -- Error number returned by stored procedure or this trigger
 @c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger
 @n_continue         int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
 @n_starttcnt        int,       -- Holds the current transaction count
 @n_cnt              int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
,@c_authority        nvarchar(1)  -- KH01

DECLARE @c_MbolKey NVARCHAR(10) = ''
, @c_MbolLineNumber NVARCHAR(5) = ''

 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
 if (select count(*) from DELETED) =
 (select count(*) from DELETED where DELETED.ArchiveCop = '9')
 BEGIN
 SELECT @n_continue = 4
 END

   IF @n_continue = 1 or @n_continue = 2  --KH01 start
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
               ,@c_errmsg = 'ntrContainerDetailDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'
      BEGIN
         INSERT INTO dbo.CONTAINERDETAIL_DELLOG ( ContainerKey, ContainerLineNumber )
         SELECT ContainerKey, ContainerLineNumber FROM DELETED
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68403   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table CONTAINER Failed. (ntrContainerDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END   --KH01 end

   
 /* #INCLUDE <TRCONDD1.SQL> */     
 IF @n_continue=1 or @n_continue=2
 BEGIN
 IF EXISTS (SELECT * FROM CONTAINER with (NOLOCK), DELETED
 WHERE CONTAINER.ContainerKey = DELETED.ContainerKey
 AND CONTAINER.Status = "9")
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err=68400
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": CONTAINER.Status = 'SHIPPED'. DELETE rejected. (ntrContainerDetailDelete)"
 END
 END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
   -- TLTING02
   IF EXISTS (	SELECT 1   FROM MbolDetail  with (NOLOCK), Mbol with (NOLOCK), DELETED
             WHERE MbolDetail.ContainerKey = DELETED.ContainerKey
             AND Mbol.MbolKey = MbolDetail.MbolKey
             AND Mbol.Status <> '9'	 )
   Begin 
	   DECLARE MBOLItem_cur CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
		   Select MbolDetail.MbolKey, MbolDetail.MbolLineNumber
		   FROM MbolDetail  with (NOLOCK), Mbol with (NOLOCK), DELETED
         WHERE MbolDetail.ContainerKey = DELETED.ContainerKey
         AND Mbol.MbolKey = MbolDetail.MbolKey
         AND Mbol.Status <> '9'	 

	   OPEN MBOLItem_cur 
	   FETCH NEXT FROM MBOLItem_cur INTO @c_MbolKey, @c_MbolLineNumber
	   WHILE @@FETCH_STATUS = 0 
	   BEGIN 

		   DELETE MbolDetail
         WHERE MbolKey = @c_MbolKey
         AND MbolLineNumber = @c_MbolLineNumber
          SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
          IF @n_err <> 0
          BEGIN
          SELECT @n_continue = 3
          SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68402   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
          SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Cascade Delete ON Table MbolDetail Failed. (ntrContainerDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
          END		
		   FETCH NEXT FROM MBOLItem_cur INTO @c_MbolKey, @c_MbolLineNumber
	   END
	   CLOSE MBOLItem_cur 
	   DEALLOCATE MBOLItem_cur
   End
 END
      /* #INCLUDE <TRCONDD2.SQL> */
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
 EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrContainerDetailDelete"
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

/* 17-Mar-2009  TLTING     Change user_name() to SUSER_SNAME()          */
/* 28-Oct-2013  TLTING    Review Editdate column update                 */

CREATE TRIGGER [dbo].[ntrContainerDetailUpdate]
 ON  [dbo].[CONTAINERDETAIL]
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

 DECLARE
 @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?
 ,         @n_err                int       -- Error number returned by stored procedure or this trigger
 ,         @n_err2 int              -- For Additional Error Detection
 ,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
 ,         @n_continue int                 
 ,         @n_starttcnt int                -- Holds the current transaction count
 ,         @c_preprocess NVARCHAR(250)         -- preprocess
 ,         @c_pstprocess NVARCHAR(250)         -- post process
 ,         @n_cnt int                  
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
 IF UPDATE(archivecop)
 BEGIN
 SELECT @n_continue = 4 
 END
 IF UPDATE(TrafficCop)
 BEGIN
 SELECT @n_continue = 4 
 END
      /* #INCLUDE <TRCONDU1.SQL> */     
 IF @n_continue=1 or @n_continue=2
 BEGIN
 IF EXISTS (SELECT * FROM CONTAINER (NOLOCK), INSERTED
 WHERE CONTAINER.ContainerKey = INSERTED.ContainerKey
 AND CONTAINER.Status = "9")
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err=68300
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": CONTAINER.Status = 'SHIPPED'. UPDATE rejected. (ntrContainerDetailUpdate)"
 END
 END
 IF ( @n_continue=1 or @n_continue=2 ) AND NOT UPDATE(EditDate) 
 BEGIN
 UPDATE CONTAINERDETAIL
 SET  EditDate = GETDATE(),
 EditWho = SUSER_SNAME()
 FROM CONTAINERDETAIL, INSERTED
 WHERE CONTAINERDETAIL.ContainerKey = INSERTED.ContainerKey
 AND CONTAINERDETAIL.ContainerLineNumber = INSERTED.ContainerLineNumber
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=68302   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table CONTAINERDETAIL. (ntrContainerDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
      /* #INCLUDE <TRCONDU2.SQL> */
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
 execute nsp_logerror @n_err, @c_errmsg, "ntrContainerDetailUpdate"
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
ALTER TABLE [dbo].[CONTAINERDETAIL] ADD CONSTRAINT [PKContainerDetail] PRIMARY KEY CLUSTERED ([ContainerKey], [ContainerLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Containerdetail_PalletKey] ON [dbo].[CONTAINERDETAIL] ([PalletKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CONTAINERDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CONTAINERDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CONTAINERDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CONTAINERDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Container ', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'ContainerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A portable platform designed to allow a forklift or pallet jack to lift, move, and store various loads.', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'PalletKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status. 0=Default, 5=Verified', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define field 01', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'Userdefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define field 02', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'Userdefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define field 03', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'Userdefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define field 04', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'Userdefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define field 05', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'Userdefine05'
GO
