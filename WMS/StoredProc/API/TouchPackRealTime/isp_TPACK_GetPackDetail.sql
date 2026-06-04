SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_GetPackDetail                                      */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get the PackDetail for specific carton                       */
/* Called By      : isp_TPACK_API_GetCartonDetail                                */
/*                  isp_TPACK_API_SearchSKU                                      */
/*                  isp_TPACK_ValidateUserInput                                  */    
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-04   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_GetPackDetail] (
	  @cType             NVARCHAR(30)      = ''
   , @bIsDiscrete       BIT               = 0
   , @bIsCustom         BIT               = 0
   , @cPickSlipNo       NVARCHAR(10)      = ''
   , @cOrderKey         NVARCHAR(10)      = ''
   , @cLoadKey          NVARCHAR(10)      = ''
   , @cDropID           NVARCHAR(20)      = ''
   , @cStorerKey        NVARCHAR(15)      = ''
   , @cFacility         NVARCHAR(5)       = ''
   , @cScanType         NVARCHAR(20)      = ''
   , @cSKUList          NVARCHAR(1000)    = ''
   , @c_UserID          NVARCHAR(256)     = ''  
   , @cLangCode         NVARCHAR(3)       = ''
   , @nCartonNo         INT               = 0
   , @nPageIndex        INT               = 0
   , @nPageSize         INT               = 0
   , @cLottableList     NVARCHAR(1000)     = ''
   , @cPackDetailList   NVARCHAR(MAX)     = ''  OUTPUT
   , @b_Success         INT               = 0   OUTPUT
   , @n_ErrNo           INT               = 0   OUTPUT
   , @c_ErrMsg          NVARCHAR(250)     = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF 
   
   DECLARE @n_Continue        INT            = 1  
         , @n_StartCnt        INT            = @@TRANCOUNT  

   DECLARE @cSKU                 NVARCHAR(20)
         , @cSQLQuery            NVARCHAR(MAX) 
         , @cSQLSelectClause     NVARCHAR(2000)
         , @cSQLFromClause       NVARCHAR(2000)
         , @cSQLWhereClause      NVARCHAR(2000)
         , @cSQLGroupByClause    NVARCHAR(2000)
         , @cSQLOrderByClause    NVARCHAR(2000)
         , @cSQLPageClause       NVARCHAR(2000)
         , @cSQLParams           NVARCHAR(2000) 
         , @cSQLQueryEnd         NVARCHAR(1000)
         , @oDynamicJson         NVARCHAR(MAX) 
         , @nSKUCount            INT
         , @cDynamicColumn1      NVARCHAR(100)
         , @cDynamicColumn2      NVARCHAR(100)
         , @cDynamicColumn3      NVARCHAR(100)
         , @cDynamicColumn4      NVARCHAR(100)
         , @cDynamicColumn5      NVARCHAR(4000)
         , @cOffset              NVARCHAR(10)
         , @cAuthority           NVARCHAR(30)

   SET @b_Success             = 0
   SET @cPackDetailList       = ''
   SET @cSKU                  = ''
   SET @cSQLQuery             = ''
   SET @cSQLSelectClause      = ''
   SET @cSQLFromClause        = ''
   SET @cSQLWhereClause       = ''
   SET @cSQLGroupByClause     = ''
   SET @cSQLOrderByClause     = ''
   SET @cSQLPageClause        = ''
   SET @cSQLParams            = ''
   SET @cSQLQueryEnd          = ''
   SET @oDynamicJson          = ''
   SET @nSKUCount             = 0
   SET @cDynamicColumn1       = ''
   SET @cDynamicColumn2       = ''
   SET @cDynamicColumn3       = ''
   SET @cDynamicColumn4       = ''
   SET @cDynamicColumn5       = ''
   SET @cOffset               = ''

   SET @cSQLQueryEnd = ' FOR JSON PATH )) ' + CHAR(13)
                     + ' ),'''') ' + CHAR(13)
   SET @cSQLSelectClause = 'SELECT @oDynamicJson = ISNULL(( JSON_QUERY(( SELECT S.SKU AS sku ' + CHAR(13)
                         + ', S.Descr AS descr ' + CHAR(13)
                         + ', S.RetailSKU AS retailSKU ' + CHAR(13)
                         + ', S.ManufacturerSKU AS manufacturerSKU ' + CHAR(13)
                         + ', S.AltSKU AS altSKU ' + CHAR(13)
                        

   SET @cSQLGroupByClause = 'GROUP BY S.SKU ' + CHAR(13)
                          + ', S.Descr ' + CHAR(13)
                          + ', S.RetailSKU ' + CHAR(13)
                          + ', S.ManufacturerSKU ' + CHAR(13)
                          + ', S.AltSKU ' + CHAR(13)

   SET @cOffset = ISNULL(TRY_CAST(@nPageIndex AS NVARCHAR(10)),'0')

   SET @cSQLPageClause = ' OFFSET ' +  @cOffset + ' ROWS ' + CHAR(13)
                       + ' FETCH NEXT ' +  TRY_CAST(@nPageSize AS NVARCHAR(10)) + ' ROWS ONLY ' + CHAR(13)

   SET @cSQLParams = @cSQLParams
                   + ' @oDynamicJson NVARCHAR(MAX) OUTPUT ' 
   
   EXEC nspGetRight    
        @c_Facility  = @cFacility    
      , @c_StorerKey = @cStorerKey   
      , @c_sku       = ''    
      , @c_ConfigKey = 'TPS-dynamicPackDetail'    
      , @c_authority = @cAuthority        OUTPUT    
      , @b_Success   = @b_Success         OUTPUT
      , @n_err       = @n_ErrNo           OUTPUT
      , @c_errmsg    = @c_ErrMsg          OUTPUT
      , @c_Option1   = @cDynamicColumn1   OUTPUT
      , @c_Option2   = @cDynamicColumn2   OUTPUT
      , @c_Option3   = @cDynamicColumn3   OUTPUT
      , @c_Option4   = @cDynamicColumn4   OUTPUT
      , @c_Option5   = @cDynamicColumn5   OUTPUT

   IF @b_Success = 0
   BEGIN    
      SET @n_Continue  = 3  
      GOTO EXIT_SP
   END

   IF @cAuthority = '1'
   BEGIN
      IF  @cDynamicColumn3 = 'CUSTOM' 
      BEGIN
         IF @cDynamicColumn5 = '' 
         AND ISJSON(@cDynamicColumn5) <> 1
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 10952      
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Invalid configuration for dynamic columns.'
            GOTO EXIT_SP
         END
      END
      ELSE
      BEGIN
         IF @cDynamicColumn1 <> ''
         BEGIN
            SET @cSQLSelectClause = @cSQLSelectClause
                                 + ', ''' + rdt.rdtGetParsedString(@cDynamicColumn1, 2, '.') + ''' AS DynamicColumn1 ' + CHAR(13)
      
            IF rdt.rdtGetParsedString(@cDynamicColumn1, 1, '.') = 'SKU'
            BEGIN
               SET @cSQLSelectClause = @cSQLSelectClause
                                    + ', S.'
               SET @cSQLGroupByClause = @cSQLGroupByClause 
                                    + ', S.'
            END
            ELSE IF rdt.rdtGetParsedString(@cDynamicColumn1, 1, '.') = 'PACKDETAIL'
            BEGIN
               SET @cSQLSelectClause = @cSQLSelectClause
                                    + ', PD.'                            
               SET @cSQLGroupByClause = @cSQLGroupByClause 
                                    + ', PD.'
            END
            SET @cSQLSelectClause = @cSQLSelectClause 
                                 + rdt.rdtGetParsedString(@cDynamicColumn1, 2, '.') + ' AS DynamicValue1 ' + CHAR(13)
            SET @cSQLGroupByClause = @cSQLGroupByClause 
                                 + rdt.rdtGetParsedString(@cDynamicColumn1, 2, '.') + CHAR(13)
         END
         
         IF @cDynamicColumn2 <> ''
         BEGIN
            SET @cSQLSelectClause = @cSQLSelectClause
                                 + ', ''' + rdt.rdtGetParsedString(@cDynamicColumn2, 2, '.') + ''' AS DynamicColumn2 ' + CHAR(13)

            IF rdt.rdtGetParsedString(@cDynamicColumn2, 1, '.') = 'SKU'
            BEGIN
               SET @cSQLSelectClause = @cSQLSelectClause
                                    + ', S.'
               SET @cSQLGroupByClause = @cSQLGroupByClause 
                                    + ', S.'
            END
            ELSE IF rdt.rdtGetParsedString(@cDynamicColumn2, 1, '.') = 'PACKDETAIL'
            BEGIN
               SET @cSQLSelectClause = @cSQLSelectClause
                                    + ', PD.'                            
               SET @cSQLGroupByClause = @cSQLGroupByClause 
                                    + ', PD.'
            END
            SET @cSQLSelectClause = @cSQLSelectClause 
                                 + rdt.rdtGetParsedString(@cDynamicColumn2, 2, '.') + ' AS DynamicValue2 ' + CHAR(13)
            SET @cSQLGroupByClause = @cSQLGroupByClause 
                                 + rdt.rdtGetParsedString(@cDynamicColumn2, 2, '.') + CHAR(13)
         END
      END       
   END
   ELSE
   BEGIN
      SET @cSQLSelectClause = @cSQLSelectClause
                            + ', '''' AS DynamicColumn1 ' + CHAR(13)
                            + ', '''' AS DynamicColumn2 ' + CHAR(13)
                            + ', '''' AS DynamicValue1 ' + CHAR(13)
                            + ', '''' AS DynamicValue2 ' + CHAR(13)
   END            

   IF ISNULL(@cSKUList,'') <> ''
   BEGIN
      SELECT @nSKUCount=COUNT(1)
      FROM OPENJSON(@cSKUList)
      WITH (SKU NVARCHAR(20))

      
      IF @cLottableList <> ''
      BEGIN
         SET @cSQLSelectClause = @cSQLSelectClause
                                 + ', JSON_QUERY((SELECT lottable ' + CHAR(13)
                                 + '  FROM OPENJSON(@cLottableList) WITH (sku NVARCHAR(20), lottable NVARCHAR(30)) t ' + CHAR(13)
                                 + '  WHERE t.sku = S.sku FOR JSON PATH)) AS lottables ' + CHAR(13)
      END
      ELSE
      BEGIN
         SET @cSQLSelectClause = @cSQLSelectClause
                               + ', JSON_QUERY(''[]'') AS lottables '  + CHAR(13)
      END


      SET @cSQLFromClause = @cSQLFromClause 
                          + ' FROM SKU S (NOLOCK) ' + CHAR(13)

      SET @cSQLWhereClause = @cSQLWhereClause
                           + ' WHERE S.StorerKey = @cStorerKey ' + CHAR(13)
                           
   
      IF @nCartonNo <> 0
      BEGIN
         SET @cSQLSelectClause = @cSQLSelectClause
                               + ', COALESCE(SUM(PD.Qty),0) AS packedQty ' + CHAR(13)
         
         SET @cSQLFromClause = @cSQLFromClause
                             + ' LEFT JOIN PACKDETAIL PD (NOLOCK) ' + CHAR(13)
                             + ' ON S.StorerKey = PD.StorerKey ' + CHAR(13)
                             + ' AND S.SKU = PD.SKU ' + CHAR(13)
                             + ' AND PD.PickSlipNo = @cPickSlipNo ' + CHAR(13)
                             + ' AND PD.CartonNo = @nCartonNo ' + CHAR(13)

      END
      ELSE
      BEGIN
         SET @cSQLSelectClause = @cSQLSelectClause
                               + ', 0 AS packedQty ' + CHAR(13)
      END

      IF @nSKUCount = 1
      BEGIN
         SELECT @cSKU = SKU
         FROM OPENJSON(@cSKUList)
         WITH (SKU NVARCHAR(20))

         SET @cSQLWhereClause = @cSQLWhereClause
                              + ' AND S.SKU = @cSKU '  + CHAR(13)
      END
      ELSE
      BEGIN
         SET @cSQLWhereClause = @cSQLWhereClause
                              + ' AND EXISTS (SELECT 1 FROM OPENJSON(@cSKUList) WITH (SKU NVARCHAR(20)) t WHERE t.SKU = S.SKU) '  + CHAR(13)
      END

      SET @cSQLOrderByClause = @cSQLOrderByClause 
                             + ' ORDER BY LEN(S.SKU) ASC, MAX(S.EditDate) DESC ' + CHAR(13)

      SET @cSQLParams = @cSQLParams
                      + ' , @cLottableList NVARCHAR(1000) '
                      + ' , @cStorerKey NVARCHAR(15) '
                      + ' , @cPickSlipNo NVARCHAR(10) '
                      + ' , @nCartonNo INT '
                      + ' , @cSKU NVARCHAR(20) '
                      + ' , @cSKUList NVARCHAR(1000) '

      IF @cDynamicColumn3 = 'CUSTOM'
      BEGIN
         SET @cSQLSelectClause = @cSQLSelectClause + JSON_VALUE(@cDynamicColumn5, '$.select')
         SET @cSQLFromClause = @cSQLFromClause + JSON_VALUE(@cDynamicColumn5, '$.from')
         SET @cSQLWhereClause = @cSQLWhereClause + JSON_VALUE(@cDynamicColumn5, '$.where')
         SET @cSQLGroupByClause = @cSQLGroupByClause + JSON_VALUE(@cDynamicColumn5, '$.groupBy')
      END

      SET @cSQLQuery = @cSQLSelectClause 
                     + @cSQLFromClause 
                     + @cSQLWhereClause 
                     + @cSQLGroupByClause
                     + @cSQLOrderByClause
                     + @cSQLPageClause
                     + @cSQLQueryEnd

      -- PRINT @cSQLQuery 

      --Store JSON result into variable
      EXEC sp_executesql  @cSQLQuery
                        , @cSQLParams
                        , @oDynamicJson OUTPUT
                        , @cLottableList
                        , @cStorerKey
                        , @cPickSlipNo
                        , @nCartonNo
                        , @cSKU
                        , @cSKUList
   END
   ELSE
   BEGIN
      SET @cSQLSelectClause = @cSQLSelectClause 
                            --+ ', SUM(PD.Qty) AS packedQty ' + CHAR(13)
                            + ', JSON_QUERY(''[]'') AS lottables ' + CHAR(13)
                            + ', COALESCE(SUM(PD.Qty),0) AS packedQty ' + CHAR(13)

      SET @cSQLFromClause = @cSQLFromClause
                          + ' FROM PACKDETAIL PD (NOLOCK) ' + CHAR(13)
                          + ' INNER JOIN SKU S (NOLOCK) ' + CHAR(13)
                          + ' ON PD.StorerKey = S.StorerKey ' + CHAR(13)
                          + ' AND PD.SKU = S.SKU ' + CHAR(13)

      SET @cSQLWhereClause = @cSQLWhereClause
                           + ' WHERE PD.PickSlipNo = @cPickSlipNo ' + CHAR(13)
                           + ' AND PD.CartonNo = @nCartonNo ' + CHAR(13)

      SET @cSQLOrderByClause = @cSQLOrderByClause 
                             + ' ORDER BY MAX(PD.EditDate) DESC ' + CHAR(13)

      SET @cSQLParams = @cSQLParams
                      + ' , @cPickSlipNo NVARCHAR(10) '
                      + ' , @nCartonNo INT ' 

      IF @cDynamicColumn3 = 'CUSTOM'
      BEGIN
         SET @cSQLSelectClause = @cSQLSelectClause + JSON_VALUE(@cDynamicColumn5, '$.select')
         SET @cSQLFromClause = @cSQLFromClause + JSON_VALUE(@cDynamicColumn5, '$.from')
         SET @cSQLWhereClause = @cSQLWhereClause + JSON_VALUE(@cDynamicColumn5, '$.where')
         SET @cSQLGroupByClause = @cSQLGroupByClause + JSON_VALUE(@cDynamicColumn5, '$.groupBy')
      END

      SET @cSQLQuery = @cSQLSelectClause 
                     + @cSQLFromClause 
                     + @cSQLWhereClause 
                     + @cSQLGroupByClause
                     + @cSQLOrderByClause
                     + @cSQLPageClause
                     + @cSQLQueryEnd

      -- PRINT @cSQLQuery
      
      --Store JSON result into variable
      EXEC sp_executesql  @cSQLQuery
                        , @cSQLParams
                        , @oDynamicJson OUTPUT
                        , @cPickSlipNo
                        , @nCartonNo
   END

   SET @cPackDetailList = @oDynamicJson

   IF @cPackDetailList = '' AND @nPageIndex = 0
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 10951      
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No PackDetail Found.'
      GOTO EXIT_SP
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
      SELECT @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END



