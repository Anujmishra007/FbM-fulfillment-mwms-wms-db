SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: ispPRREC38                                            */
/* Creation Date: 08-JUN-2026                                              */
/* Copyright: MAERSK                                                       */
/* Written by: JihHaur                                                     */
/*                                                                         */
/* Purpose: FCR-12180 AEOMX - On ASN finalize, derive Cube/Weight per EA   */
/*          from mono-SKU UCC dimensions in RECEIPTDETAIL.Notes/Notes2,     */
/*          apply department compression factor and min/max range          */
/*          validation (CODELKUP CUBEPARAMS), then update PACK config       */
/*          (CubeUOM3, Cube, NetWgt) for the SKU. 1:1 SKU->Pack.            */
/*                                                                         */
/* Called By: ASN manual finalization                                      */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 2026-06-08   JihHaur 1.0   Created.                                     */
/***************************************************************************/
CREATE OR ALTER PROC [dbo].[ispPRREC38]
(     @c_Receiptkey  NVARCHAR(10)
  ,   @b_Success     INT           OUTPUT
  ,   @n_Err         INT           OUTPUT
  ,   @c_ErrMsg      NVARCHAR(255) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
 
   DECLARE @b_Debug            INT
         , @n_Continue         INT
         , @n_StartTranCount    INT
         , @c_StorerKey         NVARCHAR(15)
         -- cursor / per-SKU working vars
         , @c_Sku               NVARCHAR(20)
         , @c_PackKey           NVARCHAR(10)
         , @c_Dept              NVARCHAR(30)
         , @c_UCC               NVARCHAR(30)
         , @n_UCCQty            FLOAT
         , @c_Notes             NVARCHAR(500)
         , @c_Notes2            NVARCHAR(500)
         -- parsed dimension / weight values
         , @n_Length            FLOAT
         , @n_Width             FLOAT
         , @n_Height            FLOAT
         , @n_Weight            FLOAT
         -- CODELKUP department parameters
         , @n_CompFactor        FLOAT
         , @n_MinCube           FLOAT
         , @n_MaxCube           FLOAT
         -- calculated results
         , @n_TotalCube         FLOAT
         , @n_CubePerEA         FLOAT
         , @n_AdjCubePerEA      FLOAT
         , @n_WeightPerEA       FLOAT
         -- parse helpers
         , @n_Pos               INT
         , @n_End               INT
 
   SET @b_Success      = 1
   SET @n_Err          = 0
   SET @c_ErrMsg       = ''
   SET @b_Debug        = '0'
   SET @n_Continue     = 1
   SET @n_StartTranCount = @@TRANCOUNT
 
   /*-----------------------------------------------------------------*/
   /* STEP 0 : Entry validation                                       */
   /*-----------------------------------------------------------------*/
   IF NOT EXISTS( SELECT 1
                  FROM RECEIPT WITH (NOLOCK)
                  WHERE ReceiptKey = @c_Receiptkey
                )
   BEGIN
      GOTO QUIT_SP
   END
 
   /*-----------------------------------------------------------------*/
   /* STEP 1 : Cursor over each distinct SKU on the receipt           */
   /*          that has at least one mono-SKU UCC.                     */
   /*          Mono-SKU UCC = UserDefine01 mapping to exactly one      */
   /*          distinct Sku within this receipt.                       */
   /*-----------------------------------------------------------------*/
   DECLARE cur_Sku CURSOR LOCAL FAST_FORWARD FOR
      SELECT DISTINCT RD.Sku, RD.StorerKey
      FROM RECEIPTDETAIL RD WITH (NOLOCK)
      WHERE RD.ReceiptKey = @c_Receiptkey
      AND (RD.UserDefine01 IS NOT NULL AND RD.UserDefine01 <> '') 
      AND RD.UserDefine01 IN ( -- mono-SKU UCCs only
            SELECT M.UserDefine01
            FROM RECEIPTDETAIL M WITH (NOLOCK)
            WHERE M.ReceiptKey = @c_Receiptkey
            AND (M.UserDefine01 IS NOT NULL AND M.UserDefine01 <> '')
            GROUP BY M.UserDefine01
            HAVING COUNT(DISTINCT M.Sku) = 1
      )
 
   OPEN cur_Sku
   FETCH NEXT FROM cur_Sku INTO @c_Sku, @c_StorerKey
 
   WHILE @@FETCH_STATUS = 0
   BEGIN
      /* reset per-SKU state */
      SET @c_PackKey      = NULL
      SET @c_Dept         = NULL
      SET @c_UCC          = NULL
      SET @n_UCCQty       = 0
      SET @c_Notes        = ''
      SET @c_Notes2       = ''
      SET @n_Length       = 0
      SET @n_Width        = 0
      SET @n_Height       = 0
      SET @n_Weight       = 0
      SET @n_CompFactor   = 0
      SET @n_MinCube      = 0
      SET @n_MaxCube      = 0
 
      /*-----------------------------------------------------------------*/
      /* STEP 2 : Resolve SKU -> Pack and department.                    */
      /*          Skip if SKU/Pack missing.                              */
      /*-----------------------------------------------------------------*/
      SELECT @c_PackKey = S.PACKKey
           , @c_Dept    = LTRIM(RTRIM(ISNULL(S.BUSR1,'')))
      FROM SKU S WITH (NOLOCK)
      WHERE S.StorerKey = @c_StorerKey
      AND S.Sku = @c_Sku
 
      IF ISNULL(@c_PackKey,'') = ''
         GOTO NEXT_SKU
 
      /*-----------------------------------------------------------------*/
      /* STEP 3 : Processed control - prevent recalculation.             */
      /*          PACK.ReplenishZone1 is repurposed as the processed     */
      /*          marker for this enrichment (default 'N', set to 'Y'    */
      /*          after a successful PACK update in STEP 9). It is not   */
      /*          used by any replenishment logic in this project.        */
      /*-----------------------------------------------------------------*/
      IF EXISTS( SELECT 1 FROM PACK WITH (NOLOCK)
                 WHERE PackKey = @c_PackKey
                 AND ISNULL(ReplenishZone1,'N') = 'Y' )
         GOTO NEXT_SKU
 
      /*-----------------------------------------------------------------*/
      /* STEP 4 : Department must exist in CODELKUP CUBE_PARAM, else skip */
      /*-----------------------------------------------------------------*/
      IF @c_Dept = ''
         GOTO NEXT_SKU
 
      SELECT @n_CompFactor = CONVERT(FLOAT, NULLIF(LTRIM(RTRIM(UDF01)),''))
           , @n_MinCube    = CONVERT(FLOAT, NULLIF(LTRIM(RTRIM(UDF02)),''))
           , @n_MaxCube    = CONVERT(FLOAT, NULLIF(LTRIM(RTRIM(UDF03)),''))
      FROM CODELKUP WITH (NOLOCK)
      WHERE LISTNAME = 'CUBE_PARAM'
      AND Code = @c_Dept
      AND Storerkey = @c_StorerKey
 
      IF @@ROWCOUNT = 0 OR ISNULL(@n_CompFactor,0) = 0
         GOTO NEXT_SKU
 
      /*-----------------------------------------------------------------*/
      /* STEP 5 : Pick the mono-SKU UCC with the HIGHEST EA qty for this  */
      /*          SKU and pull its Notes / Notes2.                        */
      /*-----------------------------------------------------------------*/
      ;WITH CTE_SingleSkuUCC AS
      (
         SELECT M.UserDefine01
         FROM RECEIPTDETAIL M WITH (NOLOCK)
         WHERE M.ReceiptKey = @c_Receiptkey
         AND (M.UserDefine01 IS NOT NULL AND M.UserDefine01 <> '')
         GROUP BY M.UserDefine01
         HAVING COUNT(DISTINCT M.Sku) = 1
      )
      SELECT TOP 1
             @c_UCC    = RD.UserDefine01
           , @n_UCCQty = RD.QtyReceived
           , @c_Notes  = ISNULL(RD.Notes, '')
           , @c_Notes2 = ISNULL(RD.Notes2, '')
      FROM RECEIPTDETAIL RD WITH (NOLOCK)
      JOIN CTE_SingleSkuUCC S ON S.UserDefine01 = RD.UserDefine01
      WHERE RD.ReceiptKey = @c_Receiptkey
      AND   RD.Sku = @c_Sku
      AND   (RD.UserDefine01 IS NOT NULL AND RD.UserDefine01 <> '') 
      ORDER BY RD.QtyReceived DESC
 
      IF ISNULL(@c_UCC,'') = '' OR ISNULL(@n_UCCQty,0) <= 0
         GOTO NEXT_SKU
 
      /*-----------------------------------------------------------------*/
      /* STEP 6 : Parse Length/Width/Height/Weight from Notes.            */
      /*  Format: Length="55.4"&Width="33.2"&Height="30.5"&Weight="16.786"*/
      /*  Dimensions UOM = M, Weight UOM = KG (per prerequisites).        */
      /*-----------------------------------------------------------------*/
      -- Length
      SET @n_Pos = CHARINDEX('Length="', @c_Notes)
      IF @n_Pos > 0
      BEGIN
         SET @n_Pos = @n_Pos + 8
         SET @n_End = CHARINDEX('"', @c_Notes, @n_Pos)
         IF @n_End > @n_Pos
            SET @n_Length = CONVERT(FLOAT, NULLIF(SUBSTRING(@c_Notes, @n_Pos, @n_End - @n_Pos),''))
      END
      -- Width
      SET @n_Pos = CHARINDEX('Width="', @c_Notes)
      IF @n_Pos > 0
      BEGIN
         SET @n_Pos = @n_Pos + 7
         SET @n_End = CHARINDEX('"', @c_Notes, @n_Pos)
         IF @n_End > @n_Pos
            SET @n_Width = CONVERT(FLOAT, NULLIF(SUBSTRING(@c_Notes, @n_Pos, @n_End - @n_Pos),''))
      END
      -- Height
      SET @n_Pos = CHARINDEX('Height="', @c_Notes)
      IF @n_Pos > 0
      BEGIN
         SET @n_Pos = @n_Pos + 8
         SET @n_End = CHARINDEX('"', @c_Notes, @n_Pos)
         IF @n_End > @n_Pos
            SET @n_Height = CONVERT(FLOAT, NULLIF(SUBSTRING(@c_Notes, @n_Pos, @n_End - @n_Pos),''))
      END
      -- Weight
      SET @n_Pos = CHARINDEX('Weight="', @c_Notes)
      IF @n_Pos > 0
      BEGIN
         SET @n_Pos = @n_Pos + 8
         SET @n_End = CHARINDEX('"', @c_Notes, @n_Pos)
         IF @n_End > @n_Pos
            SET @n_Weight = CONVERT(FLOAT, NULLIF(SUBSTRING(@c_Notes, @n_Pos, @n_End - @n_Pos),''))
      END
 
      /* Missing dimension or weight data -> skip (Test #7) */
      IF ISNULL(@n_Length,0) <= 0 OR ISNULL(@n_Width,0) <= 0
         OR ISNULL(@n_Height,0) <= 0 OR ISNULL(@n_Weight,0) <= 0
         GOTO NEXT_SKU
 
      /*-----------------------------------------------------------------*/
      /* STEP 7 : Calculate Cube/EA, Weight/EA, apply compression factor */
      /*-----------------------------------------------------------------*/
      SET @n_TotalCube    = @n_Length * @n_Width * @n_Height
      SET @n_CubePerEA    = @n_TotalCube  / @n_UCCQty
      SET @n_WeightPerEA  = @n_Weight     / @n_UCCQty
      SET @n_AdjCubePerEA = @n_CubePerEA  * @n_CompFactor
 
      /*-----------------------------------------------------------------*/
      /* STEP 8 : Validate adjusted cube/EA against department range.     */
      /*          Outside range -> skip cube & weight update (Test #11).  */
      /*-----------------------------------------------------------------*/
      IF @n_AdjCubePerEA < @n_MinCube OR @n_AdjCubePerEA > @n_MaxCube
         GOTO NEXT_SKU
 
      /*-----------------------------------------------------------------*/
      /* STEP 9 : Update PACK configuration (1:1 with SKU).               */
      /*   Master Unit Cube  -> PACK.CubeUOM3 = adjusted cube/EA          */
      /*   Other UOM Cube     -> PACK.Cube     = adjusted cube/EA          */
      /*                         PACK.PackUOM5 = 'M'                       */
      /*   Other UOM NetWgt   -> PACK.NetWgt   = weight/EA                 */
      /*                         PACK.PackUOM7 = 'KG'                      */
      /*   Processed marker   -> PACK.ReplenishZone1 = 'Y'                 */
      /*-----------------------------------------------------------------*/
      UPDATE PACK WITH (ROWLOCK)
      SET  CubeUOM3        = @n_AdjCubePerEA
         , Cube            = @n_AdjCubePerEA
         , PackUOM5        = 'M'
         , NetWgt          = @n_WeightPerEA
         , PackUOM7        = 'KG'
         , ReplenishZone1  = 'Y'
         , TrafficCop      = NULL
      WHERE PackKey = @c_PackKey
 
      SET @n_err = @@ERROR
      IF @n_err <> 0
      BEGIN
         SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
         SET @n_err = 121800
         SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(6),@n_err)+': Update PACK Table Failed. (ispPRREC38)'
                       + ' ( SKU='+ISNULL(RTRIM(@c_Sku),'')+' PackKey='+ISNULL(RTRIM(@c_PackKey),'')
                       + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
         SET @n_continue = 3
         CLOSE cur_Sku
         DEALLOCATE cur_Sku
         GOTO QUIT_SP
      END
 
      NEXT_SKU:
      FETCH NEXT FROM cur_Sku INTO @c_Sku, @c_StorerKey
   END
 
   CLOSE cur_Sku
   DEALLOCATE cur_Sku
 
   QUIT_SP:
   IF CURSOR_STATUS('LOCAL', 'cur_Sku') IN (0 , 1)
   BEGIN
      CLOSE cur_Sku
      DEALLOCATE cur_Sku
   END
  
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0
 
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTranCount
      BEGIN
         ROLLBACK TRAN
      END
      RETURN
   END
   ELSE
   BEGIN
      SET @b_success = 1
      RETURN
   END
END
GO
 
GRANT EXECUTE ON [dbo].[ispPRREC38] TO nSQL
GO
