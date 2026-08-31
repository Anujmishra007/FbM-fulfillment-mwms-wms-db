SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************************************/  
/* Copyright: MAERSK                                                            */  
/* Purpose: isp_BT_Bartender_GB_CSCUPCPb_CSCUK01                              */  
/*                                                                              */  
/* Modifications log:                                                           */  
/*                                                                              */  
/* Date       Rev  Author     Purposes                                          */  
/* 2026-03-16 1.0  SKA900     Created (WCEET-4327)                               */  
/********************************************************************************/  
CREATE OR ALTER PROC [dbo].[isp_BT_Bartender_GB_CSCUPCPb_CSCUK01]
(
  @c_Sparm01            NVARCHAR(250)   -- SKU
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

    CREATE TABLE #Result  
    (  
      ID INT IDENTITY(1,1),
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
    );

   --------------------------------------------------------------------
   -- INSERT DATA INTO RESULT TABLE (First 8 Columns Used, Rest NULL)
   --------------------------------------------------------------------
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
          SKU.ItemClass + SKU.Color
        , SKU.Style + SKU.Color
        , SKU.AltSKU
        , SKU.AltSKU
        , SKU.DESCR
        , SKU.Size
        , CASE 
                WHEN SKU.BUSR5 LIKE 'M%' THEN 'Mens'
                WHEN SKU.BUSR5 LIKE 'W%' THEN 'Womens'
                WHEN SKU.BUSR5 LIKE 'Y%' THEN 'Youth'
                WHEN SKU.BUSR5 LIKE 'U%' THEN 'Unisex'
                WHEN SKU.BUSR5 IS NULL OR LTRIM(RTRIM(SKU.BUSR5)) = '' THEN ''
                ELSE ''
          END
        , CASE 
                WHEN SKU.BUSR5 LIKE 'M%' THEN 'M'
                WHEN SKU.BUSR5 LIKE 'W%' THEN 'W'
                WHEN SKU.BUSR5 LIKE 'Y%' THEN 'Y'
                WHEN SKU.BUSR5 LIKE 'U%' THEN 'U'
                WHEN SKU.BUSR5 IS NULL OR LTRIM(RTRIM(SKU.BUSR5)) = '' THEN ''
                ELSE ''
          END
        , NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
          ,NULL,NULL

    FROM SKU
    WHERE SKU.SKU = @c_Sparm01 AND StorerKey='CSCUK01';

    --------------------------------------------------------------------
    -- RETURN RESULT
    --------------------------------------------------------------------
    SELECT * FROM #Result
    ORDER BY ID;
END
GO
