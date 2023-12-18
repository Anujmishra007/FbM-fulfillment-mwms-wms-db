SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* SP: ispPopulateTOASN_OODIE                                           */
/* Creation Date: 08-Jun-2023                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-22729 - [AU]_OODIE_AutoCreateASN_New                    */
/*                                                                      */
/* Called By: ntrMBOLHeaderUpdate                                       */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */ 
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver. Purposes                                   */
/* 08-Jun-2023  WLChooi 1.0  DevOps Combine Script                      */
/************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[ispPopulateTOASN_OODIE] 
      @c_OrderKey NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON   
   SET QUOTED_IDENTIFIER OFF   
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF 

   DECLARE @c_ExternReceiptKey      NVARCHAR(20),
           @c_SKU                   NVARCHAR(20),
           @c_PackKey               NVARCHAR(10),
           @c_UOM                   NVARCHAR(5),
           @c_StorerKey             NVARCHAR(15),
           @c_OrderLine             NVARCHAR(5),
           @c_Facility              NVARCHAR(5),
           @c_ExternOrderLine       NVARCHAR(10)

   DECLARE @c_Lottable01            NVARCHAR(18),
           @c_Lottable02            NVARCHAR(18),
           @c_Lottable03            NVARCHAR(18),
           @d_Lottable04            DATETIME,
           @d_Lottable05            DATETIME,
           @c_Lottable06            NVARCHAR(30),
           @c_Lottable07            NVARCHAR(30),
           @c_Lottable08            NVARCHAR(30),
           @c_Lottable09            NVARCHAR(30),
           @c_Lottable10            NVARCHAR(30),
           @c_Lottable11            NVARCHAR(30),
           @c_Lottable12            NVARCHAR(30),
           @d_Lottable13            DATETIME,
           @d_Lottable14            DATETIME,
           @d_Lottable15            DATETIME,
           @n_ShippedQty            INT,
           @c_Trackingno            NVARCHAR(50)

   DECLARE @c_NewReceiptKey         NVARCHAR(10),
           @c_ReceiptLine           NVARCHAR(5),
           @n_LineNo                INT,
           @c_ToFacility            NVARCHAR(5),
           @n_ExpectedQty           INT,
           @n_QtyReceived           INT,
           @n_RemainExpectedQty     INT,
           @c_ToLoc                 NVARCHAR(30),
           @c_ToID                  NVARCHAR(30),
           @c_ToLot                 NVARCHAR(30),
           @n_CtnOrder              INT,
           @c_mbolkey               NVARCHAR(20),
           @c_UDF01                 NVARCHAR(50),
           @c_UDF10                 NVARCHAR(50),
           @c_ExternLineNo          NVARCHAR(20),
           @c_WarehouseReference    NVARCHAR(10),
           @c_Dropid                NVARCHAR(20),
           @c_Channel               NVARCHAR(80),
           @c_ReceiptLineNo         NVARCHAR(5),
           @c_ReceiptGroup          NVARCHAR(10),
           @c_RecType               NVARCHAR(10),
           @c_DocType               NVARCHAR(10),
           @c_Notes                 NVARCHAR(MAX),
           @n_cnt                   INT,
           @c_SellerName            NVARCHAR(100),
           @c_SellerCompany         NVARCHAR(100),
           @c_ExternOrderkey        NVARCHAR(50),
           @c_UDF02                 NVARCHAR(50),
           @n_BeforeReceivedQty     INT,
           @c_CLShort               NVARCHAR(10)
    
   DECLARE @n_continue              INT,
           @b_success               INT,
           @n_err                   INT,
           @c_errmsg                NVARCHAR(255),
           @n_StartTranCnt          INT

   SELECT @n_continue = 1, @b_success = 1, @n_err = 0, @c_errmsg = '', @n_StartTranCnt = @@TRANCOUNT

   --Retrieve info
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN             
      SELECT TOP 1 @c_ExternReceiptKey   = ORDERS.ExternOrderKey
                 , @c_WarehouseReference = ORDERS.OrderKey
                 , @c_RecType            = ORDERS.[Type]
                 , @c_StorerKey          = ORDERS.StorerKey
                 , @c_Facility           = ISNULL(CL.UDF01,'')
                 , @c_Notes              = 'ASN FOR STOCK TO TRANSFER'
                 , @c_SellerName         = MBOL.ExternMbolKey
                 , @c_SellerCompany      = ORDERS.C_Company
                 , @c_ReceiptGroup       = ORDERS.UserDefine09
                 , @c_Mbolkey            = ORDERS.MBOLKey
                 , @c_ExternOrderkey     = ORDERS.ExternOrderKey
                 , @c_UDF02              = ISNULL(CL.UDF02,'')
                 , @c_CLShort            = ISNULL(CL.Short,'')
                 , @c_DocType            = 'A'
      FROM ORDERS (NOLOCK)
      LEFT JOIN CODELKUP CL (NOLOCK) ON (CL.LISTNAME = 'ORDTYP2ASN' AND CL.Code = ORDERS.[Type]
                                     AND CL.Storerkey = ORDERS.StorerKey AND CL.UDF01 = ORDERS.ConsigneeKey)
      JOIN MBOLDETAIL (NOLOCK) ON (MBOLDETAIL.OrderKey = ORDERS.OrderKey)
      JOIN MBOL (NOLOCK) ON (MBOL.MbolKey = MBOLDETAIL.MbolKey)
      WHERE ORDERS.OrderKey = @c_OrderKey
      
      IF @@ROWCOUNT = 0
         GOTO QUIT_SP
         
      SET @c_ToLoc = ''

      IF EXISTS ( SELECT 1
                  FROM LOC (NOLOCK)
                  WHERE LOC = @c_UDF02 )
      BEGIN
         SET @c_ToLoc = @c_UDF02
      END
   END   

   WHILE @@TRANCOUNT > 0
      COMMIT TRAN

   IF @@TRANCOUNT = 0
      BEGIN TRAN

   -- Create receipt
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN          
      IF EXISTS (SELECT 1 FROM RECEIPT WITH (NOLOCK) 
                 WHERE WarehouseReference = @c_WarehouseReference
                 AND ExternReceiptKey = @c_ExternReceiptKey
                 AND StorerKey = @c_StorerKey)
      BEGIN
          GOTO QUIT_SP
      END
      ELSE
      BEGIN 
         -- get next receipt key
         SELECT @b_success = 0
         EXECUTE nspg_getkey
            'RECEIPT'
            , 10
            , @c_NewReceiptKey OUTPUT
            , @b_success OUTPUT
            , @n_err OUTPUT
            , @c_errmsg OUTPUT
         
         IF @b_success = 1
         BEGIN
            INSERT INTO RECEIPT (ReceiptKey, ExternReceiptKey, WarehouseReference, RECType, StorerKey
                               , Facility, Notes, SellerName, SellerCompany, ReceiptGroup, MBOLKey, DOCTYPE)
            VALUES (@c_NewReceiptKey, @c_ExternReceiptKey, @c_WarehouseReference, @c_RecType, @c_StorerKey
                  , @c_Facility, @c_Notes, @c_SellerName, @c_SellerCompany, @c_ReceiptGroup, @c_Mbolkey, @c_DocType)
         END
         ELSE
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 63520   
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Generate Receipt Key Failed! (ispPopulateTOASN_OODIE)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
            GOTO QUIT_SP
         END
      END
   END 
   
   -- Create receiptdetail    
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN          
      SELECT @c_OrderLine = SPACE(5), @n_LineNo = 0
      SELECT @c_ExternOrderLine = SPACE(5)

      DECLARE PICK_CUR CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
          SELECT SUM(ISNULL(PICKDETAIL.Qty,0)) AS Qty,
                 LOTATTRIBUTE.Lottable01,
                 LOTATTRIBUTE.Lottable02,
                 LOTATTRIBUTE.Lottable03,
                 LOTATTRIBUTE.Lottable04,
                 LOTATTRIBUTE.Lottable05,
                 ISNULL(LOTATTRIBUTE.Lottable06,''),
                 ISNULL(LOTATTRIBUTE.Lottable07,''),
                 ISNULL(LOTATTRIBUTE.Lottable08,''),
                 ISNULL(LOTATTRIBUTE.Lottable09,''),
                 ISNULL(LOTATTRIBUTE.Lottable10,''),
                 ISNULL(LOTATTRIBUTE.Lottable11,''),
                 ISNULL(LOTATTRIBUTE.Lottable12,''),
                 LOTATTRIBUTE.Lottable13,
                 LOTATTRIBUTE.Lottable14,
                 LOTATTRIBUTE.Lottable15,
                 PICKDETAIL.lot,
                 PICKDETAIL.SKU,
                 PICKDETAIL.DropID,
                 ORDERDETAIL.PackKey,
                 ORDERDETAIL.UOM
          FROM PICKDETAIL (NOLOCK) 
          JOIN LotAttribute (NOLOCK) ON (PickDetail.LOT = LotAttribute.LOT)
          JOIN SKU S WITH (NOLOCK) ON (S.Storerkey = Pickdetail.Storerkey AND S.SKU = Pickdetail.SKU)
          JOIN ORDERDETAIL (NOLOCK) ON (ORDERDETAIL.OrderKey = PICKDETAIL.OrderKey AND ORDERDETAIL.OrderLineNumber = PICKDETAIL.OrderLineNumber 
                                   AND ORDERDETAIL.StorerKey = PICKDETAIL.Storerkey AND ORDERDETAIL.Sku = PICKDETAIL.Sku)
          WHERE PICKDETAIL.OrderKey = @c_OrderKey 
          GROUP BY PICKDETAIL.StorerKey, PICKDETAIL.SKU, 
                   LOTATTRIBUTE.Lottable01, LOTATTRIBUTE.Lottable02, LOTATTRIBUTE.Lottable03, LOTATTRIBUTE.Lottable04, LOTATTRIBUTE.Lottable05,
                   LOTATTRIBUTE.Lottable06, LOTATTRIBUTE.Lottable07, LOTATTRIBUTE.Lottable08, LOTATTRIBUTE.Lottable09, LOTATTRIBUTE.Lottable10,
                   LOTATTRIBUTE.Lottable11, LOTATTRIBUTE.Lottable12, LOTATTRIBUTE.Lottable13, LOTATTRIBUTE.Lottable14, LOTATTRIBUTE.Lottable15,
                   PICKDETAIL.lot, PICKDETAIL.SKU, PICKDETAIL.DropID, ORDERDETAIL.PackKey, ORDERDETAIL.UOM

      OPEN PICK_CUR
            
      FETCH NEXT FROM PICK_CUR INTO @n_QtyReceived, @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05, 
                                    @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10,
                                    @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15,
                                    @c_ToLot, @c_SKU, @c_DropID, @c_PackKey, @c_UOM

      WHILE @@FETCH_STATUS <> -1
      BEGIN         
         SET @n_LineNo = @n_LineNo + 1

         SELECT @c_ReceiptLine = RIGHT( '0000' + LTRIM(RTRIM(CAST(@n_LineNo AS NVARCHAR(5 )))), 5)
   
         IF @n_QtyReceived IS NULL
            SELECT @n_QtyReceived = 0   
            
         IF @c_ToLoc <> '' AND @c_CLShort = '1'
         BEGIN
            SET @n_BeforeReceivedQty = ISNULL(@n_QtyReceived, 0)
         END
         ELSE
         BEGIN
            SET @n_BeforeReceivedQty = 0
         END

         SELECT @c_ToID = PLD.PalletKey
         FROM PackDetail PD (NOLOCK)
         JOIN PackHeader PH (NOLOCK) ON PD.PickSlipNo = PH.PickSlipNo
         JOIN ORDERS O (NOLOCK) ON PH.OrderKey = O.OrderKey
         JOIN CartonTrack CT (NOLOCK) ON PD.LabelNo = CT.LabelNo AND CT.KeyName = PD.StorerKey
         LEFT JOIN PALLETDETAIL PLD (NOLOCK) ON  PLD.CaseId = PD.LabelNo
                                             AND PLD.UserDefine02 = CT.TrackingNo
                                             AND PLD.UserDefine01 = O.OrderKey
         WHERE PD.LabelNo = @c_DropID AND PD.SKU = @c_SKU AND PD.StorerKey = @c_StorerKey

         SELECT @c_Trackingno = CT.Trackingno
         FROM CARTONTRACK CT (NOLOCK)
         WHERE CT.LabelNo = @c_Dropid
         AND CT.KeyName = @c_StorerKey

         INSERT INTO RECEIPTDETAIL (ReceiptKey,                ReceiptLineNumber,   ExternReceiptKey, 
                                    StorerKey,                 SKU, 
                                    QtyExpected,               QtyReceived,
                                    ToLoc,                     
                                    Lottable01,                Lottable02,          Lottable03,       Lottable04,       Lottable05,
                                    Lottable06,                Lottable07,          Lottable08,       Lottable09,       Lottable10,
                                    Lottable11,                Lottable12,          Lottable13,       Lottable14,       Lottable15,
                                    BeforeReceivedQty,         
                                    ToID,                      ToLot,               Packkey,          UOM,              UserDefine01)
                     VALUES        (@c_NewReceiptKey,          @c_ReceiptLine,      @c_ExternReceiptKey,
                                    @c_StorerKey,              @c_SKU,
                                    ISNULL(@n_QtyReceived, 0), 0,              
                                    ISNULL(@c_ToLoc,''),
                                    @c_Lottable01,             @c_Lottable02,       @c_Lottable03,    @d_Lottable04,    @d_Lottable05, 
                                    @c_Lottable06,             @c_Lottable07,       @c_Lottable08,    @c_Lottable09,    @c_Lottable10,
                                    @c_Lottable11,             @c_Lottable12,       @d_Lottable13,    @d_Lottable14,    @d_Lottable15,
                                    ISNULL(@n_BeforeReceivedQty, 0),
                                    @c_ToID,                   @c_ToLot,            @c_PackKey,       @c_UOM,           @c_Trackingno)
     
         FETCH NEXT FROM PICK_CUR INTO @n_QtyReceived, @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05, 
                                       @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10,
                                       @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15,
                                       @c_ToLot, @c_SKU, @c_DropID, @c_PackKey, @c_UOM
      END -- WHILE @@FETCH_STATUS <> -1
      CLOSE PICK_CUR
      DEALLOCATE PICK_CUR
   END

   WHILE @@TRANCOUNT > 0
      COMMIT TRAN

   IF @@TRANCOUNT = 0
      BEGIN TRAN

   --Finalize
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN                                                       
      SET @n_cnt = 0
                
      ;WITH ORD AS (SELECT PD.Sku, SUM(PD.Qty) AS Qty
                   FROM PICKDETAIL PD (NOLOCK)
                   WHERE PD.Orderkey = @c_Orderkey
                   GROUP BY PD.Sku),    
           REC AS (SELECT RD.Sku, SUM(BeforeReceivedQty) AS Qty
                   FROM RECEIPT R (NOLOCK)
                   JOIN RECEIPTDETAIL RD (NOLOCK) ON R.Receiptkey = RD.Receiptkey
                   WHERE R.Receiptkey = @c_NewReceiptKey
                   GROUP BY RD.Sku)
      SELECT @n_cnt = COUNT(1)
      FROM ORD 
      LEFT JOIN REC ON ORD.Sku = REC.Sku
      WHERE ORD.Qty <> ISNULL(REC.Qty,0)

      IF ISNULL(@n_cnt,0) <> 0
      BEGIN
         SET @n_continue = 3
         SET @n_err = 63530 
         SET @c_errmsg = 'Create ASN Failed. ASN and Order Qty Not Tally. (ispPopulateTOASN_OODIE)'
         GOTO QUIT_SP
      END
      ELSE
      BEGIN
         IF NOT EXISTS ( SELECT 1 
                         FROM RECEIPTDETAIL (NOLOCK)
                         WHERE ReceiptKey = @c_NewReceiptKey
                         AND ToLoc = '' ) AND @c_CLShort = '1'
         BEGIN
            EXEC dbo.ispFinalizeReceipt      
                  @c_ReceiptKey        = @c_NewReceiptKey      
                 ,@b_Success           = @b_Success  OUTPUT      
                 ,@n_err               = @n_err     OUTPUT      
                 ,@c_ErrMsg            = @c_ErrMsg    OUTPUT       
                                   
            IF @b_Success <> 1      
            BEGIN
               SET @n_continue = 3
               SET @c_errmsg = 'ASN Finalize Error (ispPopulateTOASN_OODIE): ' +  RTRIM(ISNULL(@c_errmsg,'')) 
               GOTO QUIT_SP
            END 
         END
      END
   END

   WHILE @@TRANCOUNT > 0
      COMMIT TRAN

 QUIT_SP:
   
   IF CURSOR_STATUS('LOCAL', 'PICK_CUR') IN (0 , 1)
   BEGIN
      CLOSE PICK_CUR
      DEALLOCATE PICK_CUR   
   END

   IF @n_Continue = 3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_success = 0
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_StartTranCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTranCnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispPopulateTOASN_OODIE'
      --RAISERROR @n_err @c_errmsg
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTranCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END  
   
   WHILE @@TRANCOUNT < @n_StartTranCnt
      BEGIN TRAN
END
GO
GRANT EXECUTE ON [dbo].[ispPopulateTOASN_OODIE] TO [NSQL] 
GO   