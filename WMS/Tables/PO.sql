CREATE TABLE [dbo].[PO]
(
[POKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_ExternPOKey] DEFAULT (' '),
[PoGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PO_PoGroup] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PODate] [datetime] NULL CONSTRAINT [DF_PO_PODate] DEFAULT (getdate()),
[SellersReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellersReference] DEFAULT (' '),
[BuyersReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyersReference] DEFAULT (' '),
[OtherReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_OtherReference] DEFAULT (' '),
[POType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_POType] DEFAULT (' '),
[SellerName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerName] DEFAULT (' '),
[SellerAddress1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerAddress1] DEFAULT (' '),
[SellerAddress2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerAddress2] DEFAULT (' '),
[SellerAddress3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerAddress3] DEFAULT (' '),
[SellerAddress4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerAddress4] DEFAULT (' '),
[SellerCity] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerCity] DEFAULT (' '),
[SellerState] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerState] DEFAULT (' '),
[SellerZip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerZip] DEFAULT (' '),
[SellerPhone] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerPhone] DEFAULT (' '),
[SellerVat] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerVat] DEFAULT (' '),
[BuyerName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerName] DEFAULT (' '),
[BuyerAddress1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerAddress1] DEFAULT (' '),
[BuyerAddress2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerAddress2] DEFAULT (' '),
[BuyerAddress3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerAddress3] DEFAULT (' '),
[BuyerAddress4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerAddress4] DEFAULT (' '),
[BuyerCity] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerCity] DEFAULT (' '),
[BuyerState] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerState] DEFAULT (' '),
[BuyerZip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerZip] DEFAULT (' '),
[BuyerPhone] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerPhone] DEFAULT (' '),
[BuyerVAT] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerVAT] DEFAULT (' '),
[OriginCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_OriginCountry] DEFAULT (' '),
[DestinationCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_DestinationCountry] DEFAULT (' '),
[Vessel] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_Vessel] DEFAULT (' '),
[VesselDate] [datetime] NULL CONSTRAINT [DF_PO_VesselDate] DEFAULT (NULL),
[PlaceOfLoading] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_PlaceOfLoading] DEFAULT (' '),
[PlaceOfDischarge] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_PlaceOfDischarge] DEFAULT (' '),
[PlaceofDelivery] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_PlaceofDelivery] DEFAULT (' '),
[IncoTerms] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_IncoTerms] DEFAULT (' '),
[Pmtterm] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_PmtTerm] DEFAULT (' '),
[TransMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_TransMethod] DEFAULT (' '),
[TermsNote] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_TermsNote] DEFAULT (' '),
[Signatory] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_Signatory] DEFAULT (' '),
[PlaceofIssue] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_PlaceofIssue] DEFAULT (' '),
[OpenQty] [int] NULL CONSTRAINT [DF_PO_OpenQty] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PO_Status] DEFAULT ('0'),
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_PO_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PO_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PO_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PO_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PO_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_ExternStatus] DEFAULT ('0'),
[LoadingDate] [datetime] NULL,
[ReasonCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_ReasonCode] DEFAULT (' '),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_UserDefine08] DEFAULT (' '),
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_UserDefine10] DEFAULT (' '),
[xdockpokey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SellerCompany] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerCompany] DEFAULT (''),
[SellerCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerCountry] DEFAULT (''),
[SellerContact1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerContact1] DEFAULT (''),
[SellerContact2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerContact2] DEFAULT (''),
[SellerPhone2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerPhone2] DEFAULT (''),
[SellerEmail1] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerEmail1] DEFAULT (''),
[SellerEmail2] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerEmail2] DEFAULT (''),
[SellerFax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerFax1] DEFAULT (''),
[SellerFax2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerFax2] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: ntrPOHeaderAdd                                      */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: normal receipt                                              */
/*                                                                      */
/* Called from: 3                                                       */
/*    1. From PowerBuilder                                              */
/*    2. From scheduler                                                 */
/*    3. From others stored procedures or triggers                      */
/*    4. From interface program. DX, DTS                                */
/*                                                                      */
/* Exceed version: 5.4                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2002-08-05 1.0  admin    Initial version                             */
/* 2003-09-16 1.1  wtshong  SOS# 14983 PO Header did not update         */
/*                          Supplier code                               */
/* 2003-09-16 1.2  wtshong  Bugs fixing                                 */
/* 2006-06-17 1.3  ung      SOS53688 Retrieve archived PO               */
/*                          Added ArchiveCop                            */
/* 2017-07-27 1.4  TLTING   SET Option                                  */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrPOHeaderAdd]
ON  [dbo].[PO]
FOR INSERT
AS
BEGIN
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

SET CONCAT_NULL_YIELDS_NULL OFF 
SET NOCOUNT ON 
SET QUOTED_IDENTIFIER OFF 
SET ANSI_NULLS OFF


 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
      /* #INCLUDE <TRPOHA1.SQL> */     
      
-- SOS53688 Added ArchiveCop
IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
   SELECT @n_continue = 4

