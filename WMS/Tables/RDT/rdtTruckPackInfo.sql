CREATE TABLE [RDT].[rdtTruckPackInfo]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtTruckPackInfo_StorerKey] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtTruckPackInfo_Facility] DEFAULT (''),
[Destination] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtTruckPackInfo_Destination] DEFAULT (''),
[VehicleNum] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtTruckPackInfo_VehicleNum] DEFAULT (''),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtTruckPackInfo_OrderKey] DEFAULT (''),
[TrackingNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtTruckPackInfo_TrackingNo] DEFAULT (''),
[Qty] [int] NOT NULL CONSTRAINT [DF_rdtTruckPackInfo_Qty] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtTruckPackInfo_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtTruckPackInfo_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtTruckPackInfo_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtTruckPackInfo_EditWho] DEFAULT (suser_sname()),
[CartonType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtTruckPackInfo_CartonType] DEFAULT (''),
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtTruckPackInfo_Type] DEFAULT (''),
[PalletID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtTruckPackInfo_PalletID] DEFAULT (''),
[ReturnPalletID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtTruckPackInfo_ReturnPalletID] DEFAULT (''),
[IsReturn] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtTruckPackInfo_IsReturn] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/************************************************************************/
/* Trigger: ntrRDTTruckPackInfoUpdate                                   */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/*                                                                      */
/* Called By: When update records                                       */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Purposes                                      */
/* 26-08-2020  Chermaine  Review Editdate column update                 */
/************************************************************************/

CREATE TRIGGER [RDT].[ntrRDTTruckPackInfoUpdate]
ON  [RDT].[rdtTruckPackInfo]
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

   DECLARE @b_Success int       -- Populated by calls to stored procedures - was the proc successful?
			, @n_err int           -- Error number returned by stored procedure or this trigger
			, @n_err2 int          -- For Additional Error Detection
			, @c_errmsg NVARCHAR(250)  -- Error message returned by stored procedure or this trigger
			, @n_continue  int
			, @n_starttcnt int     -- Holds the current transaction count
         , @n_cnt       int

   SELECT  @b_Success			= 0 
			, @n_err					= 0 
			, @n_err2				= 0 
			, @c_errmsg				= '' 
			, @n_continue			= 1 
			, @n_starttcnt			= @@TRANCOUNT 

   IF ( @n_continue=1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE RDT.RDTTruckPackInfo 
          SET EditDate = GETDATE(), 
              EditWho=SUSER_SNAME() 
      FROM RDT.RDTTruckPackInfo, INSERTED
      WHERE RDTTruckPackInfo.RowRef =INSERTED.RowRef
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
       	  
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 62850 --66700   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table RDTTruckPackInfo. (ntrRDTTruckPackInfoUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
      END
   END


   /* #INCLUDE <TRAHU2.SQL> */
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      DECLARE @n_IsRDT INT
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT
   
      IF @n_IsRDT = 1
      BEGIN
         -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here
         -- Instead we commit and raise an error back to parent, let the parent decide
   
         -- Commit until the level we begin with
         WHILE @@TRANCOUNT > @n_starttcnt
            COMMIT TRAN
   
         -- Raise error with severity = 10, instead of the default severity 16. 
         -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger
         RAISERROR (@n_err, 10, 1) WITH SETERROR 
   
         -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten
      END
      ELSE
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
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrRDTTruckPackInfoUpdate'
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
         RETURN
      END
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
ALTER TABLE [RDT].[rdtTruckPackInfo] ADD CONSTRAINT [PK_rdtTruckPackInfo] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtTruckPackInfo] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtTruckPackInfo] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtTruckPackInfo] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtTruckPackInfo] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Add Date', 'SCHEMA', N'RDT', 'TABLE', N'rdtTruckPackInfo', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Add Who', 'SCHEMA', N'RDT', 'TABLE', N'rdtTruckPackInfo', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton Type', 'SCHEMA', N'RDT', 'TABLE', N'rdtTruckPackInfo', 'COLUMN', N'CartonType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Destination', 'SCHEMA', N'RDT', 'TABLE', N'rdtTruckPackInfo', 'COLUMN', N'Destination'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Edit Date', 'SCHEMA', N'RDT', 'TABLE', N'rdtTruckPackInfo', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Edit Who', 'SCHEMA', N'RDT', 'TABLE', N'rdtTruckPackInfo', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Facility', 'SCHEMA', N'RDT', 'TABLE', N'rdtTruckPackInfo', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'IsReturn', 'SCHEMA', N'RDT', 'TABLE', N'rdtTruckPackInfo', 'COLUMN', N'IsReturn'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Order Key', 'SCHEMA', N'RDT', 'TABLE', N'rdtTruckPackInfo', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pallet  ID', 'SCHEMA', N'RDT', 'TABLE', N'rdtTruckPackInfo', 'COLUMN', N'PalletID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Qty', 'SCHEMA', N'RDT', 'TABLE', N'rdtTruckPackInfo', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ReturnPalletID', 'SCHEMA', N'RDT', 'TABLE', N'rdtTruckPackInfo', 'COLUMN', N'ReturnPalletID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Row Ref', 'SCHEMA', N'RDT', 'TABLE', N'rdtTruckPackInfo', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer Key', 'SCHEMA', N'RDT', 'TABLE', N'rdtTruckPackInfo', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracking No', 'SCHEMA', N'RDT', 'TABLE', N'rdtTruckPackInfo', 'COLUMN', N'TrackingNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type', 'SCHEMA', N'RDT', 'TABLE', N'rdtTruckPackInfo', 'COLUMN', N'Type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Vehicle Num', 'SCHEMA', N'RDT', 'TABLE', N'rdtTruckPackInfo', 'COLUMN', N'VehicleNum'
GO
