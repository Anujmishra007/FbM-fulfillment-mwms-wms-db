SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Copyright: MAERSK                                                          */
/* Purpose: isp_BT_Bartender_CN_SHIPUCCLBL_GOLDWIN                            */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 20-Nov-2023  1.0  WLChooi    Created (WMS-24118)                           */
/* 20-Nov-2023  1.0  WLChooi    DevOps Combine Script                         */
/******************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_BT_Bartender_CN_SHIPUCCLBL_GOLDWIN]
(
   @c_Sparm01 NVARCHAR(250)
 , @c_Sparm02 NVARCHAR(250)
 , @c_Sparm03 NVARCHAR(250)
 , @c_Sparm04 NVARCHAR(250)
 , @c_Sparm05 NVARCHAR(250)
 , @c_Sparm06 NVARCHAR(250)
 , @c_Sparm07 NVARCHAR(250)
 , @c_Sparm08 NVARCHAR(250)
 , @c_Sparm09 NVARCHAR(250)
 , @c_Sparm10 NVARCHAR(250)
 , @b_debug   INT = 0
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_intFlag     INT = 1
         , @n_CntRec      INT
         , @c_SQL         NVARCHAR(4000)
         , @c_SQLSORT     NVARCHAR(4000)
         , @c_SQLJOIN     NVARCHAR(4000)
         , @n_MaxLine     INT = 22
         , @n_CurrentPage INT = 1
         , @n_TTLpage     INT = 0
         , @n_SumQty      INT = 0

   DECLARE @c_UserName         NVARCHAR(20)
         , @c_ExecStatements   NVARCHAR(4000)
         , @c_ExecArguments    NVARCHAR(4000)
         
   -- SET RowNo = 0               
   SET @c_SQL = N''

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
   )

   SET @c_SQLJOIN = N' SELECT DISTINCT PD.LabelNo, ISNULL(TRIM(ORD.ExternOrderkey),''''), ORD.Orderkey, ' + CHAR(13) --3
                  + N' PD.CartonNo, ORD.Consigneekey, ' + CHAR(13) --5
                  + N' ISNULL(TRIM(ORD.C_Company),''''), ' + CHAR(13) --6
                  + N' LEFT(ISNULL(TRIM(ORD.C_State),'''') + ISNULL(TRIM(ORD.C_City),'''') + ISNULL(TRIM(ORD.C_Address1),'''') + ' + CHAR(13) --7
                  + N' ISNULL(TRIM(ORD.C_Address2),'''') + ISNULL(TRIM(ORD.C_Address3),'''') + ISNULL(TRIM(ORD.C_Address4),''''), 80), ' + CHAR(13) --7
                  + N' SUM(PD.Qty), ISNULL(PI.[Cube], 0.00), CONVERT(NVARCHAR(10), GETDATE(), 103) + '' '' + CONVERT(NVARCHAR(8), GETDATE(), 114), ' + CHAR(13) --10
                  + N' '''', '''', '''', '''', '''', '''', '''', '''', '''', '''', ' + CHAR(13) --20
                  + N' '''', '''', '''', '''', '''', '''', '''', '''', '''', '''', ' + CHAR(13) --30
                  + N' '''', '''', '''', '''', '''', '''', '''', '''', '''', '''', ' + CHAR(13) --40
                  + N' '''', '''', '''', '''', '''', '''', '''', '''', '''', '''', ' + CHAR(13) --50
                  + N' '''', '''', '''', '''', '''', '''', '''', '''', '''', PD.Pickslipno ' + CHAR(13) --60
                  + N' FROM PACKDETAIL PD (NOLOCK) ' + CHAR(13)
                  + N' JOIN PACKHEADER PH (NOLOCK) ON PH.Pickslipno = PD.Pickslipno ' + CHAR(13)
                  + N' JOIN ORDERS ORD (NOLOCK) ON PH.Orderkey = ORD.Orderkey ' + CHAR(13)
                  + N' LEFT JOIN PACKINFO PI (NOLOCK) ON PI.Pickslipno = PD.Pickslipno AND PI.Cartonno = PD.Cartonno ' + CHAR(13)
                  + N' WHERE PH.Pickslipno = @c_Sparm01 ' + CHAR(13)
                  + N' AND PD.Cartonno >= CONVERT(INT,@c_Sparm02) ' + CHAR(13)
                  + N' AND PD.Cartonno <= CONVERT(INT,@c_Sparm03) ' + CHAR(13)
                  + N' GROUP BY PD.LabelNo, ISNULL(TRIM(ORD.ExternOrderkey),''''), ORD.Orderkey, PD.CartonNo, ORD.Consigneekey, ' + CHAR(13)
                  + N'          ISNULL(TRIM(ORD.C_Company),''''), ISNULL(PI.[Cube], 0.00), PD.Pickslipno ,' + CHAR(13)
                  + N'          LEFT(ISNULL(TRIM(ORD.C_State),'''') + ISNULL(TRIM(ORD.C_City),'''') + ISNULL(TRIM(ORD.C_Address1),'''') + ' + CHAR(13)
                  + N'          ISNULL(TRIM(ORD.C_Address2),'''') + ISNULL(TRIM(ORD.C_Address3),'''') + ISNULL(TRIM(ORD.C_Address4),''''), 80) '

   IF @b_debug = 1
   BEGIN
      PRINT @c_SQLJOIN
   END

   SET @c_SQL = N'INSERT INTO #Result (Col01,Col02,Col03,Col04,Col05, Col06,Col07,Col08,Col09' + CHAR(13)
              + N',Col10,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20,Col21,Col22' + CHAR(13)
              + N',Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30,Col31,Col32,Col33,Col34' + CHAR(13)
              + N',Col35,Col36,Col37,Col38,Col39,Col40,Col41,Col42,Col43,Col44' + CHAR(13)
              + N',Col45,Col46,Col47,Col48,Col49,Col50,Col51,Col52,Col53,Col54' + CHAR(13)
              + N',Col55,Col56,Col57,Col58,Col59,Col60) '

   SET @c_SQL = @c_SQL + @c_SQLJOIN


   SET @c_ExecArguments = N'   @c_Sparm01          NVARCHAR(80) ' + N',  @c_Sparm02          NVARCHAR(80) '
                        + N',  @c_Sparm03          NVARCHAR(80) ' + N',  @c_Sparm04          NVARCHAR(80) '
                        + N',  @c_Sparm05          NVARCHAR(80) ' + N',  @c_Sparm06          NVARCHAR(80) '

   EXEC sp_executesql @c_SQL
                    , @c_ExecArguments
                    , @c_Sparm01
                    , @c_Sparm02
                    , @c_Sparm03
                    , @c_Sparm04
                    , @c_Sparm05
                    , @c_Sparm06

   SELECT *
   FROM #Result (NOLOCK)
   ORDER BY ID

   EXIT_SP:

END -- procedure     
GO
GRANT EXECUTE ON [dbo].[isp_BT_Bartender_CN_SHIPUCCLBL_GOLDWIN] TO [NSQL]
GO