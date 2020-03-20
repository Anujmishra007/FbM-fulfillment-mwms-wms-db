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
/******************************************************************************/       
    
CREATE PROC [dbo].[isp_Packing_List_63]               
       (@c_Orderkey NVARCHAR(20))                
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
       FROM ORDERS ORD WITH (NOLOCK)
       JOIN ORDERDETAIL ORDET WITH (NOLOCK) ON ORD.OrderKey=ORDET.OrderKey  
       JOIN SKU S WITH (NOLOCK) ON S.StorerKey = ORDET.StorerKey AND S.SKU = ORDET.SKU  
       JOIN PICKDETAIL PIDET WITH (NOLOCK) ON ORDET.Orderkey    = PIDET.Orderkey      
                                           AND PIDET.OrderLineNumber = ORDET.OrderLineNumber ' 

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
                                          , ORD.OrderKey '

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
    FROM #PACKLIST63
    ORDER BY Orderkey

 QUIT_SP:                
END  
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON [dbo].[isp_Packing_List_63] TO nSQL 
GO