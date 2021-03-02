IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_Packing_List_63]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_Packing_List_63]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
   
/******************************************************************************/                
/* Store Procedure: isp_Packing_List_63                                       */                
/* Creation Date: 04-APR-2019                                                 */                
/* Copyright: LFL                                                             */                
/* Written by: WLCHOOI                                                        */                
/*                                                                            */                
/* Purpose: WMS-8569 - CN_Trinity_Exceed_Packlist                             */    
/*                                                                            */                
/*                                                                            */                
/* Called By:  r_dw_packing_list_62                                           */                
/*                                                                            */                
/* PVCS Version: 1.0                                                          */                
/*                                                                            */                
/* Version: 1.0                                                               */                
/*                                                                            */                
/* Data Modifications:                                                        */                
/*                                                                            */                
/* Updates:                                                                   */                
/* Date         Author    Ver.  Purposes                                      */    
/*30/05/2019    WLChooi   1.0   Fixed Qty issue (WL01)                        */  
/*29/01/2021    WLChooi   1.1   WMS-16227 - Add Remark (WL02)                 */
/******************************************************************************/       
    
CREATE PROC [dbo].[isp_Packing_List_63]               
       (@c_Orderkey NVARCHAR(20), @c_Type NVARCHAR(1) = '' )   --WL02                
