CREATE TABLE [dbo].[rdsPO]
(
[rdsPONo] [int] NOT NULL,
[POKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_ExternPOKey] DEFAULT (' '),
[PoGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsPO_PoGroup] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PODate] [datetime] NULL CONSTRAINT [DF_rdsPO_PODate] DEFAULT (getdate()),
[SellersReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellersReference] DEFAULT (' '),
[BuyersReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyersReference] DEFAULT (' '),
[OtherReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_OtherReference] DEFAULT (' '),
[POType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_POType] DEFAULT (' '),
[SellerName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerName] DEFAULT (' '),
[SellerAddress1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerAddress1] DEFAULT (' '),
[SellerAddress2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerAddress2] DEFAULT (' '),
[SellerAddress3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerAddress3] DEFAULT (' '),
[SellerAddress4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerAddress4] DEFAULT (' '),
[SellerCity] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerCity] DEFAULT (' '),
[SellerState] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerState] DEFAULT (' '),
[SellerZip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerZip] DEFAULT (' '),
[SellerPhone] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerPhone] DEFAULT (' '),
[SellerVat] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerVat] DEFAULT (' '),
[BuyerName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerName] DEFAULT (' '),
[BuyerAddress1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerAddress1] DEFAULT (' '),
[BuyerAddress2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerAddress2] DEFAULT (' '),
[BuyerAddress3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerAddress3] DEFAULT (' '),
[BuyerAddress4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerAddress4] DEFAULT (' '),
[BuyerCity] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerCity] DEFAULT (' '),
[BuyerState] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerState] DEFAULT (' '),
[BuyerZip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerZip] DEFAULT (' '),
[BuyerPhone] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerPhone] DEFAULT (' '),
[BuyerVAT] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerVAT] DEFAULT (' '),
[OriginCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_OriginCountry] DEFAULT (' '),
[DestinationCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_DestinationCountry] DEFAULT (' '),
[Vessel] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_Vessel] DEFAULT (' '),
[VesselDate] [datetime] NULL CONSTRAINT [DF_rdsPO_VesselDate] DEFAULT (' '),
[PlaceOfLoading] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_PlaceOfLoading] DEFAULT (' '),
[PlaceOfDischarge] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_PlaceOfDischarge] DEFAULT (' '),
[PlaceofDelivery] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_PlaceofDelivery] DEFAULT (' '),
[IncoTerms] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_IncoTerms] DEFAULT (' '),
[Pmtterm] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_Pmtterm] DEFAULT (' '),
[TransMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_TransMethod] DEFAULT (' '),
[TermsNote] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_TermsNote] DEFAULT (' '),
[Signatory] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_Signatory] DEFAULT (' '),
[PlaceofIssue] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_PlaceofIssue] DEFAULT (' '),
[OpenQty] [int] NULL CONSTRAINT [DF_rdsPO_OpenQty] DEFAULT ((0)),
[PlannedQty] [int] NULL CONSTRAINT [DF_rdsPO_PlannedQty] DEFAULT ((0)),
[Amount] [float] NULL CONSTRAINT [DF_rdsPO_Amount] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsPO_Status] DEFAULT ('0'),
[Notes] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_rdsPO_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdsPO_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsPO_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdsPO_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsPO_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_ExternStatus] DEFAULT ('0'),
[LoadingDate] [datetime] NULL,
[ReasonCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_ReasonCode] DEFAULT (' '),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL CONSTRAINT [DF_rdsPO_UserDefine06] DEFAULT (' '),
[UserDefine07] [datetime] NULL CONSTRAINT [DF_rdsPO_UserDefine07] DEFAULT (' '),
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_UserDefine08] DEFAULT (' '),
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_UserDefine10] DEFAULT (' '),
[xdockpokey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- =============================================
-- Author: WANYT
-- Create date: 23-May-2008
-- Description: Delete Details if Header was deleted
-- =============================================
/************************************************************************/
/* Trigger: ntrRDSPOHeaderDelete                                        */
/* Creation Date: 23-May-2008                                           */
/* Copyright: IDS                                                       */
/* Written by: WANYT                                                    */
/*                                                                      */
/* Purpose: Delete in RDSPO table.                                      */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By:  Exceed                                                   */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 6Jan2008     TLTING    1.1   @@TRANCOUNT >= @n_starttcnt to rollback */
/*                              (tlting01)                              */
/*  9-Jun-2011  KHLim01   1.2   Insert Delete log                       */
/* 14-Jul-2011  KHLim02   1.3   GetRight for Delete log                 */
/*                                                                      */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrRDSPOHeaderDelete]
   ON  [dbo].[rdsPO]
   AFTER DELETE
