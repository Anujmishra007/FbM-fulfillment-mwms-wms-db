SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: isp_OrderSimilarify_Optimization                   */
/* Creation Date: 27-FEB-2025                                           */
/* Copyright: MAERSK                                                    */
/* Written by: NJOW                                                     */
/*                                                                      */
/* Purpose: FCR-7724 General Optimization function for orders similarify*/
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* GitHub Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver. Purposes                                   */
/* 10-Oct-2025  WLChooi 1.0  Initial Version                            */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_OrderSimilarify_Optimization]
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue      INT            = 1
         , @n_RowID         INT            = 0
         , @n_RowID_Comp    INT            = 0
         , @c_Orderkey      NVARCHAR(10)
         , @c_Orderkey_Comp NVARCHAR(10)
         , @n_Rating        DECIMAL(20, 2) = 0.00
         , @CURSOR_ORD      CURSOR
         , @CURSOR_ORD_COMP CURSOR

   /*
   Usage:
   CREATE TABLE #ORDER_OPTIMIZATION_INPUT (RowID INT IDENTITY(1,1), Orderkey NVARCHAR(10))
   CREATE TABLE #ORDER_OPTIMIZATION_OUTPUT (RowID INT IDENTITY(1,1), Orderkey NVARCHAR(10), Rating DECIMAL(20,2))

   INSERT INTO #ORDER_OPTIMIZATION_INPUT (Orderkey)
   SELECT OrderKey
   FROM ORDERS WITH (NOLOCK)
   WHERE Orderkey IN ( '0000128465', '0000128466', '0000128467' )

   INSERT INTO #ORDER_OPTIMIZATION_OUTPUT
   EXEC isp_OrderSimilarify_Optimization

   SELECT Orderkey
        , Rating
   FROM #ORDER_OPTIMIZATION_OUTPUT
   ORDER BY RowID

   DROP TABLE #ORDER_OPTIMIZATION_INPUT
   DROP TABLE #ORDER_OPTIMIZATION_OUTPUT
   */

   IF @n_Continue IN (1,2)
   BEGIN
      CREATE TABLE #ORDER_OPTIMIZATION_WORK
      (
         RowID    INT IDENTITY(1, 1) PRIMARY KEY
       , Orderkey NVARCHAR(10)
       , Rating   DECIMAL(20, 2)
      )
      CREATE INDEX OOW_Orderkey ON #ORDER_OPTIMIZATION_WORK (Orderkey)

      CREATE TABLE #ORDER_DETAIL
      (
         Orderkey NVARCHAR(10)
       , Sku      NVARCHAR(20)
      )
      CREATE INDEX OD_Orderkey ON #ORDER_DETAIL (Orderkey)

      INSERT INTO #ORDER_OPTIMIZATION_WORK (Orderkey, Rating)
      SELECT Orderkey
           , 0.00
      FROM #ORDER_OPTIMIZATION_INPUT
      ORDER BY RowID

      INSERT INTO #ORDER_DETAIL (Orderkey, Sku)
      SELECT DISTINCT OD.Orderkey, OD.SKU
      FROM ORDERDETAIL OD WITH (NOLOCK)
      JOIN #ORDER_OPTIMIZATION_WORK OOW WITH (NOLOCK) ON OOW.Orderkey = OD.OrderKey
   END

   IF @n_Continue IN (1,2)
   BEGIN
      SET @CURSOR_ORD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT Orderkey
           , RowID
      FROM #ORDER_OPTIMIZATION_WORK
      ORDER BY RowID

      OPEN @CURSOR_ORD

      FETCH NEXT FROM @CURSOR_ORD
      INTO @c_Orderkey
         , @n_RowID

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         SET @CURSOR_ORD_COMP = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT Orderkey
              , RowID
         FROM #ORDER_OPTIMIZATION_WORK
         WHERE RowID > @n_RowID
         ORDER BY RowID

         OPEN @CURSOR_ORD_COMP

         FETCH NEXT FROM @CURSOR_ORD_COMP
         INTO @c_Orderkey_Comp
            , @n_RowID_Comp

         WHILE @@FETCH_STATUS <> -1
         BEGIN
            SET @n_Rating = 0;

            WITH CTE_SKUORDCNT AS
            (
               SELECT OD.Sku
                    , COUNT(DISTINCT OD.Orderkey) AS NoOfOrder
               FROM #ORDER_DETAIL OD WITH (NOLOCK)
               WHERE OD.Orderkey IN ( @c_Orderkey, @c_Orderkey_Comp )
               GROUP BY OD.Sku
            )
               , CTE_SKUCNT AS
            (
               SELECT COUNT(DISTINCT Sku) AS TotalSku
               FROM CTE_SKUORDCNT
            )
               , CTE_SKUNOTCOMMON AS
            (
               SELECT COUNT(1) AS TotalSkuNotCommon
               FROM CTE_SKUORDCNT
               WHERE NoOfOrder = 1
            )
            SELECT @n_Rating = IIF(ISNULL(CTE_SKUCNT.TotalSku, 0) = 0
                                   , 0
                                   , CTE_SKUNOTCOMMON.TotalSkuNotCommon / (CTE_SKUCNT.TotalSku * 1.00))
            FROM CTE_SKUNOTCOMMON
            JOIN CTE_SKUCNT ON 1 = 1

            UPDATE #ORDER_OPTIMIZATION_WORK
            SET Rating = Rating + @n_Rating
            WHERE RowID = @n_RowID

            UPDATE #ORDER_OPTIMIZATION_WORK
            SET Rating = Rating + @n_Rating
            WHERE RowID = @n_RowID_Comp

            FETCH NEXT FROM @CURSOR_ORD_COMP
            INTO @c_Orderkey_Comp
               , @n_RowID_Comp
         END
         CLOSE @CURSOR_ORD_COMP
         DEALLOCATE @CURSOR_ORD_COMP

         FETCH NEXT FROM @CURSOR_ORD
         INTO @c_Orderkey
            , @n_RowID
      END
      CLOSE @CURSOR_ORD
      DEALLOCATE @CURSOR_ORD
   END

   --Output Result
   SELECT Orderkey
        , Rating
   FROM #ORDER_OPTIMIZATION_WORK
   ORDER BY Rating
          , Orderkey
END