IF @n_continue=1 or @n_continue=2
BEGIN
   DECLARE @cPOKey NVARCHAR(10)
    
   SELECT @cPOKey = Space(10)
    
   If EXISTS(SELECT 1 FROM INSERTED 
             JOIN STORER (NOLOCK) ON (STORER.Storerkey = INSERTED.SellerName AND STORER.Type = '5')
             WHERE SellerAddress1 = '')
   BEGIN
         Update PO
            Set SellerAddress1 = STORER.Address1,         
                SellerAddress2 = STORER.Address2,
                SellerAddress3 = STORER.Address3,
                SellerAddress4 = STORER.Address4,
                SellerCity = STORER.City,
                SellerState= STORER.State,
                SellerZip = STORER.Zip,
                SellerPhone = STORER.Phone1
         FROM PO (NOLOCK)
         JOIN INSERTED ON (PO.POKey = INSERTED.POKey)
         JOIN STORER (NOLOCK) ON (STORER.StorerKey = PO.SellerName AND STORER.Type = '5')
         WHERE PO.SellerAddress1 = ''
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=64301   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Insert Failed On Table PO. (nspPOHeaderAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
         END
      END
   END
END 
      /* #INCLUDE <TRPOHA2.SQL> */
IF @n_continue=3  -- Error Occured - Process And Return
BEGIN
   IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
   BEGIN
     ROLLBACK TRAN
   END
   Else
   BEGIN
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
        COMMIT TRAN
      END
   END
   Execute nsp_logerror @n_err, @c_errmsg, "ntrPOHeaderAdd"
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/* 14-Jul-2011  KHLim02       GetRight for Delete log                   */
/* 2017-07-27   TLTING        SET Option                                  */

CREATE TRIGGER [dbo].[ntrPOHeaderDelete]
 ON [dbo].[PO]
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
,@c_authority        NVARCHAR(1)  -- KHLim02
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
      /* #INCLUDE <TRPOHD1.SQL> */     
 IF (select count(*) from DELETED) =
 (select count(*) from DELETED where DELETED.ArchiveCop = '9')
 BEGIN
 select @n_continue = 4
 END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 DELETE PODetail FROM PODetail, Deleted
 WHERE PODetail.POKey=Deleted.POKey
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 64501   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On Table PODETAIL Failed. (ntrPOHeaderDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
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
               ,@c_errmsg = 'ntrPOHeaderDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.PO_DELLOG ( POKey )
         SELECT POKey FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table PO Failed. (ntrPOHeaderDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

      /* #INCLUDE <TRPOHD2.SQL> */
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
 EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrPOHeaderDelete"
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
/* Trigger:  ntrPOHeaderUpdate                                          */  
/* Creation Date:                                                       */  
/* Copyright: IDS                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:  PO Header Update trigger                                   */  
/*                                                                      */  
/* Input Parameters:                                                    */  
/*                                                                      */  
/* Output Parameters:  None                                             */  
/*                                                                      */  
/* Return Status:  None                                                 */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Local Variables:                                                     */  
/*                                                                      */  
/* Called By:                                                           */  
/*                                                                      */  
/* PVCS Version: 1.2                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author    Purposes                                      */  
/* 12-Nov-2002  Ricky     Include changes from SOS Oct 1st-Oct 31th By  */  
/*                        Ricky                                         */  
/* 21-Apr-2003  June      TBL HK - FBR10621                             */  
/* 26-Apr-2003  YokeBeen  Modified TransmitLogKey2 for IDSHK TBL        */  
/* 12-Jun-2003  Shong     Performance Tuning - Changing a logic when    */  
/*                        insert into Transmitlog (TBL interface)       */  
/* 02-Dec-2004  Wally     Changes done by HK local IT (SOS27580)        */  
/* 29-Mar-2005  Shong     Performance Tuning                            */  
/* 18-Apr-2005  MaryVong  Check-in for Shong's changes (SOS34015)       */  
/* 15-Aug-2005  June      SOS39407 - Update POdetail.ExternPOkey        */  
/* 13-Oct-2005  Ong       SOS41855 - No TBLPOCLOSE transmitlog when     */  
/*                        PO.OpenQty <> 0                               */  
/* 07-Aug-2006  Vicky     SOS#55884 - Insert into Transmitlog3 when     */  
/*                        PO.ExternStatus is closed                     */  
/* 04-Oct-2006  Shong     Add Loop for Insert Transmitlog3              */  
/*                        And do not reverse the status back to 0       */  
/* 29-May-2008  YokeBeen  SOS#107041 - New trigger point upon PO.Status */  
/*                        to be updated to '1' for PO Outbound with     */  
/*                        StorerConfig.ConfigKey = 'POPreITF'.          */  
/*                        - (YokeBeen01)                                */  
/* 11-Nov-2010  TLTING    SOS195797 - Check detail qty for auto close PO*/  
/* 21-Feb-2011            SOS195797 - add checking sum(qtyreceived) >0  */  
/*                        (tlting01)                                    */  
/* 01-Aug-2011  SPChin    SOS222461 - Bug Fixed                         */  
/* 24-May-2012  TLTING01  DM Integrity issue - Update editdate for      */  
/*                         status < '9'                                 */  
/* 28-Oct-2013  TLTING     Review Editdate column update                */  
/* 28-Jan-2017  TLTING     Set Option                                   */  
/*----------------------------------------------------------------------*/  
/* 22-Feb-2019  YokeBeen  WMS8093 - Adding new trigger point with setup */  
/*                        using ITFTriggerConfig.                       */  
/*                        - Moved existing trigger points to perform in */  
/*                          sub-sp isp_ITF_ntrPO. - (YokeBeen02)        */  
/************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrPOHeaderUpdate]  
ON  [dbo].[PO]  
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
           @b_Success               int       -- Populated by calls to stored procedures - was the proc successful?  
         , @n_err                   int       -- Error number returned by stored procedure or this trigger  
         , @n_err2                  int       -- For Additional Error Detection  
         , @c_errmsg                NVARCHAR(250) -- Error message returned by stored procedure or this trigger  
         , @n_continue              int  
         , @n_starttcnt             int       -- Holds the current transaction count  
         , @c_preprocess            NVARCHAR(250) -- preprocess  
         , @c_pstprocess            NVARCHAR(250) -- post process  
         , @n_cnt                   int  
         , @c_trmlogkey             NVARCHAR(10)  
         , @c_pokey                 NVARCHAR(10)  
         , @c_Storerkey             NVARCHAR(15)    -- added fro idsv5 by June 21.Jun.02  
         , @c_authority             NVARCHAR(1)     -- added for idsv5 by June 21.Jun.02  
         , @c_extpo                 NVARCHAR(1)     -- added by Vicky 18 Apr 2003 - for TBLHK  
         , @n_PO_OpenQty            int             -- SOS41855  
         , @c_pologitf              NVARCHAR(1)     -- SOS#55884  
         , @c_instorerkey           NVARCHAR(15)    -- SOS#55884  
         , @c_inspokey              NVARCHAR(10)    -- SOS#55884  
         , @c_POpreITF              NVARCHAR(1)     -- (YokeBeen01)  
         , @c_StatusUpdated         NVARCHAR(1)     -- (YokeBeen02)   
         , @c_ExternStatusUpdated   NVARCHAR(1)     -- (YokeBeen02)   
         , @c_Proceed               NVARCHAR(1)     -- (YokeBeen02)  
         , @c_COLUMN_NAME           VARCHAR(50)     -- (YokeBeen02)   
         , @c_ColumnsUpdated        VARCHAR(1000)   -- (YokeBeen02)  
         , @b_ColumnsUpdated        VARBINARY(1000) -- (YokeBeen02)  
  
   SET @c_StatusUpdated = 'N'                -- (YokeBeen02)  
   SET @c_ExternStatusUpdated = 'N'          -- (YokeBeen02)  
   SET @c_Proceed = 'N'                      -- (YokeBeen02)  
   SET @b_ColumnsUpdated = COLUMNS_UPDATED() -- (YokeBeen02)  
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  
  
   IF UPDATE(ArchiveCop)  
   BEGIN  
      SELECT @n_continue = 4  
   END  
     
   -- tlting02  
   IF EXISTS ( SELECT 1 FROM INSERTED, DELETED  
                WHERE INSERTED.POKey = DELETED.POKey  
                AND ( INSERTED.[status] < '9' OR DELETED.[status] < '9' ) )   
         AND ( @n_continue=1 OR @n_continue=2 )  
         AND NOT UPDATE(EditDate)  
   BEGIN  
      UPDATE PO WITH (ROWLOCK)  
         SET EditDate = GETDATE(), EditWho = SUSER_SNAME(), TrafficCop = NULL  
         FROM PO, INSERTED  
         WHERE PO.POKey = INSERTED.POKey  
         AND PO.[status] < '9'   
  
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),ISNULL(dbo.fnc_RTrim(@n_err),0)), @n_err=63816     
         SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(dbo.fnc_RTrim(@n_err),0))   
                         + ': Update Failed On Table PO. (ntrPOHeaderUpdate)' + ' ( '   
                           + ' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '  
      END  
   END  
     
   IF UPDATE(TrafficCop)  
   BEGIN  
      SELECT @n_continue = 4  
   END  
  
   /* #INCLUDE <TRPOHU1.SQL> */  
  
   IF UPDATE(EXTERNSTATUS)  
   BEGIN  
      /* -- (YokeBeen02) - Start  
      -- (YokeBeen01) - Start  
      DECLARE C_PO_ITF_RECORDS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
       SELECT INSERTED.Storerkey,  
              INSERTED.POKey  
         FROM INSERTED  
        WHERE INSERTED.ExternStatus = '1'  
  
      OPEN C_PO_ITF_RECORDS  
  
      FETCH NEXT FROM C_PO_ITF_RECORDS INTO @c_instorerkey, @c_inspokey  
  
      WHILE @@FETCH_STATUS <> -1  
      BEGIN  
         -- if PO.status = '1'  
         IF EXISTS (SELECT 1 FROM PO WITH (NOLOCK) WHERE POKey = @c_inspokey AND ExternStatus = '1')  
         BEGIN  
            -- Insert into Transmitlog3 when PO.ExternStatus = '1'  
            SELECT @b_success = 0  
            EXECUTE nspGetRight NULL,  -- facility  
                    @c_instorerkey,    -- Storerkey  
                    NULL,              -- Sku  
                   'POPreITF',         -- Configkey  
                    @b_success    output,  
                    @c_POpreITF   output,  
                    @n_err        output,  
                    @c_errmsg     output  
  
            IF @b_success <> 1  
            BEGIN  
               SELECT @n_continue = 3, @c_errmsg = 'ntrPOHeaderUpdate' + ISNULL(dbo.fnc_RTrim(@c_errmsg),'')  
            END  
            ELSE IF @c_POpreITF = '1'  
            BEGIN  
               SELECT @b_success = 1  
               EXEC dbo.ispGenTransmitLog3 'POPREREQ', @c_inspokey, '', @c_instorerkey, ''  
                                          , @b_success OUTPUT  
                                          , @n_err OUTPUT  
                                          , @c_errmsg OUTPUT  
  
               IF @b_success <> 1  
               BEGIN  
                  SELECT @n_continue = 3  
                  SELECT @c_errmsg = CONVERT(CHAR(250),ISNULL(dbo.fnc_RTrim(@n_err),0)), @n_err=63810  
                  SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(dbo.fnc_RTrim(@n_err),0))  
                                   + ': Unable to obtain transmitlogkey (ntrPOHeaderUpdate)' + ' ( '  
                                   + ' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '  
               END  
            END -- Insert into Transmitlog3 when PO.ExternStatus = '1'  
         END  
  
         FETCH NEXT FROM C_PO_ITF_RECORDS INTO @c_instorerkey, @c_inspokey  
      END -- While  
      CLOSE C_PO_ITF_RECORDS  
      DEALLOCATE C_PO_ITF_RECORDS  
      -- (YokeBeen01) - End  
      -- (YokeBeen02) - End */  
  
      -- if manually close, update status to '9'  
      -- SOS#55884 (Begin)  
      DECLARE C_PO_INSERT_RECORDS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
       SELECT INSERTED.Storerkey,  
              INSERTED.POKey  
         FROM INSERTED  
        WHERE INSERTED.ExternStatus = '9'  
  
      -- SOS#55884 (End)  
  
      OPEN C_PO_INSERT_RECORDS  
      FETCH NEXT FROM C_PO_INSERT_RECORDS INTO @c_instorerkey, @c_inspokey  
  
      WHILE @@FETCH_STATUS <> -1  
      BEGIN  
         IF EXISTS (SELECT 1 FROM PO WITH (NOLOCK) WHERE POKEY = @c_inspokey AND status < '9' AND externstatus = '9' )  
         BEGIN  
            SET @c_StatusUpdated = 'Y' -- (YokeBeen02)  
  
            UPDATE PO WITH (ROWLOCK)  
               SET status = '9',  
                   trafficcop = NULL  
             WHERE POKEY = @c_inspokey  
               AND Externstatus = '9'  
  
            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
            IF @n_err <> 0  
            BEGIN  
               SELECT @n_continue = 3  
               SELECT @c_errmsg = CONVERT(CHAR(250),ISNULL(dbo.fnc_RTrim(@n_err),0)), @n_err=63811  
               SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(dbo.fnc_RTrim(@n_err),0))  
                                + ': Update Failed On Table PO. (ntrPOHeaderUpdate) ( '  
                                + ' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '  
            END  
         END  
  
         /* -- (YokeBeen02) - Start  
         -- SOS#55884 - Insert into Transmitlog3 when PO.ExternStatus is closed (Start)  
         SELECT @b_success = 0  
         EXECUTE nspGetRight NULL,  -- facility  
                 @c_instorerkey,  -- Storerkey  
                 NULL,            -- Sku  
                'POLOG',         -- Configkey  
                 @b_success    output,  
                 @c_pologitf   output,  
                 @n_err        output,  
                 @c_errmsg     output  
  
         IF @b_success <> 1  
         BEGIN  
            SELECT @n_continue = 3, @c_errmsg = 'ntrPOHeaderUpdate' + ISNULL(dbo.fnc_RTrim(@c_errmsg),'')  
         END  
         ELSE IF @c_pologitf = '1'  
         BEGIN  
            SELECT @b_success = 1  
            EXEC ispGenTransmitLog3 'POLOG', @c_inspokey, '', @c_instorerkey, ''  
                                   , @b_success OUTPUT  
                                   , @n_err OUTPUT  
                                   , @c_errmsg OUTPUT  
  
            IF @b_success <> 1  
            BEGIN  
               SELECT @n_continue = 3  
               SELECT @c_errmsg = CONVERT(CHAR(250),ISNULL(dbo.fnc_RTrim(@n_err),0)), @n_err=63812  
               SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(dbo.fnc_RTrim(@n_err),0))  
                                + ': Unable to obtain transmitlogkey (ntrPOHeaderUpdate)' + ' ( '  
                                + ' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '  
            END  
         END -- SOS#55884 - Insert into Transmitlog3 when PO.ExternStatus is closed (End)  
         -- (YokeBeen02) - Start */  
         FETCH NEXT FROM C_PO_INSERT_RECORDS INTO @c_instorerkey, @c_inspokey  
      END -- While  
      CLOSE C_PO_INSERT_RECORDS  
      DEALLOCATE C_PO_INSERT_RECORDS  
   END -- IF UPDATE(EXTERNSTATUS)  
  
   -- Start : SOS39407  
   IF UPDATE(ExternPOkey)  
   BEGIN  
      UPDATE PODetail WITH (ROWLOCK)  
         SET ExternPokey = INSERTED.ExternPOkey,  
             Trafficcop = NULL,  
             EditDate = GETDATE(),   --tlting  
             EditWho = SUSER_SNAME()  
        FROM PODetail, INSERTED, DELETED  
       WHERE PODetail.Pokey = INSERTED.POKey  
         AND INSERTED.POKEY = DELETED.POkey  
  
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),ISNULL(dbo.fnc_RTrim(@n_err),0)), @n_err=63813  
         SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(dbo.fnc_RTrim(@n_err),0))  
                          + ': Update Failed On Table PODetail. (ntrPOHeaderUpdate)' + ' ( '  
                          + ' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '  
      END  
   END  
   -- End : SOS39407  
  
