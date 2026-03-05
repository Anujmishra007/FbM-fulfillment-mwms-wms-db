SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*****************************************************************************/
/* Stored Procedure: isp_Bartender_MLPN_CabsCaseID_Label_List_RPrint		 */
/* Creation Date: 15-01-2026                                                 */
/* Copyright: MAERSK                                                         */
/* Written by: AGM046                                                        */
/*                                                                           */
/* Purpose: 	 													         */
/*                                                                           */
/* Called By: EMG03_JCB_Cabs_Kitting_Detail_Label_001.btw		  	         */ 
/*                                                                           */
/* PVCS Version: 1.0                                                         */
/*                                                                           */
/* Version: 1.0                                                              */
/*                                                                           */
/* Data Modifications:                                                       */
/*                                                                           */
/* Updates:                                                                  */
/* Date         Author   Ver  Purposes                                       */
/* 15-01-2026   AGM046   1.0                                                 */
/* 04-04-2026   AGM046   1.2  Added Description column to the existing logic */
/*****************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[isp_Bartender_MLPN_CabsCaseID_Label_List_RPrint] (  
   @c_Sparm01 NVARCHAR(250),	-- DropID                   
   @c_Sparm02 NVARCHAR(250),	-- Not used	                 
   @c_Sparm03 NVARCHAR(250),	-- Not used	                  
   @c_Sparm04 NVARCHAR(250),	-- Not used                  
   @c_Sparm05 NVARCHAR(250),	-- Not used                  
   @c_Sparm06 NVARCHAR(250),	-- Not used                  
   @c_Sparm07 NVARCHAR(250),	-- Not used                  
   @c_Sparm08 NVARCHAR(250),	-- Not used                  
   @c_Sparm09 NVARCHAR(250),	-- Not used                  
   @c_Sparm10 NVARCHAR(250),	-- Not used                  
   @b_debug   INT = 0                             
)
AS  
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- Raw pick lines summarized by SKU
   DECLARE @tempTable TABLE
   (
      ID INT IDENTITY(0,1),
      LabelHeader NVARCHAR(100),
      OrderName NVARCHAR(100),
      OrderID NVARCHAR(100),
      WaveID NVARCHAR(100),
      [Delivery_Date&Time] NVARCHAR(100),
      [Date&Time_Picked] NVARCHAR(100),
      ToLocation NVARCHAR(100),
      UID NVARCHAR(100),
      DataCheck NVARCHAR(100),
      CaseID NVARCHAR(100),
      SKU NVARCHAR(100),
	  DescSKU NVARCHAR(100),
      QTY NVARCHAR(100)
   );

   INSERT INTO @tempTable

      -- NUEVO
      SELECT
         CASE
            WHEN orm.[Type] = '2' THEN 'CABS Tote Label'
            WHEN orm.[Type] = '6' AND x.UomDesc = 'Full Pallet' THEN 'T4 Full pallet pick'
            WHEN orm.[Type] = '6' AND x.UomDesc <> 'Full Pallet' THEN 'T4 Partial Pick Pallet'
            WHEN orm.[Type] = '8' THEN 'LANDPOWER Pallet Label'
            ELSE 'Not a kitting order'
         END AS LabelHeader,
         orm.ExternOrderKey,
         orm.OrderKey,
         pd.WaveKey,
         FORMAT(orm.DeliveryDate,'dd/MM/yyyy hh:mm tt') AS DeliveryDateFmt,
         FORMAT(MIN(pd.EditDate),'dd-MM-yyyy hh:mm tt') AS MinEditDateFmt,
         pd.Loc,
         pd.EditWho,
         '' AS DataCheck,
         @c_Sparm01, -- CASEID
         pd.SKU,
		 sku.descr,
         SUM(pd.Qty) AS TotalQty
      FROM dbo.PICKDETAIL pd WITH (NOLOCK)
      INNER JOIN dbo.ORDERS orm WITH (NOLOCK)
         ON orm.StorerKey = pd.StorerKey
        AND orm.OrderKey  = pd.OrderKey
	  INNER JOIN dbo.SKU sku WITH (NOLOCK)
	  ON pd.Storerkey = sku.StorerKey 
     AND pd.Sku  = sku.Sku
      INNER JOIN dbo.V_CODELKUP cdl WITH (NOLOCK)
         ON cdl.LISTNAME = 'TMUOM'
        AND cdl.Code     = pd.[UOM]
        AND ISNULL(cdl.Storerkey, '') = (
            CASE
               WHEN EXISTS (
                  SELECT TOP 1 1
                  FROM V_CODELKUP WITH (NOLOCK)
                  WHERE LISTNAME = 'TMUOM'
                    AND Code = pd.[UOM]
                    AND Storerkey = pd.StorerKey
               ) THEN pd.StorerKey ELSE ''
            END
        )
      CROSS APPLY (
         SELECT
            CASE
               WHEN cdl.[Description] = 'Piece/Each (Special)' THEN 'Piece/Each'
               ELSE cdl.[Description]
            END AS UomDesc
      ) x
      WHERE pd.StorerKey = 'JCB'
        AND pd.CaseID     = @c_Sparm01
      GROUP BY
         orm.ExternOrderKey,
         orm.OrderKey,
         orm.[Type],
         x.UomDesc,
         pd.WaveKey,
         orm.DeliveryDate,
         pd.Loc,
         pd.EditWho,
         pd.ID,
         pd.DropID,
         pd.SKU,
		 sku.descr; -- new;

   -- Output table declaration: BarTender expects many generic columns
   DECLARE @Result TABLE
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

   -- Return an error message if there is no data
   IF NOT EXISTS (SELECT 1 FROM @tempTable)
   BEGIN
      INSERT INTO @Result (Col01, Col10)
      VALUES ('Kitting Label', 'No data found for LPN');

      SELECT * FROM @Result;
      RETURN;
   END
   ELSE
   BEGIN
      -- Variables for data separation into pages (@pageSize)
      DECLARE
         @counter INT = 0,
         @pageSize INT = 10,
         @totalLines INT = (SELECT MAX(ID) FROM @tempTable),
         @totalPages INT,
         @pageID NVARCHAR(50),
         @c_LPN NVARCHAR(80),

         @c_SKU01 NVARCHAR(80), @c_SKUDSC01 NVARCHAR(80), @c_SKUQTY01 INT,
         @c_SKU02 NVARCHAR(80), @c_SKUDSC02 NVARCHAR(80), @c_SKUQTY02 INT,
         @c_SKU03 NVARCHAR(80), @c_SKUDSC03 NVARCHAR(80), @c_SKUQTY03 INT,
         @c_SKU04 NVARCHAR(80), @c_SKUDSC04 NVARCHAR(80), @c_SKUQTY04 INT,
         @c_SKU05 NVARCHAR(80), @c_SKUDSC05 NVARCHAR(80), @c_SKUQTY05 INT,
         @c_SKU06 NVARCHAR(80), @c_SKUDSC06 NVARCHAR(80), @c_SKUQTY06 INT,
         @c_SKU07 NVARCHAR(80), @c_SKUDSC07 NVARCHAR(80), @c_SKUQTY07 INT,
         @c_SKU08 NVARCHAR(80), @c_SKUDSC08 NVARCHAR(80), @c_SKUQTY08 INT,
         @c_SKU09 NVARCHAR(80), @c_SKUDSC09 NVARCHAR(80), @c_SKUQTY09 INT,
         @c_SKU10 NVARCHAR(80), @c_SKUDSC10 NVARCHAR(80), @c_SKUQTY10 INT;

      SET @totalPages = CEILING(1.0 * (SELECT MAX(ID) + 1 FROM @tempTable) / @pageSize);

      WHILE @counter <= @totalLines
      BEGIN
         SET @pageID = CONCAT(CEILING(1.0 * (@counter + 1) / @pageSize), '/', @totalPages);

         SELECT
            @c_LPN = CaseID,
            --
			@c_SKU01    = CASE WHEN @counter % @pageSize = 0 THEN SKU     END,					
			@c_SKUDSC01 = CASE WHEN @counter % @pageSize = 0 THEN DescSKU END,
			@c_SKUQTY01 = CASE WHEN @counter % @pageSize = 0 THEN QTY     END,
			--
			@c_SKU02    = CASE WHEN @counter % @pageSize = 1 THEN SKU     END,
			@c_SKUDSC02 = CASE WHEN @counter % @pageSize = 1 THEN DescSKU END,
			@c_SKUQTY02 = CASE WHEN @counter % @pageSize = 1 THEN QTY     END,
			--
			@c_SKU03    = CASE WHEN @counter % @pageSize = 2 THEN SKU     END,
			@c_SKUDSC03 = CASE WHEN @counter % @pageSize = 2 THEN DescSKU END,
			@c_SKUQTY03 = CASE WHEN @counter % @pageSize = 2 THEN QTY     END,
			--
			@c_SKU04    = CASE WHEN @counter % @pageSize = 3 THEN SKU     END,
			@c_SKUDSC04 = CASE WHEN @counter % @pageSize = 3 THEN DescSKU END,
			@c_SKUQTY04 = CASE WHEN @counter % @pageSize = 3 THEN QTY     END,
			--
			@c_SKU05    = CASE WHEN @counter % @pageSize = 4 THEN SKU     END,
			@c_SKUDSC05 = CASE WHEN @counter % @pageSize = 4 THEN DescSKU END,
			@c_SKUQTY05 = CASE WHEN @counter % @pageSize = 4 THEN QTY     END,
			--
			@c_SKU06    = CASE WHEN @counter % @pageSize = 5 THEN SKU     END,
			@c_SKUDSC06 = CASE WHEN @counter % @pageSize = 5 THEN DescSKU END,
			@c_SKUQTY06 = CASE WHEN @counter % @pageSize = 5 THEN QTY     END,
			--
			@c_SKU07    = CASE WHEN @counter % @pageSize = 6 THEN SKU     END,
			@c_SKUDSC07 = CASE WHEN @counter % @pageSize = 6 THEN DescSKU END,
			@c_SKUQTY07 = CASE WHEN @counter % @pageSize = 6 THEN QTY     END,
			--
			@c_SKU08    = CASE WHEN @counter % @pageSize = 7 THEN SKU     END,
			@c_SKUDSC08 = CASE WHEN @counter % @pageSize = 7 THEN DescSKU END,
			@c_SKUQTY08 = CASE WHEN @counter % @pageSize = 7 THEN QTY     END,
			--
			@c_SKU09    = CASE WHEN @counter % @pageSize = 8 THEN SKU     END,
			@c_SKUDSC09 = CASE WHEN @counter % @pageSize = 8 THEN DescSKU END,
			@c_SKUQTY09 = CASE WHEN @counter % @pageSize = 8 THEN QTY     END,
			--
			@c_SKU10    = CASE WHEN @counter % @pageSize = 9 THEN SKU     END,
			@c_SKUDSC10 = CASE WHEN @counter % @pageSize = 9 THEN DescSKU END,
			@c_SKUQTY10 = CASE WHEN @counter % @pageSize = 9 THEN QTY     END
			--
         FROM @tempTable
         WHERE ID = @counter;

         IF NOT EXISTS (SELECT 1 FROM @Result WHERE Col11 = @pageID)
         BEGIN
            INSERT INTO @Result (Col10, Col11)
            VALUES (@c_LPN, @pageID);
         END;

         UPDATE @Result
         SET
            Col12 = ISNULL(@c_SKU01, Col12),  Col32 = ISNULL(@c_SKUDSC01, Col32),  Col13 = ISNULL(@c_SKUQTY01, Col13),
            Col14 = ISNULL(@c_SKU02, Col14),  Col33 = ISNULL(@c_SKUDSC02, Col33),  Col15 = ISNULL(@c_SKUQTY02, Col15),
            Col16 = ISNULL(@c_SKU03, Col16),  Col34 = ISNULL(@c_SKUDSC03, Col34),  Col17 = ISNULL(@c_SKUQTY03, Col17),
            Col18 = ISNULL(@c_SKU04, Col18),  Col35 = ISNULL(@c_SKUDSC04, Col35),  Col19 = ISNULL(@c_SKUQTY04, Col19),
            Col20 = ISNULL(@c_SKU05, Col20),  Col36 = ISNULL(@c_SKUDSC05, Col36),  Col21 = ISNULL(@c_SKUQTY05, Col21),
            Col22 = ISNULL(@c_SKU06, Col22),  Col37 = ISNULL(@c_SKUDSC06, Col37),  Col23 = ISNULL(@c_SKUQTY06, Col23),
            Col24 = ISNULL(@c_SKU07, Col24),  Col38 = ISNULL(@c_SKUDSC07, Col38),  Col25 = ISNULL(@c_SKUQTY07, Col25),
            Col26 = ISNULL(@c_SKU08, Col26),  Col39 = ISNULL(@c_SKUDSC08, Col39),  Col27 = ISNULL(@c_SKUQTY08, Col27),
            Col28 = ISNULL(@c_SKU09, Col28),  Col40 = ISNULL(@c_SKUDSC09, Col40),  Col29 = ISNULL(@c_SKUQTY09, Col29),
            Col30 = ISNULL(@c_SKU10, Col30),  Col41 = ISNULL(@c_SKUDSC10, Col41),  Col31 = ISNULL(@c_SKUQTY10, Col31)
         WHERE Col11 = @pageID;

         SET @counter += 1;
      END;
   END;

   -- Final output
   SELECT * FROM @Result ORDER BY ID;
END;
