CREATE TABLE [dbo].[OrderSelection]
(
[OrderSelectionKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultFlag] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_DefaultFlag] DEFAULT ('0'),
[OrderDateStart] [datetime] NOT NULL CONSTRAINT [DF_OrderSelection_OrderDateStart] DEFAULT ('JAN 01 1900'),
[OrderDateEnd] [datetime] NOT NULL CONSTRAINT [DF_OrderSelection_OrderDateEnd] DEFAULT ('DEC 31 9999'),
[DeliveryDateStart] [datetime] NOT NULL CONSTRAINT [DF_OrderSelection_DeliveryDateStart] DEFAULT ('JAN 01 1900'),
[DeliveryDateEnd] [datetime] NOT NULL CONSTRAINT [DF_OrderSelection_DeliveryDateEnd] DEFAULT ('DEC 31 9999'),
[OrderTypeStart] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_OrderTypeStart] DEFAULT (' '),
[OrderTypeEnd] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_OrderTypeEnd] DEFAULT ('9'),
[OrderGroupStart] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_OrderGroupStart] DEFAULT (' '),
[OrderGroupEnd] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_OrderGroupEnd] DEFAULT ('9'),
[OrderPriorityStart] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_OrderPriorityStart] DEFAULT ('0'),
[OrderPriorityEnd] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_OrderPriorityEnd] DEFAULT ('9'),
[StorerKeyStart] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_StorerKeyStart] DEFAULT ('0'),
[StorerKeyEnd] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_StorerKeyEnd] DEFAULT (replicate('Z',(15))),
[OrderKeyStart] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_OrderKeyStart] DEFAULT ('0'),
[OrderKeyEnd] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_OrderKeyEnd] DEFAULT (replicate('Z',(20))),
[ExternOrderKeyStart] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_ExternOrderKeyStart] DEFAULT (' '),
[ExternOrderKeyEnd] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_ExternOrderKeyEnd] DEFAULT (replicate('Z',(20))),
[ConsigneeKeyStart] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_ConsigneeKeyStart] DEFAULT (' '),
[ConsigneeKeyEnd] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_ConsigneeKeyEnd] DEFAULT (replicate('Z',(30))),
[CarrierKeyStart] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_CarrierKeyStart] DEFAULT (' '),
[CarrierKeyEnd] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_CarrierKeyEnd] DEFAULT (replicate('Z',(30))),
[RouteStart] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_RouteStart] DEFAULT ('0'),
[RouteEnd] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_RouteEnd] DEFAULT (replicate('Z',(10))),
[DoorStart] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_DoorStart] DEFAULT ('0'),
[DoorEnd] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_DoorEnd] DEFAULT (replicate('Z',(10))),
[StopStart] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_StopStart] DEFAULT ('0'),
[StopEnd] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_StopEnd] DEFAULT (replicate('Z',(10))),
[CartonizationGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_CartonizationGroup] DEFAULT ('STD'),
[RoutingKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_RoutingKey] DEFAULT ('STD'),
[PickCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_PickCode] DEFAULT ('USESKUTBL'),
[DoCartonization] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_DoCartonization] DEFAULT ('Y'),
[DoRouting] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_DoRouting] DEFAULT ('N'),
[MaxOrders] [int] NOT NULL CONSTRAINT [DF_OrderSelection_MaxOrders] DEFAULT ((0)),
[PreAllocationGrouping] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_PreAllocationGrouping] DEFAULT ('1'),
[PreAllocationSort] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_PreAllocationSort] DEFAULT ('1'),
[WaveOption] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_WaveOption] DEFAULT ('DISCRETE'),
[BatchPickMaxCube] [int] NOT NULL CONSTRAINT [DF_OrderSelection_BatchPickMaxCube] DEFAULT ((0)),
[BatchPickMaxCount] [int] NOT NULL CONSTRAINT [DF_OrderSelection_BatchPickMaxCount] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_OrderSelection_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_OrderSelection_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderSelection_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL,
[BillToKeyStart] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_BillToKeyStart] DEFAULT ('0'),
[BillToKeyEnd] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_BillToKeyEnd] DEFAULT ('ZZZZZZZZZZ'),
[InvoiceStart] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_InvoiceStart] DEFAULT ('0'),
[InvoiceEnd] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_InvoiceEnd] DEFAULT ('ZZZZZZZZZZ'),
[facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_facility] DEFAULT (' '),
[LoadingDateStart] [datetime] NULL CONSTRAINT [DF_OrderSelection_LoadingDateStart] DEFAULT ('JAN 01 1900'),
[LoadingDateEnd] [datetime] NULL CONSTRAINT [DF_OrderSelection_LoadingDateEnd] DEFAULT ('DEC 31 9999'),
[XDockPOKeyStart] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_XDockPOKeyStart] DEFAULT (' '),
[XDockPOKeyEnd] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_XDockPOKeyEnd] DEFAULT ('ZZZZZZZZZZ'),
[BuyerPOStart] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_BuyerPOStart] DEFAULT (' '),
[BuyerPOEnd] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_BuyerPOEnd] DEFAULT ('ZZZZZZZZZZ'),
[DynamicPickSlipCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_DynamicPickSlipCode] DEFAULT (''),
[DocTypeStart] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_DocTypeStart] DEFAULT (' '),
[DocTypeEnd] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_DocTypeEnd] DEFAULT ('Z'),
[M_ISOCntryCodeStart] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_M_ISOCntryCodeStart] DEFAULT (' '),
[M_ISOCntryCodeEnd] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_M_ISOCntryCodeEnd] DEFAULT ('ZZZZZZZZZZ'),
[UserDefine05Start] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_UserDefine05Start] DEFAULT (' '),
[UserDefine05End] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_UserDefine05End] DEFAULT ('ZZZZZZZZZZZZZZZZZZZZ'),
[SpecialHandlingStart] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_SpecialHandlingStart] DEFAULT (' '),
[SpecialHandlingEnd] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_SpecialHandlingEnd] DEFAULT ('Z'),
[DeliveryNoteStart] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_DeliveryNoteStart] DEFAULT (' '),
[DeliveryNoteEnd] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderSelection_DeliveryNoteEnd] DEFAULT ('ZZZZZZZZZZ')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrOrderSelectionUpdate                                     */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
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
/* Called By: When records Updated                                      */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author  Ver.  Purposes                                   */
/* 30-SEP-2013 TLTING  1.0   Initial Version                            */ 
/************************************************************************/

