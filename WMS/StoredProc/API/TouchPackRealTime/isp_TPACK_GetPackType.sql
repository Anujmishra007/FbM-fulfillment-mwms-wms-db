SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Stored Proc: isp_TPACK_GetPackType                                            */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Determine Pack Type (Single/Multi/MPOC)                      */
/*                                                                               */
/* Pack Type Logic:                                                              */
/* 1. Single: Orders.Ecom_Single_Flag='S' OR sum(pickdetail.qty)=1 per order     */
/* 2. Multi:  Orders.Ecom_Single_Flag='M' OR sum(pickdetail.qty)>1 per order     */
/* 3. MPOC:   1 DropID (ToteID) : Multiple Orders                                */
/*            Check if any DropID has multiple distinct OrderKeys                */
/* Date         Rev  Author     Purposes                                         */
/* 2025-11-28   1.0  Sean       Created - Initial implementation                 */
/* 2025-12-16   1.1  Sean       Update MPOC logic                                */
/* 2025-12-17   1.2  Sean       Restructure query logic based on @cType          */
/* 2026-12-17   1.3  Sean       UWP-46560 issue fix                              */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_GetPackType] (
     @cType                NVARCHAR(30)      = ''    -- 'order', 'pickslip', 'toteid'
   , @bIsDiscrete          BIT               = 0     -- 1=Discrete (1 pickslip=1 order), 0=Consolidate
   , @bIsCustom            BIT               = 0     -- Custom pickslip flag
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''    -- ToteID
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @cLangCode            NVARCHAR(10)      = ''
   , @cPackType            NVARCHAR(20)      = ''    OUTPUT
   , @b_Success            INT               = 0     OUTPUT
   , @n_ErrNo              INT               = 0     OUTPUT
   , @c_ErrMsg             NVARCHAR(250)     = ''    OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_DEFAULTS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue          INT            = 1
         , @n_StartCnt          INT            = @@TRANCOUNT
         , @nOrderCount         INT            = 0
         , @nHasMPOC            BIT            = 0

   SET @b_Success = 0
   SET @n_ErrNo   = 0
   SET @c_ErrMsg  = ''
   SET @cPackType = ''

   DECLARE @OrderAnalysis TABLE (
        OrderKey         NVARCHAR(20)
      , EcomSingleFlag   NCHAR(1)
      , TotalQty         INT
   )

   -- Branch 1: @cType = 'pickslip' OR (@cType = 'order' AND @bIsCustom = 0)
   IF @cType = 'pickslip' OR (@cType = 'order' AND @bIsCustom = 0)
   BEGIN
      IF @bIsDiscrete = 1
      BEGIN
         INSERT INTO @OrderAnalysis (OrderKey, EcomSingleFlag, TotalQty)
         SELECT  pd.OrderKey
               , o.Ecom_Single_Flag
               , SUM(pd.Qty) AS TotalQty
         FROM PICKDETAIL pd (NOLOCK)
         INNER JOIN ORDERS o (NOLOCK) ON o.OrderKey = pd.OrderKey
         WHERE pd.OrderKey = @cOrderKey
         AND pd.StorerKey = @cStorerKey
         AND o.StorerKey = @cStorerKey
         AND pd.[Status] <= '9'
         AND o.[Status] <= '9'
         GROUP BY pd.OrderKey, o.Ecom_Single_Flag
      END
      ELSE
      BEGIN
         INSERT INTO @OrderAnalysis (OrderKey, EcomSingleFlag, TotalQty)
         SELECT  pd.OrderKey
               , o.Ecom_Single_Flag
               , SUM(pd.Qty) AS TotalQty
         FROM PICKDETAIL pd (NOLOCK)
         INNER JOIN ORDERS o (NOLOCK) ON o.OrderKey = pd.OrderKey
         WHERE EXISTS (SELECT 1
                      FROM LOADPLANDETAIL lpd (NOLOCK)
                      WHERE lpd.OrderKey = pd.OrderKey
                      AND lpd.LoadKey = @cLoadKey)
         AND pd.StorerKey = @cStorerKey
         AND o.StorerKey = @cStorerKey
         AND pd.[Status] <= '9'
         AND o.[Status] <= '9'
         GROUP BY pd.OrderKey, o.Ecom_Single_Flag

         IF EXISTS (
            SELECT 1
            FROM PICKDETAIL pd (NOLOCK)
            WHERE EXISTS (SELECT 1
                         FROM LOADPLANDETAIL lpd (NOLOCK)
                         WHERE lpd.OrderKey = pd.OrderKey
                         AND lpd.LoadKey = @cLoadKey)
            AND pd.StorerKey = @cStorerKey
            AND pd.[Status] <= '9'
            AND pd.DropID IS NOT NULL
            AND pd.DropID <> ''
            GROUP BY pd.DropID
            HAVING COUNT(DISTINCT pd.OrderKey) > 1
         )
         BEGIN
            SET @nHasMPOC = 1
         END
      END
   END
   -- Branch 2: @cType = 'toteid'
   ELSE IF @cType = 'toteid'
   BEGIN
      INSERT INTO @OrderAnalysis (OrderKey, EcomSingleFlag, TotalQty)
      SELECT  pd.OrderKey
            , o.Ecom_Single_Flag
            , SUM(pd.Qty) AS TotalQty
      FROM PICKDETAIL pd (NOLOCK)
      INNER JOIN ORDERS o (NOLOCK) ON o.OrderKey = pd.OrderKey
      WHERE pd.StorerKey = @cStorerKey
      AND pd.DropID = @cDropID
      AND pd.[Status] <= '9'
      AND o.[Status] <= '9'
      GROUP BY pd.OrderKey, o.Ecom_Single_Flag

      SELECT @nOrderCount = COUNT(DISTINCT OrderKey)
      FROM @OrderAnalysis

      IF @nOrderCount > 1
      BEGIN
         SET @nHasMPOC = 1
      END
   END
   -- Branch 3: @cType = 'order'
   ELSE IF @cType = 'order'
   BEGIN
      INSERT INTO @OrderAnalysis (OrderKey, EcomSingleFlag, TotalQty)
      SELECT  pd.OrderKey
            , o.Ecom_Single_Flag
            , SUM(pd.Qty) AS TotalQty
      FROM PICKDETAIL pd (NOLOCK)
      INNER JOIN ORDERS o (NOLOCK) ON o.OrderKey = pd.OrderKey
      WHERE pd.OrderKey = @cOrderKey
      AND pd.StorerKey = @cStorerKey
      AND o.StorerKey = @cStorerKey
      AND pd.[Status] <= '9'
      AND o.[Status] <= '9'
      GROUP BY pd.OrderKey, o.Ecom_Single_Flag
   END

   SELECT @nOrderCount = COUNT(DISTINCT OrderKey)
   FROM @OrderAnalysis

   -- Step 2: MPOC Check
   IF @nHasMPOC = 1
   BEGIN
      SET @cPackType = 'MPOC'
      SET @b_Success = 1
      GOTO EXIT_SP
   END

   -- Step 4: Single Order - Determine Single/Multi based on Ecom flag or quantity
   IF EXISTS (SELECT 1 FROM @OrderAnalysis WHERE EcomSingleFlag = 'M' OR TotalQty > 1)
   BEGIN
      SET @cPackType = 'Multi'
   END
   ELSE IF EXISTS (SELECT 1 FROM @OrderAnalysis WHERE EcomSingleFlag = 'S' OR TotalQty = 1)
   BEGIN
      SET @cPackType = 'Single'
   END

   SET @b_Success = 1

EXIT_SP:
   IF @n_Continue = 3
   BEGIN
      SET @b_Success = 0
      IF @@TRANCOUNT > @n_StartCnt AND @@TRANCOUNT = 1
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartCnt
         BEGIN
            COMMIT TRAN
         END
      END
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO