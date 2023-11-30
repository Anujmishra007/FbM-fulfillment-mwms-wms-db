SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Copyright: IDS                                                             */
/* Purpose: isp_Bartender_CN_TPYSKULBL02_GetParm                              */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2023-09-20 1.0  CSCHONG    Devops Scripts Combine & Created (WMS-23532)    */
/******************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_Bartender_CN_TPYSKULBL02_GetParm]
(  @parm01            NVARCHAR(250),
   @parm02            NVARCHAR(250),
   @parm03            NVARCHAR(250),
   @parm04            NVARCHAR(250),
   @parm05            NVARCHAR(250),
   @parm06            NVARCHAR(250),
   @parm07            NVARCHAR(250),
   @parm08            NVARCHAR(250),
   @parm09            NVARCHAR(250),
   @parm10            NVARCHAR(250),
   @b_debug             INT = 0
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @c_OrderKey        NVARCHAR(10),
      @c_PrintMbol       NVARCHAR(1),
      @c_printbyOrder    NVARCHAR(1),
      @c_Deliverydate    DATETIME,
      @n_intFlag         INT,
      @n_CntRec          INT,
      @c_SQL             NVARCHAR(4000),
      @c_SQLSORT         NVARCHAR(4000),
      @c_SQLJOIN         NVARCHAR(4000),
      @c_condition1      NVARCHAR(150) ,
      @c_condition2      NVARCHAR(150),
      @c_SQLGroup        NVARCHAR(4000),
      @c_SQLOrdBy        NVARCHAR(150),
      @c_ExecArguments   NVARCHAR(4000),
      @c_SQLInsert       NVARCHAR(4000),
      @c_parm01          NVARCHAR(250),
      @c_parm02          NVARCHAR(250),
      @c_parm03          NVARCHAR(250),
      @n_ttlctn          INT,
      @n_Skuctn          INT,
      @n_Cartonno        INT,
      @n_ctnrec          INT,
      @n_lineno          INT,
      @n_recid           INT


  DECLARE @d_Trace_StartTime   DATETIME,
           @d_Trace_EndTime    DATETIME,
           @c_Trace_ModuleName NVARCHAR(20),
           @d_Trace_Step1      DATETIME,
           @c_Trace_Step1      NVARCHAR(20),
           @c_UserName         NVARCHAR(20),
           @n_cntsku           INT,
           @c_mode             NVARCHAR(1),
           @c_sku              NVARCHAR(20),
           @c_getOrderkey      NVARCHAR(20),
           @c_getUdef09        NVARCHAR(30),
           @c_key01            NVARCHAR(50),
           @n_lineCtn          INT,
           @n_LineStart        INT,
           @c_getparm02        NVARCHAR(80),
           @c_getparm03        NVARCHAR(80),
           @c_getparm04        NVARCHAR(80),
           @c_getparm01        NVARCHAR(80),
           @c_getparm06        NVARCHAR(80), 
           @c_getparm07        NVARCHAR(80),
           @n_getparm10        INT,
           @c_receiptkey       NVARCHAR(20),
           @c_printbysku       NVARCHAR(1)  ='N',
           @c_printbyrec       NVARCHAR(1)  ='N'


   SET @d_Trace_StartTime = GETDATE()
   SET @c_Trace_ModuleName = ''

--SELECT @parm01 '@parm01'

    IF EXISTS (SELECT 1 FROM RECEIPT (NOLOCK) WHERE receiptkey=@parm01)
    BEGIN

          SET @c_receiptkey = @parm01

          SELECT TOP 1 @c_sku = RD.sku 
          FROM Receiptdetail RD (NOLOCK)
          WHERE RD.ReceiptKey = @c_receiptkey
          AND RD.Lottable04 IS NOT NULL 
          ORDER BY RD.AddDate DESC

          SET @c_printbyrec='Y'
          SET @c_printbysku ='N'
    END

     IF EXISTS (SELECT 1 FROM UPC (NOLOCK) WHERE UPC=@parm03) OR EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE sku=@parm03)
     BEGIN
        IF @c_printbyrec = 'N'
        BEGIN

          SET @c_printbysku='Y'

       END

     END

    IF EXISTS (SELECT 1 FROM UPC (NOLOCK) WHERE UPC=@parm03) AND @c_printbysku ='Y'
    BEGIN

          SET @c_receiptkey = ''

          SELECT TOP 1 @c_sku = RD.sku
          FROM UPC WITH (NOLOCK)
          JOIN dbo.RECEIPTDETAIL RD WITH (NOLOCK) ON RD.Sku = UPC.sku AND RD.StorerKey = UPC.storerkey
          WHERE UPC.UPC=@parm03
          AND UPC.StorerKey = @parm02
          ORDER BY RD.sku

          SET @c_receiptkey = ''

          --SELECT TOP 1 @c_receiptkey = RD.ReceiptKey
          --            ,@c_sku = MIN(sku)
          --FROM dbo.RECEIPTDETAIL RD WITH (NOLOCK)
          --WHERE RD.sku=@c_sku
          --AND RD.StorerKey = @parm02
          --GROUP BY RD.ReceiptKey
          --ORDER BY RD.ReceiptKey desc


          SET @c_printbysku ='Y'
    END
    ELSE 
    BEGIN
        
        IF @c_printbyrec='N'
        BEGIN
           SET @c_printbysku ='Y'
           SET @c_sku =  @parm03    
        END
    END

    --IF EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE sku=@parm01 AND storerkey = @parm02)
    --BEGIN
    --      SET @c_receiptkey = ''

    --      --SELECT TOP 1 @c_receiptkey = RD.ReceiptKey
    --      --            ,@c_sku = MIN(sku)
    --      --FROM dbo.RECEIPTDETAIL RD WITH (NOLOCK)
    --      --WHERE RD.sku=@parm01
    --      --AND RD.StorerKey = @parm02
    --      --GROUP BY RD.ReceiptKey
    --      --ORDER BY RD.ReceiptKey desc

    --      SET @c_sku = @parm01

    --      SET @c_printbysku ='Y'
    --END

     SELECT DISTINCT PARM1=@c_receiptkey, PARM2=@c_sku,PARM3=@parm02,PARM4=@c_printbysku,PARM5='',PARM6='',PARM7='',PARM8='',PARM9='',PARM10='',Key1='',Key2='',Key3='',Key4='',Key5='' 

   EXIT_SP:

      SET @d_Trace_EndTime = GETDATE()
      SET @c_UserName = SUSER_SNAME()


   END -- procedure
GO
GRANT EXECUTE ON  [dbo].[isp_Bartender_CN_TPYSKULBL02_GetParm] TO [NSQL]
GO
