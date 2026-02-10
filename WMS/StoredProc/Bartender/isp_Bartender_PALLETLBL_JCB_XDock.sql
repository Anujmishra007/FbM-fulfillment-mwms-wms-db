
/****** Object:  StoredProcedure [dbo].[isp_Bartender_PALLETLBL_JCB_XDock]    Script Date: 7/16/2025 10:22:45 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/******************************************************************************/
/* Copyright: MAERSK                                                          */
/* Purpose: isp_Bartender_PALLETLBL_JCB_XDock                                */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2024-01-26 1.0  SKE140     Created (------)                                */
/* 2024-04-30 1.1  SKE140     SSCC change to 20 digits                        */
/******************************************************************************/

ALTER     PROC [dbo].[isp_Bartender_PALLETLBL_JCB_XDock]
(  @c_Sparm01  NVARCHAR(250),
   @c_Sparm02  NVARCHAR(250),
   @c_Sparm03  NVARCHAR(250),
   @c_Sparm04  NVARCHAR(250),
   @c_Sparm05  NVARCHAR(250),
   @c_Sparm06  NVARCHAR(250),
   @c_Sparm07  NVARCHAR(250),
   @c_Sparm08  NVARCHAR(250),
   @c_Sparm09  NVARCHAR(250),
   @c_Sparm10  NVARCHAR(250),
   @b_debug    INT = 0
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @StorerKey      NVARCHAR(15)
   DECLARE @Company        NVARCHAR(45)
   DECLARE @SystemPO       NVARCHAR(30)
   DECLARE @Bu             NVARCHAR(30)
   DECLARE @SystemASN      NVARCHAR(30)
   DECLARE @InvoiceNo      NVARCHAR(30)
   DECLARE @SKU            NVARCHAR(20)
   DECLARE @SKUDescription NVARCHAR(60)
   DECLARE @PalletSeq      NVARCHAR(30)
   DECLARE @SupplierNo     NVARCHAR(20)
   DECLARE @cInvXRD        NVARCHAR(15)
   DECLARE @Receipt_date   NVARCHAR(10)
   DECLARE @Expiry_date    NVARCHAR(10)
   DECLARE @ToID           NVARCHAR(30)
   DECLARE @SupplierName   NVARCHAR(50)
   DECLARE @BUName         NVARCHAR(50)
   DECLARE @sscc           NVARCHAR(20)
   DECLARE @next_value     NVARCHAR(10),
           @digits         INT,
           @pos            INT,
           @check_digit    INT

   CREATE TABLE [#Result] (
      [ID]    [INT] IDENTITY(1,1) NOT NULL,
      [Col01] [NVARCHAR] (80) NULL,
      [Col02] [NVARCHAR] (80) NULL,
      [Col03] [NVARCHAR] (80) NULL,
      [Col04] [NVARCHAR] (80) NULL,
      [Col05] [NVARCHAR] (80) NULL,
      [Col06] [NVARCHAR] (80) NULL,
      [Col07] [NVARCHAR] (80) NULL,
      [Col08] [NVARCHAR] (80) NULL,
      [Col09] [NVARCHAR] (80) NULL,
      [Col10] [NVARCHAR] (80) NULL,
      [Col11] [NVARCHAR] (80) NULL,
      [Col12] [NVARCHAR] (80) NULL,
      [Col13] [NVARCHAR] (80) NULL,
      [Col14] [NVARCHAR] (80) NULL,
      [Col15] [NVARCHAR] (80) NULL,
      [Col16] [NVARCHAR] (80) NULL,
      [Col17] [NVARCHAR] (80) NULL,
      [Col18] [NVARCHAR] (80) NULL,
      [Col19] [NVARCHAR] (80) NULL,
      [Col20] [NVARCHAR] (80) NULL,
      [Col21] [NVARCHAR] (80) NULL,
      [Col22] [NVARCHAR] (80) NULL,
      [Col23] [NVARCHAR] (80) NULL,
      [Col24] [NVARCHAR] (80) NULL,
      [Col25] [NVARCHAR] (80) NULL,
      [Col26] [NVARCHAR] (80) NULL,
      [Col27] [NVARCHAR] (80) NULL,
      [Col28] [NVARCHAR] (80) NULL,
      [Col29] [NVARCHAR] (80) NULL,
      [Col30] [NVARCHAR] (80) NULL,
      [Col31] [NVARCHAR] (80) NULL,
      [Col32] [NVARCHAR] (80) NULL,
      [Col33] [NVARCHAR] (80) NULL,
      [Col34] [NVARCHAR] (80) NULL,
      [Col35] [NVARCHAR] (80) NULL,
      [Col36] [NVARCHAR] (80) NULL,
      [Col37] [NVARCHAR] (80) NULL,
      [Col38] [NVARCHAR] (80) NULL,
      [Col39] [NVARCHAR] (80) NULL,
      [Col40] [NVARCHAR] (80) NULL,
      [Col41] [NVARCHAR] (80) NULL,
      [Col42] [NVARCHAR] (80) NULL,
      [Col43] [NVARCHAR] (80) NULL,
      [Col44] [NVARCHAR] (80) NULL,
      [Col45] [NVARCHAR] (80) NULL,
      [Col46] [NVARCHAR] (80) NULL,
      [Col47] [NVARCHAR] (80) NULL,
      [Col48] [NVARCHAR] (80) NULL,
      [Col49] [NVARCHAR] (80) NULL,
      [Col50] [NVARCHAR] (80) NULL,
      [Col51] [NVARCHAR] (80) NULL,
      [Col52] [NVARCHAR] (80) NULL,
      [Col53] [NVARCHAR] (80) NULL,
      [Col54] [NVARCHAR] (80) NULL,
      [Col55] [NVARCHAR] (80) NULL,
      [Col56] [NVARCHAR] (80) NULL,
      [Col57] [NVARCHAR] (80) NULL,
      [Col58] [NVARCHAR] (80) NULL,
      [Col59] [NVARCHAR] (80) NULL,
      [Col60] [NVARCHAR] (80) NULL
   )

    IF EXISTS (SELECT 1 FROM dbo.LOTxLOCxID LLI WITH(NOLOCK) WHERE ID = @c_Sparm02 AND StorerKey = 'JCB' and qty > 0)
      BEGIN
         SET @cInvXRD = 'LLI' --Pallet is in the LOTxLOCxID table
         PRINT @cInvXRD
      END

   ELSE IF EXISTS (SELECT 1 FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK) WHERE StorerKey = 'JCB' AND ToId = @c_Sparm02)
      BEGIN
         SET @cInvXRD = 'RD' --Pallet is NOT in the LOTxLOCxID table but is in RECEIPTDETAIL
         PRINT @cInvXRD
      END

    IF @c_Sparm01 = ''
    BEGIN
        SELECT TOP 1 @c_Sparm01 = ReceiptKey 
        FROM RECEIPTDETAIL 
        WHERE ToId = @c_Sparm02;
    END
    
    IF @cInvXRD = 'RD' --If pallet is not in inventory but in receipt
      BEGIN
   SELECT TOP 1
      @StorerKey      = RD.StorerKey
      ,@SystemPO       = ISNULL(RD.POKey,'')
      ,@Bu             = ISNULL(RD.Lottable03,'')
	  ,@SupplierNo     = ISNULL(RD.Lottable08,'')
	  ,@InvoiceNo      = ISNULL(RD.Lottable09,'')
      ,@SystemASN      = ISNULL(@c_Sparm01,'')
      ,@ToID           = ISNULL(CONVERT(NVARCHAR(20),RD.ToID),'')
      ,@Receipt_date   = CONVERT(NVARCHAR(10), DateReceived, 111)
      ,@Expiry_date    = CONVERT(NVARCHAR(10), Lottable04, 111)
   FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK)
   INNER JOIN dbo.RECEIPT R WITH(NOLOCK) ON R.ReceiptKey = RD.ReceiptKey
   INNER JOIN dbo.SKU S WITH(NOLOCK) ON S.SKU = RD.SKU AND S.StorerKey = RD.StorerKey
   WHERE RD.ReceiptKey =  @c_Sparm01
   AND (RD.ToID = @c_Sparm02
      OR RD.ToID = SUBSTRING(@c_Sparm02, 10, 10)
   )

   SELECT TOP 1 @SupplierName = ISNULL(Company,'')
   FROM dbo.STORER ST(NOLOCK)
   WHERE St.Type='5' and ST.StorerKey = @SupplierNo
   
   SELECT TOP 1 @BUName = ISNULL([Description],'')
   FROM dbo.CODELKUP CD(NOLOCK)
   WHERE CD.LISTNAME = 'JCBPLANT#' and CD.SHORT=@Bu
   
   SELECT TOP 1 @Company = ISNULL(Company,'')
   FROM dbo.STORER ST(NOLOCK)
   WHERE ST.StorerKey = @StorerKey

   SELECT @PalletSeq = PALLET_SEQ
   FROM (
      SELECT ToID,DateReceived
         ,ROW_NUMBER() OVER(PARTITION BY Lottable09 ORDER BY DateReceived ASC,ReceiptLineNumber ASC) AS PALLET_SEQ
      FROM (
         SELECT ToID
            ,MIN(DateReceived) AS DateReceived
            ,MIN(ReceiptLineNumber) AS ReceiptLineNumber
            ,Lottable09
         FROM dbo.RECEIPTDETAIL RD (NOLOCK)
         WHERE RD.ReceiptKey =  @c_Sparm01
            AND Lottable09 = @InvoiceNo
            AND DateReceived > 0
            AND ToID IS NOT NULL
         GROUP BY Lottable09,ToID
      ) A
   ) B
   WHERE (ToID = @c_Sparm02
      OR ToID = SUBSTRING(@c_Sparm02, 10, 10)
   )
  

   INSERT INTO #Result (Col01,Col02,Col03,Col04,Col05, Col06,Col07,Col08,Col09,Col10
         ,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20
         ,Col21,Col22,Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30
         ,Col31,Col32,Col33,Col34,Col35,Col36,Col37,Col38,Col39,Col40
         ,Col41,Col42,Col43,Col44,Col45,Col46,Col47,Col48,Col49,Col50
         ,Col51,Col52,Col53,Col54,Col55,Col56,Col57,Col58,Col59,Col60)
   SELECT   ISNULL(@InvoiceNo,'') AS Col01
         ,ISNULL(@PalletSeq,'') AS Col02
         ,ISNULL(@Receipt_date,'') AS Col03
         ,ISNULL(@SupplierName,'') AS Col04
         ,ISNULL(@BUName,'') AS Col05
         ,ISNULL(@Bu,'') AS Col06
         ,ISNULL(CONVERT(NVARCHAR(20),@ToID),'') AS Col07
         ,ISNULL(@SystemASN,'') AS Col08
         ,ISNULL(@SystemPO,'') AS Col09
         ,ISNULL(@StorerKey,'') AS Col10
         ,ISNULL(@Expiry_date,'') AS Col11
         ,'' AS Col12
         ,'' AS Col13
         ,'' AS Col14,'' AS Col15,'' AS Col16,'' AS Col17,'' AS Col18,'' AS Col19,'' AS Col20
         ,'' AS Col21,'' AS Col22,'' AS Col23,'' AS Col24,'' AS Col25,'' AS Col26,'' AS Col27,'' AS Col28,'' AS Col29,'' AS Col30
         ,'' AS Col31,'' AS Col32,'' AS Col33,'' AS Col34,'' AS Col35,'' AS Col36,'' AS Col37,'' AS Col38,'' AS Col39,'' AS Col40
         ,'' AS Col41,'' AS Col42,'' AS Col43,'' AS Col44,'' AS Col45,'' AS Col46,'' AS Col47,'' AS Col48,'' AS Col49,'' AS Col50
         ,'' AS Col51,'' AS Col52,'' AS Col53,'' AS Col54,'' AS Col55,'' AS Col56,'' AS Col57,'' AS Col58,'' AS Col59,'' AS Col60

   SELECT * FROM #Result (nolock)
   END

   IF @cInvXRD = 'LLI' --If pallet is not in inventory but in receipt
      BEGIN
     
   SELECT TOP 1
      @StorerKey      = LD.StorerKey
      ,@SystemPO       = ISNULL(LA.lottable07,'')
      ,@Bu             = ISNULL(LA.Lottable03,'')
	  ,@SupplierNo     = ISNULL(LA.Lottable08,'')
	  ,@InvoiceNo      = ISNULL(LA.Lottable09,'')
      ,@SystemASN      = ISNULL(@c_Sparm01,'')
      ,@ToID           = ISNULL(CONVERT(NVARCHAR(20),LD.ID),'')
      ,@Receipt_date   = CONVERT(NVARCHAR(10), LA.Lottable05, 111)
      ,@Expiry_date    = CONVERT(NVARCHAR(10), LA.Lottable04, 111)
      ,@SupplierName   =  ISNULL(ST.Company,'')
      ,@BUName   =   ISNULL(CD.Description, '')
   FROM dbo.LOTxLOCxID LD WITH(NOLOCK)
      INNER JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON LD.lot = LA.lot AND LA.SKU = LD.SKU AND LD.Qty > 0
      INNER JOIN dbo.STORER ST WITH (NOLOCK) ON ST.Type = '5' AND ST.StorerKey = LA.Lottable08
      INNER JOIN dbo.CODELKUP CD WITH (NOLOCK) ON CD.LISTNAME = 'JCBPLANT#' AND CD.SHORT = LA.Lottable03
   WHERE  LD.ID = @c_Sparm02
   


   SELECT @PalletSeq = PALLET_SEQ
   FROM (
      SELECT ToID,DateReceived
         ,ROW_NUMBER() OVER(PARTITION BY Lottable09 ORDER BY DateReceived ASC,ReceiptLineNumber ASC) AS PALLET_SEQ
      FROM (
         SELECT ToID
            ,MIN(DateReceived) AS DateReceived
            ,MIN(ReceiptLineNumber) AS ReceiptLineNumber
            ,Lottable09
         FROM dbo.RECEIPTDETAIL RD (NOLOCK)
         WHERE RD.ReceiptKey =  @c_Sparm01
            AND Lottable09 = @InvoiceNo
            AND DateReceived > 0
            AND ToID IS NOT NULL
         GROUP BY Lottable09,ToID
      ) A
   ) B
   WHERE (ToID = @c_Sparm02
      OR ToID = SUBSTRING(@c_Sparm02, 10, 10)
   )
 

   INSERT INTO #Result (Col01,Col02,Col03,Col04,Col05, Col06,Col07,Col08,Col09,Col10
         ,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20
         ,Col21,Col22,Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30
         ,Col31,Col32,Col33,Col34,Col35,Col36,Col37,Col38,Col39,Col40
         ,Col41,Col42,Col43,Col44,Col45,Col46,Col47,Col48,Col49,Col50
         ,Col51,Col52,Col53,Col54,Col55,Col56,Col57,Col58,Col59,Col60)
   SELECT   ISNULL(@InvoiceNo,'') AS Col01
         ,ISNULL(@PalletSeq,'') AS Col02
         ,ISNULL(@Receipt_date,'') AS Col03
         ,ISNULL(@SupplierName,'') AS Col04
         ,ISNULL(@BUName,'') AS Col05
         ,ISNULL(@Bu,'') AS Col06
         ,ISNULL(CONVERT(NVARCHAR(20),@ToID),'') AS Col07
         ,ISNULL(@SystemASN,'') AS Col08
         ,ISNULL(@SystemPO,'') AS Col09
         ,ISNULL(@StorerKey,'') AS Col10
         ,ISNULL(@Expiry_date,'') AS Col11
         ,'' AS Col12
         ,'' AS Col13
         ,'' AS Col14,'' AS Col15,'' AS Col16,'' AS Col17,'' AS Col18,'' AS Col19,'' AS Col20
         ,'' AS Col21,'' AS Col22,'' AS Col23,'' AS Col24,'' AS Col25,'' AS Col26,'' AS Col27,'' AS Col28,'' AS Col29,'' AS Col30
         ,'' AS Col31,'' AS Col32,'' AS Col33,'' AS Col34,'' AS Col35,'' AS Col36,'' AS Col37,'' AS Col38,'' AS Col39,'' AS Col40
         ,'' AS Col41,'' AS Col42,'' AS Col43,'' AS Col44,'' AS Col45,'' AS Col46,'' AS Col47,'' AS Col48,'' AS Col49,'' AS Col50
         ,'' AS Col51,'' AS Col52,'' AS Col53,'' AS Col54,'' AS Col55,'' AS Col56,'' AS Col57,'' AS Col58,'' AS Col59,'' AS Col60

   SELECT * FROM #Result (nolock)
   END

EXIT_SP:

END -- procedure

