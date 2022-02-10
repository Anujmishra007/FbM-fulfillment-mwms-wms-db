CREATE TABLE [dbo].[HOUSEAIRWAYBILLDETAIL]
(
[HAWBKEY] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HAWBLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_HAWBLineNumber] DEFAULT (' '),
[NumberOfPieces] [int] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_NumberOfPieces] DEFAULT ((1)),
[GrossWeight] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_GrossWeight] DEFAULT ((0)),
[UOMWeight] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_UOMWeight] DEFAULT (' '),
[RateClass] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_RateClass] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_Sku] DEFAULT (' '),
[SkuDescription] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_SkuDescription] DEFAULT (' '),
[ChargeableWeight] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_ChargeableWeight] DEFAULT ((0)),
[Rate] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_Rate] DEFAULT ((0)),
[Extension] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_Extension] DEFAULT ((0)),
[UOMVolume] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_UOMVolume] DEFAULT (' '),
[Length] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_Length] DEFAULT ((0)),
[Width] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_Width] DEFAULT ((0)),
[Height] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_Height] DEFAULT ((0)),
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [timestamp] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE TRIGGER [dbo].[ntrHouseAirWayBillDetailAdd]
 ON  [dbo].[HOUSEAIRWAYBILLDETAIL]
 FOR INSERT
 AS
 BEGIN
    SET NOCOUNT ON
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
      /* #INCLUDE <TRHABDA1.SQL> */     
 IF @n_continue=1 or @n_continue=2
 BEGIN
 IF EXISTS (SELECT * FROM HouseAirWayBill, INSERTED
 WHERE HouseAirWayBill.HAWBKey = INSERTED.HAWBKey
 AND HouseAirWayBill.Status = "9")
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err=72302
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": HouseAirWayBill.Status = 'SHIPPED'. DELETE rejected. (ntrHouseAirWayBillDetailAdd)"
 END
 END
      /* #INCLUDE <TRHABDA2.SQL> */
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
 execute nsp_logerror @n_err, @c_errmsg, "ntrHouseAirWayBillDetailAdd"
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

CREATE TRIGGER [dbo].[ntrHouseAirWayBillDetailDelete]
 ON [dbo].[HOUSEAIRWAYBILLDETAIL]
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
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
      /* #INCLUDE <TRHABDD1.SQL> */     
 IF (select count(*) from DELETED) =
 (select count(*) from DELETED where DELETED.ArchiveCop = '9')
 BEGIN
 SELECT @n_continue = 4
 END
 IF @n_continue=1 or @n_continue=2
 BEGIN
 IF EXISTS (SELECT * FROM HouseAirWayBill, DELETED
 WHERE HouseAirWayBill.HAWBKey = DELETED.HAWBKey
 AND HouseAirWayBill.Status = "9")
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err=72500
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": HouseAirWayBill.Status = 'SHIPPED'. DELETE rejected. (ntrHouseAirWayBillDetailDelete)"
 END
 END
      /* #INCLUDE <TRHABDD2.SQL> */
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
 EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrHouseAirWayBillDetailDelete"
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

CREATE TRIGGER [dbo].[ntrHouseAirWayBillDetailUpdate]
 ON  [dbo].[HOUSEAIRWAYBILLDETAIL]
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
 IF UPDATE(TrafficCop)
 BEGIN
 SELECT @n_continue = 4 
 END
 IF UPDATE(ArchiveCop)
 BEGIN
 SELECT @n_continue = 4 
 END
      /* #INCLUDE <TRHABDU1.SQL> */     
 IF @n_continue=1 or @n_continue=2
 BEGIN
 IF EXISTS (SELECT * FROM HouseAirWayBill, INSERTED
 WHERE HouseAirWayBill.HAWBKey= INSERTED.HAWBKey
 AND HouseAirWayBill.Status = "9")
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err=72400
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": HouseAirWayBill.Status = 'SHIPPED'. UPDATE rejected. (ntrHouseAirWayBillDetailUpdate)"
 END
 END
 IF ( @n_continue=1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
 BEGIN
 UPDATE HouseAirWayBillDetail with (ROWLOCK) 
 SET  EditDate = GETDATE(),
 EditWho = SUSER_SNAME()
 FROM HouseAirWayBillDetail, INSERTED
 WHERE HouseAirWayBillDetail.HAWBKey= INSERTED.HAWBKey AND
 HouseAirWayBillDetail.HAWBLineNumber = INSERTED.HAWBLineNumber
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72402   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table HouseAirWayBillDetail. (ntrHouseAirWayBillDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
      /* #INCLUDE <TRHABDU2.SQL> */
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
 execute nsp_logerror @n_err, @c_errmsg, "ntrHouseAirWayBillDetailUpdate"
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
ALTER TABLE [dbo].[HOUSEAIRWAYBILLDETAIL] ADD CONSTRAINT [PKHouseAirWayBillDetail] PRIMARY KEY CLUSTERED ([HAWBKEY], [HAWBLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[HOUSEAIRWAYBILLDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[HOUSEAIRWAYBILLDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[HOUSEAIRWAYBILLDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[HOUSEAIRWAYBILLDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying House Airway Bill.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'HAWBKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information about House Airway Bill Detail.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The cost per unit of a commodity or service.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'Rate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'SkuDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'TrafficCop'
GO
