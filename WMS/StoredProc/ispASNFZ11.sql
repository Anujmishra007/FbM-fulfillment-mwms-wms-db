IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[ispASNFZ11]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[ispASNFZ11]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: ispASNFZ11                                            */
/* Creation Date: 18-Sep-2017                                              */
/* Copyright: LFL                                                          */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: WMS-2866 - CN PVH ASN finalize syncronize sku with other storer*/
/*                                                                         */
/* Called By:                                                              */
/*                                                                         */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 2019-01-10   CSCHONG 1.0   WMS-7547 (CS01)                              */
/***************************************************************************/  
CREATE PROC [dbo].[ispASNFZ11]  
(     @c_Receiptkey  NVARCHAR(10)   
  ,   @b_Success     INT           OUTPUT
  ,   @n_Err         INT           OUTPUT
  ,   @c_ErrMsg      NVARCHAR(255) OUTPUT   
  ,   @c_ReceiptLineNumber NVARCHAR(5)=''
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
      
   DECLARE @n_Continue       INT,
           @n_StartTranCount INT,
           @c_Storerkey      NVARCHAR(15),
           @c_Facility       NVARCHAR(5),
           @c_authority      NVARCHAR(30),
           @c_option1        NVARCHAR(50),
           @c_option2        NVARCHAR(50),
           @c_option3        NVARCHAR(50),
           @c_option4        NVARCHAR(50),
           @c_option5        NVARCHAR(4000),
           @c_Sku            NVARCHAR(20)

   --CS01 Start		   
   DECLARE  
           @n_StartTCnt             INT
         , @c_DocType               NVARCHAR(10)
         , @c_RecType               NVARCHAR(10)

         , @c_Packkey               NVARCHAR(10)
         , @c_UOM                   NVARCHAR(10)
         , @c_UDF10                 NVARCHAR(30)
         , @c_UDF02                 NVARCHAR(30)

         , @c_AdjustmentType        NVARCHAR(10)
         , @c_AdjustmentType1       NVARCHAR(10)
         , @c_AdjustmentType2       NVARCHAR(10)
         , @c_AdjustmentKeys        NVARCHAR(10)
         , @c_AdjustmentKey         NVARCHAR(10)

         , @c_AdjustmentLineNumber  NVARCHAR(5)
         , @c_ReasonCode            NVARCHAR(10)
         , @c_ShortReasonCode       NVARCHAR(10)
         , @c_OverReasonCode        NVARCHAR(10)
         , @c_Loc                   NVARCHAR(10)
         , @c_Lottable02            NVARCHAR(18)
         , @dt_Lottable05           DATETIME
         , @n_QtyExpected           INT
         , @n_QtyReceived           INT
         , @n_QtyVariance           INT

         , @n_KeyNo                 INT
         , @n_KeyNo1                INT
         , @n_KeyNo2                INT
         , @n_KeyLineNo             INT
         , @n_Cnt                   INT
         , @n_Batch                 INT
 
   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1
   SET @n_err      = 0
   SET @c_errmsg   = ''

   CREATE TABLE #TMP_ADJ
         (  KeyNo          INT            NOT NULL
         ,  AdjustmentKey  NVARCHAR(10)   NULL
         ,  AdjustmentType NVARCHAR(10)   NULL
         ,  Storerkey      NVARCHAR(15)   NULL
         ,  Facility       NVARCHAR(5)    NULL
         ,  UserDefine01   NVARCHAR(30)   NULL
         )

   CREATE TABLE #TMP_ADJDET
         (  KeyNo                INT            NOT NULL
         ,  AdjustmentKey        NVARCHAR(10)   NULL
         ,  AdjustmentLineNumber NVARCHAR(5)    NULL
         ,  Storerkey            NVARCHAR(15)   NULL
         ,  Sku                  NVARCHAR(20)   NULL
         ,  Packkey              NVARCHAR(10)   NULL
         ,  UOM                  NVARCHAR(10)   NULL
         ,  Lot                  NVARCHAR(10)   NULL
         ,  Loc                  NVARCHAR(10)   NULL
         ,  ID                   NVARCHAR(18)   NULL
         ,  Qty                  INT            NULL
         ,  ReasonCode           NVARCHAR(10)   NULL
         ,  Lottable05           DATETIME       NULL       
         )
      --CS01 End                               
   SELECT @b_Success = 1, @n_Err = 0, @c_ErrMsg = '', @n_Continue = 1, @n_StartTranCount = @@TRANCOUNT              

   IF @n_continue IN (1,2)
   BEGIN   	
   	  SELECT @c_Storerkey = R.Storerkey,
   	         @c_Facility = R.Facility
   	  FROM RECEIPT R (NOLOCK)
   	  WHERE R.Receiptkey = @c_Receiptkey
   	
   	  Execute nspGetRight 
              @c_facility,  
              @c_StorerKey,              
              '', -- @c_SKU,                    
              'PostFinalizeReceiptSP ', -- Configkey
              @b_success    OUTPUT,
              @c_authority  OUTPUT,
              @n_err        OUTPUT,
              @c_errmsg     OUTPUT,
              @c_option1    OUTPUT,  --other storer
              @c_option2    OUTPUT,  --other strategykey
              @c_option3    OUTPUT,  
              @c_option4    OUTPUT,  
              @c_option5    OUTPUT
              
      IF NOT EXISTS(SELECT 1 FROM STORER (NOLOCK) WHERE Storerkey = @c_Option1)
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 63500
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Invalid Storerkey of option1 (ispASNFZ11)' + ' ( '
                                + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
      END        
              
      IF NOT EXISTS(SELECT 1 FROM STRATEGY (NOLOCK) WHERE Strategykey = @c_Option2)
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 63510
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Invalid strategykey of option2 (ispASNFZ11)' + ' ( '
                                + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
      END        
   END

   IF @n_continue IN (1,2)
   BEGIN   	
      DECLARE CUR_RECEIPTDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT DISTINCT RD.Sku
         FROM RECEIPTDETAIL RD (NOLOCK)    	
         LEFT JOIN SKU (NOLOCK) ON RD.Sku = SKU.Sku AND SKU.Storerkey = @c_Option1     
         WHERE RD.Receiptkey = @c_Receiptkey
         AND RD.ReceiptLineNumber = CASE WHEN ISNULL(@c_ReceiptLineNumber,'') <> '' THEN @c_ReceiptLineNumber ELSE RD.ReceiptLineNumber END
         AND SKU.Sku IS NULL         
      
      OPEN CUR_RECEIPTDETAIL  
      FETCH NEXT FROM CUR_RECEIPTDETAIL INTO @c_Sku
      
      WHILE @@FETCH_STATUS = 0  AND @n_continue IN(1,2)
      BEGIN   
         INSERT INTO SKU
         (
         	StorerKey,
         	Sku,
         	DESCR,
         	SUSR1,
         	SUSR2,
         	SUSR3,
         	SUSR4,
         	SUSR5,
         	MANUFACTURERSKU,
         	RETAILSKU,
         	ALTSKU,
         	PACKKey,
         	STDGROSSWGT,
         	STDNETWGT,
         	STDCUBE,
         	TARE,
         	CLASS,
         	[ACTIVE],
         	SKUGROUP,
         	Tariffkey,
         	BUSR1,
         	BUSR2,
         	BUSR3,
         	BUSR4,
         	BUSR5,
         	LOTTABLE01LABEL,
         	LOTTABLE02LABEL,
         	LOTTABLE03LABEL,
         	LOTTABLE04LABEL,
         	LOTTABLE05LABEL,
         	NOTES1,
         	NOTES2,
         	PickCode,
         	StrategyKey,
         	CartonGroup,
         	PutCode,
         	PutawayLoc,
         	PutawayZone,
         	InnerPack,
         	[Cube],
         	GrossWgt,
         	NetWgt,
         	ABC,
         	CycleCountFrequency,
         	LastCycleCount,
         	ReorderPoint,
         	ReorderQty,
         	StdOrderCost,
         	CarryCost,
         	Price,
         	Cost,
         	ReceiptHoldCode,
         	ReceiptInspectionLoc,
         	OnReceiptCopyPackkey,
         	IOFlag,
         	TareWeight,
         	LotxIdDetailOtherlabel1,
         	LotxIdDetailOtherlabel2,
         	LotxIdDetailOtherlabel3,
         	AvgCaseWeight,
         	TolerancePct,
         	SkuStatus,
         	Length,
         	Width,
         	Height,
         	[weight],
         	itemclass,
         	ShelfLife,
         	Facility,
         	BUSR6,
         	BUSR7,
         	BUSR8,
         	BUSR9,
         	BUSR10,
         	ReturnLoc,
         	ReceiptLoc,
         	archiveqty,
         	XDockReceiptLoc,
         	PrePackIndicator,
         	PackQtyIndicator,
         	StackFactor,
         	IVAS,
         	OVAS,
         	Style,
         	Color,
         	[Size],
         	Measurement,
         	HazardousFlag,
         	TemperatureFlag,
         	ProductModel,
         	CtnPickQty,
         	CountryOfOrigin,
         	IB_UOM,
         	IB_RPT_UOM,
         	OB_UOM,
         	OB_RPT_UOM,
         	ABCPL,
         	ABCCS,
         	ABCEA,
         	DisableABCCalc,
         	ABCPeriod,
         	ABCStorerkey,
         	ABCSku,
         	--ABCExcludeSUSRNo,
         	--ABCExcludeSUSRValue,
         	OldStorerkey,
         	OldSku,
         	LOTTABLE06LABEL,
         	LOTTABLE07LABEL,
         	LOTTABLE08LABEL,
         	LOTTABLE09LABEL,
         	LOTTABLE10LABEL,
         	LOTTABLE11LABEL,
         	LOTTABLE12LABEL,
         	LOTTABLE13LABEL,
         	LOTTABLE14LABEL,
         	LOTTABLE15LABEL,
         	LottableCode,
         	ImageFolder,
         	OTM_SKUGroup,
         	Pressure,
         	SerialNoCapture
)
         SELECT 
         	@c_Option1,
         	Sku,
         	DESCR,
         	SUSR1,
         	SUSR2,
         	SUSR3,
         	SUSR4,
         	SUSR5,
         	MANUFACTURERSKU,
         	RETAILSKU,
         	ALTSKU,
         	PACKKey,
         	STDGROSSWGT,
         	STDNETWGT,
         	STDCUBE,
         	TARE,
         	CLASS,
         	[ACTIVE],
         	SKUGROUP,
         	Tariffkey,
         	BUSR1,
         	BUSR2,
         	BUSR3,
         	BUSR4,
         	BUSR5,
         	LOTTABLE01LABEL,
         	LOTTABLE02LABEL,
         	LOTTABLE03LABEL,
         	LOTTABLE04LABEL,
         	LOTTABLE05LABEL,
         	NOTES1,
         	NOTES2,
         	PickCode,
         	@c_Option2,
         	CartonGroup,
         	PutCode,
         	PutawayLoc,
         	PutawayZone,
         	InnerPack,
         	[Cube],
         	GrossWgt,
         	NetWgt,
         	ABC,
         	CycleCountFrequency,
         	LastCycleCount,
         	ReorderPoint,
         	ReorderQty,
         	StdOrderCost,
         	CarryCost,
         	Price,
         	Cost,
         	ReceiptHoldCode,
         	ReceiptInspectionLoc,
         	OnReceiptCopyPackkey,
         	IOFlag,
         	TareWeight,
         	LotxIdDetailOtherlabel1,
         	LotxIdDetailOtherlabel2,
         	LotxIdDetailOtherlabel3,
         	AvgCaseWeight,
         	TolerancePct,
         	SkuStatus,
         	Length,
         	Width,
         	Height,
         	[weight],
         	itemclass,
         	ShelfLife,
         	Facility,
         	BUSR6,
         	BUSR7,
         	BUSR8,
         	BUSR9,
         	BUSR10,
         	ReturnLoc,
         	ReceiptLoc,
         	archiveqty,
         	XDockReceiptLoc,
         	PrePackIndicator,
         	PackQtyIndicator,
         	StackFactor,
         	IVAS,
         	OVAS,
         	Style,
         	Color,
         	[Size],
         	Measurement,
         	HazardousFlag,
         	TemperatureFlag,
         	ProductModel,
         	CtnPickQty,
         	CountryOfOrigin,
         	IB_UOM,
         	IB_RPT_UOM,
         	OB_UOM,
         	OB_RPT_UOM,
         	ABCPL,
         	ABCCS,
         	ABCEA,
         	DisableABCCalc,
         	ABCPeriod,
         	ABCStorerkey,
         	ABCSku,
         	--ABCExcludeSUSRNo,
         	--ABCExcludeSUSRValue,
         	OldStorerkey,
         	OldSku,
         	LOTTABLE06LABEL,
         	LOTTABLE07LABEL,
         	LOTTABLE08LABEL,
         	LOTTABLE09LABEL,
         	LOTTABLE10LABEL,
         	LOTTABLE11LABEL,
         	LOTTABLE12LABEL,
         	LOTTABLE13LABEL,
         	LOTTABLE14LABEL,
         	LOTTABLE15LABEL,
         	LottableCode,
         	ImageFolder,
         	OTM_SKUGroup,
         	Pressure,
         	SerialNoCapture
         FROM SKU (NOLOCK)
         WHERE Storerkey = @c_Storerkey
         AND Sku = @c_Sku 	

         SELECT @n_err = @@ERROR
         IF  @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 63510
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert SKU Table Failed! (ispASNFZ11)' + ' ( '
                                   + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
         END
            	         	        
         FETCH NEXT FROM CUR_RECEIPTDETAIL INTO @c_Sku
      END
      CLOSE CUR_RECEIPTDETAIL  
      DEALLOCATE CUR_RECEIPTDETAIL                                              	  
   END        
   
   --CS01 Start
   SET @c_Facility = ''
   SET @c_Storerkey= ''
   SET @c_DocType  = ''
   SET @c_RecType  = ''
   SET @c_UDF10 = ''
   SET @c_UDF02 = ''
  
   SELECT @c_Facility = RECEIPT.Facility
         ,@c_Storerkey= RECEIPT.Storerkey
         ,@c_DocType  = RECEIPT.DocType
         ,@c_RecType  = RECEIPT.RecType
		 ,@c_UDF10    = RECEIPT.userdefine10
		 ,@c_UDF02    = RECEIPT.userdefine02
   FROM   RECEIPT WITH (NOLOCK)
   WHERE  RECEIPT.ReceiptKey = @c_ReceiptKey
   AND    RECEIPT.DocType = 'R'
   AND    RECEIPT.userdefine02='TU'
   --AND    RECEIPT.RecType = 'RTN'

   IF @c_DocType <> 'R'
   BEGIN
      GOTO QUIT_SP
   END 
    
   IF @c_RecType = 'NIF'
   BEGIN
      GOTO QUIT_SP
   END 

   IF @c_UDF02 <> 'TU'
   BEGIN
      GOTO QUIT_SP
   END

   SET @c_Loc = ''
   SELECT @c_Loc = FACILITY.UserDefine04
   FROM FACILITY WITH (NOLOCK)
   WHERE Facility = @c_Facility

   IF EXISTS ( SELECT 1
               FROM   RECEIPTDETAIL WITH (NOLOCK)  
               WHERE  RECEIPTDETAIL.ReceiptKey = @c_ReceiptKey
               AND    RECEIPTDETAIL.QtyExpected <> RECEIPTDETAIL.QtyReceived
             )
   BEGIN  
      SET @c_AdjustmentType = ''
      SELECT TOP 1 @c_AdjustmentType1 = SUBSTRING(Code,3,28)
      FROM CODELKUP WITH (NOLOCK)
      WHERE ListName = 'NONADJITF'
      AND   Storerkey = @c_Storerkey

      SET @c_Lottable02 = '' 
      SET @c_AdjustmentType2 = '001'
	  
	  SET @c_ReasonCode = ''
      SELECT TOP 1 @c_ReasonCode = long
      FROM CODELKUP WITH (NOLOCK)
      WHERE ListName = 'ASN2ADJ'
      AND   Storerkey = @c_Storerkey
	  AND short  = @c_DocType
	  and Codelkup.UDF01 = @c_UDF10
      
   END

   WHILE @@TRANCOUNT > 0
   BEGIN
      COMMIT TRAN
   END

    BEGIN TRAN 

   SET @n_KeyNo = -1
   DECLARE CUR_RECDET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT KeyLineNo = ROW_NUMBER() OVER (PARTITION BY RECEIPTDETAIL.ReceiptKey
                                        , CASE WHEN RECEIPTDETAIL.QtyExpected > RECEIPTDETAIL.QtyReceived THEN 0 
                                          WHEN RECEIPTDETAIL.QtyExpected < RECEIPTDETAIL.QtyReceived THEN 5
                                          ELSE 9 END 
                                          ORDER BY 
                                          CASE WHEN RECEIPTDETAIL.QtyExpected > RECEIPTDETAIL.QtyReceived THEN 0 
                                               WHEN RECEIPTDETAIL.QtyExpected < RECEIPTDETAIL.QtyReceived THEN 5
                                               ELSE 9 END)
         ,RECEIPTDETAIL.Sku
         ,RECEIPTDETAIL.Packkey
         ,RECEIPTDETAIL.UOM
         ,RECEIPTDETAIL.QtyExpected
         ,RECEIPTDETAIL.QtyReceived
   FROM   RECEIPTDETAIL WITH (NOLOCK)  
   WHERE  RECEIPTDETAIL.ReceiptKey = @c_ReceiptKey
   ORDER BY CASE WHEN RECEIPTDETAIL.QtyExpected > RECEIPTDETAIL.QtyReceived THEN 0 
                 WHEN RECEIPTDETAIL.QtyExpected < RECEIPTDETAIL.QtyReceived THEN 5
                 ELSE 9 END

   OPEN CUR_RECDET
   
   FETCH NEXT FROM CUR_RECDET INTO  @n_KeyLineNo
                                 ,  @c_Sku
                                 ,  @c_Packkey
                                 ,  @c_UOM
                                 ,  @n_QtyExpected
                                 ,  @n_QtyReceived
                                  

   WHILE @@FETCH_STATUS <> -1
   BEGIN

      SET @n_QtyVariance = 0
      IF @n_QtyExpected > @n_QtyReceived
      BEGIN
         SET @n_QtyVariance = @n_QtyExpected - @n_QtyReceived
         SET @c_AdjustmentType= @c_AdjustmentType1
         --SET @c_ReasonCode = @c_ShortReasonCode
      END
      ELSE 
      BEGIN
         SET @n_QtyVariance = @n_QtyReceived - @n_QtyExpected
         SET @c_AdjustmentType= @c_AdjustmentType2
         --SET @c_ReasonCode = @c_OverReasonCode
      END

      SET @n_Cnt = 1
      IF @n_QtyVariance > 0 
      BEGIN
         WHILE @n_Cnt <= 2
         BEGIN 
            IF @n_KeyLineNo = 1
            BEGIN
               SET @n_KeyNo = @n_KeyNo + 1
               IF @n_Cnt = 1
               BEGIN

                  SET @n_KeyNo1 = @n_KeyNo
               END
               ELSE
               BEGIN
                  SET @n_KeyNo2 = @n_KeyNo 
                  SET @c_AdjustmentType = CASE WHEN @c_AdjustmentType = @c_AdjustmentType1 THEN @c_AdjustmentType2 
                                               WHEN @c_AdjustmentType = @c_AdjustmentType2 THEN @c_AdjustmentType1 
                                               END
				  --SET @c_AdjustmentType = @c_AdjustmentType1
               END

               INSERT INTO #TMP_ADJ
               (  KeyNo
               ,  AdjustmentType
               ,  StorerKey
               ,  Facility
               ,  UserDefine01
               )
               VALUES 
               (  @n_KeyNo
               ,  @c_AdjustmentType
               ,  @c_Storerkey
               ,  @c_Facility
               ,  @c_ReceiptKey
               )
               SET @n_err = @@ERROR
               IF @n_err <> 0
               BEGIN
                  SET @n_continue = 3
                  SET @n_err = 60020  
                  SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Insert into #TMP_ADJ Table. (ispASNFZ11)' 
                                 + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) ' 
                  GOTO QUIT_SP
               END


            END

            IF @n_Cnt = 1
            BEGIN
               SET @n_KeyNo = @n_KeyNo1
            END
            ELSE
            BEGIN
               SET @n_KeyNo = @n_KeyNo2
               SET @n_QtyVariance = @n_QtyVariance * - 1
            END 

            SET @c_AdjustmentLineNumber = RIGHT('00000' + CONVERT (NVARCHAR(5), @n_KeyLineNo),5)

            INSERT INTO #TMP_ADJDET
               (  KeyNo
               ,  AdjustmentLineNumber
               ,  StorerKey
               ,  Sku
               ,  Packkey
               ,  UOM
               ,  Lot
               ,  Loc
               ,  Id
               ,  Qty
               ,  ReasonCode
               ,  Lottable05
               )
            VALUES 
               (  @n_KeyNo
               ,  @c_AdjustmentLineNumber
               ,  @c_StorerKey
               ,  @c_Sku
               ,  @c_Packkey
               ,  @c_UOM
               ,  ''
               ,  @c_Loc
               ,  ''
               ,  @n_QtyVariance
               ,  @c_ReasonCode
               ,  CONVERT(NVARCHAR(10), GETDATE(), 112)
               )
                 
            SET @n_err = @@ERROR
            IF @n_err <> 0
            BEGIN
               SET @n_continue = 3
               SET @n_err = 60030  
               SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Insert into #TMP_ADJDET Table. (ispASNFZ11)' 
                              + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) ' 
               GOTO QUIT_SP
            END

            SET @n_Cnt = @n_Cnt + 1
         END
      END

      FETCH NEXT FROM CUR_RECDET INTO  @n_KeyLineNo
                                    ,  @c_Sku
                                    ,  @c_Packkey
                                    ,  @c_UOM
                                    ,  @n_QtyExpected
                                    ,  @n_QtyReceived 
   END
   CLOSE CUR_RECDET
   DEALLOCATE CUR_RECDET      

   SET @n_batch = 0
   SELECT @n_batch = COUNT(1)
   FROM #TMP_ADJ

   IF @n_batch > 0
   BEGIN
      SET @c_AdjustmentKeys = ''
      EXECUTE nspg_GetKey 
              @KeyName     = 'ADJUSTMENT'
            , @fieldlength = 10
            , @keystring   = @c_AdjustmentKey   OUTPUT
            , @b_success   = @b_success         OUTPUT
            , @n_err       = @n_err             OUTPUT
            , @c_errmsg    = @c_errmsg          OUTPUT
            , @b_resultset = 0
            , @n_batch     = @n_Batch
   
      IF @b_success <> 1
      BEGIN
         SET @n_continue = 3                                                                                              
         SET @n_err = 60040                                                                                               
         SET @c_errmsg='NSQL'+ CONVERT(CHAR(5),@n_err)+': Error Executing nspg_GetKey. (ispASNFZ11)' 
                        + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ).'                                  
         GOTO QUIT_SP        
      END

      UPDATE #TMP_ADJ 
         SET AdjustmentKey = RIGHT('0000000000' + CONVERT(NVARCHAR(10), CONVERT(INT, @c_AdjustmentKey) + KeyNo),10)

      SET @n_err = @@ERROR
      IF @n_err <> 0
      BEGIN
         SET @n_continue = 3
         SET @n_err = 60050  
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Update ##TMP_ADJ Table. (ispASNFZ11)' 
                        + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) ' 
         GOTO QUIT_SP
      END

      UPDATE #TMP_ADJDET 
         SET AdjustmentKey = RIGHT('0000000000' + CONVERT(NVARCHAR(10), CONVERT(INT, @c_AdjustmentKey) + KeyNo),10)

      SET @n_err = @@ERROR
      IF @n_err <> 0
      BEGIN
         SET @n_continue = 3
         SET @n_err = 60060  
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Update #TMP_ADJDET Table. (ispASNFZ11)' 
                        + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) ' 
         GOTO QUIT_SP
      END

      DECLARE CUR_ADJ CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT Adjustmentkey
      FROM   #TMP_ADJ  
      ORDER BY Adjustmentkey

      OPEN CUR_ADJ
   
      FETCH NEXT FROM CUR_ADJ INTO @c_Adjustmentkey
      WHILE @@FETCH_STATUS <> -1
      BEGIN
         INSERT INTO ADJUSTMENT
            (  AdjustmentKey
            ,  AdjustmentType
            ,  StorerKey
            ,  Facility
            ,  UserDefine01
            )
         SELECT 
               Adjustmentkey
            ,  AdjustmentType
            ,  Storerkey
            ,  Facility
            ,  UserDefine01
         FROM #TMP_ADJ
         WHERE Adjustmentkey = @c_Adjustmentkey

         SET @n_err = @@ERROR
         IF @n_err <> 0
         BEGIN
            SET @n_continue = 3
            SET @n_err = 60070  
            SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Insert into ADJUSTMENT Table. (ispASNFZ11)' 
                           + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) ' 
            GOTO QUIT_SP
         END

         INSERT INTO ADJUSTMENTDETAIL
            (  Adjustmentkey
            ,  AdjustmentLineNumber
            ,  StorerKey
            ,  Sku
            ,  Packkey
            ,  UOM
            ,  Lot
            ,  Loc
            ,  Id
            ,  Qty
            ,  ReasonCode
            ,  Lottable05
            )
         SELECT  
               AdjustmentKey
            ,  AdjustmentLineNumber
            ,  StorerKey
            ,  Sku
            ,  Packkey
            ,  UOM
            ,  Lot
            ,  Loc
            ,  Id
            ,  Qty
            ,  ReasonCode
            ,  Lottable05
         FROM #TMP_ADJDET
         WHERE Adjustmentkey = @c_Adjustmentkey  
         ORDER BY AdjustmentLineNumber       
                 
         SET @n_err = @@ERROR
         IF @n_err <> 0
         BEGIN
            SET @n_continue = 3
            SET @n_err = 60080  
            SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Insert into ADJUSTMENTDETAIL Table. (ispASNFZ11)' 
                           + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) ' 
            GOTO QUIT_SP
         END

         FETCH NEXT FROM CUR_ADJ INTO @c_Adjustmentkey
      END 
      CLOSE CUR_ADJ
      DEALLOCATE CUR_ADJ
   END

   WHILE @@TRANCOUNT > 0 
   BEGIN
      COMMIT TRAN
   END        

   DECLARE CUR_ADJ CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT Adjustmentkey
   FROM   #TMP_ADJ  
   ORDER BY Adjustmentkey

   OPEN CUR_ADJ
   
   FETCH NEXT FROM CUR_ADJ INTO @c_Adjustmentkey
   WHILE @@FETCH_STATUS <> -1
   BEGIN
      EXECUTE isp_FinalizeADJ
               @c_ADJKey   = @c_AdjustmentKey
            ,  @b_Success  = @b_Success OUTPUT 
            ,  @n_err      = @n_err     OUTPUT 
            ,  @c_errmsg   = @c_errmsg  OUTPUT   

      IF @n_err <> 0  
      BEGIN 
         SET @n_continue= 3 
         SET @n_err  = 60090
         SET @c_errmsg = 'NSQL'+ CONVERT(CHAR(5),@n_err)+': Execute isp_FinalizeADJ Failed. (ispASNFZ11)'
         GOTO QUIT_SP 
      END
      
      SET @n_Cnt = 0

      SELECT @n_Cnt = 1
      FROM ADJUSTMENTDETAIL WITH (NOLOCK)
      WHERE AdjustmentKey = @c_AdjustmentKey
      AND FinalizedFlag <> 'Y'

      IF @n_Cnt = 0
      BEGIN          
         UPDATE ADJUSTMENT WITH (ROWLOCK)
         SET FinalizedFlag = 'Y'
         WHERE AdjustmentKey = @c_AdjustmentKey


         IF @n_err <> 0  
         BEGIN 
            SET @n_continue= 3 
            SET @n_err  = 60090
            SET @c_errmsg = 'NSQL'+ CONVERT(CHAR(5),@n_err)+': Execute isp_FinalizeADJ Failed. (ispASNFZ11)'
            GOTO QUIT_SP 
         END
      END

      FETCH NEXT FROM CUR_ADJ INTO @c_Adjustmentkey
   END 
   CLOSE CUR_ADJ
   DEALLOCATE CUR_ADJ
   --CS01 End	   	   	   
   QUIT_SP:

   IF CURSOR_STATUS( 'LOCAL', 'CUR_RECDET') in (0 , 1)  
   BEGIN
      CLOSE CUR_RECDET
      DEALLOCATE CUR_RECDET
   END


   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT > @n_StartTCnt AND @@TRANCOUNT = 1
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ispASNFZ11'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END 
    
END
GO

GRANT EXECUTE ON [dbo].[ispASNFZ11] TO nSQL 
GO
