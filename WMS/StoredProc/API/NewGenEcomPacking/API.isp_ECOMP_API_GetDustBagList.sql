/************************************************************************/              
/* Store procedure: [API].[isp_ECOMP_API_GetDustBagList]                */              
/* Creation Date: 12-JAN-2026                                           */
/* Copyright: Maersk                                                  	*/
/* Written by: Cheong                                              		*/
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By: SCEAPI                                                    */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date           Author   Purposes										*/
/* 12-JAN-2026    Cheong   FCR-9149 - get required dustbag list         */
/************************************************************************/

CREATE OR ALTER PROC [API].[isp_ECOMP_API_GetDustBagList](
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
   SET ANSI_DEFAULTS OFF 
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @n_Continue                    INT            = 1
         , @n_StartCnt                    INT            = @@TRANCOUNT

         , @c_ComputerName                NVARCHAR(30)   = ''

         , @c_OrderKey                    NVARCHAR(10)   = ''
         , @c_StorerKey                   NVARCHAR(15)   = ''
         , @c_SKU                         NVARCHAR(20)   = ''
		 , @c_DustBagCount				  INT			 = 0
		 , @c_isDustBagRequired			  BIT			 = 0
		 , @c_Action					  INT			 = 0

         , @b_sp_Success                  INT
         , @n_sp_err                      INT
         , @c_sp_errmsg                   NVARCHAR(250)= ''
	  
	  DROP TABLE IF EXISTS #t_Summary
	  CREATE TABLE #t_Summary(
			Activity             NVARCHAR(100) NULL
		  , Qty                  INT            NULL
	   )

   SET @b_Success                         = 0
   SET @n_ErrNo                           = 0
   SET @c_ErrMsg                          = ''
   SET @c_ResponseString                  = ''

   --Change Login User
   --SET @n_sp_err = 0     
   --EXEC [WM].[lsp_SetUser] @c_UserName = @c_UserID OUTPUT, @n_Err = @n_sp_err OUTPUT, @c_ErrMsg = @c_sp_errmsg OUTPUT    
       
   --EXECUTE AS LOGIN = @c_UserID    
       
   --IF @n_sp_err <> 0     
   --BEGIN      
   --   SET @n_Continue = 3      
   --   SET @n_ErrNo = @n_sp_err      
   --   SET @c_ErrMsg = @c_sp_errmsg     
   --   GOTO QUIT      
   --END  


   SELECT @c_Action			= ISNULL(RTRIM(ActionCode   ), '')
		 ,@c_Orderkey       = ISNULL(RTRIM(OrderKey     ), '')
         ,@c_Storerkey      = ISNULL(RTRIM(Storerkey    ), '')
   FROM OPENJSON (@c_RequestString)
   WITH ( 
	  ActionCode      INT		         '$.Action',
      OrderKey        NVARCHAR(10)       '$.OrderKey',
      Storerkey       NVARCHAR(10)       '$.Storer'
   )     

   IF @c_OrderKey = ''
   BEGIN
      SET @n_Continue = 3 
      SET @n_ErrNo = 51201
      SET @c_ErrMsg = 'No orderkey found.'
      GOTO QUIT
   END
   ELSE IF @c_Storerkey = ''
   BEGIN
      SET @n_Continue = 3 
      SET @n_ErrNo = 51201
      SET @c_ErrMsg = 'No storerKey found.'
      GOTO QUIT
   END
   
   IF @b_Debug = 1
	  BEGIN
		 PRINT '@c_Orderkey = ' + @c_Orderkey
		 PRINT '@c_Storerkey = ' + @c_Storerkey
	  END

	IF @c_Action = 1
	BEGIN
		--check whether any sku in the order require dust bag
		SELECT @c_DustBagCount = COUNT(*)  
			FROM SKUCONFIG(NOLOCK) SC  
			LEFT JOIN Orderdetail(NOLOCK) od ON sc.SKU=od.SKU and od.StorerKey=sc.StorerKey  
			LEFT JOIN Orders(NOLOCK) o ON o.OrderKey=od.OrderKey  
			LEFT JOIN Sku(NOLOCK) s ON s.SKU=sc.SKU and s.StorerKey=sc.StorerKey  
			WHERE sc.ConfigType='EPACKSUMMARY'  
				AND s.HazardousFlag='FCD'  
				AND s.StorerKey=@c_Storerkey  
				AND o.DocType='E'  
				AND od.OrderKey= @c_Orderkey  

		--if count > 0, select the detail of the SKU/Dust Bag/Activity into temp table
		IF @c_DustBagCount > 0
		BEGIN
		INSERT INTO #t_Summary(Activity,Qty)
			SELECT sc.userdefine01 as Activity,sum(pd.qty) as QTY 
				FROM SKUConfig(NOLOCK) sc   
				LEFT JOIN SKU(NOLOCK) s ON sc.SKU=s.SKU and sc.StorerKey=sc.StorerKey  
				LEFT JOIN PackDetail(NOLOCK) pd on pd.SKU=sc.SKU and pd.StorerKey=sc.StorerKey  
				LEFT JOIN PackHeader(NOLOCK) ph on ph.PickSlipNo=pd.PickSlipNo   
				LEFT JOIN Orders(NOLOCK) o on o.OrderKey=ph.OrderKey  
				WHERE ph.OrderKey = @c_Orderkey  
					AND sc.ConfigType='EPACKSUMMARY'  
					AND s.HazardousFlag='FCD'  
					AND o.DocType='E'  
					AND s.StorerKey= @c_Storerkey
					GROUP BY sc.userdefine01
	
			IF (SELECT COUNT(*) FROM #t_Summary) > 0
			BEGIN
				SET @c_isDustBagRequired = 1
			END
		END
	END
	ELSE IF @c_Action = 2
	BEGIN
		UPDATE ORDERINFO SET ORDERINFO10 = 9  WHERE OrderKey = @c_OrderKey
	END

   SET @c_ResponseString = ISNULL(( 
                              SELECT TOP 1
                                     @c_isDustBagRequired As 'isDustBagRequired'                                   
                                    ,ISNULL(( 
                                       SELECT Activity AS 'Activity' 
									   , Qty AS 'Qty'
									   FROM #t_Summary
                                       FOR JSON PATH 
                                     ),'[]') As 'DustBagList'
                              FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                           ), '')

   QUIT:
   IF @n_Continue= 3  -- Error Occured - Process And Return      
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
END -- Procedure  
