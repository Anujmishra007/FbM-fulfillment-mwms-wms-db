SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/********************************************************************************/
/* Copyright: LFL                                                               */
/* Purpose: isp_BT_Bartender_IN_UCCLBL_001                                      */
/*                                                                              */
/* Modifications log:                                                           */
/*                                                                              */
/* Date       Rev  Author     Purposes                                          */
/* 2023-06-27 1.0  CSCHONG    Created (WMS-22822)                               */
/* 2023-06-27 1.0  CSCHONG    DevOps Combine Script                             */
/********************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_BT_Bartender_IN_UCCLBL_001]
(  @c_Sparm01            NVARCHAR(250),
   @c_Sparm02            NVARCHAR(250),
   @c_Sparm03            NVARCHAR(250),
   @c_Sparm04            NVARCHAR(250),
   @c_Sparm05            NVARCHAR(250),
   @c_Sparm06            NVARCHAR(250),
   @c_Sparm07            NVARCHAR(250),
   @c_Sparm08            NVARCHAR(250),
   @c_Sparm09            NVARCHAR(250),
   @c_Sparm10            NVARCHAR(250),
   @b_debug              INT = 0
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   --SET ANSI_WARNINGS OFF

   DECLARE @n_intFlag            INT,
           @n_CntRec             INT,
           @c_SQL                NVARCHAR(4000),
           @c_SQLSORT            NVARCHAR(4000),
           @c_SQLJOIN            NVARCHAR(4000),
           @c_ExecStatements     NVARCHAR(4000),
           @c_ExecArguments      NVARCHAR(4000),

           @n_TTLpage            INT,
           @n_CurrentPage        INT,
           @n_MaxLine            INT,
           @n_Continue           INT,
           @c_cartonno           NVARCHAR(10),
           @c_Storerkey          NVARCHAR(15),
           @c_piclskipno         NVARCHAR(20),
           @c_JoinStatement      NVARCHAR(4000)

   DECLARE @c_SKU01              NVARCHAR(80),
           @c_SKU02              NVARCHAR(80),
           @c_SKU03              NVARCHAR(80),
           @c_SKU04              NVARCHAR(80),
           @c_SKU05              NVARCHAR(80),
           @c_SKU06              NVARCHAR(80),
           @c_SKU07              NVARCHAR(80),
           @c_SKU_DESCR01        NVARCHAR(80),
           @c_SKU_DESCR02        NVARCHAR(80),
           @c_SKU_DESCR03        NVARCHAR(80),
           @c_SKU_DESCR04        NVARCHAR(80),
           @c_SKU_DESCR05        NVARCHAR(80),
           @c_SKU_DESCR06        NVARCHAR(80),
           @c_SKU_DESCR07        NVARCHAR(80),
           @c_SKU_PQty01         NVARCHAR(10),
           @c_SKU_PQty02         NVARCHAR(10),
           @c_SKU_PQty03         NVARCHAR(10),
           @c_SKU_PQty04         NVARCHAR(10),
           @c_SKU_PQty05         NVARCHAR(10),
           @c_SKU_PQty06         NVARCHAR(10),
           @c_SKU_PQty07         NVARCHAR(10),
           @c_SKU                NVARCHAR(80),
           @c_SKU_DESCR          NVARCHAR(80),
           @n_SKU_PQty           INT,
           @c_SSCC               NVARCHAR(10),
           @n_Total_PQty         INT,
           @n_Total_CQty         INT,
           @c_dropid             NVARCHAR(20)   

   SET @n_CurrentPage = 1
   SET @n_TTLpage = 1
   SET @n_MaxLine = 7
   SET @n_CntRec = 1
   SET @n_intFlag = 1
   SET @c_JoinStatement = ''
   SET @c_SQL = ''
   SET @n_Continue = 1

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

CREATE TABLE [#TMP_SKUDET] (
      [ID]                    [INT] IDENTITY(1,1) NOT NULL,
      [Pickslipno]            [NVARCHAR] (20) NULL,
      [cartonno]              [NVARCHAR] (20) NULL,
      [dropid]                [NVARCHAR] (20) NULL,
      [SKU]                   [NVARCHAR] (80) NULL,
      [SDESCR]                [NVARCHAR] (60) NULL,
      [Qty]                   INT NULL,
      [Retrieve]              [NVARCHAR] (1) DEFAULT 'N')



            INSERT INTO #Result (Col01,Col02,Col03,Col04,Col05, Col06,Col07,Col08,Col09  
                                 ,Col10,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20,Col21,Col22  
                                 ,Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30,Col31,Col32,Col33,Col34  
                                 ,Col35,Col36,Col37,Col38,Col39,Col40,Col41,Col42,Col43,Col44  
                                 ,Col45,Col46,Col47,Col48,Col49,Col50,Col51,Col52,Col53,Col54  
                                 ,Col55,Col56,Col57,Col58,Col59,Col60)  
  
  
  
      SELECT DISTINCT PD.CartonNo,OH.ExternOrderKey,PD.LabelNo,PD.LabelNo,OH.C_Company,  
                  SUBSTRING(ISNULL(OH.C_Address1,'')+SPACE(1)+ISNULL(OH.C_Address2,''),1,80),'','', '','',    --10  
                  '','','','','',     --15  
                  '','','','','',     --20  
                  '','','','','','','','','','',  --30  
                  '','','','','','','','','','',   --40  
                  '','','','','','','','','','',   --50  
                  '','','','','','','','','',PH.PickSlipNo    --60  
      FROM PACKHEADER PH WITH (NOLOCK) 
      JOIN PACKDETAIL PD WITH (NOLOCK) ON PD.PickSlipNo = PH.PickSlipNo
      JOIN ORDERS OH WITH (NOLOCK) ON OH.OrderKey = PH.OrderKey 
      JOIN SKU S WITH (NOLOCK) ON PD.StorerKey = S.StorerKey AND PD.sku = S.Sku
      WHERE PD.CartonNo = @c_Sparm02 
      AND PD.LabelNo = @c_Sparm03
      AND PH.StorerKey = @c_Sparm01
     AND PD.PickSlipNo = @c_Sparm04



   IF @n_Continue IN (1,2)
   BEGIN
      DECLARE CUR_RowNoLoop CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT col01,col60,col03
      FROM #Result

      OPEN CUR_RowNoLoop

      FETCH NEXT FROM CUR_RowNoLoop INTO @c_cartonno,@c_piclskipno,@c_dropid

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         SET @c_SKU01       = ''
         SET @c_SKU02       = ''
         SET @c_SKU03       = ''
         SET @c_SKU04       = ''
         SET @c_SKU05       = ''
         SET @c_SKU06       = ''
         SET @c_SKU07       = ''
         SET @c_SKU_DESCR01 = ''
         SET @c_SKU_DESCR02 = ''
         SET @c_SKU_DESCR03 = ''
         SET @c_SKU_DESCR04 = ''
         SET @c_SKU_DESCR05 = ''
         SET @c_SKU_DESCR06 = ''
         SET @c_SKU_DESCR07 = ''
         SET @c_SKU_PQty01  = ''
         SET @c_SKU_PQty02  = ''
         SET @c_SKU_PQty03  = ''
         SET @c_SKU_PQty04  = ''
         SET @c_SKU_PQty05  = ''
         SET @c_SKU_PQty06  = ''
         SET @c_SKU_PQty07  = ''
         --SET @c_SSCC01  = ''
         --SET @c_SSCC02  = ''
         --SET @c_SSCC03  = ''
         --SET @c_SSCC04  = ''
         --SET @c_SSCC05  = ''
         --SET @c_SSCC06  = ''
         --SET @c_SSCC07  = ''

       INSERT INTO #TMP_SKUDET
       (
           Pickslipno,
           cartonno,
           dropid,
           SKU,
           SDESCR,
           Qty,
           Retrieve
       )
      SELECT PD.PickSlipNo,PD.CartonNo,PD.LabelNo, PD.SKU, SKU.Descr, PD.Qty, 'N'
      FROM PackDetail PD (NOLOCK)
      JOIN SKU WITH (NOLOCK) ON SKU.StorerKey = PD.StorerKey AND SKU.Sku = PD.SKU
     -- JOIN dbo.PICKDETAIL PIDET ON PIDET.PickSlipNo = PD.PickSlipNo
     -- JOIN dbo.LOTATTRIBUTE LOTT (NOLOCK) ON LOTT.StorerKey = PIDET.Storerkey AND LOTT.Sku = PIDET.Sku AND LOTT.Lot = PIDET.Lot
      AND PD.Storerkey = @c_Sparm01 AND PD.PickSlipNo = @c_piclskipno AND PD.CartonNo = CAST(@c_cartonno AS INT) AND pd.LabelNo =@c_dropid

         SELECT @n_CntRec = COUNT (1)
         FROM #TMP_SKUDET
         WHERE cartonno = CAST(@c_cartonno AS INT)
         AND Pickslipno = @c_piclskipno  
         AND dropid = @c_dropid
         AND Retrieve = 'N'

       IF @b_debug = '1'
       BEGIN
           SELECT @n_CntRec,'@n_CntRec',* FROM #TMP_SKUDET
       END
         SET @n_TTLpage =  FLOOR(@n_CntRec / @n_MaxLine ) + CASE WHEN @n_CntRec % @n_MaxLine > 0 THEN 1 ELSE 0 END

    IF @n_CntRec = 0
    BEGIN
      SET @n_CntRec = 0
    END

         WHILE @n_intFlag <= @n_CntRec
         BEGIN
            IF @n_intFlag > @n_MaxLine AND (@n_intFlag % @n_MaxLine) = 1 --AND @c_LastRec = 'N'
            BEGIN
               SET @n_CurrentPage = @n_CurrentPage + 1

               IF (@n_CurrentPage > @n_TTLpage)
               BEGIN
                  BREAK;
               END



               INSERT INTO #Result (Col01,Col02,Col03,Col04,Col05, Col06,Col07,Col08,Col09
                                   ,Col10,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20,Col21,Col22
                                   ,Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30,Col31,Col32,Col33,Col34
                                   ,Col35,Col36,Col37,Col38,Col39,Col40,Col41,Col42,Col43,Col44
                                   ,Col45,Col46,Col47,Col48,Col49,Col50,Col51,Col52,Col53,Col54
                                   ,Col55,Col56,Col57,Col58,Col59,Col60)
               SELECT TOP 1 Col01,Col02,Col03,col04,col05,col06,'','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','',Col60
               FROM #Result

               SET @c_SKU01       = ''
               SET @c_SKU02       = ''
               SET @c_SKU03       = ''
               SET @c_SKU04       = ''
               SET @c_SKU05       = ''
               SET @c_SKU06       = ''
               SET @c_SKU07       = ''
               SET @c_SKU_DESCR01 = ''
               SET @c_SKU_DESCR02 = ''
               SET @c_SKU_DESCR03 = ''
               SET @c_SKU_DESCR04 = ''
               SET @c_SKU_DESCR05 = ''
               SET @c_SKU_DESCR06 = ''
               SET @c_SKU_DESCR07 = ''
               SET @c_SKU_PQty01  = ''
               SET @c_SKU_PQty02  = ''
               SET @c_SKU_PQty03  = ''
               SET @c_SKU_PQty04  = ''
               SET @c_SKU_PQty05  = ''
               SET @c_SKU_PQty06  = ''
               SET @c_SKU_PQty07  = ''
               --SET @c_SSCC01  = ''
               --SET @c_SSCC02  = ''
               --SET @c_SSCC03  = ''
               --SET @c_SSCC04  = ''

            END

   IF @n_CntRec <>0
   BEGIN 
            SELECT @c_SKU       = T.SKU
                 , @c_SKU_DESCR = T.SDESCR
                 , @n_SKU_PQty  = SUM(T.Qty)
              --   , @c_SSCC  = T.SSCC
            FROM #TMP_SKUDET T
            WHERE ID = @n_intFlag
            GROUP BY T.SKU, T.SDESCR--,T.SSCC


            IF (@n_intFlag % @n_MaxLine) = 1
            BEGIN
              SET @c_SKU01 = @c_SKU
              SET @c_SKU_DESCR01 = @c_SKU_DESCR
              SET @c_SKU_PQty01 = CONVERT(NVARCHAR(10),@n_SKU_PQty)

            END
            ELSE IF (@n_intFlag % @n_MaxLine) = 2
            BEGIN
              SET @c_SKU02 = @c_SKU
              SET @c_SKU_DESCR02 = @c_SKU_DESCR
              SET @c_SKU_PQty02 = CONVERT(NVARCHAR(10),@n_SKU_PQty)

            END
            ELSE IF (@n_intFlag % @n_MaxLine) = 3
            BEGIN
              SET @c_SKU03 = @c_SKU
              SET @c_SKU_DESCR03 = @c_SKU_DESCR
              SET @c_SKU_PQty03 = CONVERT(NVARCHAR(10),@n_SKU_PQty)

            END
            ELSE IF (@n_intFlag % @n_MaxLine) = 4
            BEGIN
              SET @c_SKU04 = @c_SKU
              SET @c_SKU_DESCR04 = @c_SKU_DESCR
              SET @c_SKU_PQty04 = CONVERT(NVARCHAR(10),@n_SKU_PQty)

            END
            ELSE IF (@n_intFlag % @n_MaxLine) = 5
            BEGIN
              SET @c_SKU05 = @c_SKU
              SET @c_SKU_DESCR05 = @c_SKU_DESCR
              SET @c_SKU_PQty05 = CONVERT(NVARCHAR(10),@n_SKU_PQty)

            END
            ELSE IF (@n_intFlag % @n_MaxLine) = 6
            BEGIN
              SET @c_SKU06 = @c_SKU
              SET @c_SKU_DESCR06 = @c_SKU_DESCR
              SET @c_SKU_PQty06 = CONVERT(NVARCHAR(10),@n_SKU_PQty)

            END
            ELSE IF (@n_intFlag % @n_MaxLine) = 0
            BEGIN
              SET @c_SKU07 = @c_SKU
              SET @c_SKU_DESCR07 = @c_SKU_DESCR
              SET @c_SKU_PQty07 = CONVERT(NVARCHAR(10),@n_SKU_PQty)

            END


            UPDATE #Result
            SET Col07 = @c_SKU01
              , Col08 = @c_SKU_DESCR01
              , Col09 = @c_SKU_PQty01
              , Col10 = @c_SKU02
              , Col11 = @c_SKU_DESCR02
              , Col12 = @c_SKU_PQty02
              , Col13 = @c_SKU03
              , Col14 = @c_SKU_DESCR03
              , Col15 = @c_SKU_PQty03
              , Col16 = @c_SKU04
              , Col17 = @c_SKU_DESCR04
              , Col28 = @c_SKU_PQty04
              , Col19 = @c_SKU05
              , Col20 = @c_SKU_DESCR05
              , Col21 = @c_SKU_PQty05
              , Col22 = @c_SKU06
              , Col23 = @c_SKU_DESCR06
              , Col24 = @c_SKU_PQty06
              , Col25 = @c_SKU07
              , Col26 = @c_SKU_DESCR07
              , Col27 = @c_SKU_PQty07
            WHERE ID = @n_CurrentPage

            UPDATE #TMP_SKUDET
            SET Retrieve ='Y'
            WHERE ID = @n_intFlag

            SET @n_intFlag = @n_intFlag + 1

            IF @n_intFlag > @n_CntRec
            BEGIN
               BREAK;
            END
          END
         END

         FETCH NEXT FROM CUR_RowNoLoop INTO @c_cartonno,@c_piclskipno,@c_dropid
      END -- While
      CLOSE CUR_RowNoLoop
      DEALLOCATE CUR_RowNoLoop


    IF @n_CntRec = 0
    BEGIN
      SET @n_Total_PQty = 0
    END
    ELSE
    BEGIN

      SELECT @n_Total_PQty = SUM(T.Qty)
      FROM #TMP_SKUDET T

   END

      UPDATE #Result
      SET Col34 = CAST(@n_Total_PQty AS NVARCHAR(80))
      WHERE col03 = @c_Sparm04
     
   END

EXIT_SP:
   SELECT * FROM #Result (nolock)
   ORDER BY ID

   IF OBJECT_ID('tempdb..#TMP_SKUDET') IS NOT NULL
      DROP TABLE #TMP_SKUDET

   IF OBJECT_ID('tempdb..#Result') IS NOT NULL
      DROP TABLE #Result

END -- procedure
GO
GRANT EXECUTE ON  [dbo].[isp_BT_Bartender_IN_UCCLBL_001] TO [NSQL]
GO
