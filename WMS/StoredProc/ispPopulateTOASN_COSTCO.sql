SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* SP: ispPopulateTOASN_COSTCO                                          */
/* Creation Date: 17-Dec-2023                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-24418 - [CN] COSTCO Auto MBOL to ASN NEW                */
/*                                                                      */
/* Called By: ntrMBOLHeaderUpdate                                       */
/*                                                                      */
/* Github Version: 1.0                                                  */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */ 
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver. Purposes                                   */
/* 17-Dec-2023  WLChooi 1.0  DevOps Combine Script                      */
/************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[ispPopulateTOASN_COSTCO] 
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
           @c_ExternPOKey           NVARCHAR(20)

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
           @c_AltSKU                NVARCHAR(20)

   DECLARE @c_NewReceiptKey         NVARCHAR(10),
           @c_ReceiptLine           NVARCHAR(5),
           @n_LineNo                INT,
           @n_QtyExpected           INT,
           @c_MBOLKey               NVARCHAR(20),
           @c_ExternLineNo          NVARCHAR(20),
           @c_WarehouseReference    NVARCHAR(10),
           @c_RecType               NVARCHAR(10),
           @c_DocType               NVARCHAR(10),
           @c_CarrierName           NVARCHAR(45),
           @c_Carrierkey            NVARCHAR(45),
           @n_BeforeReceivedQty     INT
    
   DECLARE @n_continue              INT,
           @b_success               INT,
           @n_err                   INT,
           @c_errmsg                NVARCHAR(255),
           @n_StartTranCnt          INT

   SELECT @n_continue = 1, @b_success = 1, @n_err = 0, @c_errmsg = '', @n_StartTranCnt = @@TRANCOUNT

   --Retrieve info
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN             
      SELECT TOP 1 @c_ExternReceiptKey   = IIF(CountOrdkey > 1, '', ORDERS.ExternOrderKey)
                 , @c_WarehouseReference = ORDERS.OrderKey
                 , @c_RecType            = ISNULL(TRIM(CL.UDF03),'')
                 , @c_StorerKey          = ISNULL(TRIM(CL.UDF01),'')
                 , @c_Facility           = ISNULL(TRIM(CL.UDF02),'')
                 , @c_CarrierName        = LEFT(ISNULL(TRIM(ORDERS.B_contact2),''), 45)
                 , @c_Carrierkey         = LEFT(ISNULL(TRIM(ORDERS.B_contact1),''), 45)
                 , @c_MBOLKey            = ORDERS.MBOLKey
                 , @c_DocType            = 'A'
      FROM ORDERS (NOLOCK)
      LEFT JOIN CODELKUP CL (NOLOCK) ON (CL.LISTNAME = 'ORDTYP2ASN' AND CL.Code = ORDERS.[Type]
                                     AND CL.Storerkey = ORDERS.StorerKey AND CL.Short = ORDERS.Facility)
      JOIN MBOLDETAIL (NOLOCK) ON (MBOLDETAIL.OrderKey = ORDERS.OrderKey)
      JOIN MBOL (NOLOCK) ON (MBOL.MbolKey = MBOLDETAIL.MbolKey)
      CROSS APPLY ( SELECT COUNT(DISTINCT M.Orderkey) AS CountOrdkey
                    FROM MBOLDETAIL M (NOLOCK)
                    WHERE M.MbolKey = MBOL.MbolKey ) AS MD
      WHERE ORDERS.OrderKey = @c_OrderKey

      IF @@ROWCOUNT = 0
         GOTO QUIT_SP
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
                               , Facility, CarrierName, CarrierKey, MBOLKey, DOCTYPE)
            VALUES (@c_NewReceiptKey, @c_ExternReceiptKey, @c_WarehouseReference, @c_RecType, @c_StorerKey
                  , @c_Facility, @c_CarrierName, @c_Carrierkey, @c_MBOLKey, @c_DocType)
         END
         ELSE
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 63520   
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Generate Receipt Key Failed! (ispPopulateTOASN_COSTCO)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
            GOTO QUIT_SP
         END
      END
   END 
   
   -- Create receiptdetail    
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN          
      SELECT @c_OrderLine = SPACE(5), @n_LineNo = 1
      SELECT @c_ExternLineNo = SPACE(5)

      WHILE 1=1
      BEGIN
         SET ROWCOUNT 1

         SELECT @c_SKU = TRIM(ORDERDETAIL.SKU)
              , @c_AltSKU = ISNULL(TRIM(ORDERDETAIL.AltSku), '')
              , @c_OrderLine = ORDERDETAIL.OrderLineNumber
              , @c_ExternLineNo = ORDERDETAIL.ExternLineNo
              , @c_ExternPOKey = ORDERDETAIL.ExternOrderKey
         FROM ORDERDETAIL (NOLOCK)
         JOIN ORDERS (NOLOCK) ON (ORDERS.OrderKey = ORDERDETAIL.OrderKey) 
         WHERE ( ORDERDETAIL.QtyAllocated + ORDERDETAIL.QtyPicked + ORDERDETAIL.SHIPPEDQTY > 0 ) AND  
               ( ORDERDETAIL.OrderKey = @c_OrderKey ) AND             
               ( ORDERDETAIL.OrderLineNumber > @c_OrderLine )
         ORDER by ORDERDETAIL.OrderLineNumber

         IF @@ROWCOUNT = 0
            BREAK

         SELECT @c_UOM = ISNULL(TRIM(PACK.PackUOM3), '')
              , @c_PackKey = ISNULL(TRIM(SKU.PACKKey), '')
         FROM SKU (NOLOCK)
         JOIN PACK (NOLOCK) ON SKU.PACKKey = PACK.PackKey
         WHERE SKU.StorerKey = @c_StorerKey
         AND SKU.SKU = @c_SKU

         IF @@ROWCOUNT = 0
            BREAK

         SET ROWCOUNT 0

         IF dbo.fnc_RTrim(@c_OrderKey) IS NOT NULL AND 
            dbo.fnc_RTrim(@c_OrderLine) IS NOT NULL 
         BEGIN
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
                       LOTATTRIBUTE.Lottable15
                FROM PICKDETAIL (NOLOCK) 
                JOIN LotAttribute (NOLOCK) ON (PickDetail.LOT = LotAttribute.LOT)
                WHERE (PICKDETAIL.OrderKey = @c_OrderKey AND PICKDETAIL.OrderLineNumber = @c_OrderLine)
                GROUP BY PICKDETAIL.StorerKey, PICKDETAIL.SKU, 
                         LOTATTRIBUTE.Lottable01, LOTATTRIBUTE.Lottable02, LOTATTRIBUTE.Lottable03, LOTATTRIBUTE.Lottable04, LOTATTRIBUTE.Lottable05,
                         LOTATTRIBUTE.Lottable06, LOTATTRIBUTE.Lottable07, LOTATTRIBUTE.Lottable08, LOTATTRIBUTE.Lottable09, LOTATTRIBUTE.Lottable10,
                         LOTATTRIBUTE.Lottable11, LOTATTRIBUTE.Lottable12, LOTATTRIBUTE.Lottable13, LOTATTRIBUTE.Lottable14, LOTATTRIBUTE.Lottable15
            
            OPEN PICK_CUR
                  
            FETCH NEXT FROM PICK_CUR INTO @n_QtyExpected, @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05, 
                                          @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10,
                                          @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15
            
            WHILE @@FETCH_STATUS <> -1
            BEGIN         
               SELECT @c_ReceiptLine = RIGHT( '0000' + LTRIM(RTRIM(CAST(@n_LineNo AS NVARCHAR(5 )))), 5)
            
               IF @n_QtyExpected IS NULL
                  SELECT @n_QtyExpected = 0   
                  
               SET @n_BeforeReceivedQty = 0
            
               INSERT INTO RECEIPTDETAIL (ReceiptKey,                ReceiptLineNumber,         ExternReceiptKey, 
                                          ExternLineNo,              StorerKey,                 SKU, 
                                          AltSKU,                    QtyExpected,               QtyReceived,                  
                                          Lottable01,                Lottable02,                Lottable03,       Lottable04,       Lottable05,
                                          Lottable06,                Lottable07,                Lottable08,       Lottable09,       Lottable10,
                                          Lottable11,                Lottable12,                Lottable13,       Lottable14,       Lottable15,
                                          BeforeReceivedQty,         ExternPoKey,               Packkey,          UOM,              ToLoc)
                           VALUES        (@c_NewReceiptKey,          @c_ReceiptLine,            @c_ExternPOKey,
                                          @c_ExternLineNo,           @c_StorerKey,              @c_SKU,
                                          @c_AltSku,                 ISNULL(@n_QtyExpected, 0), 0,              
                                          @c_Lottable01,             @c_Lottable02,             @c_Lottable03,    @d_Lottable04,    @d_Lottable05, 
                                          @c_Lottable06,             @c_Lottable07,             @c_Lottable08,    @c_Lottable09,    @c_Lottable10,
                                          @c_Lottable11,             @c_Lottable12,             @d_Lottable13,    @d_Lottable14,    @d_Lottable15,
                                          @n_BeforeReceivedQty,      @c_ExternPOKey,            @c_PackKey,       @c_UOM,           '')
            
               SET @n_LineNo = @n_LineNo + 1

               FETCH NEXT FROM PICK_CUR INTO @n_QtyExpected, @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05, 
                                             @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10,
                                             @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15
            END -- WHILE @@FETCH_STATUS <> -1
            CLOSE PICK_CUR
            DEALLOCATE PICK_CUR
         END
      END
      SET ROWCOUNT 0
   END

   WHILE @@TRANCOUNT > 0
      COMMIT TRAN

   IF @@TRANCOUNT = 0
      BEGIN TRAN

   --Finalize
   --IF @n_continue = 1 OR @n_continue = 2
   --BEGIN                                                       
   --   SET @n_cnt = 0
                
   --   ;WITH ORD AS (SELECT PD.Sku, SUM(PD.Qty) AS Qty
   --                FROM PICKDETAIL PD (NOLOCK)
   --                WHERE PD.Orderkey = @c_Orderkey
   --                GROUP BY PD.Sku),    
   --        REC AS (SELECT RD.Sku, SUM(BeforeReceivedQty) AS Qty
   --                FROM RECEIPT R (NOLOCK)
   --                JOIN RECEIPTDETAIL RD (NOLOCK) ON R.Receiptkey = RD.Receiptkey
   --                WHERE R.Receiptkey = @c_NewReceiptKey
   --                GROUP BY RD.Sku)
   --   SELECT @n_cnt = COUNT(1)
   --   FROM ORD 
   --   LEFT JOIN REC ON ORD.Sku = REC.Sku
   --   WHERE ORD.Qty <> ISNULL(REC.Qty,0)

   --   IF ISNULL(@n_cnt,0) <> 0
   --   BEGIN
   --      SET @n_continue = 3
   --      SET @n_err = 63530 
   --      SET @c_errmsg = 'Create ASN Failed. ASN and Order Qty Not Tally. (ispPopulateTOASN_COSTCO)'
   --      GOTO QUIT_SP
   --   END
   --   ELSE
   --   BEGIN
   --      EXEC dbo.ispFinalizeReceipt      
   --            @c_ReceiptKey        = @c_NewReceiptKey      
   --           ,@b_Success           = @b_Success  OUTPUT      
   --           ,@n_err               = @n_err     OUTPUT      
   --           ,@c_ErrMsg            = @c_ErrMsg    OUTPUT       
                                
   --      IF @b_Success <> 1      
   --      BEGIN
   --         SET @n_continue = 3
   --         SET @c_errmsg = 'ASN Finalize Error (ispPopulateTOASN_COSTCO): ' +  RTRIM(ISNULL(@c_errmsg,'')) 
   --         GOTO QUIT_SP
   --      END 
   --   END
   --END

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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispPopulateTOASN_COSTCO'
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
GRANT EXECUTE ON [dbo].[ispPopulateTOASN_COSTCO] TO [NSQL] 
GO   