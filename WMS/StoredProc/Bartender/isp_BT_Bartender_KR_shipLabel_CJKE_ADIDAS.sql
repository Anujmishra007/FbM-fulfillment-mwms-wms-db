SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Copyright: MAERSK                                                          */
/* Purpose: isp_BT_Bartender_KR_shipLabel_CJKE_ADIDAS                         */
/*          Modified from isp_BT_Bartender_KR_shipLabel_CJKE                  */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date        Rev  Author    Purposes                                        */
/* 26-Nov-2023 1.0  WLChooi   Created (WMS-24242)                             */
/* 26-Nov-2023 1.0  WLChooi   DevOps Combine Script                           */
/******************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_BT_Bartender_KR_shipLabel_CJKE_ADIDAS]
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

   DECLARE @n_MaxLine       INT
         , @c_OHCompany     NVARCHAR(45)
         , @c_OHAddress     NVARCHAR(80)
         , @c_OHPhone1      NVARCHAR(80)
         , @c_OHZip         NVARCHAR(80)
         , @c_ExtOrdkey     NVARCHAR(30)
         , @c_Pickslipno    NVARCHAR(20)
         , @c_STNotes2      NVARCHAR(60)
         , @c_OHComdescr    NVARCHAR(80)
         , @c_OHPhone1descr NVARCHAR(80)
         , @c_OHUDF04descr  NVARCHAR(80)
         , @c_OHUDF04       NVARCHAR(80)
         , @c_OHMCountry    NVARCHAR(80)
         , @c_OHMState      NVARCHAR(80)
         , @c_OHUDF03       NVARCHAR(80)
         , @c_OHMcity       NVARCHAR(80)
         , @c_OHMContact1   NVARCHAR(80)
         , @n_CartonNo      INT
         , @c_OHMContact2   NVARCHAR(80)
         , @c_OHccity       NVARCHAR(80)
         , @c_OHbcity       NVARCHAR(80)
         , @c_OHMAdd3       NVARCHAR(80)
         , @c_OHMAdd4       NVARCHAR(80)
         , @c_labelno       NVARCHAR(20)
         , @n_MAxCarton     INT
         , @c_OHDisPlace    NVARCHAR(30)
         , @c_OHNotes       NVARCHAR(80)
         , @c_CLNotes       NVARCHAR(80)
         , @n_ctnsku        INT = 0
         , @c_Orderkey      NVARCHAR(10)
         , @c_DeliveryNote  NVARCHAR(80)
         , @c_B_Addr        NVARCHAR(80)
         , @c_B_Contact1    NVARCHAR(80)
         , @c_Col50         NVARCHAR(80)
         , @c_C_Contact1    NVARCHAR(80)

   DECLARE @c_line01    NVARCHAR(80)
         , @c_SKU01     NVARCHAR(80)
         , @c_SKUDesr01 NVARCHAR(80)
         , @n_qty01     INT
         , @c_line02    NVARCHAR(80)
         , @c_SKU02     NVARCHAR(80)
         , @c_SKUDesr02 NVARCHAR(80)
         , @n_qty02     INT
         , @c_line03    NVARCHAR(80)
         , @c_SKU03     NVARCHAR(80)
         , @c_SKUDesr03 NVARCHAR(80)
         , @n_qty03     INT
         , @c_line04    NVARCHAR(80)
         , @c_SKU04     NVARCHAR(80)
         , @c_SKUDesr04 NVARCHAR(80)
         , @n_qty04     INT
         , @c_line05    NVARCHAR(80)
         , @c_SKU05     NVARCHAR(80)
         , @c_SKUDesr05 NVARCHAR(80)
         , @n_qty05     INT
         , @c_line06    NVARCHAR(80)
         , @c_SKU06     NVARCHAR(80)
         , @c_SKUDesr06 NVARCHAR(80)
         , @n_qty06     INT

   DECLARE @c_SQL     NVARCHAR(4000)
         , @c_SQLSORT NVARCHAR(4000)
         , @c_SQLJOIN NVARCHAR(4000)
         , @n_TTLpage INT

   DECLARE @d_Trace_StartTime  DATETIME
         , @d_Trace_EndTime    DATETIME
         , @c_Trace_ModuleName NVARCHAR(20)
         , @d_Trace_Step1      DATETIME
         , @c_Trace_Step1      NVARCHAR(20)
         , @c_UserName         NVARCHAR(20)

   DECLARE @n_CntRec      INT
         , @n_CurrentPage INT
         , @n_intFlag     INT
         , @c_SKU         NVARCHAR(80)
         , @c_SKUDesr     NVARCHAR(80)
         , @n_qty         INT

   SET @n_CurrentPage = 1
   SET @n_TTLpage = 1
   SET @n_MaxLine = 6
   SET @n_CntRec = 1
   SET @n_intFlag = 1

   SET @d_Trace_StartTime = GETDATE()
   SET @c_Trace_ModuleName = N''

   -- SET RowNo = 0                     
   SET @c_SQL = N''

   DECLARE @c_Storerkey      NVARCHAR(15)
         , @c_ShowPackdetail NVARCHAR(1) = N'N'

   SELECT @c_Storerkey = StorerKey
   FROM PackHeader (NOLOCK)
   WHERE PickSlipNo = @c_Sparm1

   IF EXISTS (  SELECT 1
                FROM CODELKUP (NOLOCK)
                WHERE LISTNAME = 'CJKECUSTID' AND Storerkey = @c_Storerkey AND UDF02 = 'SKULabel')
   BEGIN
      SET @c_ShowPackdetail = N'Y'
   END

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

   CREATE TABLE [#SKULULUContent]
   (
      [ID]          [INT]          IDENTITY(1, 1) NOT NULL
    , [Pickslipno]  [NVARCHAR](20) NULL
    , [labelno]     [NVARCHAR](20) NULL
    , [labellineno] [NVARCHAR](10) NULL
    , [SKU]         [NVARCHAR](20) NULL
    , [SDESCR]      [NVARCHAR](80) NULL
    , [skuqty]      INT            NULL
    , [Retrieve]    [NVARCHAR](1)  DEFAULT 'N'
   )


   IF @b_debug = 1
   BEGIN
      PRINT 'start'
   END

   SET @c_SKU01 = N''
   SET @c_SKUDesr01 = N''
   SET @n_qty01 = 0
   SET @c_SKU02 = N''
   SET @c_SKUDesr02 = N''
   SET @n_qty02 = 0
   SET @c_SKU03 = N''
   SET @c_SKUDesr03 = N''
   SET @n_qty03 = 0

   DECLARE CUR_StartRecLoop CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT DISTINCT o.C_Company
                 , ISNULL(o.C_Phone1, '')
                 , (ISNULL(o.C_Address1, '') + ISNULL(o.C_Address2, '') + ISNULL(o.C_Address3, ''))
                 , ISNULL(o.C_Zip, '')
                 , ISNULL(ST.Notes2, '')
                 , (SUBSTRING(o.C_Company, 1, LEN(o.C_Company) - LEN(RIGHT(o.C_Company, 1))) + '*')
                 , (SUBSTRING(o.C_Phone1, 1, LEN(o.C_Phone1) - LEN(RIGHT(o.C_Phone1, 4))) + '****')
                 , (SUBSTRING(pd.LabelNo, 1, 4) + '-' + SUBSTRING(pd.LabelNo, 5, 4) + '-' + SUBSTRING(pd.LabelNo, 9, 4))
                 , ISNULL(pd.LabelNo, '')
                 , ISNULL(o.M_Country, '')
                 , ISNULL(o.M_State, '')
                 , ISNULL(o.UserDefine03, '')
                 , ISNULL(o.M_City, '')
                 , ISNULL(o.M_Contact1, '')
                 , pd.CartonNo
                 , o.ExternOrderKey
                 , ISNULL(o.M_Contact2, '')
                 , ISNULL(o.C_City, '')
                 , ISNULL(o.B_City, '')
                 , ISNULL(o.M_Address4, '')
                 , pd.LabelNo
                 , MAX(pd.CartonNo)
                 , pd.PickSlipNo
                 , o.DischargePlace
                 , ISNULL(o.M_Address3, '')
                 , SUBSTRING(o.Notes, 1, 80)
                 , ISNULL(CL.Notes, '')
                 , o.OrderKey
                 , ISNULL(TRIM(o.DeliveryNote), '')
                 , LEFT(ISNULL(TRIM(ST.B_Address1), '') + ISNULL(TRIM(ST.B_Address2), ''), 80)
                 , ISNULL(TRIM(ST.B_contact1), '')
                 , ISNULL(TRIM(C1.Notes), '')
                 , ISNULL(TRIM(o.C_Contact1), '')
   FROM PackHeader AS ph WITH (NOLOCK)
   JOIN PackDetail AS pd ON pd.PickSlipNo = ph.PickSlipNo
   JOIN ORDERS AS o WITH (NOLOCK) ON o.OrderKey = ph.OrderKey
   JOIN STORER ST WITH (NOLOCK) ON ST.StorerKey = o.StorerKey
   LEFT JOIN PackInfo PIF (NOLOCK) ON pd.CartonNo = PIF.CartonNo AND pd.PickSlipNo = PIF.PickSlipNo
   LEFT JOIN CODELKUP CL WITH (NOLOCK) ON  CL.LISTNAME = 'CARRIERBOX'
                                       AND CL.Code = ISNULL(PIF.CartonType, '')
                                       AND CL.Storerkey = ph.StorerKey
   LEFT JOIN CODELKUP C1 WITH (NOLOCK) ON  C1.LISTNAME = 'ADBRAND'
                                       AND C1.Code = o.DeliveryPlace
                                       AND C1.Storerkey = ph.StorerKey
   WHERE pd.PickSlipNo = @c_Sparm1 AND pd.LabelNo = @c_Sparm2
   GROUP BY o.C_Company
          , ISNULL(o.C_Phone1, '')
          , (ISNULL(o.C_Address1, '') + ISNULL(o.C_Address2, '') + ISNULL(o.C_Address3, ''))
          , ISNULL(o.C_Zip, '')
          , ISNULL(ST.Notes2, '')
          , (SUBSTRING(o.C_Company, 1, LEN(o.C_Company) - LEN(RIGHT(o.C_Company, 1))) + '*')
          , (SUBSTRING(o.C_Phone1, 1, LEN(o.C_Phone1) - LEN(RIGHT(o.C_Phone1, 4))) + '****') --7
          , (SUBSTRING(pd.UPC, 1, 4) + '-' + SUBSTRING(pd.UPC, 5, 4) + '-' + SUBSTRING(pd.UPC, 9, 4))
          , ISNULL(pd.UPC, '')
          , ISNULL(o.M_Country, '')
          , ISNULL(o.M_State, '')
          , ISNULL(o.UserDefine03, '')
          , ISNULL(o.M_City, '')
          , ISNULL(o.M_Contact1, '')
          , pd.CartonNo
          , o.ExternOrderKey
          , ISNULL(o.M_Contact2, '')
          , ISNULL(o.C_City, '')
          , ISNULL(o.B_City, '')
          , ISNULL(o.M_Country, '')
          , ISNULL(o.M_Address4, '')
          , pd.LabelNo
          , pd.PickSlipNo
          , o.DischargePlace
          , ISNULL(o.M_Address3, '')
          , SUBSTRING(o.Notes, 1, 80)
          , ISNULL(CL.Notes, '')
          , o.OrderKey
          , ISNULL(TRIM(o.DeliveryNote), '')
          , LEFT(ISNULL(TRIM(ST.B_Address1), '') + ISNULL(TRIM(ST.B_Address2), ''), 80)
          , ISNULL(TRIM(ST.B_contact1), '')
          , ISNULL(TRIM(C1.Notes), '')
          , ISNULL(TRIM(o.C_Contact1), '')

   OPEN CUR_StartRecLoop

   FETCH NEXT FROM CUR_StartRecLoop
   INTO @c_OHCompany
      , @c_OHPhone1
      , @c_OHAddress
      , @c_OHZip
      , @c_STNotes2
      , @c_OHComdescr
      , @c_OHPhone1descr
      , @c_OHUDF04descr
      , @c_OHUDF04
      , @c_OHMCountry
      , @c_OHMState
      , @c_OHUDF03
      , @c_OHMcity
      , @c_OHMContact1
      , @n_CartonNo
      , @c_ExtOrdkey
      , @c_OHMContact2
      , @c_OHccity
      , @c_OHbcity
      , @c_OHMAdd4
      , @c_labelno
      , @n_MAxCarton
      , @c_Pickslipno
      , @c_OHDisPlace
      , @c_OHMAdd3
      , @c_OHNotes
      , @c_CLNotes
      , @c_Orderkey    
      , @c_DeliveryNote
      , @c_B_Addr      
      , @c_B_Contact1  
      , @c_Col50      
      , @c_C_Contact1

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      IF @b_debug = 1
      BEGIN
         PRINT 'Cur start'
      END

      INSERT INTO #Result (Col01, Col02, Col03, Col04, Col05, Col06, Col07, Col08, Col09, Col10, Col11, Col12, Col13
                         , Col14, Col15, Col16, Col17, Col18, Col19, Col20, Col21, Col22, Col23, Col24, Col25, Col26
                         , Col27, Col28, Col29, Col30, Col31, Col32, Col33, Col34, Col35, Col36, Col37, Col38, Col39
                         , Col40, Col41, Col42, Col43, Col44, Col45, Col46, Col47, Col48, Col49, Col50, Col51, Col52
                         , Col53, Col54, Col55, Col56, Col57, Col58, Col59, Col60)
      VALUES (@c_OHCompany, @c_OHPhone1, @c_OHAddress, @c_OHZip, @c_STNotes2, @c_OHComdescr, @c_OHPhone1descr --7 
            , @c_OHUDF04descr, @c_labelno, @c_OHMCountry, @c_OHMState, '', '' --13  
            , '', '', '', '', '', '', '' --20       
            , @c_OHMAdd3, @c_OHMAdd4, @c_OHMContact1, @n_CartonNo, @c_ExtOrdkey, @c_OHMContact2 --26
            , @c_OHccity, @c_OHbcity, @c_OHDisPlace, @c_OHMAdd4, @c_labelno, @n_MAxCarton, @c_OHMcity, @c_OHNotes
            , @c_CLNotes, '', '', '', '' --39
            , '', '', '', '', '', '', @c_Orderkey, @c_DeliveryNote, @c_B_Addr, @c_B_Contact1, @c_Col50 --50   
            , @c_C_Contact1, '', '', '', '', '', '', '', @c_Pickslipno, 'O')

      IF @b_debug = 1
      BEGIN
         SELECT *
         FROM #Result (NOLOCK)
      END

      FETCH NEXT FROM CUR_StartRecLoop
      INTO @c_OHCompany
         , @c_OHPhone1
         , @c_OHAddress
         , @c_OHZip
         , @c_STNotes2
         , @c_OHComdescr
         , @c_OHPhone1descr
         , @c_OHUDF04descr
         , @c_OHUDF04
         , @c_OHMCountry
         , @c_OHMState
         , @c_OHUDF03
         , @c_OHMcity
         , @c_OHMContact1
         , @n_CartonNo
         , @c_ExtOrdkey
         , @c_OHMContact2
         , @c_OHccity
         , @c_OHbcity
         , @c_OHMAdd4
         , @c_labelno
         , @n_MAxCarton
         , @c_Pickslipno
         , @c_OHDisPlace
         , @c_OHMAdd3
         , @c_OHNotes
         , @c_CLNotes
         , @c_Orderkey    
         , @c_DeliveryNote
         , @c_B_Addr      
         , @c_B_Contact1  
         , @c_Col50 
         , @c_C_Contact1

   END -- While                     
   CLOSE CUR_StartRecLoop
   DEALLOCATE CUR_StartRecLoop

   IF @c_Storerkey NOT IN ( 'NIKEKR', 'AOS', 'COS', 'ARK' )
      SET @c_ShowPackdetail = N'Y'

   IF @c_ShowPackdetail = 'Y'
   BEGIN
      DECLARE CUR_RowNoLoop CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT Col09
                    , Col59
                    , CAST(Col24 AS INT)
      FROM #Result
      ORDER BY Col59
             , CAST(Col24 AS INT)

      OPEN CUR_RowNoLoop

      FETCH NEXT FROM CUR_RowNoLoop
      INTO @c_labelno
         , @c_Pickslipno
         , @n_CartonNo

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         SET @n_ctnsku = 0

         SELECT @n_ctnsku = COUNT(DISTINCT PD.SKU)
         FROM PackHeader PH WITH (NOLOCK)
         JOIN PackDetail PD WITH (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
         WHERE PD.PickSlipNo = @c_Pickslipno AND PD.CartonNo = CAST(@n_CartonNo AS INT) AND PD.LabelNo = @c_labelno

         INSERT INTO #SKULULUContent
         SELECT TOP 6 @c_Pickslipno
                    , @c_labelno
                    , PD.LabelLine
                    , PD.SKU
                    , S.DESCR
                    , SUM(PD.Qty)
                    , 'N'
         FROM PackHeader PH WITH (NOLOCK)
         JOIN PackDetail PD WITH (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
         JOIN SKU S WITH (NOLOCK) ON S.Sku = PD.SKU AND S.StorerKey = PH.StorerKey
         WHERE PD.PickSlipNo = @c_Pickslipno AND PD.CartonNo = CAST(@n_CartonNo AS INT) AND PD.LabelNo = @c_labelno
         GROUP BY PD.LabelLine
                , PD.SKU
                , S.DESCR
         ORDER BY CAST(PD.LabelLine AS INT)

         SET @c_SKU01 = N''
         SET @c_SKUDesr01 = N''
         SET @n_qty01 = ''
         SET @c_SKU02 = N''
         SET @c_SKUDesr02 = N''
         SET @n_qty02 = ''
         SET @c_SKU03 = N''
         SET @c_SKUDesr03 = N''
         SET @n_qty03 = ''

         SET @c_SKU04 = N''
         SET @c_SKUDesr04 = N''
         SET @n_qty04 = ''
         SET @c_SKU05 = N''
         SET @c_SKUDesr05 = N''
         SET @n_qty05 = ''
         SET @c_SKU06 = N''
         SET @c_SKUDesr06 = N''
         SET @n_qty06 = ''

         IF @b_debug = 1
            SELECT *
            FROM #SKULULUContent

         SELECT @n_CntRec = COUNT(1)
         FROM #SKULULUContent
         WHERE Pickslipno = @c_Pickslipno AND labelno = @c_labelno AND Retrieve = 'N'

         SET @n_TTLpage = FLOOR(@n_CntRec / @n_MaxLine) + CASE WHEN @n_CntRec % @n_MaxLine > 0 THEN 1
                                                               ELSE 0 END

         WHILE @n_intFlag <= @n_CntRec
         BEGIN
            SELECT @c_SKU = SKU
                 , @c_SKUDesr = SDESCR
                 , @n_qty = skuqty
            FROM #SKULULUContent
            WHERE ID = @n_intFlag

            IF (@n_intFlag % @n_MaxLine) = 1 --AND @n_recgrp = @n_CurrentPage  
            BEGIN
               SET @c_SKU01 = @c_SKU
               SET @c_SKUDesr01 = @c_SKUDesr
               SET @n_qty01 = @n_qty
            END
            ELSE IF (@n_intFlag % @n_MaxLine) = 2 --AND @n_recgrp = @n_CurrentPage  
            BEGIN
               SET @c_SKU02 = @c_SKU
               SET @c_SKUDesr02 = @c_SKUDesr
               SET @n_qty02 = @n_qty
            END
            ELSE IF (@n_intFlag % @n_MaxLine) = 3 --AND @n_recgrp = @n_CurrentPage  
            BEGIN
               SET @c_SKU03 = @c_SKU
               SET @c_SKUDesr03 = @c_SKUDesr
               SET @n_qty03 = @n_qty
            END
            ELSE IF (@n_intFlag % @n_MaxLine) = 4 --AND @n_recgrp = @n_CurrentPage  
            BEGIN
               SET @c_SKU04 = @c_SKU
               SET @c_SKUDesr04 = @c_SKUDesr
               SET @n_qty04 = @n_qty
            END
            ELSE IF (@n_intFlag % @n_MaxLine) = 5 --AND @n_recgrp = @n_CurrentPage  
            BEGIN
               SET @c_SKU05 = @c_SKU
               SET @c_SKUDesr05 = @c_SKUDesr
               SET @n_qty05 = @n_qty
            END
            ELSE IF (@n_intFlag % @n_MaxLine) = 0 --AND @n_recgrp = @n_CurrentPage  
            BEGIN
               SET @c_SKU06 = @c_SKU
               SET @c_SKUDesr06 = @c_SKUDesr
               SET @n_qty06 = @n_qty
            END

            UPDATE #Result
            SET Col12 = @c_SKU01
              , Col13 = @c_SKUDesr01
              , Col14 = CASE WHEN CAST(@n_qty01 AS NVARCHAR(80)) = '0' THEN ''
                             ELSE CAST(@n_qty01 AS NVARCHAR(80))END
              , Col15 = @c_SKU02
              , Col16 = @c_SKUDesr02
              , Col17 = CASE WHEN CAST(@n_qty02 AS NVARCHAR(80)) = '0' THEN ''
                             ELSE CAST(@n_qty02 AS NVARCHAR(80))END
              , Col18 = @c_SKU03
              , Col19 = @c_SKUDesr03
              , Col20 = CASE WHEN CAST(@n_qty03 AS NVARCHAR(80)) = '0' THEN ''
                             ELSE CAST(@n_qty03 AS NVARCHAR(80))END
              , Col36 = @c_SKU04
              , Col37 = @c_SKUDesr04
              , Col38 = CASE WHEN CAST(@n_qty04 AS NVARCHAR(80)) = '0' THEN ''
                             ELSE CAST(@n_qty04 AS NVARCHAR(80))END
              , Col39 = @c_SKU05
              , Col40 = @c_SKUDesr05
              , Col41 = CASE WHEN CAST(@n_qty05 AS NVARCHAR(80)) = '0' THEN ''
                             ELSE CAST(@n_qty05 AS NVARCHAR(80))END
              , Col42 = @c_SKU06
              , Col43 = @c_SKUDesr06
              , Col44 = CASE WHEN CAST(@n_qty06 AS NVARCHAR(80)) = '0' THEN ''
                             ELSE CAST(@n_qty06 AS NVARCHAR(80))END
              , Col45 = CAST(@n_ctnsku AS NVARCHAR(20))
            WHERE ID = @n_CurrentPage AND Col59 <> ''

            UPDATE #SKULULUContent
            SET Retrieve = 'Y'
            WHERE ID = @n_intFlag

            SET @n_intFlag = @n_intFlag + 1

            IF @n_intFlag > @n_CntRec
            BEGIN
               BREAK;
            END
         END

         FETCH NEXT FROM CUR_RowNoLoop
         INTO @c_labelno
            , @c_Pickslipno
            , @n_CartonNo
      END
      CLOSE CUR_RowNoLoop
      DEALLOCATE CUR_RowNoLoop
   END

   SELECT *
   FROM #Result WITH (NOLOCK)
   EXIT_SP:

END -- procedure   
GO
GRANT EXECUTE ON [dbo].[isp_BT_Bartender_KR_shipLabel_CJKE_ADIDAS] TO [NSQL]
GO