CREATE TABLE [dbo].[ORDERDETAIL]
(
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderDetailSysId] [int] NULL CONSTRAINT [DF_ORDERDETAIL_OrderDetailSysId] DEFAULT (rand()*(2147483647)),
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_ExternOrderKey] DEFAULT (' '),
[ExternLineNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_ExternLineNo] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Sku] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_StorerKey] DEFAULT (' '),
[ManufacturerSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_ManufacturerSku] DEFAULT (' '),
[RetailSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_RetailSku] DEFAULT (' '),
[AltSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_AltSku] DEFAULT (' '),
[OriginalQty] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_OriginalQty] DEFAULT ((0)),
[OpenQty] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_OpenQty] DEFAULT ((0)),
[ShippedQty] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_ShippedQty] DEFAULT ((0)),
[AdjustedQty] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_AdjustedQty] DEFAULT ((0)),
[QtyPreAllocated] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_QtyPreAllocated] DEFAULT ((0)),
[QtyAllocated] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_QtyAllocated] DEFAULT ((0)),
[QtyPicked] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_QtyPicked] DEFAULT ((0)),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_UOM] DEFAULT (' '),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_PackKey] DEFAULT ('STD'),
[PickCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_PickCode] DEFAULT (' '),
[CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CartonGroup] DEFAULT (' '),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_LOT] DEFAULT (' '),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_ID] DEFAULT (' '),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Facility] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Status] DEFAULT ('0'),
[UnitPrice] [float] NULL CONSTRAINT [DF_ORDERDETAIL_UnitPrice] DEFAULT ((0)),
[Tax01] [float] NULL CONSTRAINT [DF_ORDERDETAIL_Tax01] DEFAULT ((0)),
[Tax02] [float] NULL CONSTRAINT [DF_ORDERDETAIL_Tax02] DEFAULT ((0)),
[ExtendedPrice] [float] NULL CONSTRAINT [DF_ORDERDETAIL_ExtendedPrice] DEFAULT ((0)),
[UpdateSource] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_UpdateSource] DEFAULT ('0'),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_LOTTABLE01] DEFAULT (' '),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_LOTTABLE02] DEFAULT (' '),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_LOTTABLE03] DEFAULT (' '),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_ORDERDETAIL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ORDERDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ORDERDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TariffKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FreeGoodQty] [int] NULL CONSTRAINT [DF_ORDERDETAIL_FreeGoodQty] DEFAULT ((0)),
[GrossWeight] [float] NULL CONSTRAINT [DF_ORDERDETAIL_GROSSWEIGHT] DEFAULT ((0)),
[Capacity] [float] NULL CONSTRAINT [DF_ORDERDETAIL_CAPACITY] DEFAULT ((0)),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QtyToProcess] [int] NULL CONSTRAINT [DF_OrderDetail_QtyToProcess] DEFAULT ((0)),
[MinShelfLife] [int] NULL CONSTRAINT [DF_OrderDetail_MinShelfLife] DEFAULT ((0)),
[UserDefine01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine04] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine05] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine06] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine07] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine08] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine09] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POkey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine10] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnteredQTY] [int] NULL CONSTRAINT [DF_OrderDetail_EnteredQTY] DEFAULT ((0)),
[ConsoOrderKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternConsoOrderKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Orderdetail_ExternConsoOrderKey] DEFAULT (' '),
[ConsoOrderLineNo] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERDETAIL_ConsoOrderLineNo] DEFAULT (''),
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[Notes] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERDETAIL_Notes] DEFAULT (''),
[Notes2] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERDETAIL_Notes2] DEFAULT (''),
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERDETAIL_Channel] DEFAULT (''),
[HashValue] [tinyint] NULL CONSTRAINT [DF_Orderdetail_HashValue] DEFAULT ((1)),
[SalesChannel] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderDetail_SalesChannel] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*************************************************************************/
/* Trigger: ntrOrderDetailAdd                                            */
/* Creation Date:                                                        */
/* Copyright: IDS                                                        */
/* Written by:                                                           */
/*                                                                       */
/* Purpose:                                                              */
/*                                                                       */
/* Input Parameters: NONE                                                */
/*                                                                       */
/* OUTPUT Parameters: NONE                                               */
/*                                                                       */
/* Return Status: NONE                                                   */
/*                                                                       */
/* Usage:                                                                */
/*                                                                       */
/* Local Variables:                                                      */
/*                                                                       */
/* Called By: When records INSERTED                                      */
/*                                                                       */
/* PVCS Version: 1.2                                                     */
/*                                                                       */
/* Version: 5.4                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author  ver  Purposes                                    */
/* 03-Jan-2008  Shong   1.1  SOS#89405 - ReOpen CANCEL Status when new   */
/*                           line Added for all.                         */
/* 24-Aug-2009  TLTING  1.2  SOS#140063 - Keep original Open Qty         */
/*                                      No change to it  (tlting01)      */
/* 01-Dec-2009  SHONGN  1.3  SOS#143271 Added Error Checking When update */
/*                           ExternOrderKey                              */  
/* 27-Feb-2012  NJOW01  1.4  237150-Populate sku outgoing shelflife to   */
/*                           orderdetail                                 */
/* 12-May-2014  YTWan   1.5  SOS#310515 - New Requirement Caculate       */
/*                           Orders.Capacity from Pack module (Wan01)    */
/* 26-Jan-2016  YTWan   1.6  Fixed (Wan02)                               */
/* 08-Aug-2016  TLTING  1.7  Add nolock                                  */
/* 20-Sep-2016  TLTING  1.8  Change SetROWCOUNT 1 to Top 1               */
/* 03-Feb-2017  TLTING  1.9  Extend field length for decimal             */
/* 15-May-2018  tlting02 2.0 Single\Multi Orders                         */
/* 24-Aug-2018  SWT01    2.1  Performance Tuning                         */ 
/* 27-Sep-2018  TLTING03 2.2  Performance Tuning                         */ 
/* 17-Aug-2020  Shong    2.3  Split Trigger to Pre and Post              */
/* 11-Nov-2020  Shong    2.4  Fixing CANC Order status update to 1 issues*/
/*                            (SWT001)                                   */
/* 02-Jun-2021  NJOW03   2.5  WMS-16977 Fix @c_newstatus default value   */
/*************************************************************************/
CREATE   TRIGGER [dbo].[ntrOrderDetailAdd]
ON  [dbo].[ORDERDETAIL]
FOR INSERT
AS
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE
          @b_Success    INT       -- Populated by calls to stored procedures - was the proc successful?
,         @n_err        INT       -- Error number returned by stored procedure or this trigger       -- For Additional Error Detection
,         @c_errmsg     NVARCHAR(250) -- Error message returned by stored procedure or this trigger
,         @n_Continue   INT                 
,         @n_starttcnt  INT                -- Holds the current transaction count
,         @n_cnt        INT


SELECT @n_Continue=1, @n_starttcnt=@@TRANCOUNT
     /* #INCLUDE <TRODA1.SQL> */     

-- Added By SHONG 14-Apr-2003
-- To skip all the trigger process when insert from Archive DB due to User Request
IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
   SELECT @n_Continue = 4

Declare @c_Authority            NVARCHAR(1) = '0', 
        @c_Authority_OrdWgtVol  NVARCHAR(1) = '0', 
        @c_AuthOrdersStop       NVARCHAR(1) = '0',
        @c_Authority_OrdTLLog   NVARCHAR(1) = '0', 
        @c_Facility             NVARCHAR(5) = '', 
        @c_StorerKey            NVARCHAR(15) = '',
        @c_Sku                  NVARCHAR(20) = '',
        @c_OrderKey             NVARCHAR(10) = '', 
        @n_InsertedCount        INT = 0,  
        @c_OrderLineNumber      NVARCHAR(5),
        @c_ExternLineNo         NVARCHAR(5), 
        @c_ExternOrderKey       NVARCHAR(50),
        @c_SpecialHandling      NVARCHAR(10) = '',
        @n_Weight               DECIMAL(25,5) = 0,
        @n_CBM                  DECIMAL(25,5) = 0,
        @n_OpenQty              INT = 0,
        @c_Status               NVARCHAR(10) = '',
        @c_SOStatus             NVARCHAR(10) = '',
        @c_OrdType              NVARCHAR(10) = '',
        @c_NewStatus            NVARCHAR(10) = ''        
         
