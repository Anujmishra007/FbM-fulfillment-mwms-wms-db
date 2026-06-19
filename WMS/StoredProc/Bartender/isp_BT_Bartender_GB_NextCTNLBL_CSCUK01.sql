SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/********************************************************************************/  
/* Copyright: MAERSK                                                            */  
/* Purpose: isp_BT_Bartender_GB_NextCTNLBL_CSCUK01                              */  
/*                                                                              */  
/* Modifications log:                                                           */  
/*                                                                              */  
/* Date       Rev  Author     Purposes                                          */  
/* 2026-03-26 1.0  SKA900     Created (WCEET-4255)                               */  
/********************************************************************************/  
  
CREATE OR ALTER PROC [dbo].[isp_BT_Bartender_GB_NextCTNLBL_CSCUK01]
(  @c_Sparm01            NVARCHAR(250)   -- LabelNo
 , @c_Sparm02            NVARCHAR(250)   
 , @c_Sparm03            NVARCHAR(250)    
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

DECLARE @ORDKEY NVARCHAR(20) 
DECLARE @BillToKey NVARCHAR(20)
select @ORDKEY=OrderKey from PACKHEADER where pickslipno IN(
select pickslipno from PACKDETAIL where labelNo=@c_Sparm01 and Storerkey='CSCUK01') and Storerkey='CSCUK01'
select @BillToKey=BillToKey from ORDERS where OrderKey=@ORDKEY and Storerkey='CSCUK01'

-------------------------------------------------------------
-- VALIDATE BillToKey (return if NULL or NOT allowed)
-------------------------------------------------------------

-- 1. NULL or blank check
IF (@BillToKey IS NULL OR LTRIM(RTRIM(@BillToKey)) = '')
BEGIN
    RETURN;
END;

-- 2. Allowed BillToKey list
IF (@BillToKey NOT IN ('19300'))
BEGIN
    RETURN;   -- Not allowed → stop SP
END;

-- 3. Validate OrderKey
IF (@ORDKEY IS NULL OR LTRIM(RTRIM(@ORDKEY)) = '')
BEGIN
    RETURN;
END;


IF (@ORDKEY IS NULL OR LTRIM(RTRIM(@ORDKEY)) = '')
BEGIN
    PRINT 'OrderKey is missing.';
    RETURN;
END;

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
   
;WITH BoxList AS
(
    SELECT DISTINCT 
           o.OrderKey,
           pd.LabelNo
    FROM Orders o
    INNER JOIN PackHeader ph ON ph.OrderKey = o.OrderKey AND ph.StorerKey = o.StorerKey
    INNER JOIN PackDetail pd ON pd.PickSlipNo = ph.PickSlipNo AND pd.StorerKey = ph.StorerKey
    WHERE o.StorerKey = 'CSCUK01'
      AND o.OrderKey = @ORDKEY
),
BoxCalc AS
(
    SELECT 
           OrderKey,
           LabelNo,
           ROW_NUMBER() OVER(PARTITION BY OrderKey ORDER BY LabelNo) AS BoxNumber,
           COUNT(*) OVER(PARTITION BY OrderKey) AS TotalBoxes
    FROM BoxList
),
SizeCheck AS
(
    SELECT 
        pd.LabelNo,
        COUNT(DISTINCT sku.Size) AS DistinctSizeCount,
        MIN(sku.Size) AS SingleSize
    FROM PackDetail pd
    INNER JOIN PackHeader ph ON ph.PickSlipNo = pd.PickSlipNo AND ph.StorerKey = pd.StorerKey
    INNER JOIN SKU sku ON pd.SKU = sku.SKU AND pd.StorerKey = sku.StorerKey
    WHERE ph.OrderKey = @ORDKEY
    GROUP BY pd.LabelNo
)

 INSERT INTO #Result (
        Col01,Col02,Col03,Col04,Col05,Col06,Col07,Col08,
        Col09,Col10,Col11,Col12,Col13,Col14,Col15,Col16,
        Col17,Col18,Col19,Col20,Col21,Col22,Col23,Col24,
        Col25,Col26,Col27,Col28,Col29,Col30,Col31,Col32,
        Col33,Col34,Col35,Col36,Col37,Col38,Col39,Col40,
        Col41,Col42,Col43,Col44,Col45,Col46,Col47,Col48,
        Col49,Col50,Col51,Col52,Col53,Col54,Col55,Col56,
        Col57,Col58,Col59,Col60
    )
SELECT 
       Max(OHI.OrderInfo03) AS PONumber,
       o.OrderKey,
       sku.ItemClass AS StyleCode,
       CASE WHEN sc.DistinctSizeCount > 1 THEN 'MXD' ELSE sc.SingleSize END AS Size,
       b.BoxNumber,
       b.TotalBoxes,
	   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
       NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
       NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
       NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL

FROM Orders o
INNER JOIN OrderDetail od ON o.OrderKey = od.OrderKey AND o.StorerKey = od.StorerKey
LEFT JOIN dbo.OrderInfo OHI WITH (NOLOCK) ON o.Orderkey = OHI.Orderkey
INNER JOIN PackHeader ph ON ph.OrderKey = o.OrderKey AND ph.StorerKey = o.StorerKey
INNER JOIN PackDetail pd ON ph.PickSlipNo = pd.PickSlipNo AND ph.StorerKey  = pd.StorerKey AND od.SKU = pd.SKU
INNER JOIN SKU sku ON od.SKU = sku.SKU AND od.StorerKey = sku.StorerKey
INNER JOIN Storer s ON o.StorerKey = s.StorerKey
INNER JOIN BoxCalc b ON b.OrderKey = o.OrderKey AND b.LabelNo  = pd.LabelNo
INNER JOIN SizeCheck sc ON sc.LabelNo = pd.LabelNo

WHERE o.StorerKey = 'CSCUK01'
  AND o.OrderKey = @ORDKEY
  AND pd.LabelNo = @c_Sparm01

GROUP BY
       o.OrderKey,
       sku.ItemClass,
       s.Company,
       b.BoxNumber,
       b.TotalBoxes,
       sc.DistinctSizeCount,
       sc.SingleSize,
       pd.LabelNo;
  
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
      @c_TraceName = 'isp_BT_Bartender_GB_NextCTNLBL_CSCUK01',  
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
GO
