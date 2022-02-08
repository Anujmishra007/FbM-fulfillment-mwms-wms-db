CREATE TABLE [dbo].[AreaDetail]
(
[AreaKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AreaDetail_AreaKey] DEFAULT (' '),
[PutawayZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AreaDetail_PutawayZone] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_AreaDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AreaDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_AreaDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AreaDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************************/
/* Trigger: ntrAreaDetailDelete                                                        */
/* Creation Date:                                                                      */
/* Copyright: IDS                                                                      */
/* Written by:                                                                         */
/*                                                                                     */
/* Purpose: AreaDetail Table Delete Trigger                                            */
/*                                                                                     */
/* Called By:                                                                          */
/*                                                                                     */
/* PVCS Version: 1.2                                                                   */
/*                                                                                     */
/* Version: 5.4.2                                                                      */
/*                                                                                     */
/* Data Modifications:                                                                 */
/*                                                                                     */
/* Updates:                                                                            */
/* Date         Author  Ver   Purposes                                                 */
/* 09-08-2011   TLTING  1.1   Bug fix on validate check (tlting01)                     */
/***************************************************************************************/

CREATE TRIGGER [dbo].[ntrAreaDetailDelete]
 ON [dbo].[AreaDetail]
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
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
 IF (select count(*) from DELETED) =
 (select count(*) from DELETED where DELETED.ArchiveCop = '9')
 BEGIN
 SELECT @n_continue = 4
 END
      /* #INCLUDE <TRAD1.SQL> */     
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS(SELECT 1									-- area reference by PutawayStrategyDetail 
 FROM PutawayStrategyDetail with (NOLOCK), Deleted
 WHERE PutawayStrategyDetail.AreaTypeExclude01 = Deleted.AreaKey
 OR PutawayStrategyDetail.AreaTypeExclude02 = Deleted.AreaKey
 OR PutawayStrategyDetail.AreaTypeExclude03 = Deleted.AreaKey)
 AND NOT EXISTS(SELECT 1							-- no reference after delete -- tlting01
 FROM PutawayStrategyDetail with (NOLOCK), AreaDetail with (NOLOCK),Deleted
 WHERE NOT EXISTS( SELECT 1 from Deleted
		 WHERE Deleted.AreaKey = AreaDetail.AreaKey
		 AND Deleted.PutawayZone = AreaDetail.PutawayZone ) 
 AND ( PutawayStrategyDetail.AreaTypeExclude01 = AreaDetail.AreaKey
 OR PutawayStrategyDetail.AreaTypeExclude02 = AreaDetail.AreaKey
 OR PutawayStrategyDetail.AreaTypeExclude03 = AreaDetail.AreaKey) )
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 85900
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On AreaDetail Failed As Putaway Strategy Details Still Reference Area. (ntrAreaDetailDelete)"
 END
 END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS(SELECT 1								-- area reference by TaskManagerUserDetail 
 FROM TaskManagerUserDetail with (NOLOCK), Deleted
 WHERE TaskManagerUserDetail.AreaKey = Deleted.AreaKey)
 AND NOT EXISTS(SELECT 1						-- no reference after delete -- tlting01
 FROM AreaDetail with (NOLOCK),TaskManagerUserDetail with (NOLOCK), Deleted D2 
 WHERE NOT EXISTS( SELECT 1 from Deleted
		 WHERE Deleted.AreaKey = AreaDetail.AreaKey
		 AND Deleted.PutawayZone = AreaDetail.PutawayZone ) 
 AND AreaDetail.AreaKey = D2.AreaKey 
 AND TaskManagerUserDetail.AreaKey = AreaDetail.AreaKey)
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 85901
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On AreaDetail Failed As Task manager User Details Still Reference Area. (ntrAreaDetailDelete)"
 END
 END
      /* #INCLUDE <TRAD2.SQL> */
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
 EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrAreaDetailDelete"
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
/******************************************************************************/
/* Trigger: ntrAreaDetailUpdate                                               */
/* Creation Date:                                                             */
/* Copyright: IDS                                                             */
/* Written by:                                                                */
/*                                                                            */
/* Purpose:                                                                   */
/*                                                                            */
/* Input Parameters:                                                          */
/*                                                                            */
/* Output Parameters:                                                         */
/*                                                                            */
/* Return Status:                                                             */
/*                                                                            */
/* Usage:                                                                     */
/*                                                                            */
/* Local Variables:                                                           */
/*                                                                            */
/* Called By: When records updated                                            */
/*                                                                            */
/* PVCS Version: 1.1                                                          */
/*                                                                            */
/* Version: 5.4                                                               */
/*                                                                            */
/* Data Modifications:                                                        */
/*                                                                            */
/* Updates:                                                                   */
/* Date         Author        Ver   Purposes                                  */
/* 28-Feb-2011  Leong         1.1   SOS# 207014 - Update EditDate & EditWho   */
/* 28-Oct-2013  TLTING        1.2    Review Editdate column update            */
/******************************************************************************/

CREATE TRIGGER [dbo].[ntrAreaDetailUpdate]
ON [dbo].[AreaDetail]
FOR UPDATE
AS
BEGIN
   IF @@ROWCOUNT = 0
   BEGIN
      RETURN
   END
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Success   int,       -- Populated by calls to stored procedures - was the proc successful?
           @n_err       int,       -- Error number returned by stored procedure or this trigger
           @c_errmsg    NVARCHAR(250), -- Error message returned by stored procedure or this trigger
           @n_continue  int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
           @n_starttcnt int,       -- Holds the current transaction count
           @n_cnt       int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.

   SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT

   IF (SELECT COUNT(*) FROM DELETED) = (SELECT COUNT(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END

   --SOS# 207014 (Start)
   IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE AreaDetail with (ROWLOCK)
      SET EditWho = sUser_sName(),
          EditDate = GetDate()
      FROM AreaDetail
      JOIN INSERTED ON AreaDetail.AreaKey = INSERTED.AreaKey
      AND AreaDetail.PutawayZone = INSERTED.PutawayZone

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=86402
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On AreaDetail. (ntrAreaDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '
      END

   END
   --SOS# 207014 (End)

   IF NOT UPDATE(AreaKey)
   BEGIN
      SELECT @n_continue = 4
   END

   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      IF EXISTS(SELECT * FROM PutawayStrategyDetail, DELETED
                WHERE PutawayStrategyDetail.AreaTypeExclude01 = DELETED.AreaKey
                OR PutawayStrategyDetail.AreaTypeExclude02 = DELETED.AreaKey
                OR PutawayStrategyDetail.AreaTypeExclude03 = DELETED.AreaKey)
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 86400
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On AreaDetail Failed As Putaway Strategy Details Still Reference Area. (ntrAreaDetailUpdate)"
      END
   END

   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      IF EXISTS(SELECT * FROM TaskManagerUserDetail, DELETED
                WHERE TaskManagerUserDetail.AreaKey = DELETED.AreaKey)
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 86401
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On AreaDetail Failed As Task manager User Details Still Reference Area. (ntrAreaDetailUpdate)"
      END
   END

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
      EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrAreaDetailUpdate"
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
ALTER TABLE [dbo].[AreaDetail] ADD CONSTRAINT [PKAreaDetail] PRIMARY KEY CLUSTERED ([AreaKey], [PutawayZone]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[AreaDetail] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[AreaDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[AreaDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[AreaDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[AreaDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'An area is a collection of zones. Each zone can be in one or more areas.', 'SCHEMA', N'dbo', 'TABLE', N'AreaDetail', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AreaDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'AreaDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Area Detail.', 'SCHEMA', N'dbo', 'TABLE', N'AreaDetail', 'COLUMN', N'AreaKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AreaDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'AreaDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zone to which the Location is assigned.', 'SCHEMA', N'dbo', 'TABLE', N'AreaDetail', 'COLUMN', N'PutawayZone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'AreaDetail', 'COLUMN', N'TrafficCop'
GO
