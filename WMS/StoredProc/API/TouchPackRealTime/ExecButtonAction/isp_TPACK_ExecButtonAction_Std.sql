SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure : isp_TPACK_ExecButtonAction_Std                              */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Handle button actions for validating pack errors             */
/*                                                                               */
/* Date         Rev  Author     Description                                      */
/* 2025-11-19   1.0  Sean01     UWP-42549 - Implement Short Pick actions         */
/* 2026-01-14   1.1  Sean02     UWP-46904 - Only update unpacked items           */
/*                                (CaseID empty)                                 */
/* 2026-01-16   1.2  Sean03     UWP-47102 - Fix Scan by Pickslip                 */
/* 2026-02-04   1.3  Sean03     UWP-42549 - type= Pickslip  & isCustom = 1       */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExecButtonAction_Std] (
     @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @nCartonNo            INT               = 0
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
   , @cAction              NVARCHAR(50)      = ''
   , @cDiffListJson        NVARCHAR(MAX)     = ''
   , @b_Success            INT               = 0   OUTPUT
   , @n_ErrNo              INT               = 0   OUTPUT
   , @c_ErrMsg             NVARCHAR(250)     = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue     INT = 1  
         , @n_StartCnt     INT = @@TRANCOUNT
         , @bUnallocate    BIT = 0
   
   DECLARE @tDiffList TABLE (
      SKU       NVARCHAR(20),
      PickQty   INT,
      PackQty   INT,
      DiffQty   INT
   )

   -- Validate action type and set flag
   IF @cAction = 'SHORT_PICK'
      SET @bUnallocate = 0
   ELSE IF @cAction = 'SHORT_PICK_UNALLOCATE'
      SET @bUnallocate = 1
   ELSE
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 14153
      SET @c_ErrMsg = 'Invalid action type: ' + ISNULL(@cAction, 'NULL')
      GOTO EXIT_SP
   END

   -- Parse SKU difference list
   IF @cDiffListJson IS NOT NULL AND @cDiffListJson <> ''
   BEGIN
      INSERT INTO @tDiffList (SKU, PickQty, PackQty, DiffQty)
      SELECT SKU, PickQty, PackQty, DiffQty
      FROM OPENJSON(@cDiffListJson)
      WITH (
         SKU     NVARCHAR(20),
         PickQty INT,
         PackQty INT,
         DiffQty INT
      )
   END

   -- Execute unified update logic based on type
   IF @cType = 'pickslip' OR (@cType = 'order' AND @bIsCustom = 0)
   BEGIN
      IF @bIsDiscrete = 1
      BEGIN
         -- Discrete order update
         UPDATE pd WITH (ROWLOCK)
         SET pd.Status = 4
            ,pd.Qty = CASE WHEN @bUnallocate = 1 THEN 0 ELSE pd.Qty END
         FROM PICKDETAIL pd
         INNER JOIN @tDiffList d ON pd.SKU = d.SKU
         WHERE pd.StorerKey = @cStorerKey
            AND pd.OrderKey = @cOrderKey
            AND d.DiffQty > 0
            AND pd.Status <> 4
            AND ISNULL(pd.CaseID, '') = ''
      END
      ELSE
      BEGIN
         IF @bIsCustom = 0
         BEGIN
            UPDATE pd WITH (ROWLOCK)
            SET pd.Status = 4
               ,pd.Qty = CASE WHEN @bUnallocate = 1 THEN 0 ELSE pd.Qty END
            FROM PICKDETAIL pd 
            INNER JOIN @tDiffList d ON pd.SKU = d.SKU
            INNER JOIN LOADPLANDETAIL lpd WITH (NOLOCK) 
               ON lpd.OrderKey = pd.OrderKey AND lpd.LoadKey = @cLoadKey
            WHERE d.DiffQty > 0
               AND pd.Status <> 4
               AND ISNULL(pd.CaseID, '') = ''
         End
         ELSE -- Sean03 S
         BEGIN
            UPDATE pd WITH (ROWLOCK)
            SET pd.Status = 4
               ,pd.Qty = CASE WHEN @bUnallocate = 1 THEN 0 ELSE pd.Qty END
            FROM PICKDETAIL pd 
            INNER JOIN @tDiffList d ON pd.SKU = d.SKU
            WHERE pd.PickSlipNo = @cPickSlipNo 
               And d.DiffQty > 0
               AND pd.Status <> 4
               AND ISNULL(pd.CaseID, '') = ''
         End -- Sean03 E
      END
   END
   ELSE IF @cType = 'toteid'
   BEGIN
      -- Tote/Drop ID based update
      UPDATE pd WITH (ROWLOCK)
      SET pd.Status = 4
         ,pd.Qty = CASE WHEN @bUnallocate = 1 THEN 0 ELSE pd.Qty END
      FROM PICKDETAIL pd
      INNER JOIN @tDiffList d ON pd.SKU = d.SKU
      WHERE pd.StorerKey = @cStorerKey
         AND pd.DropID = @cDropID
         AND d.DiffQty > 0  
         AND pd.Status <> 4
         AND ISNULL(pd.CaseID, '') = ''
   END
   ELSE IF @cType = 'order'
   BEGIN
      -- Order key based update
      UPDATE pd WITH (ROWLOCK)
      SET pd.Status = 4
         ,pd.Qty = CASE WHEN @bUnallocate = 1 THEN 0 ELSE pd.Qty END
      FROM PICKDETAIL pd
      INNER JOIN @tDiffList d ON pd.SKU = d.SKU
      WHERE pd.OrderKey = @cOrderKey
         AND d.DiffQty > 0
         AND pd.Status <> 4
         AND ISNULL(pd.CaseID, '') = ''
   END
   ELSE
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 14154
      SET @c_ErrMsg = 'Invalid type: ' + ISNULL(@cType, 'NULL')
      GOTO EXIT_SP
   END

EXIT_SP:
   IF @n_Continue = 3
   BEGIN      
      SET @b_Success = 0      
      IF @@TRANCOUNT > @n_StartCnt AND @@TRANCOUNT = 1 
         ROLLBACK TRAN      
      ELSE      
         WHILE @@TRANCOUNT > @n_StartCnt      
            COMMIT TRAN      
      RETURN      
   END      
   ELSE      
   BEGIN      
      SET @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
         COMMIT TRAN      
      RETURN      
   END
END
GO