AS 
BEGIN
   DECLARE @n_StartTCnt int, 
           @n_Continue  int, 
           @b_success   int,
           @n_Err       int, 
           @c_ErrMsg    NVARCHAR(215) 
         , @n_cnt       int      -- KHLim01
         , @c_authority NVARCHAR(1)  -- KHLim02

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON 
	SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1  

   IF EXISTS(SELECT 1 FROM RDSPODetail WITH (NOLOCK) 
             JOIN DELETED ON (DELETED.Storerkey = RDSPODetail.Storerkey
                          AND DELETED.RDSPONo   = RDSPODetail.RDSPONo))
   BEGIN
      DELETE RDSPODetail 
      FROM   RDSPODetail
      JOIN DELETED ON  (DELETED.Storerkey = RDSPODetail.Storerkey
                    AND DELETED.RDSPONo   = RDSPODetail.RDSPONo)
      SET @n_Err = @@ERROR
      IF @n_Err <> 0 
      BEGIN
         SET @n_Continue = 3
         SET @b_success = -1
         SET @c_ErrMsg = 'Delete RDSPODetail Failed!'
         GOTO QUIT
      END            
   END 

   IF (SELECT count(*) FROM DELETED) =
      (SELECT count(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')  --KH01
   BEGIN
      SELECT @n_continue = 4
   END
   
   -- Start (KHLim01)
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
               ,@c_errmsg = 'ntrRDSPOHeaderDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.rdsPO_DELLOG ( rdsPONo )
         SELECT rdsPONo  FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table ORDERS Failed. (ntrRDSPOHeaderDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END
   -- End (KHLim01)

QUIT:
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_success = 0
      -- Start tlting01
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt     -- tlting01    -- @@TRANCOUNT > @n_starttcnt
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
      -- End tlting01 
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrRDSPOHeaderDelete'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_success = 1
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
/* Trigger: ntrRDSPOHeaderUpdate                                        */
/* Creation Date:  25-May-2012                                          */
/* Copyright: IDS                                                       */
/* Written by:  TLTING                                                  */
/*                                                                      */
/* Purpose: RDSPOHeader Update Transaction                              */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Return Status:                                                       */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When records updated                                      */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrRDSPOHeaderUpdate]
ON [dbo].[rdsPO]
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
	
	DECLARE	@n_err                int       -- Error number returned by stored procedure or this trigger
	,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
	,         @n_continue int                 
	,         @n_starttcnt int                -- Holds the current transaction count
	,         @n_cnt int                  
	
	SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   IF UPDATE(ArchiveCop)
   BEGIN
   	SELECT @n_continue = 4 
   END
	
   -- TLTING01
	IF @n_continue = 1 or @n_continue=2
	BEGIN
		UPDATE rdsPO
		SET EditDate = GETDATE(),
		    EditWho  = SUSER_SNAME(),
		    TrafficCop = NULL	
		FROM rdsPO (NOLOCK), INSERTED (NOLOCK)
		WHERE rdsPO.rdsPONo  = INSERTED.rdsPONo
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62303   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE Failed on RDSPOHeader table. (ntrRDSPOHeaderUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
		END
	END

   IF UPDATE(TrafficCop)
   BEGIN
   	SELECT @n_continue = 4 
   END   
	
	IF @n_continue=3  -- Error Occured - Process And Return
	BEGIN
		IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
		BEGIN
			ROLLBACK TRAN
		END
		execute nsp_logerror @n_err, @c_errmsg, "ntrRDSPOHeaderUpdate"
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
ALTER TABLE [dbo].[rdsPO] ADD CONSTRAINT [PK_rdsPO] PRIMARY KEY CLUSTERED ([rdsPONo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rdsPO] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[rdsPO] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[rdsPO] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[rdsPO] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Buyer company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'BuyerAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Buyer company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'BuyerAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Buyer company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'BuyerAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Buyer company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'BuyerAddress4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Seller company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'SellerAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Seller company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'SellerAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Seller company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'SellerAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Seller company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'SellerAddress4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'TrafficCop'
GO