CREATE TRIGGER [dbo].[ntrOrderSelectionUpdate]
ON  [dbo].[OrderSelection]
FOR UPDATE
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_DEFAULTS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   IF @@ROWCOUNT = 0
   BEGIN
      RETURN
   END -- @@ROWCOUNT = 0

   DECLARE
   @b_Success              int       -- Populated by calls to stored procedures - was the proc successful?
   ,         @n_err        int       -- Error number returned by stored procedure or this trigger
   ,         @n_err2       int       -- For Additional Error Detection
   ,         @c_errmsg     NVARCHAR(250) -- Error message returned by stored procedure or this trigger
   ,         @n_continue   int
   ,         @n_starttcnt  int       -- Holds the current transaction count
   ,         @c_preprocess NVARCHAR(250) -- preprocess
   ,         @c_pstprocess NVARCHAR(250) -- post process
   ,         @n_cnt int
   
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   IF UPDATE(TrafficCop)
   BEGIN
      SELECT @n_continue = 4
   END

   IF @n_continue = 1 OR @n_continue = 2 
   BEGIN
      UPDATE OrderSelection
      SET EditWho = sUser_sName(),
          EditDate = GetDate(),
          TrafficCop = NULL
      FROM OrderSelection 
      JOIN INSERTED ON OrderSelection.OrderSelectionKey = INSERTED.OrderSelectionKey
      SELECT @n_err = @@ERROR
      IF @n_err <> 0
      BEGIN
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update On Table OrderSelection Failed. (ntrOrderSelectionUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
      END      
   END
      
   QUIT_TR:
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
   
	   EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrOrderSelectionUpdate"
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
ALTER TABLE [dbo].[OrderSelection] ADD CONSTRAINT [PKOrderSelection] PRIMARY KEY CLUSTERED ([OrderSelectionKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OrderSelection] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[OrderSelection] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[OrderSelection] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[OrderSelection] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Maximum Count per picking', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'BatchPickMaxCount'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Maximum Cube per Picking', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'BatchPickMaxCube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the party billed for goods shipped', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'BillToKeyEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the party billed for goods shipped', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'BillToKeyStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Buyer PO End', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'BuyerPOEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Buyer PO Start', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'BuyerPOStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Party who carriers/transports the product', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'CarrierKeyEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Party who carriers/transports the product', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'CarrierKeyStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cartonization', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'CartonizationGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Party to whom the product is delivered', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'ConsigneeKeyEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Party to whom the product is delivered', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'ConsigneeKeyStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Default by tick for allocation', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'DefaultFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The date in which the order is scheduled to be delivered', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'DeliveryDateEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The date in which the order is scheduled to be delivered', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'DeliveryDateStart'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Delivery Note End', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'DeliveryNoteEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Delivery Note Start', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'DeliveryNoteStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Alternate Order # End', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'ExternOrderKeyEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Alternate Order # Start', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'ExternOrderKeyStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Warehouse for the order to withdraw the stock from', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment Order invoice number End', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'InvoiceEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment Order invoice number Start', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'InvoiceStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Loading Date End', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'LoadingDateEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Loading Date Start', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'LoadingDateStart'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Orders ISO Country Code End', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'M_ISOCntryCodeEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Orders ISO Country Code Start', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'M_ISOCntryCodeStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date shipment order was placed', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'OrderDateEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date shipment order was placed', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'OrderDateStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller''s order group number End', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'OrderGroupEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller''s order group number Start', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'OrderGroupStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller''s/storer''s external order number', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'OrderKeyEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller''s/storer''s external order number', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'OrderKeyStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment''s priority', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'OrderPriorityEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment''s priority', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'OrderPriorityStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Order Selection Key', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'OrderSelectionKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of Shipment Order End', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'OrderTypeEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of Shipment Order Start', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'OrderTypeStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Picking method', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'PickCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pre Allocation Grouping', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'PreAllocationGrouping'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pre Allocation Sort', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'PreAllocationSort'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Delivery route under order', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'RouteEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Delivery route under order', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'RouteStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Routing', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'RoutingKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Orders Special Handling End', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'SpecialHandlingEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Orders Special Handling Start', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'SpecialHandlingStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer/seller range end of the products being shipped (Owner of the goods)', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'StorerKeyEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer/seller range start of the products being shipped (Owner of the goods)', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'StorerKeyStart'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Orders User Define 05 End', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'UserDefine05End'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Orders User Define 05 Start', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'UserDefine05Start'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Order Picking Procedure', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'WaveOption'
GO
EXEC sp_addextendedproperty N'MS_Description', 'CrossDock POkey End', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'XDockPOKeyEnd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'CrossDock POkey Start', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelection', 'COLUMN', N'XDockPOKeyStart'
GO
