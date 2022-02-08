CREATE TABLE [dbo].[XDOCK]
(
[XDOCKKEY] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HAWBKEY] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_HAWBKEY] DEFAULT (' '),
[MAWBKEY] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_MAWBKEY] DEFAULT (' '),
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_ConsigneeKey] DEFAULT (' '),
[C_contact1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Contact2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Company] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Address1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Address2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Address3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Address4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_City] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_State] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Country] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_ISOCntryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Phone1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Fax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipperKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_ShipperKey] DEFAULT (' '),
[S_contact1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Contact2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Company] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Address1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Address2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Address3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Address4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_City] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_State] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Country] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_ISOCntryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Phone1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Fax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgentKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_AgentKey] DEFAULT (' '),
[A_contact1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Contact2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Company] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Address1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Address2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Address3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Address4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_City] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_State] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Country] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_ISOCntryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Phone1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Fax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountingInfo] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Currency] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCK_Currency] DEFAULT ('USD'),
[WtValPPD] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCK_WtValPPD] DEFAULT (' '),
[WtValCol] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCK_WtValCol] DEFAULT (' '),
[OtherPPD] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCK_OtherPPD] DEFAULT (' '),
[OtherCol] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCK_OtherCol] DEFAULT (' '),
[DeclaredValueForCustoms] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCK_DeclaredValueForCustoms] DEFAULT ('As Per Invoice'),
[PlaceOfLoading] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCK_PlaceOfLoading] DEFAULT (' '),
[RouteTO01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCK_RouteTo01] DEFAULT (' '),
[RouteTO02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCK_RouteTo02] DEFAULT (' '),
[RouteTO03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCK_RouteTo03] DEFAULT (' '),
[Carrier01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCK_Carrier01] DEFAULT (' '),
[Carrier02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCK_Carrier02] DEFAULT (' '),
[Carrier03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCK_Carrier03] DEFAULT (' '),
[AirportOfDestination] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCK_AirportOfDestination] DEFAULT (' '),
[FlightDate01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_FlightDate01] DEFAULT (' '),
[FlightDate02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_FlightDate02] DEFAULT (' '),
[AmountOfInsurance] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_AmountOfInsurance] DEFAULT (' '),
[HandlingInfo] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChargeDesc01] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_ChargeDesc01] DEFAULT (' '),
[PPDCharge01] [float] NOT NULL CONSTRAINT [DF_XDOCK_PPDCharge01] DEFAULT ((0)),
[COLLCharge01] [float] NOT NULL CONSTRAINT [DF_XDOCK_COLLCharge01] DEFAULT ((0)),
[ChargeDesc02] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_ChargeDesc02] DEFAULT (' '),
[PPDCharge02] [float] NOT NULL CONSTRAINT [DF_XDOCK_PPDCharge02] DEFAULT ((0)),
[COLLCharge02] [float] NOT NULL CONSTRAINT [DF_XDOCK_COLLCharge02] DEFAULT ((0)),
[ChargeDesc03] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_ChargeDesc03] DEFAULT (' '),
[PPDCharge03] [float] NOT NULL CONSTRAINT [DF_XDOCK_PPDCharge03] DEFAULT ((0)),
[COLLCharge03] [float] NOT NULL CONSTRAINT [DF_XDOCK_COLLCharge03] DEFAULT ((0)),
[ChargeDesc04] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_ChargeDesc04] DEFAULT (' '),
[PPDCharge04] [float] NOT NULL CONSTRAINT [DF_XDOCK_PPDCharge04] DEFAULT ((0)),
[COLLCharge04] [float] NOT NULL CONSTRAINT [DF_XDOCK_COLLCharge04] DEFAULT ((0)),
[ChargeDesc05] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_ChargeDesc05] DEFAULT (' '),
[PPDCharge05] [float] NOT NULL CONSTRAINT [DF_XDOCK_PPDCharge05] DEFAULT ((0)),
[COLLCharge05] [float] NOT NULL CONSTRAINT [DF_XDOCK_COLLCharge05] DEFAULT ((0)),
[ChargeDesc06] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_ChargeDesc06] DEFAULT (' '),
[PPDCharge06] [float] NOT NULL CONSTRAINT [DF_XDOCK_PPDCharge06] DEFAULT ((0)),
[COLLCharge06] [float] NOT NULL CONSTRAINT [DF_XDOCK_COLLCharge06] DEFAULT ((0)),
[PPDChargeTotal] [float] NOT NULL CONSTRAINT [DF_XDOCK_PPDChargeTotal] DEFAULT ((0)),
[CollChargeTotal] [float] NOT NULL CONSTRAINT [DF_XDOCK_CollChargeTotal] DEFAULT ((0)),
[TotalCharge] [float] NOT NULL CONSTRAINT [DF_XDOCK_TotalCharge] DEFAULT ((0)),
[ExpectedTotalQty] [int] NOT NULL CONSTRAINT [DF_XDOCK_ExpectedTotalQty] DEFAULT ((0)),
[ExpectedTotalGrossWgt] [float] NOT NULL CONSTRAINT [DF_XDOCK_ExpectedTotalGrossWgt] DEFAULT ((0)),
[ExpectedTotalNetWgt] [float] NOT NULL CONSTRAINT [DF_XDOCK_ExpectedTotalNetWgt] DEFAULT ((0)),
[ExpectedTotalCube] [float] NOT NULL CONSTRAINT [DF_XDOCK_ExpectedTotalCube] DEFAULT ((0)),
[ReceivedTotalQty] [int] NOT NULL CONSTRAINT [DF_XDOCK_ReceivedTotalQty] DEFAULT ((0)),
[ReceivedTotalGrossWgt] [float] NOT NULL CONSTRAINT [DF_XDOCK_ReceivedTotalGrossWgt] DEFAULT ((0)),
[ReceivedTotalNetWgt] [float] NOT NULL CONSTRAINT [DF_XDOCK_ReceivedTotalNetWgt] DEFAULT ((0)),
[ReceivedTotalCube] [float] NOT NULL CONSTRAINT [DF_XDOCK_ReceivedTotalCube] DEFAULT ((0)),
[ShippedTotalQty] [int] NOT NULL CONSTRAINT [DF_XDOCK_ShippedTotalQty] DEFAULT ((0)),
[ShippedTotalGrossWgt] [float] NOT NULL CONSTRAINT [DF_XDOCK_ShippedTotalGrossWgt] DEFAULT ((0)),
[ShippedTotalNetWgt] [float] NOT NULL CONSTRAINT [DF_XDOCK_ShippedTotalNetWgt] DEFAULT ((0)),
[ShippedTotalCube] [float] NOT NULL CONSTRAINT [DF_XDOCK_ShippedTotalCube] DEFAULT ((0)),
[AlternateCurrency] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_AlternateCurrency] DEFAULT ('USD'),
[ConversionRate] [float] NOT NULL CONSTRAINT [DF_XDOCK_ConversionRate] DEFAULT ((1)),
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceiveStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_ReceiveStatus] DEFAULT ('0'),
[ShipStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_ShipStatus] DEFAULT ('0'),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_XDOCK_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_XDOCK_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_XDOCK_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCK_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/* 17-Mar-2009  TLTING     Change user_name() to SUSER_SNAME()          */