AS              
BEGIN              
   SET NOCOUNT ON              
   SET ANSI_WARNINGS OFF              
   SET QUOTED_IDENTIFIER OFF              
   SET CONCAT_NULL_YIELDS_NULL OFF      
    
   DECLARE @n_continue            INT = 1
         , @b_debug               INT = 0 
         , @c_IsOrderKey          INT = 0
         , @c_IsLoadKey           INT = 0
         , @c_ExecStatements      NVARCHAR(4000) = ''
         , @c_ExecStatements1     NVARCHAR(4000) = ''
         , @c_ExecStatements2     NVARCHAR(4000) = ''
         , @c_ExecStatementsMain  NVARCHAR(4000) = ''
         , @c_ExecArguments       NVARCHAR(4000) = ''
         , @c_GetOrderkey         NVARCHAR(20) = ''
         --WL02 S
         , @n_MaxRec              INT
         , @n_CurrentRec          INT
         , @n_MaxLineno           INT
         , @c_Storerkey           NVARCHAR(15)
         , @c_CLDescr             NVARCHAR(4000)
         --WL02 E
    
   CREATE TABLE #PACKLIST63 
         ( Company          NVARCHAR(90) NULL  
         , Contact1         NVARCHAR(50) NULL   
         , [Address]        NVARCHAR(255) NULL   
         , Phone1           NVARCHAR(50) NULL  
         , UserDefine02     NVARCHAR(60) NULL  
         , ExternOrderKey   NVARCHAR(50) NULL  
         , SKU              NVARCHAR(200) NULL 
         , Color            NVARCHAR(40) NULL   
         , Size             NVARCHAR(60) NULL 
         , Descr            NVARCHAR(60) NULL   
         , Qty              INT  NULL  
         , Orderkey         NVARCHAR(20) NULL 
         , EditWho          NVARCHAR(80) NULL  
         , ShowRemark       NVARCHAR(10) NULL   --WL02
         , IsDummy          NVARCHAR(10) NULL   --WL02
         )
   
    IF( @n_continue = 1 OR @n_continue = 2 )  
    BEGIN
      IF EXISTS(SELECT 1 FROM ORDERS (NOLOCK) WHERE Orderkey = @c_Orderkey AND Loadkey <> @c_Orderkey) --Orderkey
      BEGIN
         SET @c_IsOrderKey = 1
      END
      
      IF EXISTS (SELECT TOP 1 1 FROM ORDERS (NOLOCK) WHERE Loadkey = @c_Orderkey AND Orderkey <> @c_Orderkey) --Loadkey
      BEGIN
         SET @c_IsLoadKey = 1
      END

      IF EXISTS (SELECT TOP 1 1 FROM PACKHEADER (NOLOCK) WHERE Pickslipno = @c_Orderkey) --Pickslipno
      BEGIN
         SELECT @c_GetOrderkey = PH.Orderkey
         FROM PACKHEADER PH (NOLOCK) 
         WHERE PH.PICKSLIPNO = @c_Orderkey

         SET @c_Orderkey = @c_GetOrderkey
         SET @c_IsOrderKey = 1
      END
    END      
         
    IF( @n_continue = 1 OR @n_continue = 2 )       
    BEGIN
      SET @c_ExecStatements = N'INSERT INTO #PACKLIST63   
             ( Company        
             , Contact1       
             , [Address]      
             , Phone1         
             , UserDefine02   
             , ExternOrderKey 
             , SKU            
             , Color          
             , Size           
             , Descr          
             , Qty            
             , Orderkey       
             , EditWho   
             , ShowRemark   --WL02  
             , IsDummy      --WL02 
             )
                  
        SELECT DISTINCT ISNULL(ORD.C_Company,'''')
                       , ISNULL(ORD.C_Contact1,'''')
                       , LTRIM(RTRIM(ISNULL(ORD.C_city,''''))) + SPACE(1) + LTRIM(RTRIM(ISNULL(ORD.C_state,''''))) + SPACE(1) + 
                         LTRIM(RTRIM(ISNULL(ORD.C_address1,''''))) + SPACE(1) + LTRIM(RTRIM(ISNULL(ORD.C_address2,''''))) + SPACE(1) + LTRIM(RTRIM(ISNULL(ORD.C_address3,'''')))
                       , ISNULL(ORD.C_Phone1,'''')
                       , ISNULL(ORD.UserDefine02,'''')
                       , ORD.ExternOrderKey
                       , S.SKU
                       , ISNULL(S.Color,'''')
                       , ISNULL(S.Size,'''')
                       , RTRIM(LTRIM(ISNULL(S.DESCR,'''')))
                       , SUM(PIDET.Qty)       --WL01
                       , ORD.OrderKey
                       , MAX(PIDET.EditWho)
                       , ISNULL(CL.Short,''N'') AS ShowRemark,''N''   --WL02
       FROM ORDERS ORD WITH (NOLOCK)
       JOIN ORDERDETAIL ORDET WITH (NOLOCK) ON ORD.OrderKey=ORDET.OrderKey  
       JOIN SKU S WITH (NOLOCK) ON S.StorerKey = ORDET.StorerKey AND S.SKU = ORDET.SKU  
       JOIN PICKDETAIL PIDET WITH (NOLOCK) ON ORDET.Orderkey    = PIDET.Orderkey      
                                           AND PIDET.OrderLineNumber = ORDET.OrderLineNumber 
       LEFT JOIN CODELKUP CL WITH (NOLOCK) ON CL.LISTNAME = ''REPORTCFG'' AND CL.Code = ''ShowRemark'' AND CL.Long = ''r_dw_packing_list_63'' AND CL.Storerkey = ORD.Storerkey'    --WL02

       IF(@c_IsOrderKey = 1 AND @c_IsLoadKey = 0)
       BEGIN
         SET @c_ExecStatements1 = N'WHERE ORD.ORDERKEY = @c_Orderkey AND ORD.DOCTYPE = ''E'' '
       END
       ELSE IF (@c_IsOrderKey = 0 AND @c_IsLoadKey = 1)
       BEGIN
         SET @c_ExecStatements1 = N'WHERE ORD.LOADKEY = @c_Orderkey AND ORD.DOCTYPE = ''E'' '
       END
       ELSE
         GOTO QUIT_SP
       
       SET @c_ExecStatements2 = N'GROUP BY  ISNULL(ORD.C_Company,'''')
                                          , ISNULL(ORD.C_Contact1,'''')
                                          , ISNULL(ORD.C_city,'''')
                                          , ISNULL(ORD.C_State,'''')
                                          , ISNULL(ORD.C_Address1,'''')
                                          , ISNULL(ORD.C_Address2,'''')
                                          , ISNULL(ORD.C_Address3,'''')
                                          , ISNULL(ORD.C_Phone1,'''')
                                          , ISNULL(ORD.UserDefine02,'''')
                                          , ORD.ExternOrderKey
                                          , S.Sku
                                          , ISNULL(S.Color,'''')
                                          , ISNULL(S.Size,'''')
                                          , ISNULL(S.DESCR,'''')
                                          , ORD.OrderKey 
                                          , ISNULL(CL.Short,''N'') '   --WL02

    END

    IF( @n_continue = 1 OR @n_continue = 2 )       
    BEGIN
      SET @c_ExecStatementsMain = @c_ExecStatements + CHAR(13) +  @c_ExecStatements1  + CHAR(13) +   @c_ExecStatements2

      SET @c_ExecArguments = N'@c_Orderkey NVARCHAR(20)'
      
      IF(@b_debug = 1)
      BEGIN
         PRINT @c_ExecStatementsMain
      END

      EXEC sp_ExecuteSql @c_ExecStatementsMain, @c_ExecArguments, @c_Orderkey
    END
    
   --WL02 S
   IF EXISTS (SELECT 1 FROM #PACKLIST63 WHERE ShowRemark = 'Y')
   BEGIN
   	SELECT @c_Storerkey = OH.Storerkey
   	FROM ORDERS OH (NOLOCK)
   	JOIN #PACKLIST63 T ON T.Orderkey = OH.OrderKey
   	
      SELECT @n_MaxLineno = CASE WHEN ISNUMERIC(CL.Short) = 1 THEN CAST(CL.Short AS INT) ELSE 10 END
      FROM CODELKUP CL (NOLOCK)
      WHERE CL.LISTNAME = 'REPORTCFG' AND CL.Code = 'MaxLineNo'
      AND CL.Long = 'r_dw_packing_list_63' AND CL.Code2 = 'r_dw_packing_list_63'
      AND CL.Storerkey = @c_Storerkey
      
      IF ISNULL(@n_MaxLineno,0) = 0
      BEGIN
         SET @n_MaxLineno = 10
      END
      
      SELECT @c_CLDescr = ISNULL(CL.[Description],'')
      FROM CODELKUP CL (NOLOCK)
      WHERE CL.LISTNAME = 'PACKPrint'
      AND CL.Storerkey = @c_Storerkey
    
      SELECT @n_MaxRec = COUNT(1) FROM #PACKLIST63
      
      SET @n_CurrentRec = @n_MaxRec % @n_MaxLineno
      
      WHILE(@n_MaxRec % @n_MaxLineno <> 0 AND @n_CurrentRec < @n_MaxLineno)
      BEGIN
         INSERT INTO #PACKLIST63
         SELECT TOP 1 
                   Company        
                 , Contact1       
                 , [Address]      
                 , Phone1         
                 , UserDefine02   
                 , ExternOrderKey 
                 , NULL            
                 , NULL          
                 , NULL           
                 , NULL          
                 , NULL            
                 , Orderkey       
                 , EditWho
                 , ShowRemark
                 , 'Y'
         FROM #PACKLIST63
      
         SET @n_CurrentRec = @n_CurrentRec + 1
      END
   END
    
   IF @c_Type = 'F'
   BEGIN
      SELECT TOP 1 Orderkey, ShowRemark, @c_CLDescr
      FROM #PACKLIST63

      GOTO QUIT_SP
   END
   --WL01 E

    SELECT  Company        
          , Contact1       
          , [Address]      
          , Phone1         
          , UserDefine02   
          , ExternOrderKey 
          , SKU            
          , Color          
          , Size           
          , Descr          
          , Qty            
          , Orderkey       
          , EditWho
          , ShowRemark   --WL02
          , IsDummy      --WL02
    FROM #PACKLIST63

 QUIT_SP:                
END  
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON [dbo].[isp_Packing_List_63] TO nSQL 
GO