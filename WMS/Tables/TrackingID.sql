CREATE TABLE [dbo].[TrackingID]
(
[TrackingIDKey] [bigint] NOT NULL IDENTITY(1, 1),
[TrackingID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TrackingID_SKU] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL CONSTRAINT [DF_TrackingID_QTY] DEFAULT ((1)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TrackingID_Status] DEFAULT ('0'),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TrackingID_DropID] DEFAULT (''),
[ParentTrackingID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TrackingID_ParentTrackingID] DEFAULT (''),
[UserDefine01] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TrackingID_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TrackingID_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TrackingID_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TrackingID_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TrackingID_UserDefine05] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TrackingID_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TrackingID_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TrackingID_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TrackingID_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TrackingID_ReceiptKey] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TrackingID_Facility] DEFAULT (''),
[PickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TrackingID_PickMethod] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*********************************************************************************/  
/* Trigger:  ntrTrackingIDUpdate                                                 */
/* Creation Date: 2020-04-20                                                     */
/* Copyright: LFL                                                                */
/* Written by: WLChooi                                                           */
/*                                                                               */
/* Purpose:  Trigger point upon any Update on the TrackingID                     */
/*                                                                               */
/* Return Status:  None                                                          */
/*                                                                               */
/* Usage:                                                                        */
/*                                                                               */
/* Local Variables:                                                              */
/*                                                                               */
/* Called By: When records updated                                               */
/*                                                                               */
/* PVCS Version: 1.0                                                             */
/*                                                                               */
/* Version: 5.4                                                                  */
/*                                                                               */
/* Data Modifications:                                                           */
/*                                                                               */
/* Updates:                                                                      */
/* Date         Author    Ver.  Purposes                                         */
/*********************************************************************************/  

CREATE TRIGGER [dbo].[ntrTrackingIDUpdate]
ON  [dbo].[TrackingID]
FOR UPDATE
AS
BEGIN -- main
   IF @@ROWCOUNT = 0  
   BEGIN  
      RETURN  
   END     
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?
         , @n_err                int       -- Error number returned by stored procedure or this trigger
         , @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
         , @n_continue           int                 
         , @n_starttcnt          int       -- Holds the current transaction count
         , @c_TrafficCop         NCHAR(1)

   SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT      

   SELECT @c_TrafficCop = TrafficCop
   FROM INSERTED
   
   IF UPDATE(TrafficCop)  
   BEGIN
      SELECT @n_continue = 4 
   END

   IF (@n_continue = 1 or @n_continue = 2)  AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE TrackingID WITH (ROWLOCK)
      SET TrackingID.EditWho = SUSER_SNAME(),
          TrackingID.EditDate = GETDATE(),
          TrackingID.TrafficCop = NULL
      FROM TrackingID JOIN INSERTED ON TrackingID.TrackingIDKey = INSERTED.TrackingIDKey

      SELECT @n_err = @@ERROR 

      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=67000   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table TrackingID. (ntrTrackingIDUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
    END

   IF @n_continue = 3  -- Error Occured - Process And Return
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
    EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrTrackingIDUpdate'
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
END -- main
GO
ALTER TABLE [dbo].[TrackingID] ADD CONSTRAINT [PK_TrackingID] PRIMARY KEY CLUSTERED ([TrackingIDKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TrackingID_ParentTrackingID_StorerKey] ON [dbo].[TrackingID] ([ParentTrackingID], [StorerKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TrackingID_TrackingID_StorerKey] ON [dbo].[TrackingID] ([TrackingID], [StorerKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TrackingID] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TrackingID] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TrackingID] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TrackingID] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique ID for each/inner/carton/pallet that not kept after ship out', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'AddDate', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'AddWho', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ArchiveCop', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet ID/carton ID/UCC no/Drop ID', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'DropID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'EditDate', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'EditWho', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store Facility Value', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parent tracking ID', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'ParentTrackingID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Picking Method', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', N'QTY (optional)', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'QTY'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store ASN Value', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'ReceiptKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SKU (optional)', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'StorerKey', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Child tracking ID', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'TrackingID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'TrackingIDKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'TrafficCop', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UOM of inner/carton/pallet', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User define', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User define', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User define', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User define', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User define', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'UserDefine05'
GO
