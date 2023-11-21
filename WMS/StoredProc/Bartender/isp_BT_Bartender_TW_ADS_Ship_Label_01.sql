SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Copyright: MAERSK                                                          */
/* Purpose: isp_BT_Bartender_TW_ADS_Ship_Label_01                             */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date        Rev  Author     Purposes                                       */
/* 08-Aug-2023 1.0  WLChooi    Created (WMS-23233)                            */
/* 08-Aug-2023 1.0  WLChooi    DevOps Combine Script                          */
/******************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_BT_Bartender_TW_ADS_Ship_Label_01]
(
   @c_Sparm1  NVARCHAR(250)
 , @c_Sparm2  NVARCHAR(250)
 , @c_Sparm3  NVARCHAR(250)
 , @c_Sparm4  NVARCHAR(250)
 , @c_Sparm5  NVARCHAR(250)
 , @c_Sparm6  NVARCHAR(250)
 , @c_Sparm7  NVARCHAR(250)
 , @c_Sparm8  NVARCHAR(250)
 , @c_Sparm9  NVARCHAR(250)
 , @c_Sparm10 NVARCHAR(250)
 , @b_debug   INT = 0
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_ExecStatements NVARCHAR(MAX)
         , @c_ExecArguments  NVARCHAR(MAX)
         , @c_SQLJOIN        NVARCHAR(MAX)
         , @c_SQL            NVARCHAR(MAX)
         , @c_Condition      NVARCHAR(MAX)
         , @c_SQLJOINTable   NVARCHAR(MAX)

   DECLARE @d_Trace_StartTime  DATETIME
         , @d_Trace_EndTime    DATETIME
         , @c_Trace_ModuleName NVARCHAR(20)
         , @d_Trace_Step1      DATETIME
         , @c_Trace_Step1      NVARCHAR(20)
         , @c_UserName         NVARCHAR(50)
         , @n_Qty              INT
         , @c_SKU              NVARCHAR(80)
         , @c_Size             NVARCHAR(80)
         , @n_Qty01            INT
         , @n_Qty02            INT
         , @n_Qty03            INT
         , @n_Qty04            INT
         , @n_Qty05            INT
         , @n_Qty06            INT
         , @n_Qty07            INT
         , @n_Qty08            INT
         , @n_Qty09            INT
         , @n_Qty10            INT
         , @n_IDX01            INT
         , @n_IDX02            INT
         , @n_IDX03            INT
         , @n_IDX04            INT
         , @n_IDX05            INT
         , @n_IDX06            INT
         , @n_IDX07            INT
         , @n_IDX08            INT
         , @n_IDX09            INT
         , @n_IDX10            INT
         , @c_SKU01            NVARCHAR(80)
         , @c_SKU02            NVARCHAR(80)
         , @c_SKU03            NVARCHAR(80)
         , @c_SKU04            NVARCHAR(80)
         , @c_SKU05            NVARCHAR(80)
         , @c_SKU06            NVARCHAR(80)
         , @c_SKU07            NVARCHAR(80)
         , @c_SKU08            NVARCHAR(80)
         , @c_SKU09            NVARCHAR(80)
         , @c_SKU10            NVARCHAR(80)
         , @c_Size01           NVARCHAR(80)
         , @c_Size02           NVARCHAR(80)
         , @c_Size03           NVARCHAR(80)
         , @c_Size04           NVARCHAR(80)
         , @c_Size05           NVARCHAR(80)
         , @c_Size06           NVARCHAR(80)
         , @c_Size07           NVARCHAR(80)
         , @c_Size08           NVARCHAR(80)
         , @c_Size09           NVARCHAR(80)
         , @c_Size10           NVARCHAR(80)
         , @n_CntRec           INT = 1
         , @n_TTLpage          INT = 1             
         , @n_CurrentPage      INT = 1     
         , @n_MaxLine          INT = 10
         , @n_intFlag          INT = 1
         , @n_Total            INT = 0

   SET @d_Trace_StartTime = GETDATE()
   SET @c_Trace_ModuleName = N''

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

   CREATE TABLE [#TEMPSKU]
   (
      [ID]              [INT]          IDENTITY(1, 1) NOT NULL
    , [Pickslipno]      [NVARCHAR](10) NULL
    , [CartonNo]        [NVARCHAR](10) NULL
    , [SKU]             [NVARCHAR](80) NULL
    , [Qty]             [INT] NULL
    , [Size]            [NVARCHAR](80)
    , [Retrieve]        [NVARCHAR](1)  DEFAULT 'N'
   )

   SET @c_SQLJOIN = N' SELECT DISTINCT ' + CHAR(13)
                  + N'        ISNULL(TRIM(SSD.[Route]),''''), ISNULL(TRIM(OH.C_Company),''''), ' + CHAR(13) --2
                  + N'        ISNULL(TRIM(OH.C_Zip),'''') + ISNULL(TRIM(OH.C_Address1),'''') + ' + CHAR(13)
                  + N'        ISNULL(TRIM(OH.C_Address2),'''') + ISNULL(TRIM(OH.C_Address3),''''), ' + CHAR(13) --3
                  + N'        ISNULL(TRIM(OH.ExternOrderkey),''''), ISNULL(TRIM(CL.[Description]),''''), ' + CHAR(13) --5
                  + N'        CONVERT(NVARCHAR(10), ISNULL(OH.DeliveryDate,''19000101''), 111), ' + CHAR(13) --6
                  + N'        PH.Pickslipno, PD.CartonNo, ' + CHAR(13) --8
                  + N'        ISNULL(TRIM(OH.Consigneekey),''''), '''', ' + CHAR(13) --10
                  + N'        '''', '''', '''', '''', '''', '''', '''', '''', '''', '''', ' + CHAR(13) --20
                  + N'        '''', '''', '''', '''', '''', '''', '''', '''', '''', '''', ' + CHAR(13) --30
                  + N'        '''', '''', '''', '''', '''', '''', '''', '''', '''', '''', ' + CHAR(13) --40
                  + N'        '''', '''', '''', '''', '''', '''', '''', '''', '''', '''', ' + CHAR(13) --50
                  + N'        '''', '''', '''', '''', '''', '''', '''', '''', PH.TTLCNTS, ''''  ' + CHAR(13) --60
                  + N' FROM PACKHEADER PH (NOLOCK) ' + CHAR(13)
                  + N' JOIN PACKDETAIL PD (NOLOCK) ON PH.Pickslipno = PD.Pickslipno ' + CHAR(13)
                  + N' JOIN ORDERS OH (NOLOCK) ON PH.Orderkey = OH.Orderkey ' + CHAR(13)
                  + N' LEFT JOIN StorerSODefault SSD (NOLOCK) ON SSD.Storerkey = OH.Consigneekey ' + CHAR(13)
                  + N' LEFT JOIN CODELKUP CL (NOLOCK) ON CL.Storerkey = OH.Storerkey ' + CHAR(13)
                  + N'                               AND CL.Listname = ''ORDERTYPE'' AND CL.Code = OH.[Type] ' + CHAR(13)
                  + N' WHERE PD.Pickslipno = @c_Sparm1 ' + CHAR(13)
                  + N' AND PD.LabelNo = @c_Sparm2 '

   IF @b_debug = 1
   BEGIN
      PRINT @c_SQLJOIN
   END

   SET @c_SQL = N' INSERT INTO #Result (Col01,Col02,Col03,Col04,Col05, Col06,Col07,Col08,Col09' + CHAR(13)
                + N'                   ,Col10,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20,Col21,Col22' + CHAR(13)
                + N'                   ,Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30,Col31,Col32,Col33,Col34' + CHAR(13) 
                + N'                   ,Col35,Col36,Col37,Col38,Col39,Col40,Col41,Col42,Col43,Col44' + CHAR(13) 
                + N'                   ,Col45,Col46,Col47,Col48,Col49,Col50,Col51,Col52,Col53,Col54' + CHAR(13) 
                + N'                   ,Col55,Col56,Col57,Col58,Col59,Col60) '

   SET @c_SQL = @c_SQL + @c_SQLJOIN

   SET @c_ExecArguments = N'  @c_Sparm1         NVARCHAR(80)' 
                        + N' ,@c_Sparm2         NVARCHAR(80)'
                        + N' ,@c_Sparm3         NVARCHAR(80)' 
                        + N' ,@c_Sparm4         NVARCHAR(80)'
                        + N' ,@c_Sparm5         NVARCHAR(80)'

   EXEC sp_executesql @c_SQL
                    , @c_ExecArguments
                    , @c_Sparm1
                    , @c_Sparm2
                    , @c_Sparm3
                    , @c_Sparm4
                    , @c_Sparm5

   INSERT INTO #TEMPSKU (Pickslipno, CartonNo, SKU, Qty, Size, Retrieve)
   SELECT PD.Pickslipno
        , PD.CartonNo
        , TRIM(ISNULL(S.Style,'')) + TRIM(ISNULL(S.Color,''))
        , SUM(PD.Qty)
        , TRIM(ISNULL(S.Size,''))
        , 'N'
   FROM PACKDETAIL PD (NOLOCK)
   JOIN SKU S (NOLOCK) ON S.StorerKey = PD.StorerKey AND S.Sku = PD.Sku
   WHERE PD.PickSlipNo = @c_Sparm1
   AND PD.LabelNo = @c_Sparm2
   GROUP BY PD.Pickslipno
          , PD.CartonNo
          , TRIM(ISNULL(S.Style,'')) + TRIM(ISNULL(S.Color,''))
          , TRIM(ISNULL(S.Size,''))
   ORDER BY PD.CartonNo

   SET @n_Qty01 = NULL
   SET @n_Qty02 = NULL
   SET @n_Qty03 = NULL
   SET @n_Qty04 = NULL
   SET @n_Qty05 = NULL
   SET @n_Qty06 = NULL
   SET @n_Qty07 = NULL
   SET @n_Qty08 = NULL
   SET @n_Qty09 = NULL
   SET @n_Qty10 = NULL
   SET @c_SKU01 = N''
   SET @c_SKU02 = N''
   SET @c_SKU03 = N''
   SET @c_SKU04 = N''
   SET @c_SKU05 = N''
   SET @c_SKU06 = N''
   SET @c_SKU07 = N''
   SET @c_SKU08 = N''
   SET @c_SKU09 = N''
   SET @c_SKU10 = N''
   SET @c_Size01 = N''
   SET @c_Size02 = N''
   SET @c_Size03 = N''
   SET @c_Size04 = N''
   SET @c_Size05 = N''
   SET @c_Size06 = N''
   SET @c_Size07 = N''
   SET @c_Size08 = N''
   SET @c_Size09 = N''
   SET @c_Size10 = N''
   SET @n_IDX01 = NULL
   SET @n_IDX02 = NULL
   SET @n_IDX03 = NULL
   SET @n_IDX04 = NULL
   SET @n_IDX05 = NULL
   SET @n_IDX06 = NULL
   SET @n_IDX07 = NULL
   SET @n_IDX08 = NULL
   SET @n_IDX09 = NULL
   SET @n_IDX10 = NULL

   SELECT @n_CntRec = COUNT(1)
   FROM #TEMPSKU
   WHERE Pickslipno = @c_Sparm1 AND Retrieve = 'N'

   SET @n_TTLpage = FLOOR(@n_CntRec / @n_MaxLine) + CASE WHEN @n_CntRec % @n_MaxLine > 0 THEN 1
                                                         ELSE 0 END

   WHILE @n_intFlag <= @n_CntRec
   BEGIN
      IF @n_intFlag > @n_MaxLine AND (@n_intFlag % @n_MaxLine) = 1
      BEGIN
         SET @n_CurrentPage = @n_CurrentPage + 1

         IF (@n_CurrentPage > @n_TTLpage)
         BEGIN
            BREAK;
         END

         INSERT INTO #Result (Col01, Col02, Col03, Col04, Col05, Col06, Col07, Col08, Col09, Col10, Col11, Col12, Col13
                            , Col14, Col15, Col16, Col17, Col18, Col19, Col20, Col21, Col22, Col23, Col24, Col25, Col26
                            , Col27, Col28, Col29, Col30, Col31, Col32, Col33, Col34, Col35, Col36, Col37, Col38, Col39
                            , Col40, Col41, Col42, Col43, Col44, Col45, Col46, Col47, Col48, Col49, Col50, Col51, Col52
                            , Col53, Col54, Col55, Col56, Col57, Col58, Col59, Col60)
         SELECT TOP 1 Col01, Col02, Col03, Col04, Col05, Col06, Col07, Col08, Col09, '', '', '', ''
                    , '', '', '', '', '', '', ''
                    , '', '', '', '', '', '', '', '', '', ''
                    , '', '', '', '', '', '', '', '', '', ''
                    , '', '', '', '', '', '', '', '', '', ''
                    , '', '', '', '', '', '', '', '', Col59, ''
         FROM #Result

         SET @n_Qty01 = NULL
         SET @n_Qty02 = NULL
         SET @n_Qty03 = NULL
         SET @n_Qty04 = NULL
         SET @n_Qty05 = NULL
         SET @n_Qty06 = NULL
         SET @n_Qty07 = NULL
         SET @n_Qty08 = NULL
         SET @n_Qty09 = NULL
         SET @n_Qty10 = NULL
         SET @c_SKU01 = N''
         SET @c_SKU02 = N''
         SET @c_SKU03 = N''
         SET @c_SKU04 = N''
         SET @c_SKU05 = N''
         SET @c_SKU06 = N''
         SET @c_SKU07 = N''
         SET @c_SKU08 = N''
         SET @c_SKU09 = N''
         SET @c_SKU10 = N''
         SET @c_Size01 = N''
         SET @c_Size02 = N''
         SET @c_Size03 = N''
         SET @c_Size04 = N''
         SET @c_Size05 = N''
         SET @c_Size06 = N''
         SET @c_Size07 = N''
         SET @c_Size08 = N''
         SET @c_Size09 = N''
         SET @c_Size10 = N''
         SET @n_IDX01 = NULL
         SET @n_IDX02 = NULL
         SET @n_IDX03 = NULL
         SET @n_IDX04 = NULL
         SET @n_IDX05 = NULL
         SET @n_IDX06 = NULL
         SET @n_IDX07 = NULL
         SET @n_IDX08 = NULL
         SET @n_IDX09 = NULL
         SET @n_IDX10 = NULL
      END

      SELECT @c_SKU = SKU
           , @n_Qty = Qty
           , @c_Size = Size
      FROM #TEMPSKU
      WHERE ID = @n_intFlag
      GROUP BY SKU
             , Qty
             , Size

      IF (@n_intFlag % @n_MaxLine) = 1
      BEGIN
         SET @c_SKU01 = @c_SKU
         SET @n_Qty01 = @n_Qty
         SET @c_Size01 = @c_Size
         SET @n_IDX01 = 1
      END
      ELSE IF (@n_intFlag % @n_MaxLine) = 2
      BEGIN
         SET @c_SKU02 = @c_SKU
         SET @n_Qty02 = @n_Qty
         SET @c_Size02 = @c_Size
         SET @n_IDX02 = 2
      END
      ELSE IF (@n_intFlag % @n_MaxLine) = 3
      BEGIN
         SET @c_SKU03 = @c_SKU
         SET @n_Qty03 = @n_Qty
         SET @c_Size03 = @c_Size
         SET @n_IDX03 = 3
      END
      ELSE IF (@n_intFlag % @n_MaxLine) = 4
      BEGIN
         SET @c_SKU04 = @c_SKU
         SET @n_Qty04 = @n_Qty
         SET @c_Size04 = @c_Size
         SET @n_IDX04 = 4
      END
      ELSE IF (@n_intFlag % @n_MaxLine) = 5
      BEGIN
         SET @c_SKU05 = @c_SKU
         SET @n_Qty05 = @n_Qty
         SET @c_Size05 = @c_Size
         SET @n_IDX05 = 5
      END
      ELSE IF (@n_intFlag % @n_MaxLine) = 6
      BEGIN
         SET @c_SKU06 = @c_SKU
         SET @n_Qty06 = @n_Qty
         SET @c_Size06 = @c_Size
         SET @n_IDX06 = 6
      END
      ELSE IF (@n_intFlag % @n_MaxLine) = 7
      BEGIN
         SET @c_SKU07 = @c_SKU
         SET @n_Qty07 = @n_Qty
         SET @c_Size07 = @c_Size
         SET @n_IDX07 = 7
      END
      ELSE IF (@n_intFlag % @n_MaxLine) = 8
      BEGIN
         SET @c_SKU08 = @c_SKU
         SET @n_Qty08 = @n_Qty
         SET @c_Size08 = @c_Size
         SET @n_IDX08 = 8
      END
      ELSE IF (@n_intFlag % @n_MaxLine) = 9
      BEGIN
         SET @c_SKU09 = @c_SKU
         SET @n_Qty09 = @n_Qty
         SET @c_Size09 = @c_Size
         SET @n_IDX09 = 9
      END
      ELSE IF (@n_intFlag % @n_MaxLine) = 0
      BEGIN
         SET @c_SKU10 = @c_SKU
         SET @n_Qty10 = @n_Qty
         SET @c_Size10 = @c_Size
         SET @n_IDX10 = 10
      END

      UPDATE #Result
      SET Col10 = @n_IDX01
        , Col11 = @c_SKU01
        , Col12 = @c_Size01
        , Col13 = @n_Qty01
        , Col14 = @n_IDX02
        , Col15 = @c_SKU02
        , Col16 = @c_Size02
        , Col17 = @n_Qty02
        , Col18 = @n_IDX03
        , Col19 = @c_SKU03
        , Col20 = @c_Size03
        , Col21 = @n_Qty03
        , Col22 = @n_IDX04
        , Col23 = @c_SKU04
        , Col24 = @c_Size04
        , Col25 = @n_Qty04
        , Col26 = @n_IDX05
        , Col27 = @c_SKU05
        , Col28 = @c_Size05
        , Col29 = @n_Qty05
        , Col30 = @n_IDX06
        , Col31 = @c_SKU06
        , Col32 = @c_Size06
        , Col33 = @n_Qty06
        , Col34 = @n_IDX07
        , Col35 = @c_SKU07
        , Col36 = @c_Size07
        , Col37 = @n_Qty07
        , Col38 = @n_IDX08
        , Col39 = @c_SKU08
        , Col40 = @c_Size08
        , Col41 = @n_Qty08
        , Col42 = @n_IDX09
        , Col43 = @c_SKU09
        , Col44 = @c_Size09
        , Col45 = @n_Qty09
        , Col46 = @n_IDX10
        , Col47 = @c_SKU10
        , Col48 = @c_Size10
        , Col49 = @n_Qty10
        , Col58 = ISNULL(@n_Qty01, 0) + ISNULL(@n_Qty02, 0) + ISNULL(@n_Qty03, 0) + ISNULL(@n_Qty04, 0) + ISNULL(@n_Qty05, 0) 
                + ISNULL(@n_Qty06, 0) + ISNULL(@n_Qty07, 0) + ISNULL(@n_Qty08, 0) + ISNULL(@n_Qty09, 0) + ISNULL(@n_Qty10, 0)
      WHERE ID = @n_CurrentPage

      UPDATE #TEMPSKU
      SET Retrieve = 'Y'
      WHERE ID = @n_intFlag

      SET @n_intFlag = @n_intFlag + 1

      IF @n_intFlag > @n_CntRec
      BEGIN
         BREAK;
      END
   END

   QUIT_SP:

   SET @d_Trace_EndTime = GETDATE()
   SET @c_UserName = SUSER_SNAME()

   SELECT *
   FROM #Result WITH (NOLOCK)
END -- procedure 
GO
GRANT EXECUTE ON [dbo].[isp_BT_Bartender_TW_ADS_Ship_Label_01] TO [NSQL]
GO