IF (@n_Continue = 1 or @n_Continue=2)  
BEGIN
   DECLARE CUR_ORDHEADER CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT ORDERS.OrderKey, ORDERS.StorerKey, ORDERS.Facility, 
          ISNULL(ORDERS.SpecialHandling, ''), ORDERS.[Status], 
          ORDERS.SOStatus, ORDERS.[Type] 
   FROM dbo.ORDERS AS ORDERS (NOLOCK)
   WHERE EXISTS(SELECT 1 FROM INSERTED WHERE ORDERS.OrderKey = INSERTED.OrderKey) 

   OPEN CUR_ORDHEADER

   FETCH FROM CUR_ORDHEADER INTO @c_OrderKey, @c_StorerKey, @c_Facility, @c_SpecialHandling, @c_Status, @c_SOStatus, @c_OrdType

   WHILE @@FETCH_STATUS = 0
   BEGIN
      SET @b_Success = 0
      
      SET @c_AuthOrdersStop = '0'
      
      Execute nspGetRight @c_Facility, 
            @c_StorerKey,   -- Storer
            '',              -- Sku
            'OrdersStop',    -- ConfigKey
            @b_Success               OUTPUT, 
            @c_AuthOrdersStop        OUTPUT, 
            @n_err                   OUTPUT, 
            @c_errmsg                OUTPUT

      IF @b_Success <> 1
      BEGIN
         Select @n_Continue = 3 
         SELECT @c_errmsg = CONVERT(VARCHAR(10),@n_err), @n_err=62900   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Retrieve of Right (OrderStop) Failed (ntrOrderDetailAdd)' + ' ( ' 
         + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') + ' ) '
         BREAK 
      END
      
      IF (@n_Continue = 1 or @n_Continue=2) AND @c_AuthOrdersStop = '1'
      BEGIN
         IF EXISTS(SELECT 1 
                     FROM INSERTED 
                     JOIN SKU (NOLOCK) ON SKU.Storerkey = INSERTED.Storerkey 
                                       AND SKU.SKU = INSERTED.SKU
                                       AND SKU.SKUGROUP = 'OD' 
                     WHERE INSERTED.OrderKey = @c_OrderKey)
         BEGIN
            UPDATE ORDERS WITH (ROWLOCK)
                  SET ORDERS.Stop = StorerSODefault.Stop, 
                     TrafficCop = NULL,
                   EditDate = GETDATE(),
                   EditWho = SUSER_SNAME()  
               FROM ORDERS  
               JOIN STORERSODEFAULT (NOLOCK) ON STORERSODEFAULT.STORERKEY = ORDERS.STORERKEY
            WHERE ORDERS.OrderKey = @c_OrderKey
            
         END
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_Continue = 3
            SELECT @c_errmsg = CONVERT(VARCHAR(10),@n_err), @n_err=62903   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Of Stop On ORDERS Failed (ntrOrderDetailAdd)' 
            + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') + ' ) '
            BREAK
         END         
      END
      
      IF @n_Continue=1 or @n_Continue=2
      BEGIN
         Select @b_Success = 0

         Execute nspGetRight 
                  @c_Facility, 
                  @c_StorerKey,   -- Storer
                  '',                   -- Sku
                  'WgtnVolCalcInOrd',   -- ConfigKey
                  @b_Success          OUTPUT, 
                  @c_Authority_OrdWgtVol    OUTPUT, 
                  @n_err              OUTPUT, 
                  @c_errmsg           OUTPUT

         IF @b_Success <> 1
         BEGIN
            Select @n_Continue = 3 
            SELECT @c_errmsg = CONVERT(VARCHAR(10),@n_err), @n_err=62900   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Retrieve of Right (OrderStop) Failed (ntrOrderDetailAdd)' + ' ( ' 
            + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') + ' ) '
            BREAK
         END
      END -- IF @n_Continue=1 or @n_Continue=2
      
      -- To Calclulate the Weight and Capacity for Order Header base on INSERTED Orderdetail
      IF (@n_Continue = 1 or @n_Continue=2)  
      BEGIN
         SELECT @n_Weight = 0, 
                @n_CBM = 0, 
                @n_OpenQty = 0
                -- (SWT001) Comment by SHONG on 11/11/2020, should not initial this 
                -- @c_SOStatus = '' 
                -- @c_Status = '', 

         
         SELECT @n_Weight = ISNULL(SUM(CASE WHEN @c_Authority_OrdWgtVol IN ('1','2')
                                          THEN (INSERTED.OpenQty * SKU.STDGROSSWGT)
                                          ELSE 0
                                          END), 0.00000)
               ,@n_CBM    = ISNULL(SUM(CASE WHEN @c_Authority_OrdWgtVol = '2' AND PACK.CubeUOM1 > 0 AND PACK.CaseCnt > 0 
                                          THEN (INSERTED.OpenQty * (PACK.CubeUOM1 / PACK.CaseCnt))
                                          WHEN @c_Authority_OrdWgtVol IN ( '1', '2' )
                                          THEN (INSERTED.OpenQty * SKU.STDCUBE)
                                          ELSE 0
                                          END), 0.00000)
              , @n_OpenQty = SUM(INSERTED.OpenQty) 
         FROM INSERTED 
         JOIN SKU   WITH (NOLOCK)   ON (INSERTED.StorerKey = SKU.StorerKey)
                                          AND(INSERTED.SKU = SKU.SKU)
         JOIN PACK  WITH (NOLOCK)   ON (SKU.Packkey = PACK.Packkey)
         WHERE INSERTED.OrderKey = @c_OrderKey  
 	   
         IF @c_Status NOT IN ('0','9','CANC')
         BEGIN
         	  SET @c_NewStatus = @c_Status --NJOW03
         	  
            EXEC ispGetOrderStatus
               @c_OrderKey = @c_OrderKey,
               @c_StorerKey = @c_StorerKey,
               @c_OrdType = @c_OrdType,
               @c_NewStatus = @c_NewStatus OUTPUT,
               @b_Success = @b_Success OUTPUT,
               @n_err = @n_Err OUTPUT,
               @c_errmsg = @c_ErrMsg OUTPUT 
         END
         ELSE 
         BEGIN
            SET @c_NewStatus = @c_Status
         END
      
         UPDATE ORDERS WITH (ROWLOCK)
         SET ORDERS.GrossWeight=CONVERT(FLOAT, CONVERT(DECIMAL(15,5), ORDERS.GrossWeight) + @n_Weight)                   
            ,ORDERS.Capacity   =CONVERT(FLOAT, CONVERT(DECIMAL(15,5), ORDERS.Capacity) + @n_CBM)
            ,ORDERS.OpenQty = ORDERS.OpenQty + @n_OpenQty
            ,ORDERS.TrafficCop = NULL
            ,ORDERS.Status = @c_NewStatus
            ,ORDERS.SOStatus = CASE WHEN ORDERS.SOStatus IN ('CANC') THEN '0' ELSE ORDERS.SOStatus END
            ,ORDERS.ECOM_Single_Flag =  ( CASE WHEN ORDERS.Status NOT IN ('9','CANC') AND ORDERS.DocType = 'E' THEN 
                                          (  CASE WHEN (ORDERS.OpenQty + @n_OpenQty ) > 1 THEN 'M' ELSE 'S' END )  
                                          ELSE ORDERS.ECOM_SINGLE_Flag END  )
            ,EditDate = GETDATE()
            ,EditWho = SUSER_SNAME()                
         WHERE ORDERS.OrderKey = @c_OrderKey
          
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_Continue = 3
            SELECT @c_errmsg = CONVERT(VARCHAR(10),@n_err), @n_err=62906  
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)
                     +': Insert failed on table ORDERS. (ntrOrderDetailAdd)' + ' ( ' 
                     + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') + ' ) '
            BREAK
         END            
      END -- IF (@n_Continue = 1 or @n_Continue=2)

      -- Comment this section, no one using this anymore.
      --IF @n_Continue = 1 OR @n_Continue = 2
      --BEGIN
      --   SELECT @b_Success = 0, 
      --          @c_Authority_OrdTLLog = '0'

      --   Execute nspGetRight @c_Facility, 
      --                       @c_StorerKey,   -- Storer
      --                       '',             -- Sku
      --                       'ORDTLLOG',     -- ConfigKey
      --                       @b_Success            OUTPUT, 
      --                       @c_Authority_OrdTLLog OUTPUT, 
      --                       @n_err                OUTPUT, 
      --                       @c_errmsg             OUTPUT

      --   IF @b_Success <> 1
      --   BEGIN
      --      Select @n_Continue = 3 
      --      SELECT @c_errmsg = CONVERT(VARCHAR(10),@n_err), @n_err=62900   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      --      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Retrieve of Right (OrderStop) Failed (ntrOrderDetailAdd)' 
      --            + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') + ' ) '
      --      BREAK
      --   END

      --   IF @c_Authority_OrdTLLog = '1' 
      --   BEGIN
      --      SELECT TOP 1 
      --             @c_OrderLineNumber=INSERTED.OrderLineNumber,
      --             @c_ExternOrderKey =INSERTED.ExternOrderKey 
      --        FROM INSERTED  
      --       WHERE INSERTED.OrderKey = @c_OrderKey
      --       ORDER BY INSERTED.OrderKey, INSERTED.OrderLineNumber
   
        
      --      EXEC ispGenTransmitLog
      --         @c_TableName = 'ORDERS',
      --         @c_Key1 = @c_OrderKey,
      --         @c_Key2 = @c_OrderLineNumber,
      --         @c_Key3 = @c_ExternOrderKey,
      --         @c_TransmitBatch = 'ORDERS',
      --         @b_Success = @b_Success OUTPUT,
      --         @n_err = @n_err OUTPUT,
      --         @c_errmsg = @c_errmsg OUTPUT
                      
      --       IF @b_Success <> 1
      --       BEGIN
      --           SELECT @n_Continue = 3
      --           SELECT @c_errmsg = CONVERT(CHAR(250), @n_err),
      --                  @n_err = 62901  
      --           SELECT @c_errmsg = 'NSQL'+CONVERT(CHAR(5), @n_err)+
      --                  ': Insert Into Transmitlog Failed. (ntrOrderDetailAdd)' 
      --                 +'  ( '+' SQLSvr   MESSAGE=' + RTrim(@c_errmsg) 
      --                 +' ) '
      --          BREAK
      --       END
      --   END
      --END -- IF @n_Continue = 1 OR @n_Continue = 2
   
      ------- > START: SOS 28368 : set specialhandling on ORDERS header
      IF @n_Continue=1 or @n_Continue=2
      BEGIN
         Select @b_Success = 0, @c_authority = '0'

         Execute nspGetRight 
                     '', -- Facility 
                     @c_StorerKey, -- Storer
                     '', -- Sku
                     'PoisonOrderHandling', -- ConfigKey
                     @b_Success         OUTPUT, 
                     @c_authority      OUTPUT, 
                     @n_err             OUTPUT, 
                     @c_errmsg          OUTPUT

         IF @b_Success <> 1
         BEGIN
            Select @n_Continue = 3 
            SELECT @c_errmsg = CONVERT(VARCHAR(10),@n_err), @n_err=62900   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Retrieve of Right (OrderStop) Failed (ntrOrderDetailAdd)' 
                  + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') + ' ) '
            BREAK
         END
      END   
   
      IF (@n_Continue = 1 or @n_Continue=2) AND @c_authority = '1'
      BEGIN
         IF @c_SpecialHandling NOT IN ('Y','N') 
         BEGIN
            -- IF SKU.busr8 has value update to Y
            IF EXISTS (SELECT 1 FROM SKU (NOLOCK) 
                        JOIN INSERTED ON SKU.Storerkey = INSERTED.Storerkey
                                     AND SKU.SKU = INSERTED.SKU
                        WHERE ( SKU.BUSR8 > '' AND SKU.BUSR8 IS NOT NULL )
                        AND INSERTED.OrderKey = @c_OrderKey)
            BEGIN
               UPDATE ORDERS WITH (ROWLOCK) 
               SET ORDERS.SpecialHandling = 'Y',
                   ORDERS.TrafficCop = NULL,
                   EditDate = GETDATE(),
                   EditWho = SUSER_SNAME() 
               FROM ORDERS   
               WHERE ORDERS.OrderKey = @c_OrderKey               
            END
            ELSE IF @c_SpecialHandling <> 'N'
            BEGIN
               UPDATE ORDERS  
               SET ORDERS.SpecialHandling = 'N',
                   ORDERS.TrafficCop = Null,
                   EditDate = GETDATE(),
                   EditWho = SUSER_SNAME()  
               FROM ORDERS  
               WHERE ORDERS.OrderKey = @c_OrderKey              
            END
            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
            IF @n_err <> 0
            BEGIN
               SELECT @n_Continue = 3
               SELECT @c_errmsg = CONVERT(VARCHAR(10),@n_err), @n_err=62907   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Of Special Handling On ORDERS Failed (ntrOrderDetailAdd)' 
               + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') + ' ) '
               BREAK
            END         
         END
      END -- (@n_Continue = 1 or @n_Continue=2)

      FETCH FROM CUR_ORDHEADER INTO @c_OrderKey, @c_StorerKey, @c_Facility, @c_SpecialHandling, @c_Status, @c_SOStatus, @c_OrdType
   END

   CLOSE CUR_ORDHEADER
   DEALLOCATE CUR_ORDHEADER
END

/* #INCLUDE <TRODA2.SQL> */
IF @n_Continue=3  -- Error Occured - Process And Return
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

    EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrOrderDetailAdd'
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

