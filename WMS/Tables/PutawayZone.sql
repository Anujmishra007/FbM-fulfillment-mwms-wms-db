CREATE TABLE [dbo].[PutawayZone]
(
[PutawayZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_PutawayZone] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_Descr] DEFAULT (' '),
[InLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_InLoc] DEFAULT (' '),
[OutLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_OutLoc] DEFAULT (' '),
[Uom1PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_Uom1PickMethod] DEFAULT ('1'),
[Uom2PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_Uom2PickMethod] DEFAULT ('3'),
[Uom3PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_Uom3PickMethod] DEFAULT ('3'),
[Uom4PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_Uom4PickMethod] DEFAULT ('1'),
[Uom5PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_Uom5PickMethod] DEFAULT ('3'),
[Uom6PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_Uom6PickMethod] DEFAULT ('3'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PutawayZone_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PutawayZone_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[No_Pallet] [int] NULL,
[ZoneCategory] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PutawayZone_ZoneCategory] DEFAULT ('N'),
[Pallet_type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_Pallet_type] DEFAULT (' '),
[Floor] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PUTAWAYZONE_Floor] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/* 14-Jul-2011  KHLim02       GetRight for Delete log                   */

CREATE TRIGGER [dbo].[ntrPutawayZoneDelete]
 ON [dbo].[PutawayZone]
 FOR DELETE
 AS
 BEGIN
 IF @@ROWCOUNT = 0
 BEGIN
 RETURN
 END
  
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

 DECLARE @b_Success       int,       -- Populated by calls to stored procedures - was the proc successful?
 @n_err              int,       -- Error number returned by stored procedure or this trigger
 @c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger
 @n_continue         int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
 @n_starttcnt        int,       -- Holds the current transaction count
 @n_cnt              int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
