SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Stored Procedure: mspASNFZ05                                            */
/* Creation Date: 2026-06-25                                               */
/* Copyright: Maersk                                                       */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: FCR-13385-XDOCKCreateSOByPO                                    */
/*        :                                                                */
/*                                                                         */
/* Called By:                                                              */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: V2                                                             */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date        Author     Ver   Purposes                                   */
/* 2024-07-15  SSA01      1.0   Created.                                   */
/***************************************************************************/
CREATE OR ALTER PROC [dbo].[mspASNFZ05]
(     @c_Receiptkey  NVARCHAR(10)
  ,   @b_Success     INT           OUTPUT
  ,   @n_Err         INT           OUTPUT
  ,   @c_ErrMsg      NVARCHAR(255) OUTPUT
  ,   @c_ReceiptLineNumber  NVARCHAR(5) = ''
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Debug              INT   = 0
         , @n_Cnt                INT   = 0
         , @n_Continue           INT   = 1
         , @n_StartTranCount     INT   = @@TRANCOUNT

   DECLARE @n_OrderCnt           INT            = 0
         , @c_ASNStatus          NVARCHAR(10)   = '0'
         , @c_ExistingOrderKey             NVARCHAR(10)   = ''
         , @c_ExistingOrderStatus          NVARCHAR(10)   = '0'
         , @c_DocType            NVARCHAR(1)    = ''
         , @c_OrderKey           NVARCHAR(10)   = ''
         , @c_StorerKey          NVARCHAR(15)   = ''
         , @c_Facility           NVARCHAR(10)   = ''
         , @c_ExternOrderkey     NVARCHAR(50)   = ''
         , @c_RecType            NVARCHAR(10)   = ''
         , @c_OrderLineNumber    NVARCHAR(5)    = ''
         , @c_ExternLineNo       NVARCHAR(20)   = ''
         , @c_Sku                NVARCHAR(20)   = ''
         , @c_Packkey            NVARCHAR(10)   = ''
         , @c_UOM                NVARCHAR(10)   = ''
         , @n_OriginalQty        INT            = 0
         , @n_OpenQty            INT            = 0
         , @c_Lottable01         NVARCHAR(18)   = ''
         , @c_Lottable02         NVARCHAR(18)   = ''
         , @c_Lottable03         NVARCHAR(18)   = ''
         , @c_Lottable04        DATETIME       = NULL
         , @c_Lottable05        DATETIME       = NULL
         , @c_Lottable06        NVARCHAR(18)   = ''
         , @c_Lottable07        NVARCHAR(18)   = ''
         , @c_Lottable08         NVARCHAR(30)   = ''
         , @c_Lottable09        NVARCHAR(18)   = ''
         , @c_Lottable10        NVARCHAR(18)   = ''
         , @c_Lottable11       NVARCHAR(18)   = ''
         , @c_Lottable12       NVARCHAR(18)   = ''
         , @c_Lottable13       DATETIME       = NULL
         , @c_Lottable14        DATETIME       = NULL
         , @c_Lottable15        DATETIME       = NULL
         , @c_UserDefine02       NVARCHAR(15)  = ''
         , @c_ExternPOKey        NVARCHAR(20)  = ''
         , @CUR_RECDET           CURSOR
         , @c_NewTran            NVARCHAR(1) = 'N'
         , @c_Option5            NVARCHAR(500) = ''
         , @c_POKey              NVARCHAR(10)   = ''
         , @c_PickSlipNo      NVARCHAR(10) = ''
         , @c_GetMBOLKey            NVARCHAR(10) = ''
         , @dt_OrderDate         DATETIME
         , @dt_Delivery_Date     DATETIME
         , @c_Route              NVARCHAR(10)
         , @n_totweight          DECIMAL(20,4)
         , @n_totcube            DECIMAL(20,4)
         , @n_TotalCartons       INT            = 0


   SET @b_Success= 1
   SET @n_Err    = 0
   SET @c_ErrMsg = ''

   CREATE TABLE #TMP_ORD
      (  RowID              INT            NOT NULL IDENTITY(1,1) PRIMARY KEY
      ,  OrderKey           NVARCHAR(10)   NOT NULL   DEFAULT('')
      ,  StorerKey          NVARCHAR(15)   NULL
      ,  ExternOrderKey     NVARCHAR(50)   NOT NULL   DEFAULT ('')
      ,  POkey             NVARCHAR(10)   NULL
      ,  BuyerPO            NVARCHAR(20)   NULL
      ,  Type               NVARCHAR(10)   NOT NULL   DEFAULT ('0')
      ,  OrderDate          DATETIME       NULL       DEFAULT (GETDATE())
      ,  C_Company          NVARCHAR(45)   NULL
      ,  C_Address1         NVARCHAR(45)   NULL
      ,  C_Address2         NVARCHAR(45)   NULL
      ,  C_City             NVARCHAR(45)   NULL
      ,  C_State            NVARCHAR(45)   NULL
      ,  C_Zip              NVARCHAR(18)   NULL
      ,  C_ISOCntryCode     NVARCHAR(10)   NULL
      ,  C_Vat              NVARCHAR(18)   NULL
      ,  CountryOfOrigin    NVARCHAR(30)   NULL
      ,  CountryDestination NVARCHAR(30)   NULL
      ,  UserDefine01       NVARCHAR(20)   NULL       DEFAULT ('')
      ,  UserDefine02       NVARCHAR(20)   NULL       DEFAULT ('')
      ,  UserDefine06       DATETIME       NULL
      ,  UserDefine07       DATETIME       NULL
      ,  B_contact1         NVARCHAR(30)   NULL
      ,  B_Contact2         NVARCHAR(30)   NULL
      ,  B_Company          NVARCHAR(45)   NULL
      ,  M_Contact1         NVARCHAR(30)   NULL
      ,  M_Address1         NVARCHAR(45)   NULL
      ,  M_Address2         NVARCHAR(45)   NULL
      ,  M_Address4         NVARCHAR(45)   NULL
      ,  M_City             NVARCHAR(45)   NULL
      ,  M_State            NVARCHAR(45)   NULL
      ,  M_Zip              NVARCHAR(18)   NULL
      ,  M_Vat              NVARCHAR(18)   NULL
      ,  OpenQty            INT            NULL       DEFAULT (0)
      ,  Facility           NVARCHAR(5)    NULL
      ,  XDockFlag          NVARCHAR(1)    NULL       DEFAULT ('0')
      ,  XDOCKPOKEY         NVARCHAR(20)   NULL
      ,  DocType            NVARCHAR(1)    NULL       DEFAULT ('0')
      ,  IntermodalVehicle NVARCHAR(30)    NULL       DEFAULT ('')
      )


   CREATE TABLE #TMP_ORDDTL
      (  OrderKey          NVARCHAR(10)   NOT NULL   DEFAULT('')
      ,  ExternLineNo      NVARCHAR(20)   NOT NULL   DEFAULT('')
      ,  POkey             NVARCHAR(10)   NULL
      ,  StorerKey         NVARCHAR(15)   NULL
      ,  Sku               NVARCHAR(20)   NULL
      ,  PackKey           NVARCHAR(10)   NULL
      ,  UOM               NVARCHAR(10)   NULL
      ,  OriginalQty       INT            DEFAULT(0)
      ,  OpenQty           INT            DEFAULT(0)
      ,  Lottable01        NVARCHAR(18)   NULL
      ,  Lottable02        NVARCHAR(18)   NULL
      ,  Lottable03        NVARCHAR(18)   NULL
      ,  Lottable04        DATETIME       NULL
      ,  Lottable05        DATETIME       NULL
      ,  Userdefine02      NVARCHAR(18)   NULL  DEFAULT('')
      ,  ExternPOKey       NVARCHAR(20)   NULL
      ,  Lottable06        NVARCHAR(30)   NULL
      ,  Lottable07        NVARCHAR(30)   NULL
      ,  Lottable08        NVARCHAR(30)   NULL
      ,  Lottable09        NVARCHAR(30)   NULL
      ,  Lottable10        NVARCHAR(30)   NULL
      ,  Lottable11        NVARCHAR(30)   NULL
      ,  Lottable12        NVARCHAR(30)   NULL
      ,  Lottable13        NVARCHAR(30)   NULL
      ,  Lottable14        DATETIME       NULL
      ,  Lottable15        DATETIME       NULL
      )

              
   SET @n_Cnt = 0
   SELECT @c_Storerkey      = RECEIPT.Storerkey
         ,@c_Facility       = RECEIPT.Facility
         ,@c_DocType        = RECEIPT.DocType
         ,@n_Cnt            = 1
         ,@c_ASNStatus      = RECEIPT.ASNStatus
         ,@c_RecType        = RECEIPT.RECType
   FROM RECEIPT WITH (NOLOCK)
   WHERE RECEIPT.ReceiptKey = @c_ReceiptKey

   IF @n_Cnt = 0
   BEGIN
      GOTO QUIT_SP
   END

   IF @c_ReceiptLineNumber <> '' AND @c_ASNStatus <> '9'
   BEGIN
      GOTO QUIT_SP
   END

   IF @c_DocType <> 'X'
   BEGIN
      GOTO QUIT_SP
   END

   SET @c_NewTran = 'Y'
   
   SELECT @c_Option5 = SC.Option5
   FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey, '','PostFinalizeReceiptSP') AS SC 
   
   SET @c_NewTran = dbo.fnc_GetParamValueFromString ('@c_NewTran', @c_Option5, @c_NewTran)
   
   IF ISNULL(@c_NewTran,'') = ''
      SET @c_NewTran = 'Y'
        
   IF @c_NewTran = 'Y'
   BEGIN
      WHILE @@TRANCOUNT > 0  
      BEGIN
         COMMIT TRAN
      END
      
      BEGIN TRAN      
   END
   
   --Construct order records
   IF @n_continue IN(1,2)
   BEGIN

      --creating cursor for receiptdetail
      DECLARE CUR_RECDET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT RD.Pokey
            ,  RD.ExternPOKey
            ,  RD.ExternLineNo
            ,  RD.Storerkey
            ,  RD.Sku
            ,  RD.Packkey
            ,  RD.UOM
            ,  RD.QtyReceived
            ,  RD.QtyReceived
            ,  RD.Lottable01
            ,  RD.Lottable02
            ,  RD.Lottable03
            ,  RD.Lottable04
            ,  RD.Lottable05
            ,  ISNULL(RD.Userdefine02,'')
            ,  ISNULL(ORD.Orderkey,'')
            ,  ISNULL(ORD.Status,'')
            ,  RD.Lottable06
            ,  RD.Lottable07
            ,  RD.Lottable08
            ,  RD.Lottable09
            ,  RD.Lottable10
            ,  RD.Lottable11
            ,  RD.Lottable12
            ,  RD.Lottable13
            ,  RD.Lottable14
            ,  RD.Lottable15

         FROM  RECEIPT RH WITH (NOLOCK)
         JOIN  RECEIPTDETAIL RD WITH (NOLOCK) ON (RH.ReceiptKey = RD.ReceiptKey)
         OUTER APPLY ( SELECT TOP 1 O.Orderkey, O.Status
                       FROM ORDERS O (NOLOCK)
					   WHERE O.Storerkey = RD.Storerkey
   	                   AND O.ExternOrderKey = RD.ExternPOKey
                       AND O.ExternOrderKey <> ''
   	                   AND O.ExternOrderKey IS NOT NULL
   	                   AND O.Status <> '9') ORD
         WHERE RH.ReceiptKey = @c_Receiptkey
         AND RD.QtyExpected > 0
         ORDER BY ISNULL(RD.Userdefine02,'')
               ,  RD.ReceiptLineNumber

         OPEN CUR_RECDET

         FETCH NEXT FROM CUR_RECDET INTO @c_POKey, @c_ExternPOKey, @c_ExternLineNo, @c_Storerkey, @c_Sku, @c_Packkey, @c_UOM
         , @n_OriginalQty,@n_OpenQty,@c_Lottable01,@c_Lottable02, @c_Lottable03,@c_Lottable04, @c_Lottable05
         , @c_UserDefine02, @c_ExistingOrderKey, @c_ExistingOrderStatus, @c_Lottable06, @c_Lottable07, @c_Lottable08
         , @c_Lottable09, @c_Lottable10, @c_Lottable11, @c_Lottable12, @c_Lottable13, @c_Lottable14, @c_Lottable15

         WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)
         BEGIN
            IF @c_ExistingOrderKey <> ''
               BEGIN
               IF @c_ExistingOrderStatus = '0' 
               BEGIN

                  DECLARE CUR_ORDDET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR               	  
                     SELECT OrderLineNumber
                     FROM ORDERDETAIL (NOLOCK)
                     WHERE Orderkey = @c_ExistingOrderKey
                 
                  OPEN CUR_ORDDET

                  FETCH NEXT FROM CUR_ORDDET INTO @c_OrderLineNumber
                  
                  WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)
                  BEGIN
                     DELETE ORDERDETAIL WHERE Orderkey = @c_ExistingOrderKey AND OrderLineNumber = @c_OrderLineNumber
                     
                     FETCH NEXT FROM CUR_ORDDET INTO @c_OrderLineNumber
                  END
                  CLOSE CUR_ORDDET
                  DEALLOCATE CUR_ORDDET

               END
               ELSE 
               BEGIN
                  GOTO NEXT_RECD
               END
            END            

            SET @c_Orderkey = ''

	          SELECT TOP 1 @c_Orderkey = Orderkey
			      FROM #TMP_ORD 
			      WHERE ExternOrderKey = @c_ExternPOKey

            IF ISNULL(@c_Orderkey,'') = ''
            BEGIN
               IF @c_ExistingOrderKey <> ''
               BEGIN
                  SET @c_Orderkey = @c_ExistingOrderKey                  
               END
               ELSE
               BEGIN
                  SET @c_Orderkey = ''
                  EXECUTE nspg_GetKey
                  @KeyName = 'ORDER'
                  , @fieldlength = 10
                  , @keystring = @c_Orderkey   OUTPUT
                  , @b_Success = @b_Success    OUTPUT
                  , @n_Err     = @n_Err        OUTPUT
                  , @c_ErrMsg  = @c_ErrMsg     OUTPUT
                  , @n_Batch   = 1

                  IF @b_Success = 0
                  BEGIN
                     SET @n_Continue = 3
                     GOTO QUIT_SP
                  END
               END
               
               IF @c_ExistingOrderKey = '' AND NOT EXISTS (SELECT 1 FROM #TMP_ORD WHERE ExternOrderKey = @c_ExternPOKey)
               BEGIN
                  INSERT INTO #TMP_ORD
                  (  OrderKey
                  ,  Storerkey
                  ,  Type
                  ,  ExternOrderkey
                  ,  BuyerPO
                  ,  C_Company
                  ,  C_Address1
                  ,  C_Address2
                  ,  C_City
                  ,  C_State
                  ,  C_Zip
                  ,  C_Vat
                  ,  Facility
                  ,  CountryOfOrigin
                  ,  CountryDestination
                  ,  Userdefine01
                  ,  UserDefine02
                  ,  Userdefine06
                  ,  Userdefine07
                  ,  B_Contact1
                  ,  B_Contact2
                  ,  B_Company
                  ,  M_Contact1
                  ,  M_Address1
                  ,  M_Address2
                  ,  M_Address4
                  ,  M_City
                  ,  M_State
                  ,  M_Zip
                  ,  M_Vat
                  ,  Xdockpokey
                  ,  XDockFlag
                  ,  DocType
                  ,  InterModalVehicle
                  )
                  SELECT TOP 1
                     @c_Orderkey
                  ,  @c_Storerkey
                  ,  'XDOCK'
                  ,  ExternOrderkey  = PO.ExternPOKey
                  ,  BuyerPO   = RH.ExternReceiptKey
                  ,  C_Company      = PO.SellerName
                  ,  C_Address1     = PO.SellerAddress1
                  ,  C_Address2     = PO.SellerAddress2
                  ,  C_City     = PO.SellerCity
                  ,  C_State     = PO.SellerState
                  ,  C_Zip        = PO.SellerZip
                  ,  C_Vat        = PO.SellerVat
                  ,  Facility          = @c_Facility
                  ,  CountryOfOrigin      = PO.OriginCountry
                  ,  CountryDestination = PO.DestinationCountry
                  ,  Userdefine01       = PO.PlaceOfLoading
                  ,  UserDefine02       = PO.placeOfDischarge
                  ,  UserDefine06         = RH.UserDefine06
                  ,  UserDefine07     = RH.Userdefine07
                  ,  B_Contact1         = PO.BuyerName
                  ,  B_Contact2         = PO.BuyerAddress1
                  ,  B_Company          = PO.BuyerAddress2
                  ,  M_Contact1         = PO.BuyerName
                  ,  M_Address1        = PO.BuyerAddress1
                  ,  M_Address2        = PO.BuyerAddress2
                  ,  M_Address4      = PO.BuyerAddress4
                  ,  M_City      = PO.BuyerCity
                  ,  M_State      = PO.BuyerState
                  ,  C_Zip           = PO.BuyerZip
                  ,  M_Vat       = PO.BuyerVat
                  ,  Xdockpokey      = PO.ExternPOKey
                  ,  XDockFlag     = RH.XDockFlag
                  ,  DocType       = 'X'
                  ,  InterModalVehicle = RH.Containerkey

                  FROM  RECEIPT RH  (NOLOCK)
                  JOIN  RECEIPTDETAIL RD WITH (NOLOCK) ON (RH.ReceiptKey = RD.ReceiptKey)
                  JOIN  PO PO WITH (NOLOCK) ON  RD.Pokey = PO.Pokey
                  WHERE RD.ExternPOKey = @c_ExternPOKey
			            AND RD.ReceiptKey = @c_Receiptkey
               END               
            END

	        INSERT INTO #TMP_ORDDTL
            (  OrderKey
            ,  ExternLineNo
            ,  Storerkey
            ,  Sku
            ,  Packkey
            ,  UOM
            ,  OriginalQty
            ,  OpenQty
            ,  Lottable01
            ,  Lottable02
            ,  Lottable03
            ,  Lottable04
            ,  Lottable05
            ,  Userdefine02
            ,  POKey
            ,  ExternPOKey
            ,  Lottable06
            ,  Lottable07
            ,  Lottable08
            ,  Lottable09
            ,  Lottable10
            ,  Lottable11
            ,  Lottable12
            ,  Lottable13
            ,  Lottable14
            ,  Lottable15
            ) values (@c_Orderkey,  @c_ExternLineNo,@c_Storerkey,@c_Sku
                     , @c_Packkey, @c_UOM, @n_OriginalQty,@n_OpenQty,@c_Lottable01
                     ,@c_Lottable02, @c_Lottable03, @c_Lottable04, @c_Lottable05
                     , @c_UserDefine02, @c_POKey, @c_ExternPOKey,   @c_Lottable06
                     , @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10
                     , @c_Lottable11, @c_Lottable12, @c_Lottable13, @c_Lottable14
                     , @c_Lottable15)
            
            NEXT_RECD:

            FETCH NEXT FROM CUR_RECDET INTO @c_POKey, @c_ExternPOKey, @c_ExternLineNo, @c_Storerkey, @c_Sku, @c_Packkey, @c_UOM
                  , @n_OriginalQty,@n_OpenQty,@c_Lottable01,@c_Lottable02, @c_Lottable03,@c_Lottable04, @c_Lottable05
                  , @c_UserDefine02, @c_ExistingOrderKey, @c_ExistingOrderStatus, @c_Lottable06, @c_Lottable07, @c_Lottable08
                  , @c_Lottable09, @c_Lottable10, @c_Lottable11, @c_Lottable12, @c_Lottable13, @c_Lottable14, @c_Lottable15

         END
         CLOSE CUR_RECDET
         DEALLOCATE CUR_RECDET

         IF NOT EXISTS (SELECT 1
                        FROM #TMP_ORDDTL)
         BEGIN
            SET @n_Continue = 3
            GOTO QUIT_SP
         END
   END

   --Insert order to DB
   IF @n_continue IN(1,2)   
   BEGIN

      INSERT INTO ORDERS
      (  OrderKey
      ,  POKey
      ,  StorerKey
      ,  ExternOrderKey
      ,  BuyerPO
      ,  Type
      ,  OrderDate
      ,  C_Company
      ,  C_Address1
      ,  C_Address2
      ,  C_City
      ,  C_State
      ,  C_Zip
      ,  C_ISOCntryCode
      ,  C_Vat
      ,  Facility
      ,  CountryOfOrigin
      ,  CountryDestination
      ,  PrintDocDate
      ,  UserDefine01
      ,  UserDefine02
      ,  UserDefine06
      ,  UserDefine07
      ,  B_contact1
      ,  B_Contact2
      ,  B_Company
      ,  M_Contact1
      ,  M_Address1
      ,  M_Address2
      ,  M_Address4
      ,  M_City
      ,  M_State
      ,  M_Zip
      ,  M_Vat
      ,  xdockpokey
      ,  XDockFlag
      ,  DocType
      ,  IntermodalVehicle
      )
      SELECT
         OrderKey
      ,  POKey
      ,  StorerKey
      ,  ExternOrderKey
      ,  BuyerPO
      ,  Type
      ,  GETDATE()
      ,  C_Company
      ,  C_Address1
      ,  C_Address2
      ,  C_City
      ,  C_State
      ,  C_Zip
      ,  ISNULL(C_ISOCntryCode,'')
      ,  C_Vat
      ,  Facility
      ,  CountryOfOrigin
      ,  CountryDestination
      ,  GETDATE()
      ,  UserDefine01
      ,  UserDefine02
      ,  UserDefine06
      ,  UserDefine07
      ,  B_contact1
      ,  B_Contact2
      ,  B_Company
      ,  M_Contact1
      ,  M_Address1
      ,  M_Address2
      ,  M_Address4
      ,  M_City
      ,  M_State
      ,  M_Zip
      ,  M_Vat
      ,  Xdockpokey
      ,  XDockFlag
      ,  DocType
      ,  IntermodalVehicle
      FROM #TMP_ORD
      ORDER BY RowID

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 68010
         SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5),@n_Err)
                       + ': INSERT INTO ORDERS Table Failed. (mspASNFZ05)'
         GOTO QUIT_SP
      END
   
      INSERT INTO ORDERDETAIL
            (  Orderkey
            ,  OrderLineNumber
            ,  POKey
            ,  ExternLineNo
            ,  Storerkey
            ,  Sku
            ,  Packkey
            ,  UOM
            ,  OriginalQty
            ,  OpenQty
            ,  Lottable01
            ,  Lottable02
            ,  Lottable03
            ,  Lottable04
            ,  Lottable05
            ,  Userdefine02
            ,  ExternPOKey
            ,  Lottable06
            ,  Lottable07
            ,  Lottable08
            ,  Lottable09
            ,  Lottable10
            ,  Lottable11
            ,  Lottable12
            ,  Lottable13
            ,  Lottable14
            ,  Lottable15
            ,  ManufacturerSku
            ,  RetailSku
            ,  AltSku
            )
      SELECT td.Orderkey
            ,OrderLineNumber =  RIGHT('00000' + CONVERT(NVARCHAR(5),
                                 ROW_NUMBER() OVER ( PARTITION BY td.Orderkey
                                                   ORDER BY td.ExternLineNo
                                                            ,td.Sku)),5)
            ,td.POKey
            ,td.ExternLineNo
            ,td.Storerkey
            ,td.Sku
            ,td.Packkey
            ,td.UOM
            ,td.OriginalQty
            ,td.OpenQty
            ,td.Lottable01
            ,td.Lottable02
            ,td.Lottable03
            ,td.Lottable04
            ,td.Lottable05
            ,td.Userdefine02
            ,td.ExternPOKey
            ,td.Lottable06
            ,td.Lottable07
            ,td.Lottable08
            ,td.Lottable09
            ,td.Lottable10
            ,td.Lottable11
            ,td.Lottable12
            ,td.Lottable13
            ,td.Lottable14
            ,td.Lottable15
            ,ISNULL(s.ManufacturerSku,'')
            ,ISNULL(s.RetailSku,'')
            ,ISNULL(s.AltSku,'')
      FROM #TMP_ORDDTL td
          JOIN dbo.SKU s (NOLOCK) ON  td.Storerkey = s.Storerkey
          AND td.Sku = s.Sku

      ORDER BY td.ExternLineNo
              ,  td.Sku

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 68020
         SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5),@n_Err)
                       + ': INSERT INTO ORDERDETAIL Table Failed. (mspASNFZ05)'
         GOTO QUIT_SP
      END

      IF @c_RecType = 'XDELAY'
      BEGIN
         GOTO QUIT_SP
      END
      -- Adding for XDOCK ASN allocation
       EXEC [WM].[lsp_XDockAllocation_Wrapper]
       @c_ReceiptKey = @c_ReceiptKey,
       @b_Success    = @b_Success   OUTPUT,
       @n_Err        = @n_err       OUTPUT,
       @c_ErrMsg     = @c_errmsg  OUTPUT,
       @c_UserName   = ''

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5),@n_Err)
                       + ': XDOCK ASN Allocation Failed. (mspASNFZ05). ' + RTRIM(@c_ErrMsg)
         GOTO QUIT_SP
      END  
   END
   IF @n_continue IN(1,2)
    BEGIN
           SET @c_GetMBOLKey = ''
            IF ISNULL(@c_GetMBOLKey, '') = ''
            BEGIN
                SELECT @b_success = 0

                    EXECUTE nspg_GetKey
                                    'MBOL',
                                    10,
                                    @c_GetMBOLKey OUTPUT,
                                    @b_success    OUTPUT,
                                    @n_err        OUTPUT,
                                    @c_errmsg     OUTPUT


                                IF @b_success <> 1
                BEGIN
                    SET @n_continue = 3
                    SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(6), @n_Err) + 'OrderKey: '+ @c_Orderkey
                                                    + ': Error Executing nspg_GetKey - MBOLKey. (mspASNFZ05)'
                    GOTO QUIT_SP
                END

                INSERT INTO MBOL (MBOLKey, Facility, VesselQualifier, VoyageNumber,FinalizeFlag, ValidatedFlag, Route)
                VALUES (@c_GetMBOLKey, @c_Facility, 'VM', '99', 'N','N','99')

                SELECT @n_err = @@ERROR
                IF @n_err <> 0
                BEGIN
                SET @n_Continue = 3
                SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5),@n_Err)
                                  + ': INSERT INTO MBOL Table Failed. (mspASNFZ05)'
                GOTO QUIT_SP
                END

                UPDATE MBOL
                SET DepartureDate = GETDATE()
                  , TrafficCop    = NULL
                WHERE MbolKey = @c_GetMBOLKey

                SELECT @n_err = @@ERROR
                IF @n_err <> 0
                BEGIN
                SET @n_Continue = 3
                SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5),@n_Err)
                                  + ': UPDATE MBOL Table Failed. (mspASNFZ05)'
                GOTO QUIT_SP
                END
            END
        DECLARE CUR_ORD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
        SELECT O.Orderkey, OD.ExternPOKey
        FROM RECEIPT R (NOLOCK)
                 JOIN RECEIPTDETAIL RD (NOLOCK) ON R.Receiptkey = RD.Receiptkey
                 JOIN ORDERDETAIL OD (NOLOCK) ON OD.Storerkey = RD.Storerkey
            AND OD.ExternPOKey = RD.ExternPOKey
            AND OD.Sku = RD.Sku
                 JOIN ORDERS O (NOLOCK) ON OD.Orderkey = O.Orderkey
        WHERE R.Receiptkey = @c_Receiptkey
          AND O.Status <> '9'
        GROUP BY O.Orderkey
               ,OD.ExternPOKey

        OPEN CUR_ORD

        FETCH NEXT FROM CUR_ORD INTO @c_Orderkey, @c_ExternOrderkey

        WHILE @@FETCH_STATUS <> -1
        BEGIN

                SELECT @dt_OrderDate     = OH.OrderDate,
                       @dt_Delivery_Date = OH.DeliveryDate,
                       @c_Route          = OH.[Route],
                       @n_totweight      = SUM((OD.Qtyallocated + OD.QtyPicked + OD.ShippedQty) * SKU.StdGrossWgt),
                       @n_totcube        = SUM((OD.Qtyallocated + OD.QtyPicked + OD.ShippedQty) * SKU.StdCube),
                       @c_ExternOrderkey = OH.ExternOrderkey
                FROM ORDERS OH (NOLOCK)
                    JOIN Orderdetail OD WITH (NOLOCK) ON (OH.Orderkey = OD.Orderkey)
                    JOIN SKU WITH (NOLOCK) ON (OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku)
                WHERE OH.OrderKey = @c_Orderkey
                GROUP BY OH.OrderDate,OH.DeliveryDate,
                    OH.ExternOrderkey,
                    OH.Facility, OH.[Route]

                IF NOT EXISTS (SELECT 1 FROM MBOLDETAIL (NOLOCK) WHERE Orderkey = @c_Orderkey)
                BEGIN

                EXEC isp_InsertMBOLDetail
                                                 @cMBOLKey        = @c_GetMBOLKey,
                                                 @cFacility       = @c_Facility,
                                                 @cOrderKey       = @c_Orderkey,
                                                 @cLoadKey        = '',
                                                 @nStdGrossWgt    = @n_totweight,
                                                 @nStdCube        = @n_totcube,
                                                 @cExternOrderKey = @c_ExternOrderkey,
                                                 @dOrderDate      = @dt_OrderDate,
                                                 @dDelivery_Date  = @dt_Delivery_Date,
                                                 @cRoute          = @c_Route,
                                                 @b_Success       = @b_Success OUTPUT,
                                                 @n_err           = @n_err     OUTPUT,
                                                 @c_errmsg        = @c_errmsg  OUTPUT

                IF @n_err <> 0
                BEGIN
                    SET @n_Continue = 3
                    SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5),@n_Err)
                                  + ': Error Executing isp_InsertMBOLDetail. (mspASNFZ05). ' + RTRIM(@c_ErrMsg)
                    GOTO QUIT_SP
                END
            END
        FETCH NEXT FROM CUR_ORD INTO @c_Orderkey, @c_ExternOrderkey
        END
        CLOSE CUR_ORD
        DEALLOCATE CUR_ORD
    END


   QUIT_SP:
   
   --NJOW01 S
   IF @n_continue = 3 
   BEGIN
   	  IF @c_NewTran = 'Y'
   	  BEGIN
   	  	 IF @@TRANCOUNT > 0
   	  	 BEGIN
            ROLLBACK TRAN
         END
      END
      ELSE 
      BEGIN
      	 IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTranCount
      	 BEGIN
      	    ROLLBACK TRAN
      	 END
      END
      
      SET @b_success = 0
   END
   ELSE
   BEGIN
   	  IF @c_NewTran = 'Y'
   	  BEGIN
   	     WHILE @@TRANCOUNT > 0
         BEGIN  
            COMMIT TRAN  
         END  
   	  END
   	  ELSE
   	  BEGIN
   	     WHILE @@TRANCOUNT > @n_StartTranCount  
         BEGIN  
            COMMIT TRAN  
         END  
      END   
      SET @b_success = 1
   END
   
   WHILE @@TRANCOUNT < @n_StartTranCount 
   BEGIN  
      BEGIN TRAN  
   END
   RETURN
END
GO
GRANT EXECUTE ON [dbo].[mspASNFZ05] TO nSQL
GO