/************************************************************************/
/* Trigger: ntrOrderDetailDelete                                        */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* PVCS Version: 1.13                                                   */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Purposes                                        */
/* 17-Jan-2003  Shong   SOS Ticket 9421, Order Header Gross Weight =    */
/*                      ZERO. Problem found in one update statement     */
/*                      which doesn't consider. OrderLine when deducting*/
/*                      Weigth from Order Header.                       */
/* 04-Apr-2008  Shong   Delete DEL_OrderDetail When Records exists and  */
/*                      Insert new records.                             */ 
/* 17-Jul-2009  TLTING  Add column UserDefine10 (tlting01)              */                                                      
/* 24-Aug-2009  TLTING  Add column EnteredQty (tlting02)                */ 
/* 28-Apr-2011  KHLim01 Insert Delete log                               */
/* 14-Jul-2011  KHLim02 GetRight for Delete log                         */
/* 14-Mar-2012  KHLim03 Update EditDate                                 */
/* 22-May-2012  TLTING02 Data integrity - insert dellog 4 status < '9'  */
/* 03-Jun-2013  YTWan   Delete OrderdetailRef when delete Orderdetail.  */
/*                      Add orderinfor and orderdetailref to Orders     */
/*                      screen. - table without screen. (Wan01)         */
/* 12-May-2014  YTWan   SOS#310515 - New Requirement Caculate           */
/*                      Orders.Capacity from Pack module (Wan02)        */
/* 11-June-2014 CSCHONG Add Lottable06-15 (CS01)                        */
/* 29-Sep-2018  TLTING  performance tune                                */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrOrderDetailDelete]
ON [dbo].[ORDERDETAIL]
FOR DELETE
AS
BEGIN
   IF @@ROWCOUNT = 0
   BEGIN
      RETURN
   END
   
   SET NOCOUNT ON       -- SQL 2005 Standard
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF    
   
   DECLARE @b_Success       int,       -- Populated by calls to stored procedures - was the proc successful?
   @n_err              int,       -- Error number returned by stored procedure or this trigger
   @c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger
   @n_continue         int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
   @n_starttcnt        int,       -- Holds the current transaction count
   @n_cnt              int        -- Holds @@ROWCOUNT
  ,@c_authority        NVARCHAR(1)  -- KHLim02

   , @c_facility        NVARCHAR(5)    --(Wan02)
   , @c_Storerkey       NVARCHAR(15)   --(Wan02)
   , @c_OrdWgtVol       NVARCHAR(10)   --(Wan02)
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   /* #INCLUDE <TRODD1.SQL> */

   if (select count(*) from DELETED) = 
      (select count(*) from DELETED where DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END
   
   IF EXISTS ( SELECT 1 FROM DELETED WHERE [STATUS] < '9' ) AND (@n_continue = 1 or @n_continue=2)
   BEGIN
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
                  ,@c_errmsg = 'ntrOrderDetailDelete' + dbo.fnc_RTrim(@c_errmsg)
         END
         ELSE 
         IF @c_authority = '1'         --    End   (KHLim02)
         BEGIN
            -- Orderdetail status not reliable - like Orders 'CANC' not update to OD
            INSERT INTO dbo.ORDERDETAIL_DELLOG ( OrderKey, OrderLineNumber )
            SELECT DELETED.OrderKey, DELETED.OrderLineNumber 
            FROM DELETED
               JOIN ORDERS O (NOLOCK) on O.Orderkey = DELETED.Orderkey
            WHERE O.[STATUS] < '9'

            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
            IF @n_err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table OrderDetail Failed. (ntrOrderDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
            END
            -- Orderdetail with Orders - us OD status.
            IF @n_cnt = 0
            BEGIN
               INSERT INTO dbo.ORDERDETAIL_DELLOG ( OrderKey, OrderLineNumber )
               SELECT OrderKey, OrderLineNumber 
               FROM DELETED
               WHERE [STATUS] < '9'

               SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68102   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table OrderDetail Failed. (ntrOrderDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
               END
            END
         END
      END
      -- End (KHLim01) 
   END

   -- Added By SHONG 
   -- Date: 13-Feb-2004
   -- SOS#19801 
   -- Do not allow to delete Cancel Orders if StorerConfig = NotAllowDelCancOrd is Turn ON
   IF @n_continue = 1 or @n_continue=2
   BEGIN
      IF EXISTS(SELECT 1 
                FROM  ORDERS (NOLOCK)
                JOIN  DELETED ON (ORDERS.ORDERKEY = DELETED.ORDERKEY)
                JOIN  StorerConfig (NOLOCK) ON (ORDERS.StorerKey = StorerConfig.StorerKey AND
                                                DELETED.StorerKey = StorerConfig.StorerKey AND
                                                StorerConfig.ConfigKey = 'NotAllowDelCancOrd' AND
                                                StorerConfig.sValue = '1')
                WHERE (ORDERS.SOStatus = 'CANC' OR ORDERS.Status = 'CANC')
                )
      BEGIN
         SELECT @n_continue = 3 , @n_err = 62604
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Canceled Order(s) Not Allow to Delete. (ntrOrderDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
      END
   END

 -- Added By SHONG
   -- Date: 21 May 2002
   -- CLOSE ORDER WHEN no Detail Line
   -- Begin
   IF @n_continue = 1 or @n_continue=2
   BEGIN
      IF NOT EXISTS(SELECT 1 FROM ORDERDETAIL (NOLOCK), DELETED WHERE ORDERDETAIL.ORDERKEY = DELETED.ORDERKEY)
      BEGIN
         UPDATE ORDERS 
            SET Status = 'CANC', -- = '9', 
                SOStatus = 'CANC', -- Added by SHONG. SOS# 6845
                EditDate = GETDATE(), -- KHLim03
                TrafficCop = NULL
         FROM DELETED, StorerConfig (NOLOCK)
         WHERE ORDERS.OrderKey = DELETED.OrderKey
         AND   ORDERS.StorerKey = StorerConfig.StorerKey
         AND   StorerConfig.ConfigKey = 'OWITF'
         AND   StorerConfig.sValue = '1'
         AND   NOT EXISTS (SELECT 1 FROM ORDERDETAIL (NOLOCK) WHERE ORDERDETAIL.ORDERKEY = DELETED.ORDERKEY
               AND ORDERS.OrderKey = DELETED.OrderKey)
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 62600   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update ORDERS Failed. (ntrOrderDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
         END
      END
   END
   -- End

   -- trigantic tracking of deleted order: wally 25.jul.03
   -- start
   if @n_continue <> 4
   BEGIN
      IF EXISTS(SELECT 1 FROM DEL_ORDERDETAIL DO (NOLOCK)
                JOIN DELETED ON DO.OrderKey = DELETED.OrderKey AND DO.OrderLineNumber = DELETED.OrderLineNumber)
      BEGIN
         DELETE DEL_ORDERDETAIL 
         FROM   DEL_ORDERDETAIL DO 
         JOIN   DELETED ON DO.OrderKey = DELETED.OrderKey AND DO.OrderLineNumber = DELETED.OrderLineNumber
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 62600   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete DEL_ORDERDETAIL Failed. (ntrOrderDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
         END         
      END

      INSERT INTO DEL_ORDERDETAIL(OrderKey, OrderLineNumber, OrderDetailSysId, ExternOrderKey, ExternLineNo, 
                  Sku, StorerKey, ManufacturerSku, RetailSku, AltSku, OriginalQty, OpenQty, ShippedQty, 
                  AdjustedQty, QtyPreAllocated, QtyAllocated, QtyPicked, UOM, PackKey, PickCode, 
                  CartonGroup, Lot, ID, Facility, Status, UnitPrice, Tax01, Tax02, ExtendedPrice, 
                  UpdateSource, Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, EffectiveDate, 
                  AddDate, AddWho, EditDate, EditWho, TrafficCop, ArchiveCop, TariffKey, 
                  FreeGoodQty, GrossWeight, Capacity, LoadKey, MBOLKey, QtyToProcess, MinShelfLife, 
                  UserDefine01, UserDefine02, UserDefine03, UserDefine04, UserDefine05, UserDefine06, 
                  UserDefine07, UserDefine08, UserDefine09, pokey, ExternPOKey, UserDefine10,
                  EnteredQty, Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,Lottable11, Lottable12, Lottable13, Lottable14, Lottable15 )  --(CS01)
      SELECT OrderKey, OrderLineNumber, OrderDetailSysId, ExternOrderKey, ExternLineNo, 
                  Sku, StorerKey, ManufacturerSku, RetailSku, AltSku, OriginalQty, OpenQty, ShippedQty, 
                  AdjustedQty, QtyPreAllocated, QtyAllocated, QtyPicked, UOM, PackKey, PickCode, 
                  CartonGroup, Lot, ID, Facility, Status, UnitPrice, Tax01, Tax02, ExtendedPrice, 
                  UpdateSource, Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, EffectiveDate, 
                  getdate(), suser_sname(), getdate(), suser_sname(), TrafficCop, ArchiveCop, TariffKey, 
                  FreeGoodQty, GrossWeight, Capacity, LoadKey, MBOLKey, QtyToProcess, MinShelfLife, 
                  UserDefine01, UserDefine02, UserDefine03, UserDefine04, UserDefine05, UserDefine06, 
                  UserDefine07, UserDefine08, UserDefine09, pokey, EXternPOKey, UserDefine10,    -- tlting01 
                  EnteredQty,Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,Lottable11, Lottable12, Lottable13, Lottable14, Lottable15                   -- tlting02  --CS01
      FROM DELETED
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 62600   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Insert DEL_ORDERDETAIL Failed. (ntrOrderDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
      END         
   END
-- end

   IF @n_continue = 1 or @n_continue=2
   BEGIN
      IF EXISTS ( SELECT * FROM deleted WHERE shippedqty <> 0 )
      BEGIN
         SELECT @n_continue = 3 , @n_err = 62604
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On ORDERDETAIL Failed Because lineitem(s) are shipped. (ntrOrderDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
      END
   END
   IF @n_continue = 1 or @n_continue=2
   BEGIN
      IF EXISTS ( SELECT  1 FROM PickDetail (NOLOCK), Deleted
            WHERE PickDetail.OrderKey=Deleted.OrderKey
            AND PickDetail.OrderLineNumber=Deleted.OrderLineNumber     )
      BEGIN
         DELETE PickDetail FROM PickDetail, Deleted
         WHERE PickDetail.OrderKey=Deleted.OrderKey
         AND PickDetail.OrderLineNumber=Deleted.OrderLineNumber
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 62600   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On ORDERDETAIL Failed. (ntrOrderDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
         END
      END
   END
   IF @n_continue = 1 or @n_continue=2
   BEGIN
      IF EXISTS ( SELECT  1 FROM PreAllocatePickDetail (NOLOCK), Deleted
            WHERE PreAllocatePickDetail.OrderKey=Deleted.OrderKey
            AND PreAllocatePickDetail.OrderLineNumber=Deleted.OrderLineNumber     )
      BEGIN
         DELETE PreAllocatePickDetail FROM PreAllocatePickDetail, Deleted
         WHERE PreAllocatePickDetail.OrderKey=Deleted.OrderKey
         AND PreAllocatePickDetail.OrderLineNumber=Deleted.OrderLineNumber
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 62606   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On ORDERDETAIL Failed. (ntrOrderDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
         END
      END
   END
   --(Wan01) Start
   IF @n_continue = 1 or @n_continue=2
   BEGIN
      IF EXISTS ( SELECT  1 FROM OrderdetailRef (NOLOCK), Deleted
            WHERE OrderdetailRef.OrderKey=Deleted.OrderKey
            AND OrderdetailRef.OrderLineNumber=Deleted.OrderLineNumber     )
      BEGIN
         DELETE OrderdetailRef 
         FROM OrderdetailRef 
         JOIN Deleted ON (OrderdetailRef.OrderKey=Deleted.OrderKey
                      AND OrderdetailRef.OrderLineNumber=Deleted.OrderLineNumber)
         SET @n_err = @@ERROR
         SET @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SET @n_continue = 3
            SET @c_errmsg = CONVERT(CHAR(250),@n_err)
            SET @n_err = 62607   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SET @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On ORDERDETAIL Failed. (ntrOrderDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
         END
      END
   END
   --(Wan01) End

   IF @n_continue = 1 or @n_continue=2
   BEGIN
      DECLARE @n_deletedcount int
      SELECT @n_deletedcount = (select count(1) FROM deleted)
      IF @n_deletedcount = 1
      BEGIN
         UPDATE ORDERS
         SET  OpenQty = ORDERS.OpenQty - DELETED.OpenQty
         FROM ORDERS,
         DELETED
         WHERE     ORDERS.OrderKey = DELETED.OrderKey
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      END
      ELSE
      BEGIN
         UPDATE ORDERS SET ORDERS.OpenQty
         = (Orders.Openqty
         -
         (Select Sum(DELETED.OpenQty) From DELETED
         Where DELETED.OrderKey = ORDERS.OrderKey)
         )
         FROM ORDERS,DELETED
         WHERE ORDERS.Orderkey IN (SELECT Distinct Orderkey From DELETED)
         AND ORDERS.Orderkey = DELETED.Orderkey
      END
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62605   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Insert failed on table ORDERS. (ntrOrderDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
      END
   END

   /*---------------------------------------------Customistation Start -----------------------------------------------------------*/
   /*  Date : 15/9/99
       FBR : 005
       Author : HPH
       Purpose
       Parameters :
   -------------------------------------------------------------------------------------------------------------------------------*/

   -------------------------
   -- Fixed By SHONG 17-Jan-2003
   -- To Calclulate the Weight and Capacity for Order Header base on DELETED Orderdetail
   -- Begin
   --(Wan02) - START
   SELECT @c_facility = ORDERS.Facility
         ,@c_StorerKey= ORDERS.Storerkey
   FROM ORDERS WITH (NOLOCK)
   JOIN DELETED WITH (NOLOCK) ON (ORDERS.Orderkey = DELETED.Orderkey)

   Execute nspGetRight @c_facility 
        ,  @c_StorerKey                -- Storer
        ,  ''                          -- Sku
        ,  'WgtnVolCalcInOrd'          -- ConfigKey
        ,  @b_success               output  
        ,  @c_OrdWgtVol             output  
        ,  @n_err                   output  
        ,  @c_errmsg                output

   If @b_success <> 1
   Begin
      SET @n_continue = 3 
      SET @c_errmsg = CONVERT(CHAR(250),@n_err)
      SEt @n_err=62904   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Retrieve of Right (WgtnVolCalcInOrd) Failed (ntrOrderDetailDelete)' 
                   + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
   End
   
   --(Wan02) - END
   IF @n_continue = 1 or @n_continue=2
   BEGIN
      --(Wan02) - START
      CREATE TABLE #TMP_WGTCUBE
         (  Orderkey    NVARCHAR(10)
         ,  Weight      DECIMAL(15,5)  DEFAULT (0)
         ,  CBM         DECIMAL(15,5)  DEFAULT (0)
         )

      INSERT INTO #TMP_WGTCUBE
         (  Orderkey
         ,  Weight
         ,  CBM
         )
      SELECT DELETED.Orderkey
            ,Weight = ISNULL(SUM(DELETED.OpenQty * SKU.STDGROSSWGT), 0.00000)
            ,CBM    = ISNULL(SUM(CASE WHEN @c_OrdWgtVol = '2' AND PACK.CubeUOM1 > 0 AND PACK.CaseCnt > 0 
                                      THEN (DELETED.OpenQty * (PACK.CubeUOM1 / PACK.CaseCnt))
                                      ELSE (DELETED.OpenQty * SKU.STDCUBE)
                                      END), 0.00000)
      FROM DELETED
      JOIN SKU  WITH (NOLOCK) ON (DELETED.StorerKey = SKU.StorerKey)                                                  --(Wan02) 
                             AND(DELETED.SKU = SKU.SKU) 
      JOIN PACK WITH (NOLOCK) ON (SKU.Packkey = PACK.Packkey) 
      GROUP BY DELETED.Orderkey
      --(Wan02) - END
       SELECT @n_DeletedCount = (SELECT count(*) FROM DELETED)
       IF @n_DeletedCount = 1
       BEGIN
           UPDATE ORDERS
           SET  --ORDERS.GrossWeight = ORDERS.Capacity - (DELETED.OpenQty * SKU.STDGROSSWGT),                              --(Wan02)
                --ORDERS.Capacity = ORDERS.Capacity + (DELETED.OpenQty * SKU.STDCUBE) , TrafficCop = NULL                  --(Wan02)
                ORDERS.GrossWeight=CONVERT(FLOAT, CONVERT(DECIMAL(15,5), ORDERS.GrossWeight) - #TMP_WGTCUBE.Weight)        --(Wan02)
               ,ORDERS.Capacity   =CONVERT(FLOAT, CONVERT(DECIMAL(15,5), ORDERS.Capacity) - #TMP_WGTCUBE.CBM)              --(Wan02)                                                         --(Wan02)
               ,TrafficCop = NULL                                                                                          
               ,EditDate = GETDATE() -- KHLim03
           --FROM ORDERS, DELETED, SKU (NOLOCK)                                                                            --(Wan02)
           --WHERE ORDERS.OrderKey = DELETED.OrderKey                                                                      --(Wan02)      
           --AND   DELETED.StorerKey = SKU.StorerKey                                                                       --(Wan02)
           --AND   DELETED.SKU = SKU.SKU                                                                                   --(Wan02)
           FROM ORDERS                                                                                                     --(Wan02)   
           JOIN DELETED            ON (ORDERS.OrderKey = DELETED.OrderKey)                                                 --(Wan02) 
           JOIN SKU  WITH (NOLOCK) ON (DELETED.StorerKey = SKU.StorerKey)                                                  --(Wan02) 
                                   AND(DELETED.SKU = SKU.SKU)                                                              --(Wan02) 
           JOIN PACK WITH (NOLOCK) ON (SKU.Packkey = PACK.Packkey)                                                         --(Wan02) 
           JOIN #TMP_WGTCUBE ON (DELETED.Orderkey = #TMP_WGTCUBE.Orderkey)                                                 --(Wan02)    
                                                       
       END
       ELSE BEGIN
           UPDATE ORDERS 
               SET --GrossWeight = ORDERS.GrossWeight + (SELECT SUM(DELETED.OpenQty * SKU.STDGROSSWGT)                     --(Wan02)
                   --      FROM DELETED (NOLOCK), SKU (NOLOCK)                                                             --(Wan02)
                   --    WHERE DELETED.OrderKey = Orders.OrderKey                                                          --(Wan02)
                   --    AND  DELETED.Storerkey = SKU.Storerkey                                                            --(Wan02)
                   --    AND  DELETED.SKU = SKU.SKU),                                                                      --(Wan02)          
                   --Capacity = ORDERS.Capacity + (SELECT SUM(DELETED.OpenQty * SKU.STDCUBE)                               --(Wan02)
                   --    FROM DELETED (NOLOCK), SKU (NOLOCK)                                                               --(Wan02)
                   --    WHERE DELETED.OrderKey = Orders.OrderKey                                                          --(Wan02)
                   --    AND  DELETED.Storerkey = SKU.Storerkey                                                            --(Wan02)       
                   --    AND  DELETED.SKU = SKU.SKU)                                                                       --(Wan02)
                   ORDERS.GrossWeight=CONVERT(FLOAT, CONVERT(DECIMAL(15,5), ORDERS.GrossWeight) - #TMP_WGTCUBE.Weight)     --(Wan02)
                  ,ORDERS.Capacity   =CONVERT(FLOAT, CONVERT(DECIMAL(15,5), ORDERS.Capacity) - #TMP_WGTCUBE.CBM)           --(Wan02)                                                      --(Wan02)
                  ,TrafficCop = NULL 
                  ,EditDate = GETDATE() -- KHLim03
         --(Wan02) - START
         --  FROM ORDERS,DELETED
         --  WHERE ORDERS.Orderkey IN (Select Distinct Orderkey From DELETED) 
         --  AND ORDERS.Orderkey = DELETED.Orderkey
         FROM ORDERS
         JOIN DELETED ON (ORDERS.OrderKey = DELETED.OrderKey)
         JOIN #TMP_WGTCUBE ON (DELETED.Orderkey = #TMP_WGTCUBE.Orderkey)
         WHERE ORDERS.OrderKey IN (Select Distinct OrderKey From DELETED)
         --(Wan02) - END
       END
  
       SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
       IF @n_err <> 0
       BEGIN
           SELECT @n_continue = 3
           SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62905   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
           SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update ORDERS Gross Weight and Volume Failed. (ntrOrderDetailDelete)" + " 
                  ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
       END
   END
   -- End of Shong Fixed
 
   /* -------------------------------------------- Customisation of FBR005 ends --------------------------------------------*/

   /* #INCLUDE <TRODD2.SQL> */
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrOrderDetailDelete"
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
/* Trigger: ntrOrderDetailPreAdd                                        */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Input Parameters: NONE                                               */
/*                                                                      */
/* Output Parameters: NONE                                              */
/*                                                                      */
/* Return Status: NONE                                                  */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When records INSERTED                                     */
/*                                                                      */
/* PVCS Version: 1.2                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  ver  Purposes                                   */
/* 27-Jan-2021  TLTING01 1.1 Add new column                             */
/* 25-Mar-2021  LZG      1.2 Included new columns while insert (ZG01)   */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrOrderDetailPreAdd]
ON  [dbo].[ORDERDETAIL]
INSTEAD OF INSERT  
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE
          @b_Success    INT       -- Populated by calls to stored procedures - was the proc successful?
,         @n_err        INT       -- Error number returned by stored procedure or this trigger
,         @n_err2       INT       -- For Additional Error Detection
,         @c_errmsg     NVARCHAR(250) -- Error message returned by stored procedure or this trigger
,         @n_Continue   INT                 
,         @n_starttcnt  INT                -- Holds the current transaction count@n_StorerMinShelfLife_Per 
,         @c_preprocess NVARCHAR(250)     -- preprocess
,         @c_pstprocess NVARCHAR(250)     -- post process
,         @n_cnt        int                  
,         @n_OrderDetailSysId INT

   DECLARE @c_OrderKey        NVARCHAR(10), 
           @c_OrderLineNumber NVARCHAR(5), 
           @c_Sku             NVARCHAR(20), 
           @c_StorerKey       NVARCHAR(15),      
           @c_Facility        NVARCHAR(5)
   
   DECLARE @c_Authority_ShelfLife NVARCHAR(1), 
           @n_StorerMinShelfLife_Per Int,
           @c_SKUOutGoingShelfLife NVARCHAR(18),
           @n_MinShelfLife Int       


   SELECT @n_Continue=1, @n_starttcnt=@@TRANCOUNT

   IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
      SELECT @n_Continue = 4

   DECLARE @t_OrderDetail TABLE (
	   [OrderKey] [nvarchar](10) NOT NULL,
	   [OrderLineNumber] [nvarchar](5) NOT NULL,
	   [ExternOrderKey] [nvarchar](50) NULL,
	   [ExternLineNo] [nvarchar](20) NULL,
	   [Sku] [nvarchar](20) NOT NULL,
	   [StorerKey] [nvarchar](15) NOT NULL,
	   [ManufacturerSku] [nvarchar](20) NOT NULL,
	   [RetailSku] [nvarchar](20) NOT NULL DEFAULT '',
	   [AltSku] [nvarchar](20) NOT NULL DEFAULT '',
	   [OriginalQty] [int] NOT NULL DEFAULT 0,
	   [OpenQty] [int] NOT NULL DEFAULT 0,
	   [ShippedQty] [int] NOT NULL DEFAULT 0,
	   [AdjustedQty] [int] NOT NULL DEFAULT 0,
	   [QtyPreAllocated] [int] NOT NULL DEFAULT 0,
	   [QtyAllocated] [int] NOT NULL DEFAULT 0,
	   [QtyPicked] [int] NOT NULL DEFAULT 0,
	   [UOM] [nvarchar](10) NOT NULL DEFAULT 'EA',
	   [PackKey] [nvarchar](10) NOT NULL DEFAULT '',
	   [PickCode] [nvarchar](10) NOT NULL DEFAULT '',
	   [CartonGroup] [nvarchar](10) NULL DEFAULT '',
	   [Lot] [nvarchar](10) NOT NULL DEFAULT '',
	   [ID] [nvarchar](18) NOT NULL DEFAULT '',
	   [Facility] [nvarchar](5) NOT NULL DEFAULT '',
	   [Status] [nvarchar](10) NOT NULL DEFAULT '0',
	   [UnitPrice] [float] NULL DEFAULT 0,
	   [Tax01] [float] NULL DEFAULT 0,
	   [Tax02] [float] NULL DEFAULT 0,
	   [ExtendedPrice] [float] NULL DEFAULT 0,
	   [UpdateSource] [nvarchar](10) NOT NULL DEFAULT '',
	   [Lottable01] [nvarchar](18) NOT NULL DEFAULT '',
	   [Lottable02] [nvarchar](18) NOT NULL DEFAULT '',
	   [Lottable03] [nvarchar](18) NOT NULL DEFAULT '',
	   [Lottable04] [datetime] NULL,
	   [Lottable05] [datetime] NULL,
	   [EffectiveDate] [datetime] NOT NULL DEFAULT GETDATE(),
	   [TariffKey] [nvarchar](10) NULL DEFAULT '',
	   [FreeGoodQty] [int] NULL DEFAULT 0,
	   [GrossWeight] [float] NULL DEFAULT 0,
	   [Capacity] [float] NULL DEFAULT 0,
	   [LoadKey] [nvarchar](10) NULL DEFAULT '',
	   [MBOLKey] [nvarchar](10) NULL DEFAULT '',
	   [QtyToProcess] [int] NULL DEFAULT 0,
	   [MinShelfLife] [int] NULL DEFAULT 0,
	   [UserDefine01] [nvarchar](18) NULL DEFAULT '',
	   [UserDefine02] [nvarchar](18) NULL DEFAULT '',
	   [UserDefine03] [nvarchar](18) NULL DEFAULT '',
	   [UserDefine04] [nvarchar](18) NULL DEFAULT '',
	   [UserDefine05] [nvarchar](18) NULL DEFAULT '',
	   [UserDefine06] [nvarchar](18) NULL DEFAULT '',
	   [UserDefine07] [nvarchar](18) NULL DEFAULT '',
	   [UserDefine08] [nvarchar](18) NULL DEFAULT '',
	   [UserDefine09] [nvarchar](18) NULL DEFAULT '',
	   [POkey] [nvarchar](20) NULL DEFAULT '',
	   [ExternPOKey] [nvarchar](20) NULL DEFAULT '',
	   [UserDefine10] [nvarchar](18) NULL DEFAULT '',
	   [EnteredQTY] [int] NULL DEFAULT 0,
	   [ConsoOrderKey] [nvarchar](30) NULL DEFAULT '',
	   [ExternConsoOrderKey] [nvarchar](30) NULL DEFAULT '',
	   [ConsoOrderLineNo] [nvarchar](5) NULL DEFAULT '',
	   [Lottable06] [nvarchar](30) NULL DEFAULT '',
	   [Lottable07] [nvarchar](30) NULL DEFAULT '',
	   [Lottable08] [nvarchar](30) NULL DEFAULT '',
	   [Lottable09] [nvarchar](30) NULL DEFAULT '',
	   [Lottable10] [nvarchar](30) NULL DEFAULT '',
	   [Lottable11] [nvarchar](30) NULL DEFAULT '',
	   [Lottable12] [nvarchar](30) NULL DEFAULT '',
	   [Lottable13] [datetime] NULL,
	   [Lottable14] [datetime] NULL,
	   [Lottable15] [datetime] NULL,
	   [Notes] [nvarchar](500)  NULL DEFAULT '',
	   [Notes2] [nvarchar](500) NULL DEFAULT '',
	   [Channel] [nvarchar](20) NULL DEFAULT '',
	   [HashValue] [TinyInt] NULL DEFAULT 0, 
	   [SalesChannel]  	[nvarchar](100) DEFAULT '',
	   [AddDate] [datetime] NULL,      -- ZG01
    [AddWho] [nvarchar](128),       -- ZG01
    [EditDate] [datetime] NULL,     -- ZG01
    [EditWho] [nvarchar](128),      -- ZG01
    [ArchiveCop][nvarchar](1),      -- ZG01
    [TrafficCop][nvarchar](1)       -- ZG01
      )

   INSERT INTO @t_OrderDetail 
       (OrderKey, OrderLineNumber, ExternOrderKey,
        ExternLineNo, Sku, StorerKey, ManufacturerSku, RetailSku, AltSku,
        OriginalQty, OpenQty, ShippedQty, AdjustedQty, QtyPreAllocated,
        QtyAllocated, QtyPicked, UOM, PackKey, PickCode, CartonGroup, Lot,
        ID, Facility, [Status], UnitPrice, Tax01, Tax02, ExtendedPrice,
        UpdateSource, Lottable01, Lottable02, Lottable03, Lottable04,
        Lottable05, EffectiveDate, TariffKey, FreeGoodQty, GrossWeight,
        Capacity, LoadKey, MBOLKey, QtyToProcess, MinShelfLife,
        UserDefine01, UserDefine02, UserDefine03, UserDefine04,
        UserDefine05, UserDefine06, UserDefine07, UserDefine08,
        UserDefine09, POkey, ExternPOKey, UserDefine10, EnteredQTY,
        ConsoOrderKey, ExternConsoOrderKey, ConsoOrderLineNo, Lottable06,
        Lottable07, Lottable08, Lottable09, Lottable10, Lottable11,
        Lottable12, Lottable13, Lottable14, Lottable15, Notes, Notes2,
        Channel, HashValue, SalesChannel, 
        AddDate, AddWho, EditDate, EditWho, ArchiveCop, TrafficCop )    -- ZG01
   SELECT OrderKey, OrderLineNumber, ExternOrderKey,
        ExternLineNo, Sku, StorerKey, ManufacturerSku, RetailSku, AltSku,
        OriginalQty, OpenQty, ShippedQty, AdjustedQty, QtyPreAllocated,
        QtyAllocated, QtyPicked, UOM, PackKey, PickCode, CartonGroup, Lot,
        ID, Facility, [Status], UnitPrice, Tax01, Tax02, ExtendedPrice,
        UpdateSource, Lottable01, Lottable02, Lottable03, Lottable04,
        Lottable05, EffectiveDate, TariffKey, FreeGoodQty, GrossWeight,
        Capacity, LoadKey, MBOLKey, QtyToProcess, MinShelfLife,
        UserDefine01, UserDefine02, UserDefine03, UserDefine04,
        UserDefine05, UserDefine06, UserDefine07, UserDefine08,
        UserDefine09, POkey, ExternPOKey, UserDefine10, EnteredQTY,
        ConsoOrderKey, ExternConsoOrderKey, ConsoOrderLineNo, Lottable06,
        Lottable07, Lottable08, Lottable09, Lottable10, Lottable11,
        Lottable12, Lottable13, Lottable14, Lottable15, Notes, Notes2,
        Channel, HashValue, SalesChannel,
        AddDate, AddWho, EditDate, EditWho, ArchiveCop, TrafficCop      -- ZG01
   FROM INSERTED                
   
   SELECT TOP 1 
      @c_Facility = ORDERS.Facility,
      @c_StorerKey = ORDERS.StorerKey
   FROM @t_OrderDetail ORDDET 
   JOIN ORDERS WITH (NOLOCK) ON ORDERS.OrderKey =  ORDDET.OrderKey
   
   
   -- Added By SHONG on 09-Jun-2004
   -- Reported by Carl (IDSHK), Delete from DEL_ORDERDETAIL IF the previous records was INSERTED
   IF @n_Continue=1 or @n_Continue=2 
   BEGIN
      IF EXISTS(SELECT 1 FROM DEL_ORDERDETAIL (NOLOCK) 
                  JOIN @t_OrderDetail ORDDET  
                  ON DEL_ORDERDETAIL.OrderKey = ORDDET.OrderKey AND 
                     DEL_ORDERDETAIL.OrderLineNumber = ORDDET.OrderLineNumber )
      BEGIN
         DELETE DEL_ORDERDETAIL
         FROM   DEL_ORDERDETAIL
         JOIN @t_OrderDetail ORDDET ON DEL_ORDERDETAIL.OrderKey = ORDDET.OrderKey 
                              AND DEL_ORDERDETAIL.OrderLineNumber = ORDDET.OrderLineNumber
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
           SELECT @n_Continue = 3
           SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 62902   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
           SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': DELETE DEL_ORDERDETAIL Failed. (ntrOrderDetailPreAdd)' + ' ( ' 
           + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') + ' ) '
         END
      END 
   END

   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
       IF EXISTS(
              SELECT 1
              FROM   @t_OrderDetail ORDDET
              WHERE  (ORDDET.ExternOrderKey = '' OR ORDDET.ExternOrderKey IS NULL) AND
                     (ORDDET.ExternLineNo = '' OR ORDDET.ExternLineNo IS NULL)
          )
       BEGIN
           UPDATE ORDDET
           SET    ORDDET.ExternOrderKey = ORDERS.ExternOrderKey
                 ,ORDDET.ExternLineNo = CONVERT(INT, ORDDET.OrderLineNumber) 
           FROM   @t_OrderDetail AS ORDDET 
           JOIN   ORDERS WITH (NOLOCK) ON ORDDET.OrderKey = ORDERS.OrderKey
           WHERE  (ORDDET.ExternOrderKey = '' OR ORDDET.ExternOrderKey IS NULL) AND
                  (ORDDET.ExternLineNo = '' OR ORDDET.ExternLineNo IS NULL)
       END

       SELECT @n_err = @@ERROR,
              @n_cnt = @@ROWCOUNT
       IF @n_err<>0
       BEGIN
           SELECT @n_Continue = 3
           SELECT @c_errmsg = CONVERT(CHAR(250), @n_err),
                  @n_err = 62904  
           SELECT @c_errmsg = 'NSQL'+CONVERT(CHAR(5), @n_err)+
                  ': Updating ExternOrderKey On ORDERDETAIL Failed. (ntrOrderDetailPreAdd)' 
                 +'  ( '+' SQLSvr   MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') 
                 +' ) '
       END           
   END


   IF @n_Continue = 1 or @n_Continue=2
   BEGIN
       UPDATE ORDDET  
       SET [Status] = CASE 
                        WHEN OriginalQty + AdjustedQty = ShippedQty AND ShippedQty <> 0
                            THEN '9'
                        WHEN OriginalQty + AdjustedQty <> ShippedQty
                            THEN '0'
                        ELSE [Status]
                     END,
           [OriginalQty] = OpenQty,
           [EnteredQty] = OpenQty 
       FROM @t_OrderDetail ORDDET

       SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
       IF @n_err <> 0
       BEGIN
           SELECT @n_Continue = 3
           SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62905   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
           SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Of STATUS & OriginalQty On ORDERDETAIL Failed. (ntrOrderDetailPreAdd)' 
           + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') + ' ) '
       END
   END

   --NJOW01 Start
   IF @n_Continue=1 or @n_Continue=2
   BEGIN
      Select @b_success = 0

      Execute nspGetRight 
              @c_Facility, 
              @c_StorerKey,   -- Storer
              '',             -- Sku
              'CopySKUShelfLifeToOrdByCons',  -- ConfigKey
              @b_success          output, 
              @c_Authority_ShelfLife    output, 
              @n_err              output, 
              @c_errmsg           output

      IF @b_success <> 1
      BEGIN
         Select @n_Continue = 3 
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62908   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Retrieve of Right (PopulateSKUShelfLifeToOrd) Failed (ntrOrderDetailPreAdd)" 
         + " ( " + " SQLSvr MESSAGE=" + ISNULL(RTRIM(@c_errmsg), '') + " ) "
      END
   END


   IF (@n_Continue=1 or @n_Continue=2) AND @c_Authority_ShelfLife = '1'
   BEGIN
      DECLARE CUR_ORDDET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT OrderKey, OrderLineNumber, Sku, StorerKey
      FROM @t_OrderDetail 
      ORDER BY OrderKey, OrderLineNumber
      
      OPEN CUR_ORDDET
      
      FETCH FROM CUR_ORDDET INTO @c_OrderKey, @c_OrderLineNumber, @c_Sku, @c_StorerKey
      
      WHILE @@FETCH_STATUS = 0
      BEGIN
         SET @n_StorerMinShelfLife_Per = 0 
         
         SELECT @n_StorerMinShelfLife_Per = STORER.MinShelfLife
         FROM ORDERS WITH (NOLOCK)     
         JOIN STORER WITH (NOLOCK) ON (ORDERS.Consigneekey = STORER.Storerkey)
         WHERE OrderKey = @c_OrderKey
               
         SET @c_SKUOutGoingShelfLife = '0'
                  
         SELECT @c_SKUOutGoingShelfLife = CASE WHEN ISNUMERIC(SKU.SUSR2) = 1 THEN SKU.SUSR2 ELSE '0' END  
         FROM SKU WITH (NOLOCK) 
         WHERE SKU.Storerkey = @c_StorerKey 
         AND SKU.Sku = @c_Sku 

         IF ISNULL(@n_StorerMinShelfLife_Per,0) <> 0
         BEGIN
           IF ISNUMERIC(@c_SKUOutGoingShelfLife) = 1       
               SELECT @n_MinShelfLife = CAST(@c_SKUOutGoingShelfLife AS INT) * (@n_StorerMinShelfLife_Per / 100.00 )
           ELSE
               SELECT @n_MinShelfLife = 0               
         END     


         IF @n_MinShelfLife <> 0
         BEGIN    
            UPDATE ORDDET  
            SET MinShelfLife = @n_MinShelfLife  
            FROM @t_OrderDetail ORDDET
            WHERE ORDDET.OrderKey = @c_OrderKey
              AND ORDDET.OrderLineNumber = @c_OrderLineNumber
                     
            SELECT @n_err = @@ERROR
            IF @n_err <> 0
            BEGIN
                SELECT @n_Continue = 3
                SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62905   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Of MinShelfLife Failed. (ntrOrderDetailPreAdd)" + " ( " 
                + " SQLSvr MESSAGE=" + ISNULL(RTRIM(@c_errmsg), '') + " ) "
            END
         END
                       
         
         FETCH FROM CUR_ORDDET INTO @c_OrderKey, @c_OrderLineNumber, @c_Sku, @c_StorerKey
      END
      
      CLOSE CUR_ORDDET
      DEALLOCATE CUR_ORDDET
   END

   INSERT INTO OrderDetail 
       (OrderKey, OrderLineNumber, ExternOrderKey,
        ExternLineNo, Sku, StorerKey, ManufacturerSku, RetailSku, AltSku,
        OriginalQty, OpenQty, ShippedQty, AdjustedQty, QtyPreAllocated,
        QtyAllocated, QtyPicked, UOM, PackKey, PickCode, CartonGroup, Lot,
        ID, Facility, [Status], UnitPrice, Tax01, Tax02, ExtendedPrice,
        UpdateSource, Lottable01, Lottable02, Lottable03, Lottable04,
        Lottable05, EffectiveDate, TariffKey, FreeGoodQty, GrossWeight,
        Capacity, LoadKey, MBOLKey, QtyToProcess, MinShelfLife,
        UserDefine01, UserDefine02, UserDefine03, UserDefine04,
        UserDefine05, UserDefine06, UserDefine07, UserDefine08,
        UserDefine09, POkey, ExternPOKey, UserDefine10, EnteredQTY,
        ConsoOrderKey, ExternConsoOrderKey, ConsoOrderLineNo, Lottable06,
        Lottable07, Lottable08, Lottable09, Lottable10, Lottable11,
        Lottable12, Lottable13, Lottable14, Lottable15, Notes, Notes2,
        Channel, HashValue, SalesChannel, 
        AddDate, AddWho, EditDate, EditWho, ArchiveCop, TrafficCop)     -- ZG01
   SELECT OrderKey, OrderLineNumber, ExternOrderKey,
        ExternLineNo, Sku, StorerKey, ManufacturerSku, RetailSku, AltSku,
        OriginalQty, OpenQty, ShippedQty, AdjustedQty, QtyPreAllocated,
        QtyAllocated, QtyPicked, UOM, PackKey, PickCode, CartonGroup, Lot,
        ID, Facility, [Status], UnitPrice, Tax01, Tax02, ExtendedPrice,
        UpdateSource, Lottable01, Lottable02, Lottable03, Lottable04,
        Lottable05, EffectiveDate, TariffKey, FreeGoodQty, GrossWeight,
        Capacity, LoadKey, MBOLKey, QtyToProcess, MinShelfLife,
        UserDefine01, UserDefine02, UserDefine03, UserDefine04,
        UserDefine05, UserDefine06, UserDefine07, UserDefine08,
        UserDefine09, POkey, ExternPOKey, UserDefine10, EnteredQTY,
        ConsoOrderKey, ExternConsoOrderKey, ConsoOrderLineNo, Lottable06,
        Lottable07, Lottable08, Lottable09, Lottable10, Lottable11,
        Lottable12, Lottable13, Lottable14, Lottable15, Notes, Notes2,
        Channel, HashValue, SalesChannel,
        AddDate, AddWho, EditDate, EditWho, ArchiveCop, TrafficCop      -- ZG01
   FROM @t_OrderDetail                 
   
END -- Trigger
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
    
/************************************************************************/        
/* Trigger: ntrOrderDetailUpdate                                        */        
/* Creation Date:                                                       */        
/* Copyright: IDS                                                       */        
/* Written by:                                                          */        
/*                                                                      */        
/* Purpose:                                                             */        
/*                                                                      */        
/* Input Parameters: NONE                                               */        
/*                                                                      */        
/* Output Parameters: NONE                                              */        
/*                                                                      */        
/* Return Status: NONE                                                  */        
/*                                                                      */        
/* Usage:                                                               */        
/*                                                                      */        
/* Local Variables:                                                     */        
/*                                                                      */        
/* Called By: When records updated                                      */        
/*                                                                      */        
/* PVCS Version: 1.6                                                    */        
/*                                                                      */        
/* Version: 5.4                                                         */        
/*                                                                      */        
/* Data Modifications:                                                  */        
/*                                                                      */        
/* Updates:                                                             */        
/* Date         Author   Purposes                                       */        
/* 13-Apr-2006  SHONG    Performance Tuning (SHONG_20060413)            */        
/* 10-May-2006  MaryVong Add in RDT compatible error message            */        
/* 05-Apr-2007  MaryVong SOS72718 Add new configkey "NotUpdateUsrDf03"  */        
/* 01-Apr-2009  Vicky    SOS#133155 - Adjustedqty should be updated when*/        
/*                       there is a change of OpenQty (Vicky01)         */      
/* 04-Mar-2010  TLTING   SOS143271 Update externorderkey                */      
/* 20-Oct-2010  TLTING   Performance Tune                               */      
/* 21-Dec-2010  SHONG    Performance Tuning                             */    
/* 03-May-2012  TLTING01 Update Editdate & Editwho                      */    
/* 22-May-2012  TLTING01 DM Integrity issue - Update editdate for       */    
/*                       status < '9'                                   */    
/* 09-Jul-2013  TLTING02 Deadlock Tune                                  */  
/* 10-Jul-2013  SHONG    Deadlock Tune                                  */    
/* 28-Oct-2013  TLTING   Review Editdate column update                  */  
/* 15-Jun-2015  TLTING   Bug fix - add nolock - Deadlock Tune           */  
/* 28-Jul-2017  TLTING03 Performance tune                               */  
/* 16-Oct-2017  SHONG    Performance Tuning (SWT01)                     */
/* 26-Oct-2017  SHONG    Performance Tuning (SWT02)                     */
/************************************************************************/        
CREATE TRIGGER [dbo].[ntrOrderDetailUpdate]        
ON [dbo].[ORDERDETAIL]        
FOR Update        
AS        
BEGIN        
   /* Return Immediately If No Rows Affected */        
   IF @@ROWCOUNT = 0        
   BEGIN        
      RETURN        
   END        
   /* End Return Immediately If No Rows Affected */        
        
   SET NOCOUNT ON        
   SET ANSI_NULLS OFF      
   SET QUOTED_IDENTIFIER OFF        
   SET CONCAT_NULL_YIELDS_NULL OFF        
        
   DECLARE @b_Success     int,       -- Populated by calls to stored procedures - was the proc successful?        
      @n_err              int,       -- Error number returned by stored procedure or this trigger        
      @c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger        
      @n_continue         int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing        
      @n_starttcnt        int,       -- Holds the current transaction count        
      @n_cnt              int        -- Holds the number of rows affected by the Update statement that fired this trigger.        
        
   DECLARE @n_DeletedCount int,        
      @c_Storerkey         NVARCHAR(15),           
      @c_NotUpdUD03        NVARCHAR(1),  -- SOS72718      
      @c_OrderKey          NVARCHAR(10)  
        
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT        
    
   /* Abort Trigger if called From An Insert Trigger */        
   IF UPDATE(ArchiveCop)        
   BEGIN        
      SELECT @n_continue = 4 /* No Error But Skip Processing */        
   END        
   /* End Abort If Called From An Insert */     
       
   -- tlting01    
   IF EXISTS ( SELECT 1 FROM INSERTED, DELETED     
               WHERE INSERTED.OrderKey = DELETED.OrderKey    
               AND INSERTED.OrderLineNumber = DELETED.OrderLineNumber    
               AND ( INSERTED.[status] < '9' OR DELETED.[status] < '9' ) )    
   BEGIN    
      IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)  
      BEGIN    
         -- TLTING01       
         UPDATE ORDERDETAIL with (ROWLOCK)    
         SET EditDate   = GETDATE(),     
             EditWho    = Suser_sname(),    
             TrafficCop = NULL     
         FROM ORDERDETAIL    
         JOIN INSERTED ON ORDERDETAIL.OrderKey = INSERTED.Orderkey     
                        AND ORDERDETAIL.OrderLineNumber = INSERTED.OrderLineNumber    
         WHERE ORDERDETAIL.[status] < '9'    
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT    
         IF @n_err <> 0    
         BEGIN    
            SELECT @n_continue = 3    
            /* Trap SQL Server Error */    
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61747 --63014   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table ORDERDETAIL. (ntrOrderDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "    
            /* End Trap SQL Server Error */    
         END    
      END        
   END    
           
   /* Abort Trigger if called From An Insert Trigger */        
   IF UPDATE(TrafficCop)        
   BEGIN        
      SELECT @n_continue = 4 /* No Error But Skip Processing */        
   END        
   /* End Abort If Called From An Insert */        
        
   /* Execute Preprocess */        
   /* #INCLUDE <TRODU1.SQL> */        
   /* End Execute Preprocess */        
    
-- start tlting sos143271          
   -- To trigger Order Status              
   IF UPDATE(ExternOrderkey) AND -- (tlting01)              
      EXISTS ( SELECT 1 FROM ORDERS with (NOLOCK)             
         JOIN INSERTED ON ORDERS.OrderKey = INSERTED.Orderkey             
         WHERE ORDERS.ExternOrderKey <> INSERTED.ExternOrderkey )        
   BEGIN              
      UPDATE ORDERS with (ROWLOCK)             
      SET ExternOrderkey = INSERTED.ExternOrderkey,     
         EditDate = GETDATE(), EditWho=SUSER_SNAME(),    --tlting    
         TrafficCop = NULL        
      FROM ORDERS              
      JOIN INSERTED ON ORDERS.OrderKey = INSERTED.Orderkey              
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT              
      IF @n_err <> 0              
      BEGIN              
         SELECT @n_continue = 3              
         /* Trap SQL Server Error */              
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61744 --63014   -- Should Be Set To The SQL Errmessage but I don't know how to do so.              
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table ORDERS. (ntrOrderDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "              
         /* End Trap SQL Server Error */              
      END              
   END              
-- END tlting SOS143271       
    
        
   /* Main Processing */        
   IF (@n_continue = 1 or @n_continue=2)        
   BEGIN        
      /*Cannot Reduce The ShippedQTY Column*/        
      IF UPDATE (ShippedQty) -- SWT01    
      BEGIN        
         IF EXISTS ( SELECT 1     
                     FROM INSERTED INS_REC     
                     JOIN DELETED  DEL_REC ON (INS_REC.Orderkey = DEL_REC.OrderKey AND     
                                      INS_REC.Orderlinenumber = DEL_REC.orderlinenumber)    
                     WHERE INS_REC.Shippedqty < DEL_REC.Shippedqty )        
         BEGIN        
            SELECT @n_continue = 3, @n_err = 61741 --63004        
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Reduction Of Shipped QTY Not Allowed! (ntrOrderDetailUpdate)" 
                  + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "        
         END        
      END        
      /*End Cannot Reduce The ShippedQTY Column*/        
        
      /* Update The OriginalQTY column if the shippedqty column Is 0 */        
      IF ( @n_continue = 1 or @n_continue = 2)        
      BEGIN        
         IF UPDATE (shippedqty) OR UPDATE(openqty) OR UPDATE(QtyAllocated) OR UPDATE(QtyPicked)        
         BEGIN        
            UPDATE ORDERDETAIL WITH (ROWLOCK)        
            SET originalqty = CASE WHEN INSERTED.shippedqty = 0 AND DELETED.shippedqty=0        
                                   THEN ORDERDETAIL.openqty         
                                   ELSE INSERTED.originalqty        
                              END,        
               Adjustedqty = CASE WHEN ( INSERTED.shippedqty <> 0 or DELETED.shippedqty <> 0) AND         
                                    ( INSERTED.shippedqty + INSERTED.openqty +INSERTED.AdjustedQty <> DELETED.shippedqty + DELETED.openqty+DELETED.Adjustedqty)        
                                  THEN (INSERTED.openqty + INSERTED.shippedqty) - orderdetail.originalqty         
                                  ELSE INSERTED.Adjustedqty        
                             END,        
              [Status] = CASE WHEN INSERTED.OriginalQty + INSERTED.AdjustedQty + INSERTED.FreeGoodQty = INSERTED.ShippedQty AND INSERTED.ShippedQty <> 0        
                           THEN '9' -- Shipped        
                              WHEN INSERTED.ShippedQty > 0        
                                 THEN '9' -- Shipped        
                              --WHEN INSERTED.OpenQty = 0   AND INSERTED.Status < '9'         
                              WHEN (INSERTED.QtyAllocated + INSERTED.QtyPicked) = 0   AND INSERTED.Status < '5'      
                                 THEN '0' -- Normal         
                              WHEN (INSERTED.OpenQty = INSERTED.QtyAllocated ) AND INSERTED.QtyPicked = 0 AND DELETED.Status < '3'        
                                 THEN '2' -- Fully Allocated          
                              WHEN ((INSERTED.OpenQty <> (INSERTED.QtyAllocated + INSERTED.QtyPicked)) AND INSERTED.QtyPicked = 0         
                                     AND INSERTED.ShippedQty = 0 AND INSERTED.QtyAllocated = 0)         
                                 THEN '0' -- Normal         
                              WHEN ((INSERTED.OpenQty <> (INSERTED.QtyAllocated + INSERTED.QtyPicked)) AND INSERTED.QtyPicked = 0 AND INSERTED.ShippedQty = 0 )        
                                    AND DELETED.Status < '3'         
                                 THEN '1'        
                              WHEN (INSERTED.QtyAllocated > 0 AND INSERTED.QtyPicked > 0 AND (INSERTED.QtyAllocated <> INSERTED.QtyPicked) )         
                                    AND DELETED.Status < '4'        
                                 THEN '3'        
                            WHEN INSERTED.QtyAllocated = 0 AND INSERTED.QtyPicked > 0 And INSERTED.Status <> '9'         
                                 THEN '5'        
                           ELSE INSERTED.Status        
                       END,        
               EditDate = GETDATE(), EditWho=Suser_sname()        
            FROM ORDERDETAIL        
            JOIN INSERTED ON (ORDERDETAIL.orderkey = INSERTED.orderkey AND ORDERDETAIL.orderlinenumber = INSERTED.orderlinenumber )        
            JOIN DELETED ON (INSERTED.orderkey = DELETED.orderkey AND INSERTED.orderlinenumber = DELETED.orderlinenumber)        
        
            SELECT @n_err=@@ERROR, @n_cnt=@@ROWCOUNT        
            IF @n_err <> 0        
            BEGIN        
               SELECT @n_continue = 3        
               /* Trap SQL Server Error */        
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61742 --63005   -- Should Be Set To The SQL Errmessage but I don't know how to do so.        
               SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Trigger On ORDERDETAIL Failed. (ntrOrderDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "        
               /* End Trap SQL Server Error */        
            END        
         END        
      END -- IF ( @n_continue = 1 or @n_continue = 2)        
      /* End Removed BY NB 08/14/95 */        
      /* End Update the originalQTY column if the shippedqty column is 0 */        
              
      IF @n_continue = 1 or @n_continue = 2        
      BEGIN        
         -- SOS72718 If enable this configkey, do not update Orders.UserDefine03 when confirm Picked or Packed        
         SELECT @c_Storerkey = Storerkey        
         FROM  INSERTED        
                    
         SET @b_success = 0        
         EXECUTE nspGetRight null,  -- facility        
               @c_Storerkey,        -- Storerkey        
               null,                -- Sku        
               'NotUpdateUsrDf03',  -- Configkey        
               @b_success     output,        
               @c_NotUpdUD03  output,         
               @n_err         output,        
               @c_errmsg      output        
         IF @b_success <> 1        
         BEGIN        
            SELECT @n_continue = 3, @n_err = 61746, @c_errmsg = 'ntrOrderDetailUpdate' + dbo.fnc_RTrim(@c_errmsg)        
         END        
                 
         IF @c_NotUpdUD03 <> '1'        
         BEGIN        
    
            -- StartHere (SHONG_20060413)        
            IF UPDATE(QtyPicked)     
            AND EXISTS(SELECT 1 FROM INSERTED WHERE UnitPrice > 0)    
            AND EXISTS(SELECT 1 FROM INSERTED    
                        JOIN ORDERS with (NOLOCK) on ORDERS.ORDERKEY = INSERTED.ORDERKEY    
                      WHERE  ISNUMERIC(ISNULL(RTRIM(ORDERS.UserDefine03), 0) ) = 1)    
            AND EXISTS ( SELECT 1    
                  FROM DELETED        
                  JOIN INSERTED ON INSERTED.Orderkey = DELETED.Orderkey        
                  AND INSERTED.OrderLineNumber = DELETED.OrderLineNumber        
                  AND ( INSERTED.QtyPicked <> DELETED.QtyPicked     
                  OR INSERTED.UnitPrice <> DELETED.UnitPrice )    ) -- tlting Performance Tuning        
            BEGIN        
               SELECT @n_DeletedCount = (select count(*) FROM DELETED)        
               IF @n_DeletedCount = 1        
               BEGIN        
                  /* Only one row updated in the detail table. */        
                  UPDATE ORDERS  WITH (ROWLOCK)      
                  SET  UserDefine03 = CAST( CAST(ORDERS.UserDefine03 as float) +        
                  (INSERTED.QtyPicked * INSERTED.UnitPrice) -        
                  (DELETED.QtyPicked * DELETED.UnitPrice) as NVARCHAR(18)),    -- bug fix    
                  EditDate = GETDATE(), EditWho=SUSER_SNAME(),     --tlting      
                  TrafficCop = NULL        
                  FROM ORDERS        
                  JOIN INSERTED ON (INSERTED.OrderKey = ORDERS.OrderKey)        
                  JOIN DELETED  ON (DELETED.OrderKey = ORDERS.OrderKey AND DELETED.OrderKey = INSERTED.OrderKey)        
               END -- @n_DeletedCount = 1        
               ELSE        
               BEGIN        
                  /* Multiple rows in the detail table were updated */        
                  /* Sum up the details.openqty and update the openqty on the header */        
                  DECLARE @Ord_TotPrice TABLE (OrderKey NVARCHAR(10), TotPrice float)        
            
                  INSERT INTO @Ord_TotPrice        
                  SELECT DELETED.OrderKey, Sum(INSERTED.QtyPicked * INSERTED.UnitPrice) - SUM(DELETED.QtyPicked * DELETED.UnitPrice)        
                  FROM DELETED        
                  JOIN INSERTED ON INSERTED.Orderkey = DELETED.Orderkey        
                  AND INSERTED.OrderLineNumber = DELETED.OrderLineNumber        
                  GROUP BY DELETED.OrderKey        
                  
                  IF EXISTS(SELECT 1 FROM @Ord_TotPrice WHERE TotPrice <> 0)        
                  BEGIN        
                     UPDATE ORDERS WITH (ROWLOCK) SET UserDefine03 = UserDefine03 + TotPrice,    -- bug fix    
                        EditDate = GETDATE(), EditWho=SUSER_SNAME(),    
                        TrafficCop = NULL        
                     FROM ORDERS, @Ord_TotPrice AS OrdPrice        
                     WHERE ORDERS.Orderkey = OrdPrice.Orderkey     
                     AND ISNUMERIC(UserDefine03 ) = 1
                  END        
               END        
               -- EndHere (SHONG_20060413)        
               SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT        
               IF @n_err <> 0        
               BEGIN        
                  SELECT @n_continue = 3        
                  /* Trap SQL Server Error */        
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61743 --63014   -- Should Be Set To The SQL Errmessage but I don't know how to do so.        
                  SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table ORDERS. (ntrOrderDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "        
                  /* End Trap SQL Server Error */        
               END        
            END -- UPDATE(QtyPicked)        
         END -- @c_NotUpdUD03 <> '1'                  
      END      
       
          
      IF (@n_continue = 1 or @n_continue=2)        
      BEGIN        
         -- To trigger Order Status        
         IF ( UPDATE(QtyAllocated) OR UPDATE(QtyPicked) ) -- (SHONG_20060413)     
            AND NOT UPDATE(OpenQty)             
         BEGIN    
            SET @c_OrderKey = ''  
            
            -- SWT02 performance tuning 
            DECLARE CUR_ORDERKEY CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
            SELECT INSERTED.OrderKey          
            FROM INSERTED  
            JOIN DELETED ON INSERTED.OrderKey = DELETED.Orderkey AND 
                            INSERTED.OrderLineNumber = DELETED.OrderLineNumber 
            GROUP BY INSERTED.OrderKey 
            HAVING (SUM(INSERTED.QtyAllocated) <> SUM(DELETED.QtyAllocated)) OR 
                   (SUM(INSERTED.QtyPicked) <> SUM(DELETED.QtyPicked))    
             
            OPEN CUR_ORDERKEY
            
            FETCH NEXT FROM CUR_ORDERKEY INTO @c_OrderKey
            WHILE @@FETCH_STATUS = 0 
            BEGIN
               UPDATE ORDERS  With (ROWLOCK)      
                  SET EditDate = GETDATE(), EditWho=Suser_sname()        
               WHERE OrderKey = @c_OrderKey
                       
               SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT     
               IF @n_err <> 0        
               BEGIN        
                  SELECT @n_continue = 3        
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61744          
                  SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table ORDERS. (ntrOrderDetailUpdate)" 
                  + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "        
               END     
                           	
            	FETCH NEXT FROM CUR_ORDERKEY INTO @c_OrderKey
            END    
            CLOSE CUR_ORDERKEY
            DEALLOCATE CUR_ORDERKEY
         END        
      END         
      /* Update ORDERS.OpenQty */        
      IF (@n_continue = 1 or @n_continue=2)        
      BEGIN     
         -- Added By SHONG On 10-Jul-2013    
         -- Performance Tuning    
         IF UPDATE(OpenQty) 
         -- SWT01
         --AND EXISTS(SELECT 1 FROM INSERTED     
         --     JOIN DELETED ON INSERTED.Orderkey = DELETED.Orderkey        
         --          AND INSERTED.OrderLineNumber = DELETED.OrderLineNumber    
         --     WHERE INSERTED.OpenQty <> DELETED.OpenQty)    
         BEGIN        
            SELECT @n_DeletedCount = (select count(*) FROM DELETED)        
            IF @n_DeletedCount = 1        
            BEGIN        
               /* Only one row updated in the detail table. */        
               UPDATE ORDERS WITH (ROWLOCK)      
               SET  OpenQty = ORDERS.OpenQty + INSERTED.OpenQty - DELETED.OpenQty,  
                  EditDate = GETDATE(),   --tlting  
                  EditWho = SUSER_SNAME()    
               FROM ORDERS, INSERTED, DELETED        
               WHERE ORDERS.OrderKey = INSERTED.OrderKey        
                 AND INSERTED.OrderKey = DELETED.OrderKey        
            END        
            ELSE        
            BEGIN        
               /* Multiple rows in the detail table were updated */        
               /* Sum up the details.openqty and update the openqty on the header */        
               UPDATE ORDERS WITH (ROWLOCK)      
               SET ORDERS.OpenQty        
               = (Orders.Openqty        
               -        
               (Select Sum(DELETED.OpenQty) From DELETED        
               Where DELETED.OrderKey = ORDERS.OrderKey)        
               +        
               (Select Sum(INSERTED.OpenQty) From INSERTED        
               Where INSERTED.OrderKey = ORDERS.OrderKey)        
               ),  
               EditDate = GETDATE(),   --tlting  
               EditWho = SUSER_SNAME()        
               FROM ORDERS,DELETED,INSERTED        
               WHERE ORDERS.Orderkey IN (SELECT Distinct Orderkey From DELETED)        
               AND ORDERS.Orderkey = DELETED.Orderkey        
               AND ORDERS.Orderkey = INSERTED.Orderkey        
               AND INSERTED.Orderkey = DELETED.Orderkey        
               AND INSERTED.OrderLineNumber = DELETED.OrderLineNumber        
            END        
              
            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT        
            IF @n_err <> 0        
            BEGIN        
               SELECT @n_continue = 3        
               /* Trap SQL Server Error */        
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61745 --63014   -- Should Be Set To The SQL Errmessage but I don't know how to do so.        
               SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table ORDERS. (ntrOrderDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "        
               /* End Trap SQL Server Error */        
         END        
         END -- update (openqty)        
      END        
        
   END        
   /* Main Processing ends */        
        
   /* Post Process Starts */       
       
   IF (@n_continue = 1 or @n_continue=2)    
   BEGIN    
      IF EXISTS ( SELECT 1 FROM ORDERDETAIL with (NOLOCK)    
             JOIN INSERTED ON ORDERDETAIL.OrderKey = INSERTED.Orderkey     
                                 AND ORDERDETAIL.OrderLineNumber = INSERTED.OrderLineNumber    
                  WHERE ORDERDETAIL.STATUS in ( '9' , 'CANC') )    
             AND NOT UPDATE(EditDate)        
      BEGIN    
    
    
         -- TLTING01       
         UPDATE ORDERDETAIL with (ROWLOCK)    
         SET EditDate   = GETDATE(),     
             EditWho    = Suser_sname(),    
             TrafficCop = NULL     
         FROM ORDERDETAIL    
         JOIN INSERTED ON ORDERDETAIL.OrderKey = INSERTED.Orderkey     
                        AND ORDERDETAIL.OrderLineNumber = INSERTED.OrderLineNumber    
         WHERE ORDERDETAIL.STATUS in ( '9' , 'CANC')                         
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT    
         IF @n_err <> 0    
         BEGIN    
            SELECT @n_continue = 3    
            /* Trap SQL Server Error */    
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61746 --63014   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table ORDERDETAIL. (ntrOrderDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "    
            /* End Trap SQL Server Error */    
         END    
      END    
   END        
   /* #INCLUDE <TRODU2.SQL> */        
   /* Post Process Ends */        
           
   /* Return Statement */        
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
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrOrderDetailUpdate'        
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
     /* End Return Statement */        
END        
GO
ALTER TABLE [dbo].[ORDERDETAIL] WITH NOCHECK ADD CONSTRAINT [CK_ORDERDETAIL_QtyAllocated] CHECK (([QtyAllocated]>=(0) AND [QtyAllocated]<=([OpenQty]+[FreeGoodQty])))
GO
ALTER TABLE [dbo].[ORDERDETAIL] WITH NOCHECK ADD CONSTRAINT [CK_ORDERDETAIL_QtyPicked] CHECK (([QtyPicked]>=(0) AND [QtyPicked]<=([OpenQty]+[FreeGoodQty])))
GO
ALTER TABLE [dbo].[ORDERDETAIL] WITH NOCHECK ADD CONSTRAINT [CK_ORDERDETAIL_QtyPreAlloc] CHECK (([QtyPreAllocated]>=(0)))
GO
ALTER TABLE [dbo].[ORDERDETAIL] WITH NOCHECK ADD CONSTRAINT [CK_ORDERDETAIL_QtyPreAllocated] CHECK ((([QtyPreAllocated]+[QtyPicked])+[QtyAllocated]<=([OpenQty]+[FreeGoodQty])))
GO
ALTER TABLE [dbo].[ORDERDETAIL] WITH NOCHECK ADD CONSTRAINT [CK_ORDERDETAIL_Status] CHECK (([Status]='CANC' OR [Status]='9' OR [Status]='8' OR [Status]='7' OR [Status]='6' OR [Status]='5' OR [Status]='4' OR [Status]='3' OR [Status]='2' OR [Status]='1' OR [Status]='0'))
GO
ALTER TABLE [dbo].[ORDERDETAIL] ADD CONSTRAINT [PKOrderDetail] PRIMARY KEY CLUSTERED ([OrderKey], [OrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ORDERDETAIL_ConsoOrderKey] ON [dbo].[ORDERDETAIL] ([ConsoOrderKey], [ConsoOrderLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ORDERDETAIL_ExtOrdKey] ON [dbo].[ORDERDETAIL] ([ExternOrderKey], [ExternLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ORDERDETAIL6] ON [dbo].[ORDERDETAIL] ([LoadKey], [Status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ORDERDETAIL_MbolKey] ON [dbo].[ORDERDETAIL] ([MBOLKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ORDERDETAIL_SKU] ON [dbo].[ORDERDETAIL] ([StorerKey], [Sku]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[ORDERDETAIL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[ORDERDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ORDERDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ORDERDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ORDERDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Adjustedqty', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'AdjustedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Altsku', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'AltSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Capacity', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Capacity'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Code used to identify the family of cartons used during cartonization.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'CartonGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Consolidated order key', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ConsoOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Consolidated order detail line number imported', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ConsoOrderLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Entered quantity', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'EnteredQTY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Extended price', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ExtendedPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', 'External consolidated order key', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ExternConsoOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'External order detail line number imported', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ExternLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ExternOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer''s Purchase Order number. It is used to link ASN with order', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ExternPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'FOC quantity attached to the line item', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'FreeGoodQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Gross weight', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'GrossWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ID', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Updated when the Shipment Order is attached to a Load or when it''s moved to a new Load', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer defined lottable 01. Use for allocation', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer defined lottable 02. Use for allocation', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer defined lottable 03. Use for allocation', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Product expiry date which will be used as one of the criterias for allocation', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Product receipt date which will be used as one of the criterias for allocation', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable07', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable08', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable09', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable10', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable11', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable11'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable12', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable12'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable13', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable13'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable14', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable14'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable15', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Lottable15'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Manufacturer SKU', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ManufacturerSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Updated when the Shipment Order is attached to an MBOL or when it''s moved to a new MBOL', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'MBOLKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Minimum number of days that the customer allows between the current date and either the expiration date or the manufacturing date for the item being shipped.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'MinShelfLife'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Notes2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Open Quantity', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'OpenQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Order detail system ID', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'OrderDetailSysId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Order detail line number. System generated', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'OrderLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Original quantity', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'OriginalQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Packing configuration of the SKU. Will be defaulted to the pack key assigned in the Commodity screen. Changeable', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pick.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'PickCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'WMS Purchase Order number. It is used to process Crossdock orders, linking ASN with the order', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'POkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity allocated', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'QtyAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity picked', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'QtyPicked'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product that has been pre-allocated from the lot associated to the product.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'QtyPreAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Qty To Process', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'QtyToProcess'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Retail SKU', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'RetailSku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Distribution channels like wholesalers, retailers, distributors along with Orders', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'SalesChannel'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity shipped', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'ShippedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The SKU being ordered', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Status', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The pricing model assigned to the SKU that defines the rates and method of billing for storage and associated charges', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'TariffKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tax ID 01', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Tax01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tax ID 02', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'Tax02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Price per unit of the product ordered', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UnitPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measurement in which the SKU will be shipped', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Source update', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UpdateSource'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine01', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine02', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine03', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine04', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine05', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine06', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine07', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine08', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine09', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'OrderDetail Userdefine10', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL', 'COLUMN', N'UserDefine10'
GO