--    -- Added By SHONG  
--    -- Spec From Thailand  
--    -- Not Allow to Modify PO When Extern Status = 9 or CLOSED  
--    -- Date: 05th Dec 2000  
--    IF @n_continue=1 or @n_continue=2  
--    BEGIN  
--       IF EXISTS(SELECT POKEY FROM DELETED WHERE ExternStatus = "9")  
--       BEGIN  
--          SELECT @n_continue = 3  
--          SELECT @c_errmsg = CONVERT(CHAR(250),ISNULL(dbo.fnc_RTrim(@n_err),0)), @n_err=63814  
--          SELECT @c_errmsg="NSQL"+CONVERT(char(5),ISNULL(dbo.fnc_RTrim(@n_err),0))  
--                          +": PO Cannot be Modified, Status = CLOSED. (ntrPOHeaderUpdate)" + " ( "  
--                          + " SQLSvr MESSAGE=" + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + " ) "  
--       END  
--    END  
--    -- End of Modify  
  
   IF ( @n_continue = 1 OR @n_continue=2 ) AND NOT UPDATE(EditDate)  
   BEGIN  
      UPDATE PO WITH (ROWLOCK)  
         SET EditDate = GETDATE(), EditWho = SUSER_SNAME(), TrafficCop = NULL  
        FROM PO, INSERTED, DELETED  
       WHERE PO.POKey = INSERTED.POKey  
         AND PO.POKey = DELETED.POKey  
         AND INSERTED.POKey = DELETED.POKey  
         AND PO.STATUS = '9'        -- tlting02  
  
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),ISNULL(dbo.fnc_RTrim(@n_err),0)), @n_err=63815  
         SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(dbo.fnc_RTrim(@n_err),0))  
                          + ': Update Failed On Table PO. (ntrPOHeaderUpdate)' + ' ( '  
                          + ' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '  
      END  
   END  
  
