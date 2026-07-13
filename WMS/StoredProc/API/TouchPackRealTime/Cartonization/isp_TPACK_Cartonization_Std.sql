SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*********************************************************************************/    
/* Stored Proc: isp_TPACK_Cartonization_Std                                      */    
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Standard Cartonization process.                              */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-05-14   1.0  GCH225     UWP-55977: Standard Cartonization process.       */
/* 2026-07-07   1.1  MBR282     UWP-60792: Update logic for #tItemForCartonize   */
/*********************************************************************************/
CREATE OR ALTER PROC [API].[isp_TPACK_Cartonization_Std] (
     @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @c_UserID             NVARCHAR(256)     = ''
   , @cLangCode            NVARCHAR(10)      = ''
   , @nCartonNo            INT               = 0
   , @nCartonizeStep       INT               = 0
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

   DECLARE @n_Continue        INT            = 1  
         , @n_StartCnt        INT            = @@TRANCOUNT

         , @cOrdDocType       NVARCHAR(10) 
         , @cRecommendBy      NVARCHAR(10)
         , @cIncWeight        NVARCHAR(10)
         , @cSKUWeight        NVARCHAR(20)
         , @cSKUCube          NVARCHAR(20)
         , @cSKUHeight        NVARCHAR(20)
         , @cSKULength        NVARCHAR(20)
         , @cSKUWidth         NVARCHAR(20)
         , @cSQLQuery         NVARCHAR(MAX)
         , @cSQLSelectClause  NVARCHAR(MAX)
         , @cSQLFromClause    NVARCHAR(MAX)
         , @cSQLWhereClause   NVARCHAR(MAX)
         , @cSQLGroupByClause NVARCHAR(MAX)
         , @cSQLOrderByClause NVARCHAR(MAX)
         , @nTotalCube        DECIMAL(18, 4)
         , @nTotalWeight      DECIMAL(18, 4)
         , @bIncWeight        BIT
         , @cRecommendedCTN   NVARCHAR(20)
         , @nMaxCartonNo      INT
         , @c_Algorithm       NVARCHAR(20)
         , @c_CTNGroup        NVARCHAR(10)
         , @c_IsCompletePack  NVARCHAR(10)
         , @cCartonType       NVARCHAR(20)
         , @nRowCount         INT
   
   IF OBJECT_ID('tempdb..#tItemForCartonize','U') IS NOT NULL
   BEGIN
      DROP TABLE #tItemForCartonize
   END

   CREATE TABLE #tItemForCartonize (
        Batch    INT
      , SKU      NVARCHAR(20)
      , Qty      INT
      , [Weight] DECIMAL(18, 4) DEFAULT(0) 
      , [Cube]   DECIMAL(18, 4) DEFAULT(0) 
      , [Height] DECIMAL(18, 4) DEFAULT(0) 
      , [Length] DECIMAL(18, 4) DEFAULT(0) 
      , [Width]  DECIMAL(18, 4) DEFAULT(0) 
   )

   IF OBJECT_ID('tempdb..#OptimizeItemToPack','U') IS NOT NULL
   BEGIN
      DROP TABLE #OptimizeItemToPack
   END

   CREATE TABLE #OptimizeItemToPack
   (
      ID          INT                     IDENTITY(1,1)  PRIMARY KEY
   ,  Storerkey   NVARCHAR(15)   NOT NULL DEFAULT('')
   ,  SKU         NVARCHAR(20)   NOT NULL DEFAULT('')
   ,  Dim1        DECIMAL(10,6)  NOT NULL DEFAULT(0.00)
   ,  Dim2        DECIMAL(10,6)  NOT NULL DEFAULT(0.00)
   ,  Dim3        DECIMAL(10,6)  NOT NULL DEFAULT(0.00)
   ,  Quantity    INT            NOT NULL DEFAULT(0)
   ,  CZNCheck    INT            NOT NULL DEFAULT(0)
   )

   DECLARE @t_OptimizeResult TABLE
   (  ContainerID    NVARCHAR(10) NULL DEFAULT('')
    , AlgorithmID    NVARCHAR(10) NULL DEFAULT('')
    , IsCompletePack NVARCHAR(10) NULL DEFAULT('')
    , ID             INT          NULL DEFAULT('')
    , SKU            NVARCHAR(20) NULL DEFAULT('')
    , Qty            INT          NULL DEFAULT(0)
   )

   DECLARE @tPackedItem TABLE(
      OrderKey NVARCHAR(10)
    , LoadKey  NVARCHAR(10) 
    , SKU      NVARCHAR(20)
    , Qty      INT
   )

   DECLARE @tCartonType TABLE(
      RowID INT IDENTITY(1,1) PRIMARY KEY
    , CartonType NVARCHAR(20)
   )

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = ''

   SET @cOrdDocType        = ''
   SET @cRecommendBy       = ''
   SET @cIncWeight         = ''
   SET @cSKUWeight         = 'SKU.Weight'
   SET @cSKUCube           = 'SKU.Cube'
   SET @cSKUHeight         = 'SKU.Height'
   SET @cSKULength         = 'SKU.Length'
   SET @cSKUWidth          = 'SKU.Width'
   SET @cSQLQuery          = ''
   SET @cSQLSelectClause   = ''
   SET @cSQLFromClause     = ''
   SET @cSQLWhereClause    = ''
   SET @cSQLGroupByClause  = ''
   SET @cSQLOrderByClause  = ''
   SET @nTotalCube         = 0
   SET @nTotalWeight       = 0
   SET @bIncWeight         = 0
   SET @nMaxCartonNo       = 0
   SET @c_Algorithm        = 'HEIGHT'
   SET @c_CTNGroup         = ''
   SET @c_IsCompletePack   = ''
   SET @nRowCount          = 0
    
   -- Get configuration values
   SELECT @cOrdDocType  = CASE WHEN Code = 'OrdDocType'  THEN Short ELSE @cOrdDocType END
        , @cRecommendBy = CASE WHEN Code = 'RecommendBy' THEN Short ELSE @cRecommendBy END
        , @cIncWeight   = CASE WHEN Code = 'IncWeight'   THEN Short ELSE @cIncWeight END
        , @cSKUWeight   = CASE WHEN Code = 'SKUWeight'   THEN Short + '.' + Long ELSE @cSKUWeight END
        , @cSKUCube     = CASE WHEN Code = 'SKUCube'     THEN Short + '.' + Long ELSE @cSKUCube END
        , @cSKUHeight   = CASE WHEN Code = 'SKUHeight'   THEN Short + '.' + Long ELSE @cSKUHeight END
        , @cSKULength   = CASE WHEN Code = 'SKULength'   THEN Short + '.' + Long ELSE @cSKULength END
        , @cSKUWidth    = CASE WHEN Code = 'SKUWidth'    THEN Short + '.' + Long ELSE @cSKUWidth END
   FROM CODELKUP (NOLOCK)
   WHERE ListName = 'TPSCtnRec'
   AND Storerkey = @cStorerKey
   
   IF @cOrdDocType NOT IN ('All', 'N', 'E')
   BEGIN
      GOTO EXIT_SP
   END

   IF @cRecommendBy NOT IN ('Cube', 'LWH')
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 15902
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --'Invalid RecommendBy criteria configuration. Only Cube or LWH is allowed.'
      GOTO EXIT_SP
   END

   IF LEN(@cIncWeight) > 0
   BEGIN
      IF @cIncWeight NOT IN ('MAX', 'TARE')
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 15903
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --'Invalid IncWeight criteria configuration. Only MAX or TARE is allowed.'
         GOTO EXIT_SP
      END
      SET @bIncWeight = 1
   END

   IF @cOrdDocType <> 'All'
   BEGIN
      IF @cOrderKey <> ''
      BEGIN
         IF EXISTS ( SELECT 1
                     FROM ORDERS (NOLOCK)
                     WHERE OrderKey = @cOrderKey
                     AND DocType <> @cOrdDocType
         )
         BEGIN
            GOTO EXIT_SP
         END
      END
      ELSE IF @cLoadKey <> ''
      BEGIN
         IF EXISTS ( SELECT 1
                     FROM ORDERS O (NOLOCK)
                     INNER JOIN LOADPLANDETAIL LPD (NOLOCK)
                     ON O.OrderKey = LPD.OrderKey
                     WHERE LPD.LoadKey = @cLoadKey
                     AND O.DocType <> @cOrdDocType
         )
         BEGIN
            GOTO EXIT_SP
         END
      END
   END

   SELECT @c_CTNGroup = CartonGroup
   FROM STORER (NOLOCK)
   WHERE StorerKey = @cStorerKey

   SET @cSQLSelectClause = 'SELECT 2 AS Batch, T.SKU, T.Qty ' + CHAR(13)
                         + ', ' + @cSKUWeight   + ' AS Weight ' + CHAR(13)
                         + ', ' + @cSKUCube     + ' AS Cube ' + CHAR(13)
                         + ', ' + @cSKUHeight   + ' AS Height ' + CHAR(13)
                         + ', ' + @cSKULength   + ' AS Length ' + CHAR(13)
                         + ', ' + @cSKUWidth    + ' AS Width ' + CHAR(13)

   SET @cSQLFromClause = 'FROM #tItemForCartonize T (NOLOCK) ' + CHAR(13)
                       + 'INNER JOIN SKU (NOLOCK) ' + CHAR(13)
                       + 'ON T.SKU = SKU.SKU ' + CHAR(13)
                       + 'AND SKU.StorerKey = ''' + @cStorerKey + ''' ' + CHAR(13)

   IF rdt.rdtGetParsedString(@cSKUWeight, 1, '.')  = 'PACK' 
   OR rdt.rdtGetParsedString(@cSKUCube, 1, '.')    = 'PACK' 
   OR rdt.rdtGetParsedString(@cSKUHeight, 1, '.')  = 'PACK' 
   OR rdt.rdtGetParsedString(@cSKULength, 1, '.')  = 'PACK' 
   OR rdt.rdtGetParsedString(@cSKUWidth, 1, '.')   = 'PACK'
   BEGIN
      SET @cSQLFromClause = @cSQLFromClause 
                          + 'INNER JOIN PACK (NOLOCK) ' + CHAR(13)
                          + 'ON PACK.PACKKey = SKU.PackKey ' + CHAR(13)
   END

   IF @nCartonizeStep = 1
   BEGIN
      IF @cPickSlipNo <> ''
      BEGIN
         INSERT INTO @tPackedItem (OrderKey, LoadKey, SKU, Qty)
         SELECT  @cOrderKey
               , @cLoadKey
               , SKU
               , SUM(Qty) AS Qty
         FROM PACKDETAIL (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         AND (@cDropID = '' OR DropID = @cDropID)
         GROUP BY SKU
      END
      ELSE
      BEGIN
         IF @cType = 'toteid'
         AND @cPickSlipNo = ''
         AND @cOrderKey = ''
         AND @cLoadKey = ''
         AND @cDropID <> ''
         BEGIN
            INSERT INTO @tPackedItem (OrderKey, LoadKey, SKU, Qty)
            SELECT  ISNULL(PH.OrderKey, '') AS OrderKey
                  , ISNULL(PH.Loadkey, '') AS Loadkey
                  , PD.SKU
                  , SUM(PD.Qty) AS Qty
            FROM PACKDETAIL PD (NOLOCK)
            INNER JOIN PACKHEADER PH (NOLOCK) 
            ON PD.PickSlipNo = PH.PickSlipNo
            WHERE PD.DropID = @cDropID
            GROUP BY ISNULL(PH.OrderKey, '')
                  , ISNULL(PH.Loadkey, '')
                  , PD.SKU
         END
      END

      IF @cOrderKey <> ''
      BEGIN
         INSERT INTO #tItemForCartonize (Batch, SKU, Qty)
         SELECT  1 AS Batch
         , PD1.SKU AS SKU
         , ISNULL(PD1.PickedQty, 0) - ISNULL(PD2.Qty, 0) AS Qty
         FROM (SELECT OrderKey
         , SKU
         , SUM(Qty) AS PickedQty
         FROM PICKDETAIL (NOLOCK)
         WHERE OrderKey = @cOrderKey
         AND (@cDropID = '' OR DropID = @cDropID)
         GROUP BY OrderKey, SKU) PD1
         LEFT JOIN @tPackedItem PD2
         ON PD1.SKU = PD2.SKU
         AND PD1.OrderKey = PD2.OrderKey
      END
      ELSE IF @cLoadKey <> ''
      BEGIN
         INSERT INTO #tItemForCartonize (Batch, SKU, Qty)
         SELECT  1 AS Batch
         , PD1.SKU AS SKU
         , ISNULL(PD1.PickedQty, 0) - ISNULL(PD2.Qty, 0) AS Qty
         FROM (SELECT PD.SKU
         , LPD.LoadKey
         , SUM(PD.Qty) AS PickedQty
         FROM PICKDETAIL PD (NOLOCK)
         INNER JOIN LOADPLANDETAIL LPD (NOLOCK)
         ON PD.OrderKey = LPD.OrderKey
         WHERE LPD.LoadKey = @cLoadKey
         AND (@cDropID = '' OR PD.DropID = @cDropID)
         GROUP BY PD.SKU, LPD.LoadKey) PD1
         LEFT JOIN @tPackedItem PD2
         ON PD1.SKU = PD2.SKU
         AND PD1.LoadKey = PD2.LoadKey
      END

      IF NOT EXISTS (SELECT 1 
                     FROM #tItemForCartonize (NOLOCK)
      )
      BEGIN
         GOTO EXIT_SP
      END
      
      IF EXISTS ( SELECT 1 
                  FROM #tItemForCartonize (NOLOCK) 
                  WHERE Qty < 0
      )
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 15907
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --'Packed quantity is greater than picked quantity for one or more SKUs.'
         GOTO EXIT_SP
      END
      ELSE IF (SELECT SUM(Qty) AS TotalQty
      FROM #tItemForCartonize (NOLOCK)
      ) = 0
      BEGIN
         GOTO EXIT_SP
      END 
   END
   ELSE IF @nCartonizeStep = 2
   BEGIN
      INSERT INTO #tItemForCartonize (Batch, SKU, Qty)
      SELECT  1 AS Batch
            , SKU
            , SUM(Qty) AS SUMQty
      FROM PACKDETAIL (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      GROUP BY SKU
   END

   SET @cSQLQuery = @cSQLSelectClause
                  + @cSQLFromClause
   
   INSERT INTO #tItemForCartonize (Batch
                           , SKU
                           , Qty
                           , [Weight]
                           , [Cube]
                           , [Height]
                           , [Length]
                           , [Width]
   )
   EXEC sp_executesql @cSQLQuery

   DELETE FROM #tItemForCartonize
   WHERE Batch = 1
   
   SELECT @nTotalCube = SUM(Qty * ISNULL([Cube], 0))
      , @nTotalWeight = SUM(Qty * ISNULL([Weight], 0))
   FROM #tItemForCartonize

   IF @bIncWeight = 1
   BEGIN
      INSERT INTO @tCartonType (CartonType)
      SELECT ISNULL(RTRIM(C.CartonType), '')
      FROM CARTONIZATION C (NOLOCK)
      WHERE C.CartonizationGroup = @c_CTNGroup
      AND (C.[Cube] * (ISNULL(C.FillTolerance, 100) / 100.0)) >= @nTotalCube
      AND ((@cIncWeight = 'MAX' 
                  AND (C.MaxWeight * (ISNULL(C.FillTolerance, 100) / 100.0)) >= @nTotalWeight + ISNULL(C.CartonWeight, 0))
            OR (@cIncWeight = 'TARE' 
                  AND ((C.MaxWeight - ISNULL(C.CartonWeight, 0)) * (ISNULL(C.FillTolerance, 100) / 100.0)) >= @nTotalWeight))
      ORDER BY   C.UseSequence ASC 
               , C.[Cube] * (ISNULL(C.FillTolerance, 100) / 100.0) ASC
               , CASE @cIncWeight 
               WHEN 'TARE' THEN ((C.MaxWeight - ISNULL(C.CartonWeight, 0)) * (ISNULL(C.FillTolerance, 100) / 100.0))
               WHEN 'MAX'  THEN (C.MaxWeight * (ISNULL(C.FillTolerance, 100) / 100.0))
            END ASC
   END
   ELSE
   BEGIN
      INSERT INTO @tCartonType (CartonType)
      SELECT ISNULL(RTRIM(C.CartonType), '')
      FROM CARTONIZATION C (NOLOCK)
      WHERE C.CartonizationGroup = @c_CTNGroup
      AND (C.[Cube] * (ISNULL(C.FillTolerance, 100) / 100.0)) >= @nTotalCube
      ORDER BY   C.UseSequence ASC
               , C.[Cube] * (ISNULL(C.FillTolerance, 100) / 100.0) ASC
   END

   --If no carton type returned based on cube criteria, 
   --then try get the last carton type which has cube less than total cube without considering fill tolerance
   --, this is to make sure we can get at least one carton type for the recommendation result and avoid no recommendation result returned to user.
   IF NOT EXISTS (SELECT 1 FROM @tCartonType)
   BEGIN
      SELECT TOP 1 @cCartonType =ISNULL(RTRIM(C.CartonType), '')
      FROM CARTONIZATION C (NOLOCK)
      WHERE C.CartonizationGroup = @c_CTNGroup
      AND (C.[Cube] * (ISNULL(C.FillTolerance, 100) / 100.0)) <= @nTotalCube
      ORDER BY   C.UseSequence DESC
               , C.[Cube] * (ISNULL(C.FillTolerance, 100) / 100.0) DESC
   END

   IF @cRecommendBy = 'Cube'
   BEGIN
      IF ISNULL(@cCartonType, '') = '' 
      AND EXISTS (SELECT 1 FROM @tCartonType)
      BEGIN
         SELECT TOP 1 @cCartonType = CartonType
         FROM @tCartonType
         ORDER BY RowID ASC
      END
   END
   ELSE
   BEGIN
      INSERT INTO #OptimizeItemToPack(
              Storerkey
            , Sku
            , Dim1
            , Dim2
            , Dim3
            , Quantity
      )
      SELECT  @cStorerKey
            , SKU
            , Height
            , Width
            , [Length]
            , Qty
      FROM #tItemForCartonize (NOLOCK)

      DECLARE CUR_LOOP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT CartonType
      FROM @tCartonType
      ORDER BY RowID ASC

      OPEN CUR_LOOP
      FETCH NEXT FROM CUR_LOOP INTO @cCartonType
      WHILE @@FETCH_STATUS = 0
      BEGIN
         SET @c_IsCompletePack = ''

         DELETE FROM @t_OptimizeResult

         INSERT INTO @t_OptimizeResult (
              ContainerID
            , AlgorithmID
            , IsCompletePack
            , ID
            , SKU
            , Qty
         )
         EXEC [API].[isp_TPACK_GetCartonizationResult]
              @c_CartonGroup = @c_CTNGroup
            , @c_CartonType  = @cCartonType
            , @c_Algorithm   = @c_Algorithm
            , @cLangCode     = @cLangCode
            , @b_Success     = @b_Success       OUTPUT
            , @n_ErrNo       = @n_ErrNo         OUTPUT
            , @c_ErrMsg      = @c_ErrMsg        OUTPUT
            , @b_debug       = 0

         IF @b_Success = 0
         BEGIN
            SET @n_Continue = 3
            BREAK
         END
         
         SELECT TOP 1 @c_IsCompletePack = IsCompletePack
         FROM @t_OptimizeResult

         IF @@ROWCOUNT = 0
         BEGIN
            SET @c_IsCompletePack = 'false'
         END
         
         IF @c_IsCompletePack = 'true'
         BEGIN
            BREAK
         END

         FETCH NEXT FROM CUR_LOOP INTO @cCartonType
      END
      CLOSE CUR_LOOP
      DEALLOCATE CUR_LOOP
   END
   
   IF ISNULL(@cCartonType,'') <> ''
   BEGIN
      IF @nCartonizeStep = 1
      BEGIN
         IF EXISTS ( SELECT 1 
                     FROM PACKINFO (NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                     AND CartonType <> ''
                     AND Qty = 0
                     AND [Weight] = 0
                     AND [Cube] = 0  
         )
         BEGIN
            DELETE FROM PACKINFO
            WHERE PickSlipNo = @cPickSlipNo
            AND CartonType <> ''
            AND Qty = 0
            AND [Weight] = 0
            AND [Cube] = 0  
         END
         
         IF @nCartonNo > 0
         BEGIN
            SET @nMaxCartonNo = @nCartonNo
         END
         ELSE
         BEGIN
            SELECT @nMaxCartonNo = ISNULL(MAX(CartonNo), 0) + 1
            FROM PACKINFO (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
         END

         INSERT INTO PACKINFO(
            PickSlipNo
            , CartonNo
            , [Weight]
            , [Cube]
            , Qty
            , AddDate
            , AddWho
            , EditDate
            , EditWho
            , CartonType
            , [Length]
            , [Width]
            , [Height]
            , CartonStatus
         )
         VALUES(
            @cPickSlipNo
            , @nMaxCartonNo
            , 0
            , 0
            , 0
            , dbo.fnc_GetDate()
            , @c_UserID
            , dbo.fnc_GetDate()
            , @c_UserID
            , @cCartonType
            , ''
            , ''
            , ''
            , 'INPROGRESS'
         )

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 15909
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --'Failed to insert cartonization result into PACKINFO table.'
            GOTO EXIT_SP
         END
      END
      ELSE IF @nCartonizeStep = 2
      BEGIN
         UPDATE PACKINFO WITH (ROWLOCK)
         SET CartonType = @cCartonType
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 15906
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --'Failed to update cartonization result to PACKINFO table.'
            GOTO EXIT_SP
         END
      END
   END

EXIT_SP:
   IF @n_Continue = 3  -- Error Occured - Process And Return      
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
      SET @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END