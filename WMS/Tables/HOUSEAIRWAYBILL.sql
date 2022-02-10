CREATE TABLE [dbo].[HOUSEAIRWAYBILL]
(
[HAWBKEY] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MAWBKEY] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_MAWBKEY] DEFAULT (' '),
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_ConsigneeKey] DEFAULT (' '),
[C_contact1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Contact2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Company] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Address1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Address2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Address3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Address4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_City] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_State] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Country] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_ISOCntryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Phone1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Phone2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Fax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Fax2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipperKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_ShipperKey] DEFAULT (' '),
[S_contact1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Contact2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Company] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Address1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Address2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Address3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Address4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_City] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_State] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Country] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_ISOCntryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Phone1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Phone2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Fax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Fax2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgentKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_AgentKey] DEFAULT (' '),
[A_contact1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Contact2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Company] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Address1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Address2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Address3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Address4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_City] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_State] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Country] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_ISOCntryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Phone1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Phone2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Fax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Fax2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountingInfo] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Currency] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_Currency] DEFAULT ('USD'),
[WtValPPD] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_WtValPPD] DEFAULT (' '),
[WtValCol] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_WtValCol] DEFAULT (' '),
[OtherPPD] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_OtherPPD] DEFAULT (' '),
[OtherCol] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_OtherCol] DEFAULT (' '),
[DeclaredValueForCustoms] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_DeclaredValueForCustoms] DEFAULT ('As Per Invoice'),
[PlaceOfLoading] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_PlaceOfLoading] DEFAULT (' '),
[RouteTO01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_RouteTO01] DEFAULT (' '),
[RouteTO02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_RouteTO02] DEFAULT (' '),
[RouteTO03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_RouteTO03] DEFAULT (' '),
[Carrier01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_Carrier01] DEFAULT (' '),
[Carrier02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_Carrier02] DEFAULT (' '),
[Carrier03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_Carrier03] DEFAULT (' '),
[AirportOfDestination] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_AirportOfDestination] DEFAULT (' '),
[FlightDate01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_FlightDate01] DEFAULT (' '),
[FlightDate02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_FlightDate02] DEFAULT (' '),
[AmountOfInsurance] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_AmountOfInsurance] DEFAULT (' '),
[HandlingInfo] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChargeDesc01] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_ChargeDesc01] DEFAULT (' '),
[PPDCharge01] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_PPDCharge01] DEFAULT ((0)),
[COLLCharge01] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_COLLCharge01] DEFAULT ((0)),
[ChargeDesc02] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_ChargeDesc02] DEFAULT (' '),
[PPDCharge02] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_PPDCharge02] DEFAULT ((0)),
[COLLCharge02] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_COLLCharge02] DEFAULT ((0)),
[ChargeDesc03] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_ChargeDesc03] DEFAULT (' '),
[PPDCharge03] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_PPDCharge03] DEFAULT ((0)),
[COLLCharge03] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_COLLCharge03] DEFAULT ((0)),
[ChargeDesc04] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_ChargeDesc04] DEFAULT (' '),
[PPDCharge04] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_PPDCharge04] DEFAULT ((0)),
[COLLCharge04] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_COLLCharge04] DEFAULT ((0)),
[ChargeDesc05] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_ChargeDesc05] DEFAULT (' '),
[PPDCharge05] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_PPDCharge05] DEFAULT ((0)),
[COLLCharge05] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_COLLCharge05] DEFAULT ((0)),
[ChargeDesc06] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_ChargeDesc06] DEFAULT (' '),
[PPDCharge06] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_PPDCharge06] DEFAULT ((0)),
[COLLCharge06] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_COLLCharge06] DEFAULT ((0)),
[PPDChargeTotal] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_PPDChargeTotal] DEFAULT ((0)),
[CollChargeTotal] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_CollChargeTotal] DEFAULT ((0)),
[TotalCharge] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_TotalCharge] DEFAULT ((0)),
[TotalPkgReceived] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_TotalPkgReceived] DEFAULT ((0)),
[TotalGrossWgt] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_TotalGrossWgt] DEFAULT ((0)),
[AlternateCurrency] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_AlternateCurrency] DEFAULT ('USD'),
[ConversionRate] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_ConversionRate] DEFAULT ((1)),
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_Status] DEFAULT ('0'),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [timestamp] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/* 17-Mar-2009  TLTING     Change user_name() to SUSER_SNAME()          */
CREATE TRIGGER [dbo].[ntrHouseAirWayBillAdd]
 ON  [dbo].[HOUSEAIRWAYBILL]
 FOR INSERT
 AS
 BEGIN
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
      /* #INCLUDE <TRHABHA1.SQL> */     
 IF @n_continue=1 or @n_continue=2
 BEGIN
 IF EXISTS (SELECT * FROM INSERTED WHERE Status = "9")
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err=71402
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Bad HouseAirWayBill.Status. (nspHouseAirWayBillAdd)"
 END
 END
 IF @n_continue=1 or @n_continue=2
 BEGIN
 UPDATE HouseAirWayBill
 SET  TrafficCop = NULL,
 AddDate = GETDATE(),
 AddWho = SUSER_SNAME(),
 EditDate = GETDATE(),
 EditWho = SUSER_SNAME()
 FROM HouseAirWayBill, INSERTED
 WHERE HouseAirWayBill.HAWBKey = INSERTED.HAWBKey
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=71401   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Insert Failed On Table HouseAirWayBill. (nspHouseAirWayBillAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
      /* #INCLUDE <TRHABHA2.SQL> */
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
 execute nsp_logerror @n_err, @c_errmsg, "ntrHouseAirWayBillAdd"
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

CREATE TRIGGER [dbo].[ntrHouseAirWayBillDelete]
 ON [dbo].[HOUSEAIRWAYBILL]
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
      /* #INCLUDE <TRHABHD1.SQL> */     
 IF (select count(*) from DELETED) =
 (select count(*) from DELETED where DELETED.ArchiveCop = '9')
 BEGIN
 SELECT @n_continue = 4
 END
 IF @n_continue=1 or @n_continue=2
 BEGIN
 IF EXISTS (SELECT * FROM DELETED WHERE Status = "9")
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err=71600
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": HouseAirWayBill.Status = 'SHIPPED'. DELETE rejected. (ntrHouseAirWayBillDelete)"
 END
 END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 DELETE HouseAirWayBillDetail FROM HouseAirWayBillDetail, DELETED
 WHERE HouseAirWayBillDetail.HAWBKey = DELETED.HAWBKey
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 71602   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On Table HouseAirWayBill Failed. (ntrContainerHeaderDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
      /* #INCLUDE <TRHABHD2.SQL> */
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
 EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrHouseAirWayBillDelete"
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

CREATE TRIGGER [dbo].[ntrHouseAirWayBillUpdate]
 ON  [dbo].[HOUSEAIRWAYBILL]
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
      /* #INCLUDE <TRHABHU1.SQL> */     
 IF @n_continue=1 or @n_continue=2
 BEGIN
 IF EXISTS (SELECT * FROM DELETED, INSERTED
 WHERE DELETED.HAWBKey= INSERTED.HAWBKey
 AND DELETED.Status = "9")
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err=71500
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": HouseAirWayBill.Status = 'SHIPPED'. UPDATE rejected. (ntrHouseAirWayBillUpdate)"
 END
 END
 IF ( @n_continue=1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
 BEGIN
 UPDATE HouseAirWayBill with (ROWLOCK)
 SET  EditDate = GETDATE(),
 EditWho = SUSER_SNAME()
 FROM HouseAirWayBill, INSERTED
 WHERE HouseAirWayBill.HAWBKey= INSERTED.HAWBKey
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=71502   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table HouseAirWayBill. (ntrHouseAirWayBillUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
      /* #INCLUDE <TRHABHU2.SQL> */
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
 execute nsp_logerror @n_err, @c_errmsg, "ntrHouseAirWayBillUpdate"
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
ALTER TABLE [dbo].[HOUSEAIRWAYBILL] WITH NOCHECK ADD CONSTRAINT [CK_HAWB_Status] CHECK ((rtrim([Status]) like '[0-9]'))
GO
ALTER TABLE [dbo].[HOUSEAIRWAYBILL] ADD CONSTRAINT [PKHouseAirWayBill] PRIMARY KEY CLUSTERED ([HAWBKEY]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[HOUSEAIRWAYBILL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[HOUSEAIRWAYBILL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[HOUSEAIRWAYBILL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[HOUSEAIRWAYBILL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'A_Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'A_Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'A_Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'A_Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'A_City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'A_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Agent.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'A_contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Agent.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'A_Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'A_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'A_Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'A_Fax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country code for the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'A_ISOCntryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'A_Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'A_Phone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'A_State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'A_Zip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Information regarding accounts.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'AccountingInfo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Agent.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'AgentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'C_Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'C_Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'C_Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'C_Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'C_City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'C_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'C_contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'C_Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'C_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'C_Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'C_Fax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country code for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'C_ISOCntryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'C_Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'C_Phone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'C_State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'C_Zip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'ConsigneeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of currency used.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'Currency'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying House Airway Bill.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'HAWBKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Master Airway Bill.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'MAWBKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information about House Airway Bill.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'S_Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'S_Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'S_Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'S_Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'S_City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'S_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Shipper.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'S_contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Shipper.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'S_Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contry of the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'S_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'S_Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'S_Fax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country code for the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'S_ISOCntryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'S_Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'S_Phone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Shipper company', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'S_State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'S_Zip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Shipper.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'ShipperKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILL', 'COLUMN', N'TrafficCop'
GO