--    IF @n_continue = 1 or @n_continue=2  
--    BEGIN  
--       UPDATE PO SET  Status = "0", ExternStatus = "0"  
--         FROM PO, INSERTED, DELETED  
--        WHERE PO.POKey = INSERTED.POKey AND INSERTED.POKey = DELETED.POKey  
--          AND INSERTED.OpenQty > 0 AND DELETED.Status = "9"  
--  
--       SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
--       IF @n_err <> 0  
--       BEGIN  
--          SELECT @n_continue = 3  
--          SELECT @c_errmsg = CONVERT(CHAR(250),ISNULL(dbo.fnc_RTrim(@n_err),0)), @n_err=63816  
--          SELECT @c_errmsg="NSQL"+CONVERT(char(5),ISNULL(dbo.fnc_RTrim(@n_err),0))+": Update Failed On Table PO. (ntrPOHeaderUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "  
--       END  
--    END  
  
   IF @n_continue = 1 or @n_continue=2  
   BEGIN  
--    UPDATE PO WITH (ROWLOCK)  
--    SET  Status = "9",  
--            PO.ExternStatus="9" -- Added By Shong For PO Automate, Date: 6th Dec 2000  
--    FROM PO,  
--    INSERTED,  
--    DELETED  
--    WHERE PO.POKey = INSERTED.POKey  
--    AND PO.OpenQty = 0  
--    AND INSERTED.Openqty = 0  
--    AND INSERTED.POKey = DELETED.POKey  
--    added by wally 18.oct.2001  
--    IDSHK sos 2023: to handle po with zero qty on both ordered and received column  
  
      /* Added By Vicky 18 Apr 2003 - For TBLHK */  
      /* Only close PO Extern Status automatically when 'UPDATEEXTPO' flag is turn on */  
      DECLARE PO_UPD_CURSOR CURSOR READ_ONLY FAST_FORWARD FOR  
       SELECT StorerKey, POKey  
             ,OpenQty -- SOS41855  
         FROM INSERTED  
  
      OPEN PO_UPD_CURSOR  
  
      FETCH NEXT FROM PO_UPD_CURSOR INTO @c_Storerkey, @c_POKey, @n_PO_OpenQty -- SOS41855  
  
      WHILE @@FETCH_STATUS <> -1  
      BEGIN  
         SELECT @b_success = 0  
  
         EXECUTE nspGetRight NULL,  -- facility  
                 @c_StorerKey,      -- Storerkey  
                 NULL,              -- Sku  
                'UPDATEEXTPO',      -- Configkey  
                 @b_success    output,  
                 @c_extpo      output,  
                 @n_err        output,  
                 @c_errmsg     output  
  
         IF @b_success <> 1  
         BEGIN  
            SELECT @n_continue = 3, @c_errmsg = 'ntrPOHeaderUpdate' + dbo.fnc_RTrim(@c_errmsg)  
         END  
         ELSE IF @c_extpo = '1'  
         BEGIN  
               -- tlting01  
            IF NOT EXISTS ( SELECT 1 FROM  PODETAIL WITH (NOLOCK)  
                 WHERE PODETAIL.pokey = @c_POKey  
                 AND   PODETAIL.QtyOrdered > PODETAIL.QtyReceived )  
                 --AND (SELECT SUM(qtyreceived)  --SOS222461  
                 AND (SELECT SUM(CAST(qtyreceived AS BIGINT))  --SOS222461  
                 FROM  PODETAIL WITH (NOLOCK)  
                 WHERE PODETAIL.pokey = @c_POKey ) > 0  
--            (SELECT SUM(qtyreceived)  
--                  FROM  PODETAIL WITH (NOLOCK)  
--                 WHERE PODETAIL.pokey = @c_POKey ) > 0  
--                   AND @n_PO_OpenQty <= 0  -- SOS41855  
            BEGIN  
               SET @c_StatusUpdated = 'Y'       -- (YokeBeen02)  
               SET @c_ExternStatusUpdated = 'Y' -- (YokeBeen02)  
  
               UPDATE PO WITH (ROWLOCK)  
                  SET status = '9', externstatus = '9'                  WHERE POKey = @c_POKey  
  
               SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
               IF @n_err <> 0  
               BEGIN  
                  SELECT @n_continue = 3  
                  SELECT @c_errmsg = CONVERT(CHAR(250),ISNULL(dbo.fnc_RTrim(@n_err),0)), @n_err=63817  
                  SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(dbo.fnc_RTrim(@n_err),0))  
                                   + ': Update Failed On Table PO. (ntrPOHeaderUpdate)' + ' ( '  
                                   + ' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '  
               END  
            END  
         END -- IF @c_extpo = '1'  
  
         -- Added for IDSV5 by June 21.Jun.02, (extract from IDSTHAI) *** Start  
         IF @n_continue=1 OR @n_continue=2  
         BEGIN  
            SELECT @b_success = 0  
            EXECUTE nspGetRight NULL,  -- facility  
                    @c_StorerKey,    -- Storerkey  
                    NULL,            -- Sku  
                   'POITF',         -- Configkey  
                    @b_success    output,  
                    @c_authority  output,  
                    @n_err        output,  
                    @c_errmsg     output  
  
            IF @b_success <> 1  
            BEGIN  
               SELECT @n_continue = 3, @c_errmsg = 'ntrPOHeaderUpdate' + dbo.fnc_RTrim(@c_errmsg)  
            END  
            ELSE IF @c_authority = '1'  
            BEGIN  
               -- insert into transmitlog table when PO status = '9' (openqty = 0) or Externstatus = '9' (Closed manually)  
               IF EXISTS (SELECT 1 FROM PO WITH (NOLOCK), INSERTED, DELETED  
                           WHERE PO.Pokey = INSERTED.POKey  
                             AND INSERTED.POKEY = DELETED.POkey  
                             AND ( ( INSERTED.OpenQty <= 0  
                             AND DELETED.Openqty > 0 )  
                              OR INSERTED.Externstatus = '9' )  
                             AND PO.Pokey = @c_pokey )  
                             --AND PO.Pokey NOT IN (SELECT Key1 from transmitlog where tablename = 'PO'))  
               BEGIN  
                  IF NOT EXISTS(SELECT 1 FROM Transmitlog WITH (NOLOCK) WHERE tablename = 'PO' AND Key1 = @c_pokey)  
                  BEGIN  
                     SELECT @b_success = 1  
                     EXECUTE nspg_getkey  
                            'transmitlogkey'  
                           , 10  
                           , @c_trmlogkey OUTPUT  
                           , @b_success OUTPUT  
                           , @n_err OUTPUT  
                           , @c_errmsg OUTPUT  
  
                     IF NOT @b_success = 1  
                     BEGIN  
                        SELECT @n_continue = 3  
                        SELECT @c_errmsg = CONVERT(CHAR(250),ISNULL(dbo.fnc_RTrim(@n_err),0)), @n_err=63818  
                        SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(dbo.fnc_RTrim(@n_err),0))  
                                         + ': Unable to Obtain transmitlogkey. (ntrPOHeaderUpdate)' + ' ( '  
                                         + ' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '  
                     END  
                     ELSE  
                     BEGIN  
                        INSERT INTO transmitlog (transmitlogkey, tablename, key1, transmitflag)  
                        VALUES (@c_trmlogkey, 'PO', @c_POkey , '0')  
                     END  
                  END -- Not exists  
               END  
            END  
         END -- Added for IDSV5 by June 21.Jun.02, (extract from IDSTHAI) *** End  
  
         -- Start IDSHK TBL - Outbound PIX Export  
         -- Added by June 11.APR.2003  
         -- Modify By SHONG on 12-JUN-2003 for Performance Tuning  
         IF @n_continue=1 OR @n_continue=2  
         BEGIN  
            DECLARE  @c_TBLHKITF NVARCHAR(1)  
  
            -- insert into transmitlog2 table when PO status = '9' (openqty = 0) or Externstatus = '9' (Closed manually)  
            SELECT @c_TBLHKITF = 0  
            EXECUTE nspGetRight NULL,  -- facility  
                    @c_storerkey,      -- Storerkey  
                    NULL,              -- Sku  
                   'TBLHKITF',         -- Configkey  
                    @b_success output,  
                    @c_TBLHKITF output,  
                    @n_err output,  
                    @c_errmsg output  
  
            IF @b_success <> 1  
            BEGIN  
               SELECT @n_continue = 3  
               SELECT @c_errmsg = 'ntrPOHeaderUpdate' + dbo.fnc_RTrim(@c_errmsg)  
            END  
            ELSE IF @c_TBLHKITF = '1'  
            BEGIN  
               IF EXISTS (SELECT 1 FROM PO WITH (NOLOCK)  
                            JOIN INSERTED ON (PO.Pokey = INSERTED.POKey)  
                            JOIN DELETED ON (INSERTED.POKEY = DELETED.POkey)  
                            JOIN PODETAIL WITH (NOLOCK) ON (PO.Pokey = PODETAIL.Pokey)  
                            JOIN RECEIPTDETAIL WITH (NOLOCK) ON (PO.Pokey = RECEIPTDETAIL.POKEY)  
                            JOIN LOC WITH (NOLOCK) ON (RECEIPTDETAIL.TOLOC = LOC.LOC)  
                            LEFT OUTER JOIN ID WITH (NOLOCK) ON (RECEIPTDETAIL.TOID = ID.ID)  
                           WHERE (( INSERTED.OpenQty <= 0 AND DELETED.Openqty > 0 )  OR INSERTED.Externstatus = '9' )  
                           -- AND PO.Pokey NOT IN (SELECT Key1 FROM transmitlog2 where tablename = 'TBLPOCLOSE')  
                             AND PO.POKey = @c_pokey  
                             AND (LOC.LOCATIONFLAG = 'HOLD' OR LOC.LOCATIONFLAG = 'DAMAGED'OR ID.STATUS = 'HOLD'))  
               BEGIN  
                  IF NOT EXISTS(SELECT 1 FROM Transmitlog2 WITH (NOLOCK)  
                                        WHERE tablename = 'TBLPOCLOSE' AND Key1 = @c_pokey)  
                  BEGIN  
                     SELECT @b_success = 1  
                     EXECUTE nspg_getkey  
                            'transmitlogkey2'    -- Modified by YokeBeen on 26-Apr-2003  
                           , 10  
                           , @c_trmlogkey output  
                           , @b_success output  
                           , @n_err output  
                           , @c_errmsg output  
  
                     IF NOT @b_success = 1  
                     BEGIN  
                        SELECT @n_continue = 3  
                        SELECT @c_errmsg = CONVERT(CHAR(250),ISNULL(dbo.fnc_RTrim(@n_err),0)), @n_err=63819  
                        SELECT @c_errmsg = 'nsql' + CONVERT(CHAR(5),ISNULL(dbo.fnc_RTrim(@n_err),0))  
                                         + ': Unable To Obtain Transmitlogkey. (ntrReceiptHeaderUpdate)' + ' ( '  
                                         + ' sqlsvr message=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '  
                     END  
                     ELSE  
                     BEGIN  
                        INSERT transmitlog2 (transmitlogkey, tablename, key1, transmitflag)  
                        VALUES (@c_trmlogkey, 'TBLPOCLOSE', @c_pokey, '0')  
                     END  
                  END -- Not exist in Transmitlog2  
               END -- TBLHKITF  
               ELSE -- SOS 27580 :Normal Goods Received in Normal Location (Interface Changes)  
               BEGIN  
                  IF EXISTS (SELECT 1 FROM PO WITH (NOLOCK)  
                               JOIN INSERTED ON (PO.Pokey = INSERTED.POKey)  
                               JOIN DELETED ON (INSERTED.POKEY = DELETED.POkey)  
                               JOIN PODETAIL WITH (NOLOCK) ON (PO.Pokey = PODETAIL.Pokey)  
                               JOIN RECEIPTDETAIL WITH (NOLOCK) ON (PO.Pokey = RECEIPTDETAIL.POKEY)  
                               JOIN LOC WITH (NOLOCK) ON (RECEIPTDETAIL.TOLOC = LOC.LOC)  
                               LEFT OUTER JOIN ID WITH (NOLOCK) ON (RECEIPTDETAIL.TOID = ID.ID)  
                              WHERE (( INSERTED.OpenQty <= 0 AND DELETED.Openqty > 0 )  OR INSERTED.Externstatus = '9' )  
                               -- AND PO.Pokey NOT IN (SELECT Key1 FROM transmitlog2 where tablename = 'TBLPOCLOSE')  
                                AND PO.POKey = @c_pokey  
                                AND LOC.LOCATIONFLAG <> 'HOLD'  
                                AND LOC.LOCATIONFLAG <> 'DAMAGED'  
                                AND LOC.Status = 'OK')  
                  BEGIN  
                     IF NOT EXISTS (SELECT 1 FROM Transmitlog2 WITH (NOLOCK)  
                                     WHERE tablename = 'TBLPOCLOSE' AND Key1 = @c_pokey)  
                     BEGIN  
                        SELECT @b_success = 1  
                        EXECUTE nspg_getkey  
                               'TRANSMITLOGKEY2'    -- Modified by YokeBeen on 26-Apr-2003  
                              , 10  
                              , @c_trmlogkey output  
                              , @b_success output  
                              , @n_err output  
                              , @c_errmsg output  
  
                        IF NOT @b_success = 1  
                        BEGIN  
                           SELECT @n_continue = 3  
                           SELECT @c_errmsg = CONVERT(CHAR(250),ISNULL(dbo.fnc_RTrim(@n_err),0)), @n_err=63820  
                           SELECT @c_errmsg = 'nsql' + CONVERT(CHAR(5),ISNULL(dbo.fnc_RTrim(@n_err),0))  
                                            + ': Unable To Obtain Transmitlogkey. (ntrReceiptHeaderUpdate)' + ' ( '  
                                            + ' sqlsvr message=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '  
                        END  
                        ELSE  
                        BEGIN  
                           INSERT transmitlog2 (transmitlogkey, tablename, key1, transmitflag)  
                           VALUES (@c_trmlogkey, 'TBLPOCLOSE', @c_pokey, '0')  
                        END  
                     END -- Not exists in Trnsmitlog2 table  
                  END  
               END -- ELSE -- SOS 27580 :Normal Goods Received in Normal Location (Interface Changes)  
            END  
         END  
         -- End IDSHK TBL - Outbound PIX Export  
         /* End TBLHK*/  
  
         FETCH NEXT FROM PO_UPD_CURSOR INTO @c_Storerkey, @c_POKey, @n_PO_OpenQty -- SOS41855  
      END -- While  
      CLOSE PO_UPD_CURSOR  
      DEALLOCATE PO_UPD_CURSOR  
   END -- IF @n_continue = 1 or @n_continue=2  
  
