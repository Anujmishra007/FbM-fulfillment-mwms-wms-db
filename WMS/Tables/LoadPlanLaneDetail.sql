CREATE TABLE [dbo].[LoadPlanLaneDetail]
(
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlanLaneDetail_Loadkey] DEFAULT (' '),
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LP_LaneNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LocationCategory] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlanLaneDetail_Status] DEFAULT ('0'),
[Notes] [nvarchar] (215) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlanLaneDetail_Notes] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlanLaneDetail_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_LoadPlanLaneDetail_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlanLaneDetail_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_LoadPlanLaneDetail_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlanLaneDetail_MbolKey] DEFAULT (' ')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/* 28-Oct-2013  TLTING    Review Editdate column update                 */

CREATE TRIGGER [dbo].[ntrLoadPlanLaneDetailUpdate]
 ON  [dbo].[LoadPlanLaneDetail]
 FOR UPDATE
 AS
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
 IF UPDATE(ArchiveCop)
 BEGIN
    SELECT @n_continue = 4 
 END
      /* #INCLUDE <TRMBODU1.SQL> */     

 IF ( @n_continue = 1 or @n_continue = 2 ) AND NOT UPDATE(EditDate)
 BEGIN
    UPDATE LoadPlanLaneDetail with (ROWLOCK)
    SET EditDate = GETDATE(), EditWho = Suser_Sname(), Trafficcop = NULL
    FROM LoadPlanLaneDetail, INSERTED
    WHERE LoadPlanLaneDetail.LoadKey = INSERTED.LoadKey 
      AND LoadPlanLaneDetail.ExternOrderKey = INSERTED.ExternOrderKey
      AND LoadPlanLaneDetail.ConsigneeKey = INSERTED.ConsigneeKey
      AND LoadPlanLaneDetail.LP_LaneNumber = INSERTED.LP_LaneNumber
    SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
    IF @n_err <> 0
    BEGIN
       SELECT @n_continue = 3
       SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=73102   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
       SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table LoadPlanLaneDetail. (ntrLoadPlanLaneDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
    END
 END
 IF UPDATE(TrafficCop)
 BEGIN
    SELECT @n_continue = 4 
 END 
      /* #INCLUDE <TRMBODU2.SQL> */
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
    execute nsp_logerror @n_err, @c_errmsg, 'ntrLoadPlanLaneDetailUpdate'
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


GO
ALTER TABLE [dbo].[LoadPlanLaneDetail] ADD CONSTRAINT [PK_LoadPlanLaneDetail] PRIMARY KEY CLUSTERED ([LoadKey], [ExternOrderKey], [ConsigneeKey], [LP_LaneNumber], [MBOLKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LoadPlanLaneDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LoadPlanLaneDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LoadPlanLaneDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LoadPlanLaneDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanLaneDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanLaneDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanLaneDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanLaneDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanLaneDetail', 'COLUMN', N'TrafficCop'
GO
