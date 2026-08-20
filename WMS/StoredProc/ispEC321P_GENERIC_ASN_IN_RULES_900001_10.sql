SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************************************************************************/    
/* Store Procedure:  ispEC321P_GENERIC_ASN_IN_RULES_900001_10            */    
/* Creation Date: 10-Jul-2026                                           */     
/* Written by: PFI025                                                  */    
/*                                                                      */    
/* Purpose:  Custom inbound rules for Generic ASN 900001, step 10.      */
/*           For each detail line on the ASN, looks up the SKU in      */
/*           WMS.SKU and stamps IML_GENERIC_ASN_DET with TOLoc = 'PL01',*/
/*           clears POKey, and populates Lottable02/06/07 with the     */
/*           SKU's Alt SKU, Class, and Style/Size. Only runs when       */
/*           InParm1 on ITFInConfigDetail (InConfigType = 'ASN_900001', */
/*           InStepNumber = 10) is set to 'Y' for the storer/stream.    */
/*                                                                      */    
/* Input Parameters:  @c_TargetDBName  - Target database name           */    
/*                    @c_StorerKey     - Storerkey                      */    
/*                    @n_FileKey       - Inbound file key                */    
/*                    @c_DataStream    - Data Stream Code               */    
/*                    @n_RecordID      - ASN header RecordID            */    
/*                    @c_RulesType     - Rules type (must be blank to   */
/*                                       run; called from Core-SP       */
/*                                       Trailer)                        */    
/*                    @b_Debug         - 0/1 Debug flag                 */    
/*                                                                      */    
/* Output Parameters: @c_Status        - Status flag                   */
/*                    @c_InvalidFlag   - Invalid flag                  */
/*                    @b_Success       - Success Flag  = 0              */    
/*                    @n_Err           - Error Code    = 0              */    
/*                    @c_ErrMsg        - Error Message = ''             */    
/*                    @c_ReturnValue   - Return value                  */
/*                                                                      */    
/* Usage:  Invoked automatically as a Core-SP sub-rule during inbound   */
/*         Generic ASN 900001 processing; not called directly.          */    
/*                                                                      */    
/* Called By:  Core inbound ASN processing SP for message type 900001   */
/*             (ispEC321P_GENERIC_ASN_IN_RULES / trailer SP)            */    
/*                                                                      */    
/* PVCS Version: 1.0                                                    */    
/*                                                                      */    
/* Version:  1.0                                                        */    
/*                                                                      */    
/* Data Modifications:  Updates IML_GENERIC_ASN_DET (TOLoc, POKey,      */
/*                      Lottable02, Lottable06, Lottable07)             */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date         Author    Purposes                                      */   
/* 05-Aug-2026  PFI025    Fixed stale SKU lookup values carrying over   */
/*                        between detail rows when a SKU has no match   */
/*                        in WMS.SKU; loop now breaks on update failure */
/*                        instead of continuing silently.               */
/* 06-Aug-2026  PFI025    Moved HSCode from Tariffkey to MANUFACTURERSKU */
/************************************************************************/


CREATE OR ALTER PROC [dbo].[ispEC321P_GENERIC_ASN_IN_RULES_900001_10]   
        @c_TargetDBName    VARCHAR(30)  
      , @c_StorerKey       NVARCHAR(15)                          
      , @n_FileKey         INT   
      , @c_DataStream      VARCHAR(10)    
      , @n_RecordID        INT  
      , @c_RulesType       VARCHAR(10)   
      , @b_Debug           INT   
      , @c_Status          CHAR(1)        OUTPUT  
      , @c_InvalidFlag     CHAR(1)        OUTPUT  
      , @b_Success         INT            OUTPUT  
      , @n_err             INT            OUTPUT  
      , @c_ErrMsg          NVARCHAR(250)  OUTPUT                 
      , @c_ReturnValue     CHAR(60)       OUTPUT  
AS   
BEGIN  
   SET NOCOUNT ON     
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET ANSI_DEFAULTS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF   
  
   /********************************************/  
   /* Variables Declaration (Start)            */  
   /********************************************/  
   DECLARE @c_ExecStatements        NVARCHAR(4000)  
         , @c_ExecArguments         NVARCHAR(4000)  
         , @n_Continue              INT  
         , @n_StartTCnt             INT   
         , @c_CustomizeRules        VARCHAR(1)               
  
   DECLARE @c_InPrefix              NVARCHAR(10)                    
         , @c_InSuffix              NVARCHAR(10)                    
         , @c_InParm1               NVARCHAR(60)                    
         , @c_InParm2               NVARCHAR(60)                    
         , @c_InParm3               NVARCHAR(60)                    
         , @c_InParm4               NVARCHAR(60)                    
         , @c_InParm5               NVARCHAR(60)                  
  
         , @c_ExternReceiptKey      NVARCHAR(50)   
         , @n_Det_RecordID          INT    
         , @c_SKU                   NVARCHAR(20)
         , @c_ALTSKU                NVARCHAR(20)
         , @c_SKU_CLASS             NVARCHAR(20)
         , @c_SKU_Style             NVARCHAR(20)
         , @c_SKU_Size              NVARCHAR(20)
         , @c_POKEY                 NVARCHAR(20)
         , @c_CountryoO             NVARCHAR(10)
         , @c_HSCode                NVARCHAR(20)
         , @c_TrackingNr            NVARCHAR(60) 
         , @c_PACKKey               NVARCHAR(10)  
         , @c_PackUOM3              NVARCHAR(10)  
         , @n_SeqNo                 INT  
     
   SET @n_Continue               = 1  
   SET @b_Success                = 1  
   SET @n_StartTCnt              = @@TRANCOUNT   
   SET @c_Status                 = '9'  
   SET @c_ErrMsg                 = ''  
   SET @c_ReturnValue            = ''  
  
   SET @c_ExternReceiptKey       = ''  
   SET @n_Det_RecordID           = 0  
   SET @c_SKU                    = ''
   SET @c_POKEY                  = ''  
   SET @c_PACKKey                = ''  
   SET @c_PackUOM3               = ''  
   SET @n_SeqNo                  = 0  
   SET @c_ALTSKU                 = '' 
   SET @c_SKU_CLASS              = '' 
   SET @c_SKU_Style              = '' 
   SET @c_SKU_Size               = '' 
  
   /********************************************/  
   /* Variables Declaration (End)              */  
   /********************************************/  
  
   /********************************************/  
   /* Main Process (Start)                     */  
   /********************************************/  
  
   -- Quit SP if not calling from Core-SP Trailer ('')  
   IF ISNULL(RTRIM(@c_RulesType), '') <> ''  
      GOTO STEP_999_EXIT_SP  
  
   IF @b_debug = 1  
   BEGIN  
      SELECT '<<SUB-SP-RULES>> - ispEC321P_GENERIC_ASN_IN_RULES_900001_10 Start...'   
   END  
  
   IF @n_continue = 1 OR @n_Continue = 2    
   BEGIN   
  
      SELECT @c_InPrefix   = InPrefix  
           , @c_InSuffix   = InSuffix  
           , @c_InParm1    = InParm1   
           , @c_InParm2    = InParm2   
           , @c_InParm3    = InParm3   
           , @c_InParm4    = InParm4   
           , @c_InParm5    = InParm5  
      FROM  ITFInConfigDetail WITH (NOLOCK)  
      WHERE DataStream     =  @c_Datastream    
      AND   StorerKey      =  @c_StorerKey 
      AND   InConfigType   = 'ASN_900001'    
      AND   InStepNumber   = 10   
  
      IF ISNULL(RTRIM(@c_InParm1),'') <> ''   
      BEGIN   
         SET @c_CustomizeRules = @c_InParm1  
      END   
  
      IF @b_debug = 1  
      BEGIN  
         SELECT '<<SUB-SP-RULES>> - @c_CustomizeRules : ' + ISNULL(RTRIM(@c_CustomizeRules),'')   
      END  
  
      IF @c_CustomizeRules <> 'Y'  
      BEGIN  
         GOTO STEP_999_EXIT_SP  
      END  
  
      IF @b_debug = 1  
      BEGIN  
         SELECT '<<SUB-SP-RULES>> - @c_InParm1 : ' + ISNULL(RTRIM(@c_InParm1),'')   
      END  
  
      SELECT @c_ExternReceiptKey    = ISNULL(RTRIM(ExternReceiptKey),'')
      FROM   IML_GENERIC_ASN_HDR WITH (NOLOCK)  
      WHERE  RecordID = @n_RecordID    
      
      DECLARE C_IML_ASN_DET_IN CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
      SELECT RecordID    
           , ISNULL(RTRIM(SKU),'') 
           , POKey   
      FROM   IML_GENERIC_ASN_DET WITH (NOLOCK)  
      WHERE  DataStream        = @c_DataStream   
      AND    ExternReceiptKey  = @c_ExternReceiptKey  
      ORDER BY SeqNo   
  
      OPEN C_IML_ASN_DET_IN    
      FETCH NEXT FROM C_IML_ASN_DET_IN INTO @n_Det_RecordID         
                                          , @c_SKU           
                                          , @c_POKEY
  
      WHILE @@FETCH_STATUS <> -1    
      BEGIN
         IF @b_debug = 1  
         BEGIN  
            SELECT '<<SUB-SP-RULES>> - @c_SKU : ' + ISNULL(RTRIM(@c_SKU),'')   
         END  

         -- Reset lookup values every iteration so a SKU with no match
         -- in WMS.SKU doesn't inherit stale values from the previous row
         SET @c_ALTSKU    = ''
         SET @c_SKU_CLASS = ''
         SET @c_SKU_Style = ''
         SET @c_SKU_Size  = ''
         SET @c_CountryoO = ''
         SET @c_HSCode    = ''


         BEGIN TRAN  


        SELECT
        @c_ALTSKU    = ALTSKU, 
        @c_SKU_CLASS = CLASS ,
        @c_SKU_Style = STYLE, 
        @c_SKU_Size  = SIZE,
        @c_CountryoO = CountryOfOrigin,
        @c_HSCode = MANUFACTURERSKU    
        FROM WMS.SKU WITH (NOLOCK)
        WHERE SKU = @c_SKU
        AND Storerkey = @c_StorerKey


         UPDATE IML_GENERIC_ASN_DET WITH (ROWLOCK)   
         SET   TOLOC	  = 'R100000153',
               POKey      = '',
               Lottable03 = @c_CountryoO,
               UserDefine09 = @c_HSCode,
               Lottable02 = @c_ALTSKU,
               Lottable06 = @c_SKU_CLASS,  
               Lottable07 = CONCAT(@c_SKU_Style, '/', @c_SKU_Size)

         WHERE  RecordID    = @n_Det_RecordID   
         AND    DataStream  = @c_DataStream   
         AND    Storerkey = @c_StorerKey
           
         IF @@ERROR = 0    
         BEGIN     
            WHILE @@TRANCOUNT > 0    
         COMMIT TRAN    
         END    
         ELSE    
         BEGIN    
            SET @n_continue = 3    
            SET @n_err = 68003    
            SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0))      
                             + ': Update IML_GENERIC_ASN_DET fail. (ispEC321P_GENERIC_ASN_IN_RULES_900001_10)'      
            ROLLBACK    
         END   
                    
         FETCH NEXT FROM C_IML_ASN_DET_IN INTO @n_Det_RecordID  
                                             , @c_SKU
                                             , @c_POKEY

      END  --WHILE @@FETCH_STATUS <> -1                                                                                             
      CLOSE C_IML_ASN_DET_IN                                                                                  
      DEALLOCATE C_IML_ASN_DET_IN  
   END  
  
   STEP_999_EXIT_SP:  
   IF @b_debug = 1  
   BEGIN  
      SELECT '<<SUB-SP-RULES>> - ispEC321P_GENERIC_ASN_IN_RULES_900001_10 EXIT... InvalidFlag : '   
             + ISNULL(RTRIM(@c_InvalidFlag),'') + '. Status : ' + ISNULL(RTRIM(@c_Status),'')   
             + '. ErrMsg : ' + ISNULL(RTRIM(@c_ErrMsg),'')   
   END  
  
   /********************************************/  
   /* Main Process (End)                       */  
   /********************************************/  
END -- End Procedure  
GO