/********************************************************/    
/* Interface Trigger Points Calling Process - (Start)   */    
/********************************************************/    
   IF @n_continue = 1 OR @n_continue = 2     
   BEGIN    
      DECLARE Cur_TriggerPoints CURSOR LOCAL FAST_FORWARD READ_ONLY FOR     
      SELECT DISTINCT INSERTED.POKey, INSERTED.StorerKey  
      FROM   INSERTED   
      JOIN   PO WITH (NOLOCK) ON (INSERTED.POKey = PO.POKey)  
  
      OPEN Cur_TriggerPoints    
      FETCH NEXT FROM Cur_TriggerPoints INTO @c_POKey, @c_Storerkey  
  
      WHILE @@FETCH_STATUS <> -1    
      BEGIN  
         SET @c_Proceed = 'N'  
  
         IF EXISTS ( SELECT 1   
                     FROM  ITFTriggerConfig ITFTriggerConfig WITH (NOLOCK)         
                     WHERE ITFTriggerConfig.StorerKey   = @c_Storerkey  
                     AND   ITFTriggerConfig.SourceTable = 'PO'    
                     AND   ITFTriggerConfig.sValue      = '1' )  
         BEGIN  
            SET @c_Proceed = 'Y'             
         END  
  
         IF @c_Proceed = 'Y'  
         BEGIN  
            SET @c_ColumnsUpdated = ''      
  
            DECLARE Cur_ColUpdated CURSOR LOCAL FAST_FORWARD READ_ONLY FOR     
            SELECT COLUMN_NAME FROM dbo.fnc_GetUpdatedColumns('PO', @b_ColumnsUpdated)   
  
            OPEN Cur_ColUpdated    
            FETCH NEXT FROM Cur_ColUpdated INTO @c_COLUMN_NAME  
            WHILE @@FETCH_STATUS <> -1    
            BEGIN    
               IF @c_ColumnsUpdated = ''  
               BEGIN  
                  SET @c_ColumnsUpdated = @c_COLUMN_NAME  
               END  
               ELSE  
               BEGIN  
                  SET @c_ColumnsUpdated = @c_ColumnsUpdated + ',' + @c_COLUMN_NAME  
               END  
  
               FETCH NEXT FROM Cur_ColUpdated INTO @c_COLUMN_NAME  
            END -- WHILE @@FETCH_STATUS <> -1    
            CLOSE Cur_ColUpdated    
            DEALLOCATE Cur_ColUpdated    
  
            IF @c_StatusUpdated = 'Y'   
            BEGIN  
               IF @c_ColumnsUpdated = ''  
               BEGIN  
                  SET @c_ColumnsUpdated = 'STATUS'  
               END  
               ELSE  
               BEGIN  
                  SET @c_ColumnsUpdated = @c_ColumnsUpdated + ',' + 'STATUS'  
               END  
            END  
  
            IF @c_ExternStatusUpdated = 'Y'   
            BEGIN  
               IF @c_ColumnsUpdated = ''  
               BEGIN  
                  SET @c_ColumnsUpdated = 'EXTERNSTATUS'  
               END  
               ELSE  
               BEGIN  
                  SET @c_ColumnsUpdated = @c_ColumnsUpdated + ',' + 'EXTERNSTATUS'  
               END  
            END  
  
            EXECUTE dbo.isp_ITF_ntrPO    
                       @c_TriggerName    = 'ntrPOHeaderUpdate'  
                     , @c_SourceTable    = 'PO'    
                     , @c_Storerkey      = @c_Storerkey  
                     , @c_POKey          = @c_POKey    
                     , @c_ColumnsUpdated = @c_ColumnsUpdated                             
                     , @b_Success        = @b_Success   OUTPUT    
                     , @n_err            = @n_err       OUTPUT    
                     , @c_errmsg         = @c_errmsg    OUTPUT   
         END  
  
         FETCH NEXT FROM Cur_TriggerPoints INTO @c_POKey, @c_Storerkey  
      END -- WHILE @@FETCH_STATUS <> -1    
      CLOSE Cur_TriggerPoints    
      DEALLOCATE Cur_TriggerPoints   
   END -- IF @n_continue = 1 OR @n_continue = 2     
