CREATE TABLE [dbo].[Brokerage]
(
[BrokerageKey] [bigint] NOT NULL IDENTITY(1, 1),
[BrokerageMasterKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Brokerage_BrokerageMasterKey] DEFAULT (' '),
[BrokerageExternKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Brokerage_BrokerageExternKey] DEFAULT (' '),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BrokerageDate] [datetime] NULL CONSTRAINT [DF_Brokerage_BrokerageDate] DEFAULT (NULL),
[SellersReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_SellersReference] DEFAULT (' '),
[BuyersReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_BuyersReference] DEFAULT (' '),
[OtherReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_OtherReference] DEFAULT (' '),
[DocType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_DocType] DEFAULT (' '),
[SellerName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_SellerName] DEFAULT (' '),
[SellerAddress1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_SellerAddress1] DEFAULT (' '),
[SellerAddress2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_SellerAddress2] DEFAULT (' '),
[SellerAddress3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_SellerAddress3] DEFAULT (' '),
[SellerAddress4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_SellerAddress4] DEFAULT (' '),
[SellerCity] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_SellerCity] DEFAULT (' '),
[SellerState] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_SellerState] DEFAULT (' '),
[SellerZip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_SellerZip] DEFAULT (' '),
[SellerPhone] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_SellerPhone] DEFAULT (' '),
[SellerVat] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_SellerVat] DEFAULT (' '),
[SellerCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_SellerCountry] DEFAULT (' '),
[BuyerName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_BuyerName] DEFAULT (' '),
[BuyerAddress1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_BuyerAddress1] DEFAULT (' '),
[BuyerAddress2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_BuyerAddress2] DEFAULT (' '),
[BuyerAddress3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_BuyerAddress3] DEFAULT (' '),
[BuyerAddress4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_BuyerAddress4] DEFAULT (' '),
[BuyerCity] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_BuyerCity] DEFAULT (' '),
[BuyerState] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_BuyerState] DEFAULT (' '),
[BuyerZip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_BuyerZip] DEFAULT (' '),
[BuyerPhone] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_BuyerPhone] DEFAULT (' '),
[BuyerVat] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_BuyerVat] DEFAULT (' '),
[BuyerCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_BuyerCountry] DEFAULT (' '),
[DestinationCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_DestinationCountry] DEFAULT (' '),
[Vessel] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_Vessel] DEFAULT (' '),
[VesselDate] [datetime] NULL CONSTRAINT [DF_Brokerage_VesselDate] DEFAULT (NULL),
[PlaceOfLoading] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_PlaceOfLoading] DEFAULT (' '),
[PlaceOfDischarge] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_PlaceOfDischarge] DEFAULT (' '),
[PlaceOfDelivery] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_PlaceOfDelivery] DEFAULT (' '),
[IncoTerms] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_IncoTerms] DEFAULT (' '),
[Pmtterm] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_Pmtterm] DEFAULT (' '),
[TransMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_TransMethod] DEFAULT (' '),
[TermsNote] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_TermsNote] DEFAULT (' '),
[Signatory] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_Signatory] DEFAULT (' '),
[PlaceofIssue] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_PlaceofIssue] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_Status] DEFAULT ('0'),
[Notes] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_Notes] DEFAULT (' '),
[LoadingDate] [datetime] NULL CONSTRAINT [DF_Brokerage_LoadingDate] DEFAULT (NULL),
[ReasonCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_ReasonCode] DEFAULT (' '),
[BillOfLadingNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_BillOfLadingNo] DEFAULT (' '),
[InvoiceNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_InvoiceNo] DEFAULT (' '),
[InvoiceDate] [datetime] NULL CONSTRAINT [DF_Brokerage_InvoiceDate] DEFAULT (NULL),
[WeightUOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_WeightUOM] DEFAULT (' '),
[GrossWeight] [float] NULL CONSTRAINT [DF_Brokerage_GrossWeight] DEFAULT ('0'),
[NetWeight] [float] NULL CONSTRAINT [DF_Brokerage_NetWeight] DEFAULT ('0'),
[Currency] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_Currency] DEFAULT (' '),
[InvoiceQty] [int] NULL CONSTRAINT [DF_Brokerage_InvoiceQty] DEFAULT (' '),
[InvoiceAmount] [float] NULL CONSTRAINT [DF_Brokerage_InvoiceAmount] DEFAULT ('0'),
[CarrierCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_CarrierCode] DEFAULT (' '),
[CarrierName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_CarrierName] DEFAULT (' '),
[QtyUOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_QtyUOM] DEFAULT (' '),
[Userdefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_Userdefine01] DEFAULT (' '),
[Userdefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_Userdefine02] DEFAULT (' '),
[Userdefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_Userdefine03] DEFAULT (' '),
[Userdefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_Userdefine04] DEFAULT (' '),
[Userdefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_Userdefine05] DEFAULT (' '),
[Userdefine06] [datetime] NULL,
[Userdefine07] [datetime] NULL,
[Userdefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_Userdefine08] DEFAULT (' '),
[Userdefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_Userdefine09] DEFAULT (' '),
[Userdefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_Userdefine10] DEFAULT (' '),
[AddDate] [datetime] NULL CONSTRAINT [DF_Brokerage_AddDate] DEFAULT (getdate()),
[AddWho] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_Brokerage_EditDate] DEFAULT (getdate()),
[EditWho] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Transmitflag] [int] NULL CONSTRAINT [DF_Brokerage_Transmitflag] DEFAULT ('0'),
[VesselNum] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_VesselNum] DEFAULT (''),
[MasterWayBill] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_MasterWayBill] DEFAULT (''),
[HouseWayBill] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Brokerage_HouseWayBill] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrBrokerageAdd                                             */
/* Creation Date:                                                       */
/* Copyright: LF                                                        */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:  WMS#15134                                                  */
/* Version: 5.5                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/************************************************************************/
CREATE TRIGGER [dbo].[ntrBrokerageAdd] --First Time Deployment
--ALTER TRIGGER [dbo].[ntrBrokerageAdd]
ON  [dbo].[Brokerage]
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE   @b_Success       int       -- Populated by calls to stored procedures - was the proc successful?
   ,         @n_err           int       -- Error number returned by stored procedure or this trigger
   ,         @n_err2          int       -- For Additional Error Detection
   ,         @c_errmsg        NVARCHAR(250) -- Error message returned by stored procedure or this trigger
   ,         @n_continue      int
   ,         @n_starttcnt     int       -- Holds the current transaction count
   ,         @c_preprocess    NVARCHAR(250) -- preprocess
   ,         @c_pstprocess    NVARCHAR(250) -- post process
   ,         @n_cnt           int
   ,         @c_BrokerageKey  int
   ,         @c_Storerkey     NVARCHAR(15)

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   
   ----Not suppose to check
   --IF UPDATE(TrafficCop)
   --BEGIN
   --   SELECT @n_continue = 4
   --END

   IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END

   IF @n_continue = 1 or @n_continue = 2
   BEGIN

      SELECT @c_BrokerageKey = BrokerageKey 
           , @c_Storerkey    = Storerkey
      FROM   INSERTED
      WHERE doctype = 'PO'

      IF EXISTS( SELECT 1 FROM StorerConfig (NOLOCK) 
                  WHERE  StorerKey = @c_Storerkey
                  AND    ConfigKey = 'BRKADDLOG' 
                  AND    sValue    = '1' )
      BEGIN
         EXEC ispGenTransmitLog3 'BRKADDLOG', @c_BrokerageKey, '', @c_Storerkey, '' 
            , @b_success OUTPUT
            , @n_err OUTPUT
            , @c_errmsg OUTPUT

         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63811   -- should be set to the sql errmessage but i don't know how to do so.
            SELECT @c_errmsg = 'nsql' + CONVERT(CHAR(5),@n_err) + ': Unable To Obtain LogKey. (ntrBrokerageAdd)' + ' ( ' + ' sqlsvr message=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
         END
      END -- If exists kitlog
   END


   /* #INCLUDE <TRLU2.SQL> */
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
      
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrBrokerageAdd'

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
ALTER TABLE [dbo].[Brokerage] ADD CONSTRAINT [PK_Brokerage] PRIMARY KEY CLUSTERED ([BrokerageKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_B_BrokerageExternKey] ON [dbo].[Brokerage] ([BrokerageExternKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_B_BrokerageMasterKey] ON [dbo].[Brokerage] ([BrokerageMasterKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_B_StorerKey] ON [dbo].[Brokerage] ([Storerkey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Brokerage] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Brokerage] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Brokerage] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Brokerage] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'A Brokerage is a contract between the Logistics and Custom. It records the products and quantity of each commodity ordered, as well as the Supplier and Buyer information.', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, record will be verified and archive process to perform data archiving to the table in Archive DB.', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Bill of Lading Number', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'BillOfLadingNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Brokerage Date', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'BrokerageDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'External Brokerage key', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'BrokerageExternKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'It''s used to identify a specific Brokerage record. Automatically generated', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'BrokerageKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'External Brokerage Master key', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'BrokerageMasterKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Will automatic display buyer address1 when Buyer/ Storer is selected', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'BuyerAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Will automatic display buyer address2 when Buyer/ Storer is selected', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'BuyerAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Will automatic display buyer address3 when Buyer/ Storer is selected', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'BuyerAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Will automatic display buyer address4 when Buyer/ Storer is selected', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'BuyerAddress4'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Will automatic display buyer city when Buyer/ Storer is selected', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'BuyerCity'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Buyer''s Country', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'BuyerCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storer that is buying the goods. When to select a buyer, the corresponding information on the address and other contacts will be defaulted', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'BuyerName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Buyer''s Telephone number.', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'BuyerPhone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Buyer reference', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'BuyersReference'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Will automatic display buyer state when Buyer/ Storer is selected', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'BuyerState'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Buyer''s value added tax ID', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'BuyerVat'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Will automatic display buyer zip when Buyer/ Storer is selected', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'BuyerZip'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Carrier Code', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'CarrierCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Carrier Name', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'CarrierName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Currency code', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Currency'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Country where the goods will be delivered', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'DestinationCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Document Type', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'DocType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Gross Weight of the shipment', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'GrossWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', N'HouseWayBill', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'HouseWayBill'
GO
EXEC sp_addextendedproperty N'MS_Description', N'International Commercial Term', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'IncoTerms'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Invoice Amount', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'InvoiceAmount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Invoice Date', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'InvoiceDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Invoice Number', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'InvoiceNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Invoice Quantity', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'InvoiceQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of Loading', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'LoadingDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'MasterWayBill', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'MasterWayBill'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Net weight of the shipment', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'NetWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Remarks', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Other reference', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'OtherReference'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Place of Delivery', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'PlaceOfDelivery'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Place of Discharge', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'PlaceOfDischarge'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Place of Brokerage issued', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'PlaceofIssue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Place of Loading', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'PlaceOfLoading'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Payment Term', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Pmtterm'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UOM of quantity', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'QtyUOM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Reason Code', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Will automatic display seller address1 when Seller is selected', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'SellerAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Will automatic display seller address2 when Seller is selected', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'SellerAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Will automatic display seller address3 when Seller is selected', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'SellerAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Will automatic display seller address4 when Seller is selected', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'SellerAddress4'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Will automatic display seller city when Seller is selected', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'SellerCity'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Seller''s Country', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'SellerCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Vendor that is selling the products. When the Seller is selected, the system fills in the associated VAT# and address fields automatically. The setup will from storer master', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'SellerName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Seller''s Telephone number', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'SellerPhone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sellers Reference', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'SellersReference'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Will automatic display seller state when Seller is selected', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'SellerState'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Seller''s value added tax ID', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'SellerVat'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Will automatic display seller zip when Seller is selected', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'SellerZip'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Signatory', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Signatory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status of Brokerage', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'WMS Storer', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Credit Term', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'TermsNote'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Transport Method', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'TransMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Transmitflag', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Transmitflag'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Brokerage Userdefine1', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Userdefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Brokerage Userdefine2', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Userdefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Brokerage Userdefine3', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Userdefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Brokerage Userdefine4', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Userdefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Brokerage Userdefine5', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Userdefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Brokerage Userdefine6 - datetime field', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Userdefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Brokerage Userdefine7 - datetime field', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Userdefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Brokerage Userdefine8', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Userdefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Brokerage Userdefine9', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Userdefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Brokerage Userdefine10', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Userdefine10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the Vessel carrying the goods', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'Vessel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Estimated Arrival Date of the vessel', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'VesselDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'VesselNum', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'VesselNum'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UOM of Weight', 'SCHEMA', N'dbo', 'TABLE', N'Brokerage', 'COLUMN', N'WeightUOM'
GO
