IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_CartonOptimizeCheck]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_CartonOptimizeCheck]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: isp_CartonOptimizeCheck                                 */
/* Creation Date: 2020-09-04                                            */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:                                                             */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 09-OCT-2020 Wan      1.0   Created                                   */ 
/************************************************************************/
CREATE PROC isp_CartonOptimizeCheck
           @c_CartonGroup  NVARCHAR(10)
         , @c_CartonType   NVARCHAR(10)   = ''     OUTPUT
         , @n_MaxCube      FLOAT          = 0.00   OUTPUT
         , @n_MaxWeight    FLOAT          = 0.00   OUTPUT
         , @n_QtyToPack    INT            = 0      OUTPUT
         , @b_Success      INT            = 1      OUTPUT
         , @n_Err          INT            = 0      OUTPUT
         , @c_ErrMsg       NVARCHAR(255)  = ''     OUTPUT
         , @b_Debug        INT            = 0
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt          INT   = @@TRANCOUNT
         , @n_Continue           INT   = 1
                                 
         , @n_ID                 INT   = 0
         , @c_NewCartonType      NVARCHAR(10)   = ''  
         , @n_NewMaxCube         FLOAT          = 0.00
         , @n_NewMaxWeight       FLOAT          = 0.00
         , @c_OrigCartonType     NVARCHAR(10)   = ''  
         , @n_OrigMaxCube        FLOAT          = 0.00
         , @n_OrigMaxWeight      FLOAT          = 0.00

         , @n_Qty                INT            = 0
         , @n_PackQtyIndicator   INT            = 0
         , @n_QtyItemToReduce    INT            = 0
         , @c_Storerkey          NVARCHAR(15)   = ''
         , @c_Sku                NVARCHAR(20)   = ''

         , @c_IsCompletePack     NVARCHAR(10)   = ''  --2020-11-03

   IF OBJECT_ID('tempdb..#OptimizeResult','U') IS NULL
   BEGIN
       CREATE TABLE #OptimizeResult
       (    ContainerID       NVARCHAR(10)
       ,    AlgorithmID       NVARCHAR(10)
       ,    IsCompletePack    NVARCHAR(10) 
       ,    ID                INT
       ,    SKU               NVARCHAR(20)
       ,    Qty               INT 
       )
   END

   SET @n_Qty = @n_QtyToPack

   SET @n_ID = 0
   SELECT TOP 1 @n_ID = I.ID
      ,  @c_Storerkey = I.Storerkey
      ,  @c_Sku       = I.Sku
   FROM #t_ItemPack I
   ORDER BY I.ID DESC

   SELECT @n_PackQtyIndicator = SKU.PackQtyIndicator
   FROM SKU WITH (NOLOCK)
   WHERE SKU.Storerkey = @c_Storerkey
   AND   SKU.Sku = @c_Sku

   IF @n_PackQtyIndicator <= 1 
   BEGIN
      SET @n_QtyItemToReduce = 1
   END 
   ELSE 
   BEGIN
      IF @n_QtyToPack % @n_PackQtyIndicator > 0
      BEGIN
         SET @n_QtyItemToReduce = 1
      END
      ELSE
      BEGIN
         SET @n_QtyItemToReduce = @n_PackQtyIndicator
      END
   END

   CARTONIZE_CHECK:
   IF @b_Debug = 1
   BEGIN   
      print @c_CartonGroup  + ': ' + @c_CartonType 
      print '@n_QtyItemToReduce: ' + CAST(@n_QtyItemToReduce AS NVARCHAR)
         + ',@n_PackQtyIndicator:' + CAST(@n_PackQtyIndicator AS NVARCHAR)
   END

   TRUNCATE TABLE #OptimizeResult
   INSERT INTO #OptimizeResult (ContainerID, AlgorithmID, IsCompletePack, ID, SKU, Qty)
   EXEC isp_SubmitToCartonizeAPI
        @c_CartonGroup = @c_CartonGroup 
      , @c_CartonType  = @c_CartonType  
      , @b_Success     = @b_Success       OUTPUT
      , @n_Err         = @n_Err           OUTPUT
      , @c_ErrMsg      = @c_ErrMsg        OUTPUT
      --, @b_Debug       = @b_Debug

   IF @b_Success = 0
   BEGIN
      SET @n_Continue = 3
      SET @n_err = 84010  
      SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Executing isp_SubmitToCartonizeAPI. (isp_CartonOptimizeCheck)'   
                  + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '   
      GOTO QUIT_SP  
   END

   IF @b_Debug = 1
   BEGIN
      SELECT * FROM #OptimizeResult
      select @n_Qty, @n_QtyToPack
   END

   --2020-11-03 - START
   SET @c_IsCompletePack = ''
   SELECT @c_IsCompletePack = IsCompletePack
   FROM #OptimizeResult

   IF @c_IsCompletePack = 'TRUE'
   BEGIN
      GOTO QUIT_SP
   END
   --2020-11-03 - END

   IF @n_Qty = @n_QtyToPack  -- Not Get bigger Carton yet
   BEGIN
      --Strategy 1) Get Bigger Carton
      SET @c_NewCartonType = ''
      SELECT TOP 1 @c_NewCartonType = CZ.CartonType
                  ,@n_NewMaxCube    = CZ.[Cube]
                  ,@n_NewMaxWeight  = CZ.MaxWeight
      FROM #NikeCTNGroup CZ WITH (NOLOCK)
      WHERE CZ.CartonizationGroup = @c_CartonGroup
      AND   CZ.[Cube]    >= @n_MaxCube
      AND   CZ.MaxWeight >= @n_MaxWeight
      AND   CZ.CartonType <> @c_CartonType
      ORDER BY CZ.[Cube] 
              ,CZ.MaxWeight

      IF @b_Debug = 1
      BEGIN
        PRINT '@c_NewCartonType£º' +@c_NewCartonType 
            + ', @n_NewMaxCube£º' +  cast(@n_NewMaxCube as nvarchar)
            + ', @n_NewMaxWeight£º' +  cast(@n_NewMaxWeight as nvarchar)
            + ', @n_QtyToPack£º' +  cast(@n_QtyToPack as nvarchar)
      END 

      IF @c_NewCartonType <> ''  -- If get bigger Carton, then check if can fit
      BEGIN        
         SET @c_CartonType= @c_NewCartonType
         SET @n_MaxCube   = @n_NewMaxCube
         SET @n_MaxWeight = @n_NewMaxWeight
         GOTO CARTONIZE_CHECK
      END
   END 

   --Strategy 2) Reduce Pack Qty  
   SET @n_QtyToPack = @n_QtyToPack - @n_QtyItemToReduce

   IF @b_Debug = 1
   BEGIN
      PRINT 'N_QtyPack (B4 reduce): ' + CAST (@n_QtyToPack + @n_QtyItemToReduce AS NVARCHAR)
          + ',@n_QtyItemToReduce: ' + CAST (@n_QtyItemToReduce AS NVARCHAR)
          + ',@n_QtyToPack - @n_QtyItemToReduce£º' +  cast(@n_QtyToPack as nvarchar)
   END

   IF @n_QtyToPack <= 0 
   BEGIN
      SET @n_QtyToPack = 0
      SET @c_CartonType= @c_OrigCartonType
      SET @n_MaxCube   = @n_OrigMaxCube
      SET @n_MaxWeight = @n_OrigMaxWeight
      GOTO QUIT_SP
   END

   --SET @n_ID = 0
   --SELECT TOP 1 @n_ID = I.ID
   --FROM #t_ItemPack I
   --ORDER BY I.ID DESC

   UPDATE #t_ItemPack  
      SET Quantity = @n_QtyToPack
   WHERE ID = @n_ID

   IF @n_PackQtyIndicator > 1 AND @n_QtyToPack % @n_PackQtyIndicator = 0
   BEGIN
      SET @n_QtyItemToReduce = @n_PackQtyIndicator
   END

   GOTO CARTONIZE_CHECK

   QUIT_SP:

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_CartonOptimizeCheck'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
GRANT EXECUTE ON [dbo].isp_CartonOptimizeCheck TO nSQL 
GO