,@c_authority        NVARCHAR(1)  -- KHLim02
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
 IF (select count(*) from DELETED) =
 (select count(*) from DELETED where DELETED.ArchiveCop = '9')
 BEGIN
 SELECT @n_continue = 4
 END
      /* #INCLUDE <TRPZD1.SQL> */     
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS(SELECT *
 FROM SKU, Deleted
 WHERE SKU.PutawayZone = Deleted.PutawayZone)
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 86200
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On PutawayZone Failed As Commodities Still Reference Zone. (ntrPutawayZoneDelete)"
 END
 END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS(SELECT *
 FROM LOC, Deleted
 WHERE LOC.PutawayZone = Deleted.PutawayZone)
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 86201
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On PutawayZone Failed As Locations Still Reference Zone. (ntrPutawayZoneDelete)"
 END
 END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS(SELECT *
 FROM PutawayStrategyDetail, Deleted
 WHERE PutawayStrategyDetail.Zone = Deleted.PutawayZone)
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 86202
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On PutawayZone Failed As Putaway Strategy Details Still Reference Zone. (ntrPutawayZoneDelete)"
 END
 END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS(SELECT *
 FROM PAZoneEquipmentExcludeDetail, Deleted
 WHERE PAZoneEquipmentExcludeDetail.PutawayZone = Deleted.PutawayZone)
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 86203
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On PutawayZone Failed As PAZone Equipment Exclude Details Still Reference Zone. (ntrPutawayZoneDelete)"
 END
 END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS(SELECT *
 FROM AreaDetail, Deleted
 WHERE AreaDetail.PutawayZone = Deleted.PutawayZone)
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 86204
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On PutawayZone Failed As Area Details Still Reference Zone. (ntrPutawayZoneDelete)"
 END
 END
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
               ,@c_errmsg = 'ntrPutawayZoneDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.PutawayZone_DELLOG ( PutawayZone )
         SELECT PutawayZone FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table PutawayZone Failed. (ntrPutawayZoneDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

      /* #INCLUDE <TRPZD2.SQL> */
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
 EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrPutawayZoneDelete"
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
/* Trigger: ntrPutawayZoneUpdate                                        */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Input Parameters: NONE                                               */
/*                                                                      */
/* Output Parameters: NONE                                              */
/*                                                                      */
/* Return Status: NONE                                                  */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When records updated                                      */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 17-Mar-2009  TLTING     Change user_name() to SUSER_SNAME()          */
/* 22-May-2012  TLTING01 1.1  DM Integrity issue - Update editdate B4   */
/*                             ArchiveCop                               */
/* 28-Oct-2013  TLTING   1.2  Review Editdate column update             */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrPutawayZoneUpdate]
 ON [dbo].[PutawayZone]
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
 
 IF ( @n_continue=1 OR @n_continue=2 ) AND NOT UPDATE(EditDate)
 BEGIN
    UPDATE PUTAWAYZONE 
      SET EditDate = GetDate(),
          EditWho  = Suser_Sname(),
          TrafficCop = NULL
    FROM PUTAWAYZONE, INSERTED
    WHERE PUTAWAYZONE.PutawayZone = INSERTED.PutawayZone
 END 

 IF NOT UPDATE(PutawayZone)
 BEGIN
 SELECT @n_continue = 4
 END
      /* #INCLUDE <TRPZU1.SQL> */     
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS(SELECT *
 FROM SKU, Deleted
 WHERE SKU.PutawayZone = Deleted.PutawayZone)
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 86300
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Trigger On PutawayZone Failed As Commodities Still Reference Zone. (ntrPutawayZoneUpdate)"
 END
 END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS(SELECT *
 FROM LOC, Deleted
 WHERE LOC.PutawayZone = Deleted.PutawayZone)
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 86301
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Trigger On PutawayZone Failed As Locations Still Reference Zone. (ntrPutawayZoneUpdate)"
 END
 END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS(SELECT *
 FROM PutawayStrategyDetail, Deleted
 WHERE PutawayStrategyDetail.Zone = Deleted.PutawayZone)
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 86302
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Trigger On PutawayZone Failed As Putaway Strategy Details Still Reference Zone. (ntrPutawayZoneUpdate)"
 END
 END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS(SELECT *
 FROM PAZoneEquipmentExcludeDetail, Deleted
 WHERE PAZoneEquipmentExcludeDetail.PutawayZone = Deleted.PutawayZone)
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 86303
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Trigger On PutawayZone Failed As PAZone Equipment Exclude Details Still Reference Zone. (ntrPutawayZoneUpdate)"
 END
 END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS(SELECT *
 FROM AreaDetail, Deleted
 WHERE AreaDetail.PutawayZone = Deleted.PutawayZone)
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 86304
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Trigger On PutawayZone Failed As Area Details Still Reference Zone. (ntrPutawayZoneUpdate)"
 END
 END
      /* #INCLUDE <TRPZU2.SQL> */
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
 EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrPutawayZoneUpdate"
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
ALTER TABLE [dbo].[PutawayZone] ADD CONSTRAINT [PKPutawayZone] PRIMARY KEY CLUSTERED ([PutawayZone]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PutawayZone] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PutawayZone] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PutawayZone] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PutawayZone] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PutawayZone] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A zone is a collection of locations. When a putaway zone is created, it is defining an area for the entire warehouse, and not just the putaway process.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Text description the zone', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The facility code where the zone is residing', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Staging location for inventory into the zone. This field was introduced for pick and drop functionality. In Loc represents the intermediate drop location that all products must pass through when going into a location in the putaway zone', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'InLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', '# Pallet - customized', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'No_Pallet'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This field was introduced for Pick and Drop functionality. Out Location represents the intermediate drop location that all product must pass through when leaving a location within the Putaway Zone', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'OutLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pallet Type - customized', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'Pallet_type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Code that identifies the name of the putaway zone', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'PutawayZone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick method to use when picking cases in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'Uom1PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick method to use when picking inner packs in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'Uom2PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick method to use when picking pieces or eaches in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'Uom3PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick method to use when picking pallets in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'Uom4PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Other pick method to use when picking in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'Uom5PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Other pick method to use when picking in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'Uom6PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zone Category - customized', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'ZoneCategory'
GO