CREATE TRIGGER [dbo].[ntrXdockHeaderAdd]
 ON  [dbo].[XDOCK]
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
      /* #INCLUDE <TRXDKHA1.SQL> */     
 IF @n_continue=1 or @n_continue=2
 BEGIN
 UPDATE XDOCK SET TrafficCop = NULL, AddDate = GETDATE(), AddWho=SUSER_SNAME(), EditDate = GETDATE(), EditWho=SUSER_SNAME() FROM XDOCK,inserted
 WHERE XDOCK.XdockKey=inserted.XdockKey
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=77401   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Insert Failed On Table XDOCK. (ntrXdockHeaderAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
 IF @n_continue=1 or @n_continue=2
 BEGIN
 IF EXISTS(SELECT * FROM INSERTED WHERE ReceiveStatus <> "0" or ShipStatus <> "0")
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=77402   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Insert Failed On Table XDOCK. Status is Non-Zero. (ntrXdockHeaderAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
      /* #INCLUDE <TRXDKHA2.SQL> */
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
 execute nsp_logerror @n_err, @c_errmsg, "ntrXdockHeaderAdd"
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

CREATE TRIGGER [dbo].[ntrXDockHeaderDelete]
 ON [dbo].[XDOCK]
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
      /* #INCLUDE <TRXDKHD1.SQL> */     
 IF (select count(*) from DELETED) =
 (select count(*) from DELETED where DELETED.ArchiveCop = '9')
 BEGIN
 SELECT @n_continue = 4
 END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 DELETE XDOCKDetail FROM XDOCKDetail, Deleted
 WHERE XDOCKDetail.XDOCKKey=Deleted.XDOCKKey
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 77501   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On Table XDOCKDETAIL Failed. (ntrXDockHeaderDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
      /* #INCLUDE <TRXDKHD2.SQL> */
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
 EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrXDockHeaderDelete"
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
/* 28-Oct-2013  TLTING     Review Editdate column update                */

CREATE TRIGGER [dbo].[ntrXdockHeaderUpdate]
 ON  [dbo].[XDOCK]
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
      /* #INCLUDE <TRXDKHU1.SQL> */     
 IF @n_continue=1 or @n_continue=2
 BEGIN
 IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
 BEGIN
 UPDATE    XDOCK
 SET  EditDate = GETDATE(),
 EditWho = SUSER_SNAME()
 FROM XDOCK,
 INSERTED
 WHERE XDOCK.XDOCKKey = INSERTED.XDOCKKey
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=77601   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table XDOCK. (ntrXdockHeaderUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
 IF @n_continue = 1 or @n_continue=2
 BEGIN
 UPDATE    XDOCK
 SET  ReceiveStatus = (CASE When INSERTED.ReceivedTotalQty = 0 Then "0"
 When INSERTED.ExpectedTotalQty > INSERTED.ReceivedTotalQty THEN "5"
 When INSERTED.ExpectedTotalQty <= INSERTED.ReceivedTotalQty THEN "9"
 END
 )
 FROM XDOCK,
 INSERTED,
 DELETED
 WHERE XDOCK.XDOCKKey = INSERTED.XDOCKKey
 AND INSERTED.XDOCKKey = DELETED.XDOCKKey
 AND DELETED.ReceiveStatus = "9"    
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=77602   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table XDOCK. (ntrXdockHeaderUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
 IF @n_continue = 1 or @n_continue=2
 BEGIN
 UPDATE    XDOCK
 SET  ReceiveStatus = (CASE When INSERTED.ReceivedTotalQty = 0 Then "0"
 When INSERTED.ExpectedTotalQty > INSERTED.ReceivedTotalQty THEN "5"
 When INSERTED.ExpectedTotalQty <= INSERTED.ReceivedTotalQty THEN "9"
 END
 )
 FROM XDOCK,
 INSERTED,
 DELETED
 WHERE XDOCK.XDOCKKey = INSERTED.XDOCKKey
 AND INSERTED.XDOCKKey = DELETED.XDOCKKey
 AND DELETED.ReceiveStatus < "9"
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=77602   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table XDOCK. (ntrXdockHeaderUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
 IF @n_continue = 1 or @n_continue=2
 BEGIN
 UPDATE    XDOCK
 SET  ShipStatus =    (CASE When INSERTED.ShippedTotalQty = 0 Then "0"
 When INSERTED.ReceivedTotalQty > INSERTED.ShippedTotalQty THEN "5"
 When INSERTED.ShippedTotalQty >= INSERTED.ReceivedTotalQty THEN "9"
 END
 )
 FROM XDOCK,
 INSERTED,
 DELETED
 WHERE XDOCK.XDOCKKey = INSERTED.XDOCKKey
 AND INSERTED.XDOCKKey = DELETED.XDOCKKey
 AND DELETED.ShipStatus = "9"    
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=77602   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table XDOCK. (ntrXdockHeaderUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
 IF @n_continue = 1 or @n_continue=2
 BEGIN
 UPDATE    XDOCK
 SET  ShipStatus =    (CASE When INSERTED.ShippedTotalQty = 0 Then "0"
 When INSERTED.ReceivedTotalQty > INSERTED.ShippedTotalQty THEN "5"
 When INSERTED.ShippedTotalQty >= INSERTED.ReceivedTotalQty THEN "9"
 END
 )
 FROM XDOCK,
 INSERTED,
 DELETED
 WHERE XDOCK.XDOCKKey = INSERTED.XDOCKKey
 AND INSERTED.XDOCKKey = DELETED.XDOCKKey
 AND DELETED.ShipStatus < "9"
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=77602   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table XDOCK. (ntrXdockHeaderUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
 END
      /* #INCLUDE <TRXDKHU2.SQL> */
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
 execute nsp_logerror @n_err, @c_errmsg, "ntrXdockHeaderUpdate"
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
ALTER TABLE [dbo].[XDOCK] WITH NOCHECK ADD CONSTRAINT [CK_XDOCK_RcpStatus] CHECK ((rtrim([ReceiveStatus]) like '[0-9]'))
GO
ALTER TABLE [dbo].[XDOCK] WITH NOCHECK ADD CONSTRAINT [CK_XDOCK_ShpStatus] CHECK ((rtrim([ShipStatus]) like '[0-9]'))
GO
ALTER TABLE [dbo].[XDOCK] ADD CONSTRAINT [PKXdock] PRIMARY KEY CLUSTERED ([XDOCKKEY]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[XDOCK] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[XDOCK] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[XDOCK] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[XDOCK] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Crossdocking is a warehousing method in which inbound commodities (SKU) are received and moved to outbound docks as opposed to being placed into storage. Numerous industries have adopted various forms of crossdock activity in order to increase inventory velocity.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'A_Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'A_Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'A_Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'A_Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'A_City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'A_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Agent.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'A_contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Agent.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'A_Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'A_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'A_Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country code for the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'A_ISOCntryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'A_Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'A_State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Agent company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'A_Zip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Agent.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'AgentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'C_Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'C_Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'C_Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'C_Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'C_City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'C_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'C_contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'C_Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'C_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'C_Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country code for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'C_ISOCntryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'C_Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'C_State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'C_Zip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'ConsigneeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total cube of the product expected in the location.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'ExpectedTotalCube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total gross weight of the product expected in the location.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'ExpectedTotalGrossWgt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total net weight of the product expected in the location.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'ExpectedTotalNetWgt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total quantity of the product expected in the location.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'ExpectedTotalQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Host Airway Bill.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'HAWBKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Master Airway Bill.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'MAWBKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information about crossdock.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total cube of the product received in the location.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'ReceivedTotalCube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total gross weight of the product received in the location.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'ReceivedTotalGrossWgt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total net weight of the product received in the location.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'ReceivedTotalNetWgt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total quantity of the product received in the location.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'ReceivedTotalQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'S_Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'S_Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'S_Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'S_Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'S_City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'S_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Shipper.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'S_contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Shipper.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'S_Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country of the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'S_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'S_Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country code for the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'S_ISOCntryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'S_Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'S_State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Shipper company.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'S_Zip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total cube of the product being shipped.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'ShippedTotalCube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total gross weight of the product being shipped.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'ShippedTotalGrossWgt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total net weight of the product being shipped.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'ShippedTotalNetWgt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total quantity of the product being shipped.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'ShippedTotalQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Shipper.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'ShipperKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Cross Dock.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCK', 'COLUMN', N'XDOCKKEY'
GO
