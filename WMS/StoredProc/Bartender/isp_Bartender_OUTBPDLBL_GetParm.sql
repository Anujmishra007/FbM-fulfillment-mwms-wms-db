SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Copyright: IDS                                                             */
/* Purpose: isp_Bartender_OUTBPDLBL_GetParm                                   */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date        Rev  Author     Purposes                                       */
/* 2018-10-09  1.0  CSCHONG    Created (WMS-6575)                             */
/* 2022-03-06  1.1  MINGLE     Add logic(ML01) (WMS-19026)                    */
/* 19-Sep-2023 1.2  WLChooi    WMS-23709 - Add new logic (WL01)               */
/* 19-Sep-2023 1.2  WLChooi    DevOps Combine Script                          */
/******************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_Bartender_OUTBPDLBL_GetParm]
(
   @parm01  NVARCHAR(250)
 , @parm02  NVARCHAR(250)
 , @parm03  NVARCHAR(250)
 , @parm04  NVARCHAR(250)
 , @parm05  NVARCHAR(250)
 , @parm06  NVARCHAR(250)
 , @parm07  NVARCHAR(250)
 , @parm08  NVARCHAR(250)
 , @parm09  NVARCHAR(250)
 , @parm10  NVARCHAR(250)
 , @b_debug INT = 0
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_intFlag    INT
         , @n_CntRec     INT
         , @c_SQL        NVARCHAR(4000)
         , @c_SQLSORT    NVARCHAR(4000)
         , @c_SQLJOIN    NVARCHAR(4000)
         , @c_condition1 NVARCHAR(4000)
         , @c_condition2 NVARCHAR(150)
         , @c_SQLGroup   NVARCHAR(4000)
         , @c_SQLOrdBy   NVARCHAR(150)

   DECLARE @d_Trace_StartTime  DATETIME
         , @d_Trace_EndTime    DATETIME
         , @c_Trace_ModuleName NVARCHAR(20)
         , @d_Trace_Step1      DATETIME
         , @c_Trace_Step1      NVARCHAR(20)
         , @c_UserName         NVARCHAR(20)
         , @n_cnt              INT
         , @c_mode             NVARCHAR(1)
         , @c_sku              NVARCHAR(20)
         , @c_ExecStatements   NVARCHAR(4000)
         , @c_ExecArguments    NVARCHAR(4000)
         , @n_NoOfCopy         INT
         , @c_lot              NVARCHAR(20)
         , @n_ttlpage          INT   --WL01
         , @c_storerkey        NVARCHAR(20)
         , @c_prevSKU          NVARCHAR(20)
         , @c_prevLOT          NVARCHAR(20)
         , @n_getttlpage       INT   --WL01 S
         , @n_getlotpage       INT
         , @n_cntlot           INT
         , @c_ODLineNo         NVARCHAR(10) = N''
         , @c_PrevODLineNo     NVARCHAR(10) = N''   --WL01 E

   SET @d_Trace_StartTime = GETDATE()
   SET @c_Trace_ModuleName = N''

   -- SET RowNo = 0  
   SET @c_SQL = N''
   SET @c_mode = N'0'
   SET @c_SQLJOIN = N''
   SET @c_condition1 = N''
   SET @c_condition2 = N''
   SET @c_SQLOrdBy = N''
   SET @c_SQLGroup = N''
   SET @c_ExecStatements = N''
   SET @c_ExecArguments = N''
   SET @n_cnt = 1
   SET @c_prevSKU = N''
   SET @c_prevLOT = N''

   --IF ISNULL(@parm02,'') = '' GOTO EXIT_SP  
   IF ISNULL(@parm06, '') = 0
      SET @parm06 = 1

   --START ML01
   CREATE TABLE #TEMP_PICKDETAIL
   (
      PARM1  NVARCHAR(80)
    , PARM2  NVARCHAR(80)
    , PARM3  NVARCHAR(80)
    , PARM4  NVARCHAR(80)
    , PARM5  NVARCHAR(80)
    , PARM6  NVARCHAR(80)
    , PARM7  NVARCHAR(80)
    , PARM8  NVARCHAR(80)
    , PARM9  NVARCHAR(80)
    , PARM10 NVARCHAR(80)
    , KEY1   NVARCHAR(80)
    , KEY2   NVARCHAR(80)
    , KEY3   NVARCHAR(80)
    , KEY4   NVARCHAR(80)
    , KEY5   NVARCHAR(80)
   )

   --WL01 S
   SELECT @c_storerkey = Storerkey
   FROM ORDERS (NOLOCK)
   WHERE Orderkey = @parm01

   IF EXISTS ( SELECT 1
               FROM SKU (NOLOCK)
               WHERE Storerkey = @c_storerkey
               AND SKU = @parm02 )
   BEGIN
      SET @parm03 = @parm02
      SET @parm02 = @c_storerkey
   END
   
   /*
   IF @parm03 <> ''
   BEGIN

      DECLARE CUR_LOOP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT PD.Storerkey
                    , PD.Sku
                    , PD.Lot
                    , PD.Qty / P.CaseCnt
      FROM PICKDETAIL PD (NOLOCK)
      JOIN PACK P (NOLOCK) ON P.PackKey = PD.PackKey
      WHERE PD.OrderKey = @parm01 AND PD.Storerkey = @parm02 AND PD.Sku = @parm03 AND PD.Lot = @parm04

      OPEN CUR_LOOP

      FETCH NEXT FROM CUR_LOOP
      INTO @c_storerkey
         , @c_sku
         , @c_lot
         , @c_ttlpage

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         SET @n_NoOfCopy = @c_ttlpage
         IF @c_prevSKU <> @c_sku
            SET @n_cnt = 1
         IF @c_prevLOT <> @c_lot
            SET @n_cnt = 1
         WHILE @n_NoOfCopy >= 1
         BEGIN
            INSERT INTO #TEMP_PICKDETAIL
            SELECT PARM1 = @parm01
                 , PARM2 = @c_storerkey
                 , PARM3 = @c_sku
                 , PARM4 = @c_lot
                 , PARM5 = @c_ttlpage
                 , PARM6 = @n_cnt
                 , PARM7 = ''
                 , PARM8 = ''
                 , PARM9 = ''
                 , PARM10 = ''
                 , Key1 = 'Orderkey'
                 , Key2 = ''
                 , Key3 = ''
                 , Key4 = ''
                 , Key5 = ''


            SET @n_NoOfCopy = @n_NoOfCopy - 1
            SET @n_cnt = @n_cnt + 1
            SET @c_prevSKU = @c_sku
            SET @c_prevLOT = @c_lot

         END

         FETCH NEXT FROM CUR_LOOP
         INTO @c_storerkey
            , @c_sku
            , @c_lot
            , @c_ttlpage
      END
      CLOSE CUR_LOOP
      DEALLOCATE CUR_LOOP

   END
   ELSE
   BEGIN
      DECLARE CUR_LOOP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT PD.Storerkey
                    , PD.Sku
                    , MAX(PD.Lot)
                    , PD.Qty / P.CaseCnt
      FROM PICKDETAIL PD (NOLOCK)
      JOIN PACK P (NOLOCK) ON P.PackKey = PD.PackKey
      WHERE PD.OrderKey = @parm01
      GROUP BY PD.Storerkey
             , PD.Sku
             , PD.Qty
             , P.CaseCnt
      --AND PD.Storerkey = @c_Sparm02  
      --AND PD.Sku = @c_Sparm03  
      --AND PD.Lot = @c_Sparm04  

      OPEN CUR_LOOP

      FETCH NEXT FROM CUR_LOOP
      INTO @c_storerkey
         , @c_sku
         , @c_lot
         , @c_ttlpage

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         SET @n_NoOfCopy = @c_ttlpage
         IF @c_prevSKU <> @c_sku
            SET @n_cnt = 1
         IF @c_prevLOT <> @c_lot
            SET @n_cnt = 1
         WHILE @n_NoOfCopy >= 1
         BEGIN
            INSERT INTO #TEMP_PICKDETAIL
            SELECT PARM1 = @parm01
                 , PARM2 = @c_storerkey
                 , PARM3 = @c_sku
                 , PARM4 = @c_lot
                 , PARM5 = @c_ttlpage
                 , PARM6 = @n_cnt
                 , PARM7 = ''
                 , PARM8 = ''
                 , PARM9 = ''
                 , PARM10 = ''
                 , Key1 = 'Orderkey'
                 , Key2 = ''
                 , Key3 = ''
                 , Key4 = ''
                 , Key5 = ''


            SET @n_NoOfCopy = @n_NoOfCopy - 1
            SET @n_cnt = @n_cnt + 1
            SET @c_prevSKU = @c_sku
            SET @c_prevLOT = @c_lot

         END

         FETCH NEXT FROM CUR_LOOP
         INTO @c_storerkey
            , @c_sku
            , @c_lot
            , @c_ttlpage
      END
      CLOSE CUR_LOOP
      DEALLOCATE CUR_LOOP

   END
   --END ML01
   */

   DECLARE CUR_LOOP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT DISTINCT PD.Storerkey
                 , PD.Sku
                 , PD.Lot
                 , SUM(PD.Qty) / P.CaseCnt
                 , OD.OrderLineNumber
   FROM PICKDETAIL PD (NOLOCK)
   JOIN PACK P (NOLOCK) ON P.PackKey = PD.PackKey
   JOIN ORDERDETAIL OD WITH (NOLOCK) ON  OD.OrderKey = PD.OrderKey
                                     AND OD.OrderLineNumber = PD.OrderLineNumber
                                     AND OD.Sku = PD.Sku
                                     AND OD.StorerKey = PD.Storerkey 
   WHERE PD.OrderKey = @parm01
   AND PD.Storerkey = IIF(ISNULL(@parm02,'') = '', PD.Storerkey, @parm02)
   AND PD.Sku = IIF(ISNULL(@parm03,'') = '', PD.Sku, @parm03)    
   AND PD.Lot = IIF(ISNULL(@parm04,'') = '', PD.Lot, @parm04)    
   GROUP BY PD.Storerkey
          , P.CaseCnt
          , OD.OrderLineNumber
          , PD.Sku
          , PD.Lot
   ORDER BY OD.OrderLineNumber 

   OPEN CUR_LOOP

   FETCH NEXT FROM CUR_LOOP
   INTO @c_storerkey
      , @c_sku
      , @c_lot
      , @n_ttlpage
      , @c_ODLineNo   

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      SET @n_cntlot = 1
      SET @n_getttlpage = @n_ttlpage
      SET @n_NoOfCopy = @n_ttlpage
      SET @n_getlotpage = @n_ttlpage

      SELECT @n_cntlot = COUNT(DISTINCT PD.Lot)
      FROM PICKDETAIL PD (NOLOCK)
      JOIN PACK P (NOLOCK) ON P.PackKey = PD.PackKey
      JOIN ORDERDETAIL OD WITH (NOLOCK) ON  OD.OrderKey = PD.OrderKey
                                        AND OD.OrderLineNumber = PD.OrderLineNumber
                                        AND OD.Sku = PD.Sku
                                        AND OD.StorerKey = PD.Storerkey 
      WHERE PD.OrderKey = @parm01 AND PD.OrderLineNumber = @c_ODLineNo AND PD.Storerkey = @c_storerkey
      AND PD.Lot = IIF(ISNULL(@parm04,'') = '', PD.Lot, @parm04)

      IF @n_cntlot > 1
      BEGIN
         SELECT @n_getttlpage = SUM(PD.Qty) / MAX(P.CaseCnt)
         FROM PICKDETAIL PD (NOLOCK)
         JOIN PACK P (NOLOCK) ON P.PackKey = PD.PackKey
         JOIN ORDERDETAIL OD WITH (NOLOCK) ON  OD.OrderKey = PD.OrderKey
                                           AND OD.OrderLineNumber = PD.OrderLineNumber
                                           AND OD.Sku = PD.Sku
                                           AND OD.StorerKey = PD.Storerkey 
         WHERE PD.OrderKey = @parm01 AND PD.Sku = @c_sku AND PD.Storerkey = @c_storerkey
         AND   OD.OrderLineNumber = @c_ODLineNo

         SET @n_NoOfCopy = @n_getttlpage
      END

      IF @c_PrevODLineNo <> @c_ODLineNo
         SET @n_cnt = 1

      IF @n_NoOfCopy > @n_getlotpage
      BEGIN
         SET @n_NoOfCopy = @n_getlotpage
      END

      WHILE @n_NoOfCopy >= 1
      BEGIN
         INSERT INTO #TEMP_PICKDETAIL
         SELECT PARM1 = @parm01
              , PARM2 = @c_storerkey
              , PARM3 = @c_sku
              , PARM4 = @c_lot
              , PARM5 = @n_getttlpage
              , PARM6 = @n_cnt
              , PARM7 = ''
              , PARM8 = ''
              , PARM9 = ''
              , PARM10 = @c_ODLineNo
              , Key1 = 'Orderkey'
              , Key2 = ''
              , Key3 = ''
              , Key4 = ''
              , Key5 = ''
 
         SET @n_NoOfCopy = @n_NoOfCopy - 1
         SET @n_cnt = @n_cnt + 1
         SET @c_prevSKU = @c_sku
         SET @c_prevLOT = @c_lot
         SET @c_PrevODLineNo = @c_ODLineNo
      END

      FETCH NEXT FROM CUR_LOOP
      INTO @c_storerkey
         , @c_sku
         , @c_lot
         , @n_ttlpage
         , @c_ODLineNo     
   END
   CLOSE CUR_LOOP
   DEALLOCATE CUR_LOOP
   --WL01 E

   SET @c_SQLJOIN = N'SELECT * FROM #TEMP_PICKDETAIL ORDER BY PARM10,PARM3,CAST(PARM5 AS INT),CAST(PARM6 AS INT) ' --WL01

   SET @c_SQL = @c_SQLJOIN

   SET @c_ExecArguments = N'  @parm01           NVARCHAR(80) ' + N', @parm02           NVARCHAR(80) '
                          + N', @parm03           NVARCHAR(80) ' + N', @parm04           NVARCHAR(80) '

   EXEC sp_executesql @c_SQL
                    , @c_ExecArguments
                    , @parm01
                    , @parm02
                    , @parm03
                    , @parm04

   EXIT_SP:

   SET @d_Trace_EndTime = GETDATE()
   SET @c_UserName = SUSER_SNAME()

   IF OBJECT_ID('tempdb..#TEMP_PICKDETAIL') IS NOT NULL
      DROP TABLE #TEMP_PICKDETAIL

END -- procedure     
GO
GRANT EXECUTE ON [dbo].[isp_Bartender_OUTBPDLBL_GetParm] TO NSQL
GO