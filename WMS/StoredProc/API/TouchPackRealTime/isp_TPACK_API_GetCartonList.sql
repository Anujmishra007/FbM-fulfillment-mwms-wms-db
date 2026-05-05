SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_API_GetCartonList                                  */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get the list of carton type for specific storer              */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-09-11   1.0  GCH225     Created                                          */
/* 2026-03-03   1.1  JWF011     UWP-49326: Display CartonStatus 'PendAudit'      */
/* 2026-04-10   1.2  GCH225     UWP-54004: New Sorting and Ordering Feature      */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_API_GetCartonList] (
     @b_Debug           INT            = 0  
   , @c_Format          VARCHAR(10)    = ''  
   , @c_UserID          NVARCHAR(256)  = ''  
   , @c_OperationType   NVARCHAR(60)   = ''  
   , @c_RequestString   NVARCHAR(MAX)  = ''  
   , @b_Success         INT            = 0   OUTPUT  
   , @n_ErrNo           INT            = 0   OUTPUT  
   , @c_ErrMsg          NVARCHAR(250)  = ''  OUTPUT  
   , @c_ResponseString  NVARCHAR(MAX)  = ''  OUTPUT  
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS ON;
   SET QUOTED_IDENTIFIER ON;
   SET CONCAT_NULL_YIELDS_NULL ON;
   SET ANSI_WARNINGS ON;
   SET ANSI_PADDING ON; 

   DECLARE @n_Continue           INT            = 1  
         , @n_StartCnt           INT            = @@TRANCOUNT  
         , @b_sp_Success         INT  
         , @n_sp_err             INT  
         , @c_sp_errmsg          NVARCHAR(250)  = ''
         , @DBUserName           NVARCHAR(100)
         , @b_sp_ExecuteAs       BIT

   DECLARE @cType                NVARCHAR(30)
         , @bIsDiscrete          BIT
         , @bIsCustom            BIT
         , @cLangCode            NVARCHAR(3)
         , @cPickSlipNo          NVARCHAR(10)
         , @cOrderKey            NVARCHAR(10)
         , @cLoadKey             NVARCHAR(10)
         , @cDropID              NVARCHAR(20)
         , @cStorerKey           NVARCHAR(15)
         , @cFacility            NVARCHAR(5)
         , @nPageIndex           INT
         , @nPageSize            INT
         , @nOffset              INT
         , @cTimeZone            NVARCHAR(10)
         , @cSearchValue         NVARCHAR(128)
         , @oDynOrderQuery       NVARCHAR(MAX)
         , @SQL                  NVARCHAR(MAX)

   CREATE TABLE #tCartonList (
        nCartonNo      INT
      , cLabelNo       NVARCHAR(20)
      , cCartonStatus  NVARCHAR(20)
      , cIsUCC         NVARCHAR(5)
      , nSKUCount      INT
      , nPackedQty     INT
      , cDate          DATE
      , cTime          VARCHAR(8)
      , cPackedBy      NVARCHAR(50)
   )

   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''  
   SET @c_ResponseString      = '' 
   SET @bIsDiscrete           = 1
   SET @bIsCustom             = 0
   SET @cLangCode             = ''
   SET @cPickSlipNo           = ''
   SET @cOrderKey             = ''
   SET @cLoadKey              = ''
   SET @cDropID               = ''
   SET @cStorerKey            = ''
   SET @cFacility             = ''
   SET @nPageIndex            = 0
   SET @nPageSize             = 20
   SET @nOffset               = 0
   SEt @cTimeZone             = ''
   SET @cSearchValue          = ''
   SET @oDynOrderQuery        = ''
   SET @SQL                   = ''

   EXEC [API].[isp_ECOMP_ValidateAndSetUser]
        @c_UserID      = @c_UserID
      , @c_DBUserName  = @DBUserName OUTPUT
      , @b_ExecuteAs   = @b_sp_ExecuteAs OUTPUT
      , @b_Success     = @b_sp_Success OUTPUT
      , @n_ErrNo       = @n_sp_err OUTPUT
      , @c_ErrMsg      = @c_sp_errmsg OUTPUT

   IF @b_sp_Success = 0
   BEGIN    
      SET @n_Continue = 3
      SET @n_ErrNo = @n_sp_err      
      SET @c_ErrMsg = @c_sp_errmsg     
      GOTO EXIT_SP
   END

   IF @b_sp_ExecuteAs = 1 OR @DBUserName LIKE '%' + @c_UserID + '%'
   BEGIN
      EXECUTE AS LOGIN = @DBUserName
      SET @c_UserID = @DBUserName

      IF OBJECT_ID('dbo.fnc_GetUserName', 'FN') IS NOT NULL
      BEGIN
         IF dbo.fnc_GetUserName() NOT IN ('WMConnect', '')
         BEGIN
            SET @c_UserID = dbo.fnc_GetUserName()
         END
      END
   END

   --Decode Json Format
   SELECT  @cType             = cType
         , @bIsDiscrete       = bIsDiscrete
         , @bIsCustom         = bIsCustom
         , @cPickSlipNo       = cPickSlipNo
         , @cOrderKey         = cOrderKey
         , @cLoadKey          = cLoadKey
         , @cDropID           = cDropID
         , @cLangCode         = cLangCode
         , @cStorerKey        = cStorerKey
         , @cFacility         = cFacility
         , @cTimeZone         = cTimeZone
         , @cSearchValue      = cSearchValue
         , @nPageIndex        = nPageIndex
   FROM OPENJSON(@c_RequestString)
   WITH (
	      cType                NVARCHAR(30)
	    , bIsDiscrete          BIT
	    , bIsCustom            BIT
       , cPickSlipNo          NVARCHAR(10)      
       , cLoadKey             NVARCHAR(10)      
       , cOrderKey            NVARCHAR(10)
       , cDropID              NVARCHAR(20)
       , cLangCode            NVARCHAR(3)
       , cStorerKey           NVARCHAR(15)
       , cFacility            NVARCHAR(5)
       , cTimeZone            NVARCHAR(10)
       , cSearchValue         NVARCHAR(128)
       , nPageIndex           INT
   )

   SET @nOffset = ISNULL(@nPageIndex , 0)
   
   IF @bIsDiscrete = 1 AND @bIsCustom = 1
   BEGIN
      INSERT INTO #tCartonList
      (
           nCartonNo
         , cLabelNo
         , cCartonStatus
         , cIsUCC
         , nSKUCount
         , nPackedQty
         , cDate
         , cTime
         , cPackedBy
      )
      SELECT  X.nCartonNo
            , X.cLabelNo
            , X.cCartonStatus
            , X.cIsUCC
            , X.nSKUCount
            , X.nPackedQty
            , CONVERT(DATE, X.EditDate) AS cDate
            , CONVERT(VARCHAR(8), X.EditDate, 108) AS cTime
            , X.cPackedBy
      FROM (
         SELECT  PKI.CartonNo AS nCartonNo
               , MAX(PD.LabelNo) AS cLabelNo
               , IIF(PKI.CartonStatus IN ('INPROGRESS','HOLD','CLOSED'), UPPER(PKI.CartonStatus), 'CLOSED') AS cCartonStatus
               , IIF(ISNULL(PKI.UCCNo,'') <> '', 'Yes','No') AS cIsUCC
               , COUNT(DISTINCT PD.SKU) AS nSKUCount
               , PKI.Qty AS nPackedQty
               , SWITCHOFFSET(TODATETIMEOFFSET(PKI.EditDate, DATEPART(TZOFFSET, SYSDATETIMEOFFSET())), @cTimeZone) AS EditDate
               , PKI.EditWho AS cPackedBy
         FROM PACKINFO PKI (NOLOCK)
         LEFT JOIN PACKDETAIL PD (NOLOCK)
         ON PD.PickSlipNo = PKI.PickSlipNo
         AND PD.CartonNo = PKI.CartonNo
         WHERE PKI.PickSlipNo = @cPickSlipNo
         AND PKI.CartonStatus IN ('HOLD','CLOSED')
         AND EXISTS (SELECT 1 
                     FROM PICKDETAIL PD2 (NOLOCK)
                     WHERE PD2.OrderKey = @cOrderKey
                     AND PD2.CaseID = PD.LabelNo
                     )
         GROUP BY PKI.PickSlipNo
                  , PKI.CartonNo
                  , PKI.CartonStatus
                  , PKI.UCCNo
                  , PKI.Qty
                  , PKI.EditDate
                  , PKI.EditWho
         UNION ALL
         SELECT  PKI.CartonNo AS nCartonNo
               , MAX(PD.LabelNo) AS cLabelNo
               , IIF(PKI.CartonStatus IN ('INPROGRESS','HOLD','CLOSED'), UPPER(PKI.CartonStatus), 'CLOSED') AS cCartonStatus
               , IIF(ISNULL(PKI.UCCNo,'') <> '', 'Yes','No') AS cIsUCC
               , COUNT(DISTINCT PD.SKU) AS nSKUCount
               , PKI.Qty AS nPackedQty
               , SWITCHOFFSET(TODATETIMEOFFSET(PKI.EditDate, DATEPART(TZOFFSET, SYSDATETIMEOFFSET())), @cTimeZone) AS EditDate
               , PKI.EditWho AS cPackedBy
         FROM PACKINFO PKI (NOLOCK)
         LEFT JOIN PACKDETAIL PD (NOLOCK)
         ON PD.PickSlipNo = PKI.PickSlipNo
         AND PD.CartonNo = PKI.CartonNo
         WHERE PKI.PickSlipNo = @cPickSlipNo
         AND PKI.CartonStatus NOT IN ('HOLD','CLOSED')
         GROUP BY PKI.PickSlipNo
                  , PKI.CartonNo
                  , PKI.CartonStatus
                  , PKI.UCCNo
                  , PKI.Qty
                  , PKI.EditDate
                  , PKI.EditWho
      ) X
      WHERE (@cSearchValue = '' 
      OR ( 
            X.nCartonNo LIKE CONCAT(@cSearchValue, '%') 
         OR X.cLabelNo LIKE CONCAT(@cSearchValue, '%') 
         OR X.cCartonStatus LIKE CONCAT(@cSearchValue, '%') 
         OR X.cPackedBy LIKE CONCAT(@cSearchValue, '%')
         OR X.EditDate LIKE CONCAT(@cSearchValue, '%')
      ))
      ORDER BY IIF(X.cPackedBy = @c_UserID, 1, 2) 
               , CASE X.cCartonStatus
                  WHEN 'INPROGRESS' THEN 1
                  WHEN 'HOLD' THEN 2
                  WHEN 'CLOSED' THEN 3
                  ELSE 99
               END
               , X.nCartonNo DESC
               , X.EditDate DESC
      OFFSET ISNULL(@nOffset,0) ROWS
      FETCH NEXT ISNULL(@nPageSize,20) ROWS ONLY               
   END
   ELSE
   BEGIN
      IF @cPickSlipNo = '' AND @cDropID = ''
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 10051
         SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Failed to Perform Check Carton, PickSlipNo and DropID both are empty.
         GOTO EXIT_SP
      END

      INSERT INTO #tCartonList
      (
           nCartonNo
         , cLabelNo
         , cCartonStatus
         , cIsUCC
         , nSKUCount
         , nPackedQty
         , cDate
         , cTime
         , cPackedBy
      )
      SELECT  X.nCartonNo
            , X.cLabelNo
            , X.cCartonStatus
            , X.cIsUCC
            , X.nSKUCount
            , X.nPackedQty
            , CONVERT(DATE, X.EditDate) AS cDate
            , CONVERT(VARCHAR(8), X.EditDate, 108) AS cTime
            , X.cPackedBy
      FROM (
         SELECT  PKI.CartonNo AS nCartonNo
               , MAX(PD.LabelNo) AS cLabelNo
               , IIF(PKI.CartonStatus IN ('INPROGRESS','HOLD','CLOSED','PendAudit'), UPPER(PKI.CartonStatus), 'CLOSED') AS cCartonStatus
               , IIF(ISNULL(PKI.UCCNo,'') <> '', 'Yes','No') AS cIsUCC
               , COUNT(DISTINCT PD.SKU) AS nSKUCount
               , PKI.Qty AS nPackedQty
               , SWITCHOFFSET(TODATETIMEOFFSET(PKI.EditDate, DATEPART(TZOFFSET, SYSDATETIMEOFFSET())), @cTimeZone) AS EditDate
               , PKI.EditWho AS cPackedBy
         FROM PACKINFO PKI (NOLOCK)
         LEFT JOIN PACKDETAIL PD (NOLOCK)
         ON PD.PickSlipNo = PKI.PickSlipNo
         AND PD.CartonNo = PKI.CartonNo
         WHERE (@cPickSlipNo = '' OR PKI.PickSlipNo = @cPickSlipNo)
         AND (@cDropID = '' OR PD.DropID = @cDropID)
         GROUP BY PKI.PickSlipNo
                  , PKI.CartonNo
                  , PKI.CartonStatus
                  , PKI.UCCNo
                  , PKI.Qty
                  , PKI.EditDate
                  , PKI.EditWho
      ) X
      WHERE (@cSearchValue = '' 
      OR ( 
            X.nCartonNo LIKE CONCAT(@cSearchValue, '%') 
         OR X.cLabelNo LIKE CONCAT(@cSearchValue, '%') 
         OR X.cCartonStatus LIKE CONCAT(@cSearchValue, '%') 
         OR X.cPackedBy LIKE CONCAT(@cSearchValue, '%')
         OR X.EditDate LIKE CONCAT(@cSearchValue, '%')
      ))
      ORDER BY IIF(X.cPackedBy = @c_UserID, 1, 2) 
               , CASE X.cCartonStatus
                  WHEN 'INPROGRESS' THEN 1
                  WHEN 'HOLD' THEN 2
                  WHEN 'CLOSED' THEN 3
                  WHEN 'PendAudit' THEN 4
                  ELSE 99
               END
               , X.nCartonNo DESC
               , X.EditDate DESC
      OFFSET ISNULL(@nOffset,0) ROWS
      FETCH NEXT ISNULL(@nPageSize,20) ROWS ONLY
   END

  SELECT @oDynOrderQuery = ISNULL(STUFF((SELECT ', ' + QUOTENAME(CODE) + ' ' + Long
                               FROM CODELKUP (NOLOCK)
                               WHERE LISTNAME = 'TPCTNSORT'
                               AND StorerKey = @cStorerKey
                               AND Short >= 1 AND Short <= 9
                               AND Long IN ('DESC', 'ASC')
                               ORDER BY Short ASC
                               FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)')
                               ,1,2,''), '') -- remove leading comma

   IF @oDynOrderQuery <> ''
   BEGIN
      SET @SQL = 'SET @c_ResponseString = ISNULL((SELECT nCartonNo '
               + ', cLabelNo '
               + ', cCartonStatus '
               + ', cIsUCC '
               + ', nSKUCount '
               + ', nPackedQty '
               + ', cDate '
               + ', cTime '
               + ', cPackedBy '
               + ' FROM #tCartonList '
               + ' ORDER BY ' + @oDynOrderQuery
               + ' FOR JSON AUTO, ROOT(''Cartons'')'
               + '), ''{"Cartons":[]}'')'

       EXEC sp_executesql @SQL
       , N'@c_ResponseString NVARCHAR(MAX) OUTPUT'
       , @c_ResponseString = @c_ResponseString OUTPUT               
   END
   ELSE
   BEGIN
      SET @c_ResponseString = ISNULL ((SELECT nCartonNo
                                    , cLabelNo
                                    , cCartonStatus
                                    , cIsUCC
                                    , nSKUCount
                                    , nPackedQty
                                    , cDate
                                    , cTime
                                    , cPackedBy
                              FROM #tCartonList
                              FOR JSON AUTO, ROOT('Cartons')
                              ),'{"Cartons":[]}')
   END
EXIT_SP:
   DROP TABLE #tCartonList
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
      SELECT @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END