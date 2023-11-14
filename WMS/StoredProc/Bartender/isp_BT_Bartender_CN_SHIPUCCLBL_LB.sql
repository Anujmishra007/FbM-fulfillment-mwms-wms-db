SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Copyright: MAERSK                                                          */
/* Purpose: isp_BT_Bartender_CN_SHIPUCCLBL_LB                                 */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 10-Oct-2023  1.0  WLChooi    Created (WMS-23769)                           */
/* 10-Oct-2023  1.0  WLChooi    DevOps Combine Script                         */
/******************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_BT_Bartender_CN_SHIPUCCLBL_LB]
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

   DECLARE @d_Trace_StartTime  DATETIME
         , @d_Trace_EndTime    DATETIME
         , @c_Trace_ModuleName NVARCHAR(20)
         , @d_Trace_Step1      DATETIME
         , @c_Trace_Step1      NVARCHAR(20)
         , @c_UserName         NVARCHAR(20)
         , @c_ExecStatements   NVARCHAR(4000)
         , @c_ExecArguments    NVARCHAR(4000)
         , @n_Sum              INT
         
   DECLARE @c_Qty        NVARCHAR(80)
         , @c_SKU01      NVARCHAR(80)
         , @c_SKU02      NVARCHAR(80)
         , @c_SKU03      NVARCHAR(80)
         , @c_SKU04      NVARCHAR(80)
         , @c_SKU05      NVARCHAR(80)
         , @c_SKU06      NVARCHAR(80)
         , @c_SKU07      NVARCHAR(80)
         , @c_SKU08      NVARCHAR(80)
         , @c_SKU09      NVARCHAR(80)
         , @c_SKU10      NVARCHAR(80)
         , @c_SKU11      NVARCHAR(80)
         , @c_SKU12      NVARCHAR(80)
         , @c_SKU13      NVARCHAR(80)
         , @c_SKU14      NVARCHAR(80)
         , @c_SKU15      NVARCHAR(80)
         , @c_SKU16      NVARCHAR(80)
         , @c_SKU17      NVARCHAR(80)
         , @c_SKU18      NVARCHAR(80)
         , @c_SKU19      NVARCHAR(80)
         , @c_SKU20      NVARCHAR(80)
         , @c_SKU21      NVARCHAR(80)
         , @c_SKU22      NVARCHAR(80)
         , @c_Qty01      NVARCHAR(80)
         , @c_Qty02      NVARCHAR(80)
         , @c_Qty03      NVARCHAR(80)
         , @c_Qty04      NVARCHAR(80)
         , @c_Qty05      NVARCHAR(80)
         , @c_Qty06      NVARCHAR(80)
         , @c_Qty07      NVARCHAR(80)
         , @c_Qty08      NVARCHAR(80)
         , @c_Qty09      NVARCHAR(80)
         , @c_Qty10      NVARCHAR(80)
         , @c_Qty11      NVARCHAR(80)
         , @c_Qty12      NVARCHAR(80)
         , @c_Qty13      NVARCHAR(80)
         , @c_Qty14      NVARCHAR(80)
         , @c_Qty15      NVARCHAR(80)
         , @c_Qty16      NVARCHAR(80)
         , @c_Qty17      NVARCHAR(80)
         , @c_Qty18      NVARCHAR(80)
         , @c_Qty19      NVARCHAR(80)
         , @c_Qty20      NVARCHAR(80)
         , @c_Qty21      NVARCHAR(80)
         , @c_Qty22      NVARCHAR(80)
         , @c_Pickslipno NVARCHAR(10)
         , @c_CartonNo   NVARCHAR(10)
         , @c_Notes_1    NVARCHAR(80)
         , @c_Notes_2    NVARCHAR(80)
         , @c_Loc        NVARCHAR(10)
         , @c_SKU        NVARCHAR(20)
         , @c_Notes      NVARCHAR(4000)

   SET @d_Trace_StartTime = GETDATE()
   SET @c_Trace_ModuleName = N''

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

   CREATE TABLE [#TMP_DET]
   (
      [ID]         [INT]          IDENTITY(1, 1) NOT NULL
    , [Pickslipno] [NVARCHAR](10) NULL
    , [Cartonno]   [NVARCHAR](10) NULL
    , [Loc]        [NVARCHAR](10) NULL
    , [Notes2]     [NVARCHAR](4000) NULL
    , [SKU]        [NVARCHAR](20) NULL
    , [Qty]        [INT]          NULL
    , [Retrieve]   [NVARCHAR](1)  DEFAULT 'N'
   )

   SET @c_SQLJOIN = N' SELECT DISTINCT ISNULL(TRIM(ORD.ExternOrderkey),''''), ORD.Consigneekey, PD.CartonNo, ' + CHAR(13) --3
                  + N' '''', PDET.CaseID, ' + CHAR(13) --5
                  + N' ISNULL(TRIM(PI.CartonType),''''), '''', '''', '''', '''', ' + CHAR(13) --10
                  + N' '''', '''', '''', '''', '''', '''', '''', '''', '''', '''', ' + CHAR(13) --20
                  + N' '''', '''', '''', '''', '''', '''', '''', '''', '''', '''', ' + CHAR(13) --30
                  + N' '''', '''', '''', '''', '''', '''', '''', '''', '''', '''', ' + CHAR(13) --40
                  + N' '''', '''', '''', '''', '''', '''', '''', '''', '''', '''', ' + CHAR(13) --50
                  + N' '''', '''', '''', '''', '''', '''', '''', '''', '''', PD.Pickslipno ' + CHAR(13) --60
                  + N' FROM PACKDETAIL PD (NOLOCK) ' + CHAR(13)
                  + N' JOIN PACKHEADER PH (NOLOCK) ON PH.Pickslipno = PD.Pickslipno ' + CHAR(13)
                  + N' JOIN LOADPLANDETAIL LPD (NOLOCK) ON LPD.Loadkey = PH.Loadkey ' + CHAR(13)
                  + N' JOIN ORDERS ORD (NOLOCK) ON LPD.Orderkey = ORD.Orderkey ' + CHAR(13)
                  + N' JOIN PICKDETAIL PDET (NOLOCK) ON PDET.Orderkey = ORD.Orderkey AND PDET.CaseID = PD.LabelNo ' + CHAR(13)
                  + N'                              AND PDET.Storerkey = PD.Storerkey AND PDET.SKU = PD.SKU ' + CHAR(13)
                  + N' LEFT JOIN PACKINFO PI (NOLOCK) ON PI.Pickslipno = PD.Pickslipno AND PI.Cartonno = PD.Cartonno ' + CHAR(13)
                  + N' WHERE PH.Pickslipno = @c_Sparm01 ' + CHAR(13)
                  + N' AND PD.Cartonno >= CONVERT(INT,@c_Sparm02) ' + CHAR(13)
                  + N' AND PD.Cartonno <= CONVERT(INT,@c_Sparm03) '
                  + N' AND ORD.DocType = ''N'' '

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
   
   IF @b_debug = 1
   BEGIN
      PRINT @c_SQL
   END

   IF @b_debug = 1
   BEGIN
      SELECT *
      FROM #Result (NOLOCK)
   END

   DECLARE CUR_RowNoLoop CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
   SELECT DISTINCT Col60, CAST(Col03 AS INT)      
   FROM #Result   
   ORDER BY Col60, CAST(Col03 AS INT)  
   
   OPEN CUR_RowNoLoop     
     
   FETCH NEXT FROM CUR_RowNoLoop INTO @c_Pickslipno, @c_CartonNo   
   
   WHILE @@FETCH_STATUS <> -1   
   BEGIN  
      INSERT INTO #TMP_DET ( Pickslipno, Cartonno, Loc, Notes2, SKU, Qty, Retrieve ) 
      SELECT @c_Pickslipno, @c_CartonNo, PDET.Loc
           , ISNULL(TRIM(S.Notes2),'')
           , S.BUSR5, SUM(PD.Qty), 'N'  
      FROM PACKHEADER PH WITH (NOLOCK)  
      JOIN PACKDETAIL PD WITH (NOLOCK) ON PH.PickSlipNo = PD.Pickslipno        
      JOIN SKU S WITH (NOLOCK) ON S.Sku = PD.SKU AND S.Storerkey = PH.Storerkey
      CROSS APPLY ( SELECT TOP 1 PICKDETAIL.Loc
                    FROM PICKDETAIL (NOLOCK)
                    WHERE PICKDETAIL.CaseID = PD.LabelNo
                    AND PICKDETAIL.Storerkey = PD.Storerkey AND PICKDETAIL.SKU = PD.SKU ) AS PDET
      WHERE PD.PickSlipNo = @c_Pickslipno     
      AND PD.CartonNo = CAST(@c_CartonNo AS INT)  
      GROUP BY PDET.Loc
             , ISNULL(TRIM(S.Notes2),'')
             , S.BUSR5
             , CAST(PD.LabelLine AS INT)
      ORDER BY CAST(PD.LabelLine AS INT)  

      SET @c_SKU01 = ''
      SET @c_SKU02 = ''
      SET @c_SKU03 = ''
      SET @c_SKU04 = ''
      SET @c_SKU05 = ''
      SET @c_SKU06 = ''
      SET @c_SKU07 = ''
      SET @c_SKU08 = ''
      SET @c_SKU09 = ''
      SET @c_SKU10 = ''
      SET @c_SKU11 = ''
      SET @c_SKU12 = ''
      SET @c_SKU13 = ''
      SET @c_SKU14 = ''
      SET @c_SKU15 = ''
      SET @c_SKU16 = ''
      SET @c_SKU17 = ''
      SET @c_SKU18 = ''
      SET @c_SKU19 = ''
      SET @c_SKU20 = ''
      SET @c_SKU21 = ''
      SET @c_SKU22 = ''
      SET @c_Qty01 = ''
      SET @c_Qty02 = ''
      SET @c_Qty03 = ''
      SET @c_Qty04 = ''
      SET @c_Qty05 = ''
      SET @c_Qty06 = ''
      SET @c_Qty07 = ''
      SET @c_Qty08 = ''
      SET @c_Qty09 = ''
      SET @c_Qty10 = ''
      SET @c_Qty11 = ''
      SET @c_Qty12 = ''
      SET @c_Qty13 = ''
      SET @c_Qty14 = ''
      SET @c_Qty15 = ''
      SET @c_Qty16 = ''
      SET @c_Qty17 = ''
      SET @c_Qty18 = ''
      SET @c_Qty19 = ''
      SET @c_Qty20 = ''
      SET @c_Qty21 = ''
      SET @c_Qty22 = ''

      IF @b_debug = 1  
         SELECT * FROM #TMP_DET  
   
      SELECT @n_CntRec = COUNT (1)    
      FROM #TMP_DET  
      WHERE Pickslipno = @c_Pickslipno  
      AND CartonNo = @c_CartonNo  
      AND Retrieve = 'N'  

      SET @n_TTLpage =  FLOOR(@n_CntRec / @n_MaxLine ) + CASE WHEN @n_CntRec % @n_MaxLine > 0 THEN 1 ELSE 0 END     

      WHILE @n_intFlag <= @n_CntRec               
      BEGIN  
         IF @n_intFlag > @n_MaxLine AND (@n_intFlag % @n_MaxLine) = 1  
         BEGIN   
            SET @n_CurrentPage = @n_CurrentPage + 1  
   
            IF (@n_CurrentPage > @n_TTLpage)     
            BEGIN    
               BREAK;    
            END  
           
            INSERT INTO #Result ( Col01,Col02,Col03,Col04,Col05,Col06,Col07,Col08,Col09                     
                                , Col10,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20,Col21,Col22                   
                                , Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30,Col31,Col32,Col33,Col34                    
                                , Col35,Col36,Col37,Col38,Col39,Col40,Col41,Col42,Col43,Col44                     
                                , Col45,Col46,Col47,Col48,Col49,Col50,Col51,Col52,Col53,Col54                   
                                , Col55,Col56,Col57,Col58,Col59,Col60)     
            SELECT TOP 1 Col01,Col02,Col03,'',Col05,Col06,'','','',''
                       , '','','','','','','','','',''
                       , '','','','','','','','','',''
                       , '','','','','','','','','',''
                       , '','','','','','','','','',''
                       , '','','','','','','','','',Col60
            FROM #Result 
   
            SET @c_SKU01 = ''
            SET @c_SKU02 = ''
            SET @c_SKU03 = ''
            SET @c_SKU04 = ''
            SET @c_SKU05 = ''
            SET @c_SKU06 = ''
            SET @c_SKU07 = ''
            SET @c_SKU08 = ''
            SET @c_SKU09 = ''
            SET @c_SKU10 = ''
            SET @c_SKU11 = ''
            SET @c_SKU12 = ''
            SET @c_SKU13 = ''
            SET @c_SKU14 = ''
            SET @c_SKU15 = ''
            SET @c_SKU16 = ''
            SET @c_SKU17 = ''
            SET @c_SKU18 = ''
            SET @c_SKU19 = ''
            SET @c_SKU20 = ''
            SET @c_SKU21 = ''
            SET @c_SKU22 = ''
            SET @c_Qty01 = ''
            SET @c_Qty02 = ''
            SET @c_Qty03 = ''
            SET @c_Qty04 = ''
            SET @c_Qty05 = ''
            SET @c_Qty06 = ''
            SET @c_Qty07 = ''
            SET @c_Qty08 = ''
            SET @c_Qty09 = ''
            SET @c_Qty10 = ''
            SET @c_Qty11 = ''
            SET @c_Qty12 = ''
            SET @c_Qty13 = ''
            SET @c_Qty14 = ''
            SET @c_Qty15 = ''
            SET @c_Qty16 = ''
            SET @c_Qty17 = ''
            SET @c_Qty18 = ''
            SET @c_Qty19 = ''
            SET @c_Qty20 = ''
            SET @c_Qty21 = ''
            SET @c_Qty22 = ''
         END  
         
         SELECT @c_Loc   = Loc 
              , @c_SKU   = SKU
              , @c_Qty   = Qty  
              , @c_Notes = Notes2
         FROM #TMP_DET   
         WHERE ID = @n_intFlag  

         SELECT @c_Notes_1 = FDS.ColValue
         FROM FNC_DelimSplit('|', @c_Notes) FDS
         WHERE SeqNo = 1

         SELECT @c_Notes_2 = FDS.ColValue
         FROM FNC_DelimSplit('|', @c_Notes) FDS
         WHERE SeqNo = 2
         
         SET @c_Notes = CONVERT(NCHAR(10),ISNULL(@c_Loc,'')) 
                      + CONVERT(NCHAR(15),ISNULL(@c_Notes_1,''))
                      + CONVERT(NCHAR(15),ISNULL(@c_Notes_2,''))
                      + CONVERT(NCHAR(30),ISNULL(@c_SKU,''))

         IF (@n_intFlag % @n_MaxLine) = 1
         BEGIN   
            SET @c_SKU01 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty01 = @c_Qty  
         END     
         ELSE IF (@n_intFlag % @n_MaxLine) = 2  
         BEGIN     
            SET @c_SKU02 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty02 = @c_Qty        
         END    
         ELSE IF (@n_intFlag % @n_MaxLine) = 3  
         BEGIN     
            SET @c_SKU03 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty03 = @c_Qty      
         END   
         ELSE IF (@n_intFlag % @n_MaxLine) = 4  
         BEGIN     
            SET @c_SKU04 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty04 = @c_Qty        
         END   
         ELSE IF (@n_intFlag % @n_MaxLine) = 5 
         BEGIN     
            SET @c_SKU05 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty05 = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 6  
         BEGIN     
            SET @c_SKU06 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty06 = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 7  
         BEGIN     
            SET @c_SKU07 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty07 = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 8  
         BEGIN     
            SET @c_SKU08 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty08 = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 9  
         BEGIN     
            SET @c_SKU09 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty09 = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 10 
         BEGIN     
            SET @c_SKU10 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty10 = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 11  
         BEGIN     
            SET @c_SKU11 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty11 = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 12  
         BEGIN     
            SET @c_SKU12 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty12 = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 13  
         BEGIN     
            SET @c_SKU13 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty13 = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 14  
         BEGIN     
            SET @c_SKU14 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty14 = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 15  
         BEGIN     
            SET @c_SKU15 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty15 = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 16  
         BEGIN     
            SET @c_SKU16 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty16 = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 17  
         BEGIN     
            SET @c_SKU17 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty17 = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 18  
         BEGIN     
            SET @c_SKU18 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty18 = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 19  
         BEGIN     
            SET @c_SKU19 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty19 = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 20 
         BEGIN     
            SET @c_SKU20 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty20 = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 21  
         BEGIN     
            SET @c_SKU21 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes              
            SET @c_Qty21 = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 0
         BEGIN     
            SET @c_SKU22 = RIGHT('000'+ CAST(@n_intFlag AS NVARCHAR), 3) + @c_Notes                    
            SET @c_Qty22 = @c_Qty      
         END       

         UPDATE #Result  
         SET   Col07 = @c_SKU01         
             , Col08 = @c_SKU02         
             , Col09 = @c_SKU03      
             , Col10 = @c_SKU04       
             , Col11 = @c_SKU05         
             , Col12 = @c_SKU06         
             , Col13 = @c_SKU07     
             , Col14 = @c_SKU08  
             , Col15 = @c_SKU09  
             , Col16 = @c_SKU10
             , Col17 = @c_SKU11
             , Col18 = @c_SKU12
             , Col19 = @c_SKU13
             , Col20 = @c_SKU14
             , Col21 = @c_SKU15
             , Col22 = @c_SKU16
             , Col23 = @c_SKU17
             , Col24 = @c_SKU18
             , Col25 = @c_SKU19
             , Col26 = @c_SKU20
             , Col27 = @c_SKU21
             , Col28 = @c_SKU22
             , Col29 = @c_Qty01
             , Col30 = @c_Qty02
             , Col31 = @c_Qty03
             , Col32 = @c_Qty04
             , Col33 = @c_Qty05
             , Col34 = @c_Qty06
             , Col35 = @c_Qty07
             , Col36 = @c_Qty08
             , Col37 = @c_Qty09
             , Col38 = @c_Qty10
             , Col39 = @c_Qty11
             , Col40 = @c_Qty12
             , Col41 = @c_Qty13
             , Col42 = @c_Qty14
             , Col43 = @c_Qty15
             , Col44 = @c_Qty16
             , Col45 = @c_Qty17
             , Col46 = @c_Qty18
             , Col47 = @c_Qty19
             , Col48 = @c_Qty20
             , Col49 = @c_Qty21
             , Col50 = @c_Qty22
             , Col04 = @n_CurrentPage
         WHERE ID = @n_CurrentPage 
         AND Col60 <> ''  
   
         UPDATE #TMP_DET  
         SET Retrieve = 'Y'  
         WHERE ID = @n_intFlag  
   
         SET @n_intFlag = @n_intFlag + 1  
        
         IF @n_intFlag > @n_CntRec    
         BEGIN    
            BREAK;    
         END    
      END  
   
      SELECT @n_SumQty = SUM(PD.Qty)
      FROM PACKDETAIL PD (NOLOCK)  
      WHERE PD.PickSlipNo = @c_Pickslipno  
      AND PD.CartonNo = @c_CartonNo  
   
      UPDATE #Result  
      SET Col51 = @n_SumQty 
      WHERE Col60 = @c_Pickslipno  
      AND Col03 = @c_CartonNo  
   
      FETCH NEXT FROM CUR_RowNoLoop INTO @c_Pickslipno, @c_CartonNo    
   END  
   CLOSE CUR_RowNoLoop  
   DEALLOCATE CUR_RowNoLoop

   SELECT *
   FROM #Result (NOLOCK)
   ORDER BY ID

   EXIT_SP:

   SET @d_Trace_EndTime = GETDATE()
   SET @c_UserName = SUSER_SNAME()

END -- procedure     
GO
GRANT EXECUTE ON [dbo].[isp_BT_Bartender_CN_SHIPUCCLBL_LB] TO [NSQL]
GO