/********************************************************/    
/* Interface Trigger Points Calling Process - (End)     */    
/********************************************************/    
  
   /* #INCLUDE <TRPOHU2.SQL> */  
   IF @n_continue=3  -- Error Occured - Process And Return  
   BEGIN  
      IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt  
      BEGIN  
         ROLLBACK TRAN  
      END  
      ELSE BEGIN  
         WHILE @@TRANCOUNT > @n_starttcnt  
         BEGIN  
            COMMIT TRAN  
         END  
      END  
  
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrPOHeaderUpdate'  
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
      RETURN  
   END  
   ELSE BEGIN  
      WHILE @@TRANCOUNT > @n_starttcnt  
      BEGIN  
         COMMIT TRAN  
      END  
      RETURN  
   END  
END -- End trigger  
GO
ALTER TABLE [dbo].[PO] WITH NOCHECK ADD CONSTRAINT [CK_PO_Status] CHECK ((rtrim([Status]) like '[0-9]'))
GO
ALTER TABLE [dbo].[PO] ADD CONSTRAINT [PKPO] PRIMARY KEY CLUSTERED ([POKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ExternPOKey] ON [dbo].[PO] ([ExternPOKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_StorerKey] ON [dbo].[PO] ([StorerKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_XdockPOKey] ON [dbo].[PO] ([xdockpokey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PO] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PO] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PO] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PO] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PO] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A Purchase Order (PO) is a contract between the buyer of the product and vendor supplying the products. It records the quantity of each commodity ordered, as well as the destination of each shipment. PO can be created manually or transmitted electronically via IDS IML when the storer puts in a PO to the vendor.', 'SCHEMA', N'dbo', 'TABLE', N'PO', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display buyer address1 when Buyer/ Storer selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display buyer address2 when Buyer/ Storer selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display buyer address3 when Buyer/ Storer selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display buyer address4 when Buyer/ Storer selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerAddress4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display buyer city when Buyer/ Storer selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerCity'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer that is buying the goods in the PO. When you select a buyer, the corresponding information on the address and other contacts will be defaulted', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Buyer company.', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerPhone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer''s other reference field', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyersReference'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display buyer state when Buyer/ Storer selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerState'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer/consignee''s value added tax ID', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerVAT'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display buyer zip when Buyer/ Storer selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerZip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country where the transported goods will be delivered', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'DestinationCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place
', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Vendor PO reference key', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'ExternPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'IDS internal PO status', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'ExternStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Standard international terms of delivery', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'IncoTerms'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date and time the goods are loaded into the truck', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'LoadingDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information you wish to track in the PO', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Open Quantity', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'OpenQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country from which the transported goods will be shipped', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'OriginCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Other reference number', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'OtherReference'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Not Used', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'PlaceofDelivery'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Truck Discharge', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'PlaceOfDischarge'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Place where the PO was issued', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'PlaceofIssue'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Area of Truck Loading', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'PlaceOfLoading'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Payment term', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'Pmtterm'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Start Date', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'PODate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Purchase order group', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'PoGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'It''s used to identify a specific PO record. Automatically generated', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'POKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of purchase order. Default: Standard. User defined and configurable at Code Look up', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'POType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Reason', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display seller address1 when Seller selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display seller address2 when Seller selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Seller company.', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Seller company.', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerAddress4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display seller city when Seller selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerCity'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller company
', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerCompany'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller contact information 01
', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerContact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller contact information 02', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerContact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller country', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller email address 01', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerEmail1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller email address 02', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerEmail2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller fax number 01', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerFax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller fax number 02', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerFax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Vendor that is selling the products. When the Seller is selected, the system fills in the associated VAT# and address fields automatically. The setup will from storer master', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Seller company.', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerPhone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller telephone number 02', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerPhone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Sellers Reference', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellersReference'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display seller state when Seller selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerState'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer/consignee''s value added tax ID', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerVat'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display seller zip when Seller selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerZip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Supplier DO# or other reference number', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'Signatory'
GO
EXEC sp_addextendedproperty N'MS_Description', 'System generated PO status.   - Not Fully Received  - Received', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer that is buying the goods in the PO. When you select a buyer, the corresponding information on the address and other contacts will be defaulted', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Payment options and credit terms', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'TermsNote'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transport method e.g. land, air, sea etc.', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'TransMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine1', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine2', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine3', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine4', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine5', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine6', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine7', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine8', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine9', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine10', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carrier transporting the goods from the warehouse to the Consignee. Must be a valid carrier', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'Vessel'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date in which the PO was issued and created', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'VesselDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Not Used', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'xdockpokey'
GO
