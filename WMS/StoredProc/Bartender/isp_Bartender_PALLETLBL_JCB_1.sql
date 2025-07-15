
/****** Object:  StoredProcedure [dbo].[isp_Bartender_PALLETLBL_JCB_1]    Script Date: 7/10/2025 4:27:01 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/******************************************************************************/
/* Copyright: MAERSK                                                          */
/* Purpose: isp_Bartender_PALLETLBL_JCB_0.1                                   */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2024-01-26 1.0  SKE140     Created (SKE140)                                */
/* 2024-04-30 1.1  SKE140     SSCC change to 20 digits                        */
/******************************************************************************/

CREATE OR ALTER   PROCEDURE [dbo].[isp_Bartender_PALLETLBL_JCB_1]
   @c_Sparm01 NVARCHAR(50),  -- ReceiptKey
   @c_Sparm02 NVARCHAR(50),   -- ID filter
   @c_Sparm03  NVARCHAR(250),
   @c_Sparm04  NVARCHAR(250),
   @c_Sparm05  NVARCHAR(250),
   @c_Sparm06  NVARCHAR(250),
   @c_Sparm07  NVARCHAR(250),
   @c_Sparm08  NVARCHAR(250),
   @c_Sparm09  NVARCHAR(250),
   @c_Sparm10  NVARCHAR(250),
   @b_debug    INT = 0

AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @c_SQL NVARCHAR(4000),
      @n_TotalRecord INT,
      @n_TotalPage INT,
      @n_CurrentPage INT = 1,
      --@n_PageSize INT = 5,
      @n_PageSize INT = 2,
      @n_loopno INT = 1,
      @cStorerKey NVARCHAR(15),
      @cInvXRD NVARCHAR(15),
      @cToID NVARCHAR(30),
      @c_SKU01 NVARCHAR(50), @c_SKUQTY01 NVARCHAR(50), @c_SKUDESCR01 NVARCHAR(255), @c_Serial01 NVARCHAR(50), @c_Style01 NVARCHAR(50),
      @c_SKU02 NVARCHAR(50), @c_SKUQTY02 NVARCHAR(50), @c_SKUDESCR02 NVARCHAR(255), @c_Serial02 NVARCHAR(50), @c_Style02 NVARCHAR(50),
      @StorerKey NVARCHAR(50), @SupplierNo NVARCHAR(50), @SupplierName NVARCHAR(100), @InvoiceNo NVARCHAR(50),
      @Receipt_date NVARCHAR(10), @Bu NVARCHAR(50), @BUName NVARCHAR(100), @ID NVARCHAR(20), @TotalWeight FLOAT,
      @n_copy                 INT,
      @n_copyDefault          INT,
      @addwho NVARCHAR(50)

   SET @n_TotalPage = 1
   SET @n_CurrentPage = 1
   -- Assign parameters
   SET @cStorerKey = 'JCB'
   SET @cToID = @c_Sparm02


   IF @c_Sparm01 = ''
   BEGIN
      SELECT TOP 1 @c_Sparm01 = ReceiptKey 
      FROM RECEIPTDETAIL 
      WHERE ToId = @c_Sparm02;
   END

   select top 1 @addwho = UPPER(UserName)  from rdt.RDTMOBREC (NOLOCK) where Mobile = @c_Sparm03
   
   -- Temp data table
   DECLARE @TEMPDATA TABLE (
      ID INT IDENTITY(1,1) PRIMARY KEY,
      StorerKey NVARCHAR(50),
      SupplierNo NVARCHAR(50),
      SupplierName NVARCHAR(500),
      InvoiceNo NVARCHAR(50),
      Bu NVARCHAR(50),
      ToID NVARCHAR(50),
      ReceiptDate NVARCHAR(10),
      --TotalWeight NVARCHAR(20),
      TotalWeight FLOAT,              -- Now FLOAT
      BUName NVARCHAR(50),
      SKU NVARCHAR(50),
      Description NVARCHAR(255),
      Serial NVARCHAR(50),
      Style NVARCHAR(50),
      Qty FLOAT
   )

   -- Result temp table (adjust columns count as per your needs)
   -- Final result table (Col60 remains)
   IF OBJECT_ID('tempdb..#Result1') IS NOT NULL DROP TABLE #Result1;
   CREATE TABLE #Result1 (
      ID INT IDENTITY(1,1) PRIMARY KEY,
      Col01 NVARCHAR(80), Col02 NVARCHAR(80), Col03 NVARCHAR(80), Col04 NVARCHAR(80),
      Col05 NVARCHAR(80), Col06 NVARCHAR(80), Col07 NVARCHAR(80), Col08 NVARCHAR(80),
      Col09 NVARCHAR(80), Col10 NVARCHAR(80), Col11 NVARCHAR(80), Col12 NVARCHAR(80),
      Col13 NVARCHAR(80), Col14 NVARCHAR(80), Col15 NVARCHAR(80), Col16 NVARCHAR(80),
      Col17 NVARCHAR(80), Col18 NVARCHAR(80), Col19 NVARCHAR(80), Col20 NVARCHAR(80),
      Col21 NVARCHAR(80), Col22 NVARCHAR(80), Col23 NVARCHAR(80), Col24 NVARCHAR(80),
      Col25 NVARCHAR(80), Col26 NVARCHAR(80), Col27 NVARCHAR(80), Col28 NVARCHAR(80),
      Col29 NVARCHAR(80), Col30 NVARCHAR(80), Col31 NVARCHAR(80), Col32 NVARCHAR(80),
      Col33 NVARCHAR(80), Col34 NVARCHAR(80), Col35 NVARCHAR(80), Col36 NVARCHAR(80),
      Col37 NVARCHAR(80), Col38 NVARCHAR(80), Col39 NVARCHAR(80), Col40 NVARCHAR(80),
      Col41 NVARCHAR(80), Col42 NVARCHAR(80), Col43 NVARCHAR(80), Col44 NVARCHAR(80),
      Col45 NVARCHAR(80), Col46 NVARCHAR(80), Col47 NVARCHAR(80), Col48 NVARCHAR(80),
      Col49 NVARCHAR(80), Col50 NVARCHAR(80), Col51 NVARCHAR(80), Col52 NVARCHAR(80),
      Col53 NVARCHAR(80), Col54 NVARCHAR(80), Col55 NVARCHAR(80), Col56 NVARCHAR(80),
      Col57 NVARCHAR(80), Col58 NVARCHAR(80), Col59 NVARCHAR(80), Col60 NVARCHAR(80)
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

   IF @cInvXRD = 'RD' --If pallet is not in inventory but in receipt
      BEGIN
         -- Get header info from first matching row
         -- Load actual data
         INSERT INTO @TEMPDATA (
            StorerKey, SupplierNo, SupplierName, InvoiceNo, Bu, ToID,
            ReceiptDate, TotalWeight, BUName, SKU, Description, Serial, Style, Qty
         )
         SELECT DISTINCT
            StorerKey,
            Lottable08,
            Company,
            Lottable09,
            Lottable03,
            ToID,
            ReceiptDate,
            STDGROSSWGT,
            Description,
            SKU,
            Descr,
            Lottable01,
            Style,
            QtyReceived
         FROM (
            SELECT
               RD.StorerKey,
               ISNULL(RD.Lottable08, '') Lottable08,
               ISNULL(ST.Company, '') Company,
               ISNULL(RD.Lottable09, '') Lottable09,
               ISNULL(RD.Lottable03, '') Lottable03,
               ISNULL(CAST(RD.ToID AS NVARCHAR(20)), '') ToID,
               CONVERT(NVARCHAR(10), R.ReceiptDate, 111) ReceiptDate,
               CAST(RD.BeforeReceivedQty * s.STDGROSSWGT AS FLOAT) AS STDGROSSWGT,
               ISNULL(CD.Description, '') Description,
               S.SKU SKU,
               S.Descr Descr,
               RD.Lottable01 Lottable01,
               S.Style Style,
               RD.BeforeReceivedQty QtyReceived
            FROM dbo.RECEIPTDETAIL RD WITH (NOLOCK)
            JOIN dbo.RECEIPT R WITH (NOLOCK) ON R.ReceiptKey = RD.ReceiptKey
            JOIN dbo.SKU S WITH (NOLOCK) ON S.SKU = RD.SKU AND S.StorerKey = RD.StorerKey
            JOIN dbo.STORER ST WITH (NOLOCK) ON ST.Type = '5' AND ST.StorerKey = RD.Lottable08
            JOIN dbo.CODELKUP CD WITH (NOLOCK) ON CD.LISTNAME = 'JCBPLANT#' AND CD.SHORT = RD.Lottable03
            WHERE RD.ReceiptKey = @c_Sparm01
              AND (RD.ToID = @c_Sparm02 OR RD.ToID = SUBSTRING(@c_Sparm02, 10, 10))
         ) T1;
      END

   IF @cInvXRD = 'LLI' --If pallet is in inventory
      BEGIN
         INSERT INTO @TEMPDATA (
            StorerKey, SupplierNo, SupplierName, InvoiceNo, Bu, ToID,
            ReceiptDate, TotalWeight, BUName, SKU, Description, Serial, Style, Qty
         )
         SELECT DISTINCT
            StorerKey,
            Lottable08,
            Company,
            Lottable09,
            Lottable03,
            ToID,
            ReceiptDate,
            STDGROSSWGT,
            Description,
            SKU,
            Descr,
            Lottable01,
            Style,
            QtyReceived
         FROM (
            SELECT
               LD.StorerKey,
               ISNULL(LA.Lottable08, '') Lottable08,
               ISNULL(ST.Company, '') Company,
               ISNULL(LA.Lottable09, '') Lottable09,
               ISNULL(LA.Lottable03, '') Lottable03,
               ISNULL(CAST(LD.ID AS NVARCHAR(20)), '') ToID,
               CONVERT(NVARCHAR(10), LA.Lottable05, 111) ReceiptDate,
               CAST(LD.qty * S.STDGROSSWGT AS FLOAT) AS STDGROSSWGT,
               ISNULL(CD.Description, '') Description,
               S.SKU SKU,
               S.Descr Descr,
               LA.Lottable01 Lottable01,
               S.Style Style,
               LD.qty QtyReceived
            FROM dbo.LOTxLOCxID LD WITH (NOLOCK)
            --INNER JOIN dbo.RECEIPT R WITH (NOLOCK) ON R.ReceiptKey = RD.ReceiptKey
            INNER JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK) ON LD.lot = LA.lot AND LA.SKU = LD.SKU AND LD.Qty > 0
            INNER JOIN dbo.SKU S WITH (NOLOCK) ON S.SKU = LD.SKU AND S.StorerKey = LD.StorerKey
            INNER JOIN dbo.STORER ST WITH (NOLOCK) ON ST.Type = '5' AND ST.StorerKey = LA.Lottable08
            INNER JOIN dbo.CODELKUP CD WITH (NOLOCK) ON CD.LISTNAME = 'JCBPLANT#' AND CD.SHORT = LA.Lottable03
            WHERE  (LD.ID = @c_Sparm02)
         ) T1;
      END

   --Get @n_TotalRecord
   SELECT @n_TotalRecord = COUNT(0) FROM @TEMPDATA

   --Get @n_TotalPage
   SELECT @n_TotalPage = Ceiling(1.0 * @n_TotalRecord / @n_PageSize)
   --print @n_TotalPage

   WHILE @n_loopno <= @n_TotalRecord
      BEGIN
         --Create a new line with generic fields
         IF NOT EXISTS (SELECT 1 FROM #Result1 WHERE Col10 = @n_CurrentPage)
            BEGIN
               INSERT INTO #Result1 (
                  Col01, Col02, Col03, Col04, Col05, Col06, Col07, Col08, Col09, Col10, Col11, Col12, Col13
               )
               SELECT
                  StorerKey,
                  SupplierNo,
                  SupplierName,
                  InvoiceNo,
                  Bu,
                  ToID,
                  ReceiptDate,
                  (SELECT CAST(CAST((SELECT SUM(TotalWeight) FROM @TEMPDATA WHERE ToID = @cToID) AS DECIMAL(18, 2)) AS NVARCHAR(20)) + ' KG') AS TotalWeight,
                  BUName,
                  @n_CurrentPage,
                  @n_TotalPage,
                  ToID,
                  @addwho --10,11,12,13
               FROM @TEMPDATA
               WHERE ID = @n_loopno
            END

         --Prepare SKU data, 2 SKUs per label
         IF @n_loopno % @n_PageSize = 1
            BEGIN
               SELECT
                  @c_SKU01 = SKU,
                  @c_SKUQTY01 = CAST(Qty AS NVARCHAR(50)),
                  @c_SKUDESCR01 = Description,
                  @c_Serial01 = Serial,
                  @c_Style01 = Style
               FROM @TEMPDATA
               WHERE ID = @n_loopno;
            END

         IF @n_loopno % @n_PageSize = 0
            BEGIN
               SELECT
                  @c_SKU02 = SKU,
                  @c_SKUQTY02 = CAST(Qty AS NVARCHAR(50)),
                  @c_SKUDESCR02 = Description,
                  @c_Serial02 = Serial,
                  @c_Style02 = Style
               FROM @TEMPDATA
               WHERE ID = @n_loopno;
            END

         --Update SKU data to current row
         IF @n_loopno % @n_PageSize = 0 OR @n_loopno >= @n_TotalRecord
            BEGIN
               UPDATE #Result1
               SET
                  Col16 = @c_SKU01,
                  Col17 = @c_SKUQTY01,
                  Col18 = @c_SKUDESCR01,
                  Col19 = @c_Serial01,
                  Col20 = @c_Style01,
                  Col21 = @c_SKU02,
                  Col22 = @c_SKUQTY02,
                  Col23 = @c_SKUDESCR02,
                  Col24 = @c_Serial02,
                  Col25 = @c_Style02
               WHERE Col10 = @n_CurrentPage

               SELECT
                  @c_SKU01 = NULL,
                  @c_SKUQTY01 = NULL,
                  @c_SKUDESCR01 = NULL,
                  @c_Serial01 = NULL,
                  @c_Style01 = NULL,
                  @c_SKU02 = NULL,
                  @c_SKUQTY02 = NULL,
                  @c_SKUDESCR02 = NULL,
                  @c_Serial02 = NULL,
                  @c_Style02 = NULL

               SET @n_CurrentPage = @n_CurrentPage + 1
            END

         SET @n_loopno = @n_loopno + 1
      END

   WHILE @n_copy > 1

   BEGIN
      INSERT INTO #Result1 (
         Col01, Col02, Col03, Col04, Col05, Col06, Col07, Col08, Col09,
         Col10, Col11, Col12, Col13, Col14, Col15, Col16, Col17, Col18, Col19, Col20,
         Col21, Col22, Col23, Col24, Col25, Col26, Col27, Col28, Col29, Col30,
         Col31, Col32, Col33, Col34, Col35, Col36, Col37, Col38, Col39, Col40,
         Col41, Col42, Col43, Col44, Col45, Col46, Col47, Col48, Col49, Col50,
         Col51, Col52, Col53, Col54, Col55, Col56, Col57, Col58, Col59, Col60
      )
      SELECT
         Col01, Col02, Col03, Col04, Col05, Col06, Col07, Col08, Col09,
         Col10, Col11, Col12, Col13, Col14, Col15, Col16, Col17, Col18, Col19, Col20,
         Col21, Col22, Col23, Col24, Col25, Col26, Col27, Col28, Col29, Col30,
         Col31, Col32, Col33, Col34, Col35, Col36, Col37, Col38, Col39, Col40,
         Col41, Col42, Col43, Col44, Col45, Col46, Col47, Col48, Col49, Col50,
         Col51, Col52, Col53, Col54, Col55, Col56, Col57, Col58, Col59, Col60
      FROM #RESULT1
      --WHERE ID = 1

      SET @n_copy = @n_copy - 1
   END

   -- Return results
   SELECT * FROM #Result1;
END

