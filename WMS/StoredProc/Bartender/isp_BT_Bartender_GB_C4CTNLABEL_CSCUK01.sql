USE [GBRWMS]
GO
/****** Object:  StoredProcedure [dbo].[isp_BT_Bartender_GB_C4CTNLABEL_CSCUK01]    Script Date: 7/9/2026 1:42:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/********************************************************************************/  
/* Copyright: MAERSK                                                            */  
/* Purpose: isp_BT_Bartender_GB_C4CTNLABEL_CSCUK01                              */  
/*                                                                              */  
/* Modifications log:                                                           */  
/*                                                                              */  
/* Date       Rev  Author     Purposes                                          */  
/* 2026-02-25 1.0  SKA900     Created (WCEET-4247)     
   20206-07-09 2.0 SKA900     Carton qty correction   							*/  
/********************************************************************************/  
  
CREATE OR ALTER   PROC [dbo].[isp_BT_Bartender_GB_C4CTNLABEL_CSCUK01]
(  @c_Sparm01            NVARCHAR(250)   -- StorerKey
 , @c_Sparm02            NVARCHAR(250)   -- LabelNo
 , @c_Sparm03            NVARCHAR(250)   -- CartonNo  
 , @c_Sparm04            NVARCHAR(250)  
 , @c_Sparm05            NVARCHAR(250)  
 , @c_Sparm06            NVARCHAR(250)  
 , @c_Sparm07            NVARCHAR(250)  
 , @c_Sparm08            NVARCHAR(250)  
 , @c_Sparm09            NVARCHAR(250)  
 , @c_Sparm10            NVARCHAR(250)  
 , @b_debug              INT = 0  
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
 
 SET @c_Sparm01 = NULLIF(LTRIM(RTRIM(@c_Sparm01)), '');
 SET @c_Sparm02 = NULLIF(LTRIM(RTRIM(@c_Sparm02)), '');
 SET @c_Sparm04 = NULLIF(LTRIM(RTRIM(@c_Sparm04)), '');

 DECLARE @c_LabelEff  NVARCHAR(250) = COALESCE(@c_Sparm04, @c_Sparm01);
 DECLARE @c_CartonEff NVARCHAR(250) = @c_Sparm02;
 Declare @c_UserID NVARCHAR(50);
 Declare @ORD_KEY NVARCHAR(50);
   DECLARE @c_PickslipNo NVARCHAR(10)  = @c_Sparm01  
         , @n_CartonNo   INT           = TRY_PARSE(ISNULL(@c_Sparm02,'') AS INT)  
         , @b_Success    INT           = 0  
         , @n_err        INT           = 0  
         , @c_errmsg     NVARCHAR(255) = ''  
  
   IF OBJECT_ID('dbo.fnc_GetUserName', 'FN') IS NOT NULL
      BEGIN
         IF dbo.fnc_GetUserName() NOT IN ('WMConnect', '')
         BEGIN
            SET @c_UserID = dbo.fnc_GetUserName()
         END
      END

	--get orderkey from labelno 
	select @ORD_KEY=OrderKey from packheader where pickslipno IN(
	select pickslipno from PackDetail where LabelNo=@c_LabelEff and CartonNo=@c_CartonEff)
	

   IF OBJECT_ID('tempdb..#TEMP_PACKDET','U') IS NOT NULL  
      DROP TABLE #TEMP_PACKDET;  
  
   CREATE TABLE [#Result]  
   (  
      [ID]    [INT]          IDENTITY(1, 1) NOT NULL  
    , [Col01] [NVARCHAR](80) NULL  
    , [Col02] [NVARCHAR](80) NULL  
    , [Col03] [NVARCHAR](80) NULL  
    , [Col04] [NVARCHAR](80) NULL  
    , [Col05] [NVARCHAR](80) NULL  
    , [Col06] [NVARCHAR](80) NULL  
    , [Col07] [NVARCHAR](80) NULL  
    , [Col08] [NVARCHAR](80) NULL  
    , [Col09] [NVARCHAR](80) NULL  
    , [Col10] [NVARCHAR](80) NULL  
    , [Col11] [NVARCHAR](80) NULL  
    , [Col12] [NVARCHAR](80) NULL  
    , [Col13] [NVARCHAR](80) NULL  
    , [Col14] [NVARCHAR](80) NULL  
    , [Col15] [NVARCHAR](80) NULL  
    , [Col16] [NVARCHAR](80) NULL  
    , [Col17] [NVARCHAR](80) NULL  
    , [Col18] [NVARCHAR](80) NULL  
    , [Col19] [NVARCHAR](80) NULL  
    , [Col20] [NVARCHAR](80) NULL  
    , [Col21] [NVARCHAR](80) NULL  
    , [Col22] [NVARCHAR](80) NULL  
    , [Col23] [NVARCHAR](80) NULL  
    , [Col24] [NVARCHAR](80) NULL  
    , [Col25] [NVARCHAR](80) NULL  
    , [Col26] [NVARCHAR](80) NULL  
    , [Col27] [NVARCHAR](80) NULL  
    , [Col28] [NVARCHAR](80) NULL  
    , [Col29] [NVARCHAR](80) NULL  
    , [Col30] [NVARCHAR](80) NULL  
    , [Col31] [NVARCHAR](80) NULL  
    , [Col32] [NVARCHAR](80) NULL  
    , [Col33] [NVARCHAR](80) NULL  
    , [Col34] [NVARCHAR](80) NULL  
    , [Col35] [NVARCHAR](80) NULL  
    , [Col36] [NVARCHAR](80) NULL  
    , [Col37] [NVARCHAR](80) NULL  
    , [Col38] [NVARCHAR](80) NULL  
    , [Col39] [NVARCHAR](80) NULL  
    , [Col40] [NVARCHAR](80) NULL  
    , [Col41] [NVARCHAR](80) NULL  
    , [Col42] [NVARCHAR](80) NULL  
    , [Col43] [NVARCHAR](80) NULL  
    , [Col44] [NVARCHAR](80) NULL  
    , [Col45] [NVARCHAR](80) NULL  
    , [Col46] [NVARCHAR](80) NULL  
    , [Col47] [NVARCHAR](80) NULL  
    , [Col48] [NVARCHAR](80) NULL  
    , [Col49] [NVARCHAR](80) NULL  
    , [Col50] [NVARCHAR](80) NULL  
    , [Col51] [NVARCHAR](80) NULL  
    , [Col52] [NVARCHAR](80) NULL  
    , [Col53] [NVARCHAR](80) NULL  
    , [Col54] [NVARCHAR](80) NULL  
    , [Col55] [NVARCHAR](80) NULL  
    , [Col56] [NVARCHAR](80) NULL  
    , [Col57] [NVARCHAR](80) NULL  
    , [Col58] [NVARCHAR](80) NULL  
    , [Col59] [NVARCHAR](80) NULL  
    , [Col60] [NVARCHAR](80) NULL  
   );
   
 WITH LineQty AS (
    SELECT
        ord.OrderKey,
        ord.StorerKey,
        ord.Sku,
        ord.OrderLineNumber,
        MAX(ord.RetailSku) AS RetailSku,
        SUM(ord.OpenQty)   AS LineQty,
        SUM(SUM(ord.OpenQty)) OVER (
            PARTITION BY ord.OrderKey, ord.StorerKey, ord.Sku
            ORDER BY ord.OrderLineNumber
            ROWS UNBOUNDED PRECEDING
        ) AS LineCumEnd
    FROM ORDERDETAIL ord WITH (NOLOCK)
    WHERE ord.OrderKey = @ORD_KEY
      AND ord.StorerKey = 'CSCUK01'
     and ord.sku IN(select sku from PackDetail where LabelNo=@c_LabelEff and CartonNo=@c_CartonEff)
    GROUP BY
        ord.OrderKey,
        ord.StorerKey,
        ord.Sku,
        ord.OrderLineNumber
)
,
LineRange AS (
    SELECT
        OrderKey,
        StorerKey,
        Sku,
        OrderLineNumber,
        RetailSku,
        LineQty,
        LineCumEnd - LineQty AS LineCumStart,
        LineCumEnd
    FROM LineQty
)
 ,
CartonQty AS (
    SELECT
        ph.OrderKey,
        pd.StorerKey,
        pd.Sku,
        pd.PickSlipNo,
        pd.CartonNo,
        pd.LabelNo,
        MAX(pd.LabelLine) AS LabelLine,
        SUM(pd.ExpQty) AS CartonQty,
        SUM(pd.Qty)    AS CartonPackedQty,
        SUM(SUM(pd.ExpQty)) OVER (
            PARTITION BY ph.OrderKey, pd.StorerKey, pd.Sku
            ORDER BY pd.CartonNo, pd.LabelNo
            ROWS UNBOUNDED PRECEDING
        ) AS CartonCumEnd,
        SUM(SUM(pd.Qty)) OVER (                          -- ADDED: running total for packed qty
            PARTITION BY ph.OrderKey, pd.StorerKey, pd.Sku
            ORDER BY pd.CartonNo, pd.LabelNo
            ROWS UNBOUNDED PRECEDING
        ) AS CartonPackedCumEnd
    FROM PackHeader ph WITH (NOLOCK)
    JOIN PackDetail pd WITH (NOLOCK)
        ON ph.PickSlipNo = pd.PickSlipNo
       AND ph.StorerKey = pd.StorerKey
    WHERE ph.OrderKey = @ORD_KEY
      AND ph.StorerKey = 'CSCUK01'
     and pd.LabelNo=@c_LabelEff and pd.CartonNo=@c_CartonEff
    GROUP BY
        ph.OrderKey,
        pd.StorerKey,
        pd.Sku,
        pd.PickSlipNo,
        pd.CartonNo,
        pd.LabelNo
)
,
CartonRange AS (
    SELECT
        OrderKey,
        StorerKey,
        Sku,
        PickSlipNo,
        CartonNo,
        LabelNo,
        LabelLine,
        CartonQty,
        CartonPackedQty,
        CartonCumEnd - CartonQty AS CartonCumStart,
        CartonCumEnd,
        CartonPackedCumEnd - CartonPackedQty AS CartonPackedCumStart,   
        CartonPackedCumEnd                                            
    FROM CartonQty
)
,
Allocated AS (
    SELECT
        l.OrderKey,
        l.StorerKey,
        l.Sku,
        l.RetailSku,
        c.PickSlipNo,
        c.CartonNo,
        c.LabelNo,
        c.LabelLine,
        SUM(
            CASE
                WHEN
                    CASE WHEN l.LineCumEnd < c.CartonCumEnd THEN l.LineCumEnd ELSE c.CartonCumEnd END >
                    CASE WHEN l.LineCumStart > c.CartonCumStart THEN l.LineCumStart ELSE c.CartonCumStart END
                THEN
                    CASE WHEN l.LineCumEnd < c.CartonCumEnd THEN l.LineCumEnd ELSE c.CartonCumEnd END
                    -
                    CASE WHEN l.LineCumStart > c.CartonCumStart THEN l.LineCumStart ELSE c.CartonCumStart END
                ELSE 0
            END
        ) AS AllocQty,
        SUM(                                                              
            CASE
                WHEN
                    CASE WHEN l.LineCumEnd < c.CartonPackedCumEnd THEN l.LineCumEnd ELSE c.CartonPackedCumEnd END >
                    CASE WHEN l.LineCumStart > c.CartonPackedCumStart THEN l.LineCumStart ELSE c.CartonPackedCumStart END
                THEN
                    CASE WHEN l.LineCumEnd < c.CartonPackedCumEnd THEN l.LineCumEnd ELSE c.CartonPackedCumEnd END
                    -
                    CASE WHEN l.LineCumStart > c.CartonPackedCumStart THEN l.LineCumStart ELSE c.CartonPackedCumStart END
                ELSE 0
            END
        ) AS AllocPackedQty
    FROM LineRange l
    JOIN CartonRange c
        ON l.OrderKey = c.OrderKey
       AND l.StorerKey = c.StorerKey
       AND l.Sku = c.Sku
    GROUP BY
        l.OrderKey,
        l.StorerKey,
        l.Sku,
        l.RetailSku,
        c.PickSlipNo,
        c.CartonNo,
        c.LabelNo,
        c.LabelLine
)
SELECT
      LabelNo         = a.LabelNo
    , ExternOrderKey   = NULLIF(RTRIM(o.ExternOrderKey), '')
    , OrderInfo03      = NULLIF(RTRIM(ohi.OrderInfo03), '')
    , ordKey           = a.OrderKey
    , CustDept         = NULLIF(RTRIM(ohi.Notes2), '')
    , PickslipNo       = a.PickSlipNo
    , LabelLine        = a.LabelLine
    , SKU = CASE
                WHEN a.RetailSku IS NULL
                     OR LTRIM(RTRIM(a.RetailSku)) = ''
                     OR a.RetailSku = '0'
                    THEN a.Sku
                ELSE a.RetailSku
            END
    , Qty = CASE
                WHEN o.Status IN (0,1,2) THEN a.AllocQty
                ELSE CASE WHEN a.AllocPackedQty = 0 THEN a.AllocQty ELSE a.AllocPackedQty END
            END
    , TotalQty = SUM(
                    CASE
                        WHEN o.Status IN (0,1,2) THEN a.AllocQty
                        ELSE CASE WHEN a.AllocPackedQty = 0 THEN a.AllocQty ELSE a.AllocPackedQty END
                    END
                 ) OVER (PARTITION BY a.PickSlipNo, a.CartonNo)
    --, GrandTotalQty = SUM(a.AllocQty) OVER ()
    , CartonNo = a.CartonNo
    , BUSR4    = NULLIF(RTRIM(REPLACE(sku.BUSR4, ',', '')), '')
    , CartonType  = pai.CartonType
    , ReferenceID = NULLIF(RTRIM(ohi.ReferenceID), '')
INTO #TEMP_PACKDET
FROM Allocated a
JOIN ORDERS o WITH (NOLOCK)
    ON o.OrderKey = a.OrderKey
   AND o.StorerKey = a.StorerKey
LEFT JOIN OrderInfo ohi WITH (NOLOCK)
    ON ohi.OrderKey = a.OrderKey
LEFT JOIN SKU sku WITH (NOLOCK)
    ON sku.StorerKey = a.StorerKey
   AND sku.Sku = a.Sku
LEFT JOIN PackInfo pai WITH (NOLOCK)
    ON pai.PickSlipNo = a.PickSlipNo
   AND pai.CartonNo = a.CartonNo
WHERE a.AllocQty > 0
ORDER BY a.PickSlipNo, a.CartonNo, a.Sku;
  
   INSERT INTO #Result (
    Col01,Col02,Col03,Col04,Col05,Col06,Col07,Col08,Col09,Col10,
    Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20,
    Col21,Col22,Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30,
    Col31,Col32,Col33,Col34,Col35,Col36,Col37,Col38,Col39,Col40,
    Col41,Col42,Col43,Col44,Col45,Col46,Col47,Col48,Col49,Col50,
    Col51,Col52,Col53,Col54,Col55,Col56,Col57,Col58,Col59,Col60
)
SELECT
      Col01 = ISNULL(MAX(X.LabelNo), '')
    , Col02 = ISNULL(MAX(X.ExternOrderKey), '')
    , Col03 = ISNULL(MAX(X.OrderInfo03), '')
    , Col04 = ISNULL(MAX(X.ordKey), '')
    , Col05 = ISNULL(MAX(X.CustDept), '')
    , Col06 = ISNULL(MAX(X.PickslipNo), '')

    /* LINE 1 */
    , Col07 = ISNULL(MAX(CASE WHEN X.Line = 1 THEN CAST(X.LabelLine AS varchar(10)) END), '')
    , Col08 = ISNULL(MAX(CASE WHEN X.Line = 1 THEN X.BUSR4 END), '')
    , Col09 = ISNULL(MAX(CASE WHEN X.Line = 1 THEN X.SKU END), '')
    , Col10 = ISNULL(MAX(CASE WHEN X.Line = 1 AND X.Qty > 0 THEN CAST(X.Qty AS NVARCHAR(50)) END), '')

    /* LINE 2 */
    , Col11 = ISNULL(MAX(CASE WHEN X.Line = 2 THEN CAST(X.LabelLine AS varchar(10)) END), '')
    , Col12 = ISNULL(MAX(CASE WHEN X.Line = 2 THEN X.BUSR4 END), '')
    , Col13 = ISNULL(MAX(CASE WHEN X.Line = 2 THEN X.SKU END), '')
    , Col14 = ISNULL(MAX(CASE WHEN X.Line = 2 AND X.Qty > 0 THEN CAST(X.Qty AS NVARCHAR(50)) END), '')

    /* LINE 3 */
    , Col15 = ISNULL(MAX(CASE WHEN X.Line = 3 THEN CAST(X.LabelLine AS varchar(10)) END), '')
    , Col16 = ISNULL(MAX(CASE WHEN X.Line = 3 THEN X.BUSR4 END), '')
    , Col17 = ISNULL(MAX(CASE WHEN X.Line = 3 THEN X.SKU END), '')
    , Col18 = ISNULL(MAX(CASE WHEN X.Line = 3 AND X.Qty > 0 THEN CAST(X.Qty AS NVARCHAR(50)) END), '')

    /* LINE 4 */
    , Col19 = ISNULL(MAX(CASE WHEN X.Line = 4 THEN CAST(X.LabelLine AS varchar(10)) END), '')
    , Col20 = ISNULL(MAX(CASE WHEN X.Line = 4 THEN X.BUSR4 END), '')
    , Col21 = ISNULL(MAX(CASE WHEN X.Line = 4 THEN X.SKU END), '')
    , Col22 = ISNULL(MAX(CASE WHEN X.Line = 4 AND X.Qty > 0 THEN CAST(X.Qty AS NVARCHAR(50)) END), '')

    /* LINE 5 */
    , Col23 = ISNULL(MAX(CASE WHEN X.Line = 5 THEN CAST(X.LabelLine AS varchar(10)) END), '')
    , Col24 = ISNULL(MAX(CASE WHEN X.Line = 5 THEN X.BUSR4 END), '')
    , Col25 = ISNULL(MAX(CASE WHEN X.Line = 5 THEN X.SKU END), '')
    , Col26 = ISNULL(MAX(CASE WHEN X.Line = 5 AND X.Qty > 0 THEN CAST(X.Qty AS NVARCHAR(50)) END), '')

    /* LINE 6 */
    , Col27 = ISNULL(MAX(CASE WHEN X.Line = 6 THEN CAST(X.LabelLine AS varchar(10)) END), '')
    , Col28 = ISNULL(MAX(CASE WHEN X.Line = 6 THEN X.BUSR4 END), '')
    , Col29 = ISNULL(MAX(CASE WHEN X.Line = 6 THEN X.SKU END), '')
    , Col30 = ISNULL(MAX(CASE WHEN X.Line = 6 AND X.Qty > 0 THEN CAST(X.Qty AS NVARCHAR(50)) END), '')

    /* LINE 7 */
    , Col31 = ISNULL(MAX(CASE WHEN X.Line = 7 THEN CAST(X.LabelLine AS varchar(10)) END), '')
    , Col32 = ISNULL(MAX(CASE WHEN X.Line = 7 THEN X.BUSR4 END), '')
    , Col33 = ISNULL(MAX(CASE WHEN X.Line = 7 THEN X.SKU END), '')
    , Col34 = ISNULL(MAX(CASE WHEN X.Line = 7 AND X.Qty > 0 THEN CAST(X.Qty AS NVARCHAR(50)) END), '')

    /* LINE 8 */
    , Col35 = ISNULL(MAX(CASE WHEN X.Line = 8 THEN CAST(X.LabelLine AS varchar(10)) END), '')
    , Col36 = ISNULL(MAX(CASE WHEN X.Line = 8 THEN X.BUSR4 END), '')
    , Col37 = ISNULL(MAX(CASE WHEN X.Line = 8 THEN X.SKU END), '')
    , Col38 = ISNULL(MAX(CASE WHEN X.Line = 8 AND X.Qty > 0 THEN CAST(X.Qty AS NVARCHAR(50)) END), '')

    /* LINE 9 */
    , Col39 = ISNULL(MAX(CASE WHEN X.Line = 9 THEN CAST(X.LabelLine AS varchar(10)) END), '')
    , Col40 = ISNULL(MAX(CASE WHEN X.Line = 9 THEN X.BUSR4 END), '')
    , Col41 = ISNULL(MAX(CASE WHEN X.Line = 9 THEN X.SKU END), '')
    , Col42 = ISNULL(MAX(CASE WHEN X.Line = 9 AND X.Qty > 0 THEN CAST(X.Qty AS NVARCHAR(50)) END), '')

    /* LINE 10 */
    , Col43 = ISNULL(MAX(CASE WHEN X.Line = 10 THEN CAST(X.LabelLine AS varchar(10)) END), '')
    , Col44 = ISNULL(MAX(CASE WHEN X.Line = 10 THEN X.BUSR4 END), '')
    , Col45 = ISNULL(MAX(CASE WHEN X.Line = 10 THEN X.SKU END), '')
    , Col46 = ISNULL(MAX(CASE WHEN X.Line = 10 AND X.Qty > 0 THEN CAST(X.Qty AS NVARCHAR(50)) END), '')

    /* LINE 11 */
    , Col47 = ISNULL(MAX(CASE WHEN X.Line = 11 THEN CAST(X.LabelLine AS varchar(10)) END), '')
    , Col48 = ISNULL(MAX(CASE WHEN X.Line = 11 THEN X.BUSR4 END), '')
    , Col49 = ISNULL(MAX(CASE WHEN X.Line = 11 THEN X.SKU END), '')
    , Col50 = ISNULL(MAX(CASE WHEN X.Line = 11 AND X.Qty > 0 THEN CAST(X.Qty AS NVARCHAR(50)) END), '')

    /* LINE 12 */
    , Col51 = ISNULL(MAX(CASE WHEN X.Line = 12 THEN CAST(X.LabelLine AS varchar(10)) END), '')
    , Col52 = ISNULL(MAX(CASE WHEN X.Line = 12 THEN X.BUSR4 END), '')
    , Col53 = ISNULL(MAX(CASE WHEN X.Line = 12 THEN X.SKU END), '')
    , Col54 = ISNULL(MAX(CASE WHEN X.Line = 12 AND X.Qty > 0 THEN CAST(X.Qty AS NVARCHAR(50)) END), '')

    /* Totals */
    , Col55 = ISNULL(MAX(X.TotalQty), '')

    /* Empty placeholders */
    , Col56 = ISNULL(MAX(X.CartonType), '')
    , Col57 = ISNULL(MAX(X.ReferenceID), '')
    , Col58 = @c_UserID
    , Col59 = ''
    , Col60 = ''

FROM (
    SELECT *,
           PageNo = (ROW_NUMBER() OVER(PARTITION BY PickslipNo, CartonNo ORDER BY Sku) -1) / 12 + 1,
           Line   = (ROW_NUMBER() OVER(PARTITION BY PickslipNo, CartonNo ORDER BY Sku) -1) % 12 + 1
    FROM #TEMP_PACKDET
) X
GROUP BY X.PickslipNo, X.CartonNo, X.PageNo
ORDER BY X.PickslipNo, X.CartonNo, X.PageNo; 
  
   SELECT * FROM #Result  
   ORDER BY ID    
  
  DECLARE @d_Trace_StartTime   DATETIME,   
           @d_Trace_EndTime     DATETIME,  
           @c_Trace_ModuleName  NVARCHAR(20),   
           @d_Trace_Step1       DATETIME,   
           @c_Trace_Step1       NVARCHAR(20),
           @c_UserName          NVARCHAR(50)  

  SET @d_Trace_StartTime = GETDATE()  
   SET @c_Trace_ModuleName = ''  
   SET @d_Trace_EndTime = GETDATE()  
   SET @c_UserName = SUSER_SNAME() 

  EXEC isp_InsertTraceInfo   
      @c_TraceCode = 'BARTENDER',  
      @c_TraceName = 'isp_BT_Bartender_GB_C4CTNLABEL_CSCUK01',  
      @c_starttime = @d_Trace_StartTime,  
      @c_endtime = @d_Trace_EndTime,  
      @c_step1 = @c_UserName,  
      @c_step2 = '',  
      @c_step3 = '',  
      @c_step4 = '',  
      @c_step5 = '',  
      @c_col1 = @c_Sparm01,   
      @c_col2 = @c_Sparm02,  
      @c_col3 = @c_Sparm03,  
      @c_col4 = @c_Sparm04,  
      @c_col5 = @c_Sparm05,  
      @b_Success = 1,  
      @n_Err = 0,  
      @c_ErrMsg = '' 

END  
