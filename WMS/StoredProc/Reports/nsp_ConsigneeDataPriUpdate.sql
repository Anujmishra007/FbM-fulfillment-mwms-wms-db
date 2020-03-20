IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[nsp_ConsigneeDataPriUpdate]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [nsp_ConsigneeDataPriUpdate]
GO
/*********************************************************************************/          
/* Stored Procedure: nsp_ConsigneeDataPriUpdate                                  */          
/* Creation Date: 03-Apr-2011                                                    */          
/* Copyright: IDS                                                                */          
/* Written by: Shong                                                             */          
/*                                                                               */          
/* Purpose:  H & M Data Privacy Update                                           */          
/*                                                                               */          
/* Called By:  Backend Job                                                       */          
/*                                                                               */          
/* PVCS Version: 1.0                                                             */          
/*                                                                               */          
/* Version: 5.4                                                                  */          
/*                                                                               */          
/* Data Modifications:                                                           */          
/*                                                                               */          
/* Updates:                                                                      */          
/* Date           Author      Ver.  Purposes                                     */  
/* 13-Apr-18      TLTING      1.1   WMS-4514 - more table and column             */
/*********************************************************************************/    

CREATE PROC [dbo].[nsp_ConsigneeDataPriUpdate] (  
   @c_StorerKey NVARCHAR(20),    
   @c_WMS_DBName1 NVARCHAR(50) = '',   
   @c_WMS_DBName2 NVARCHAR(50) = '',   
   @c_WMS_DBName3 NVARCHAR(50) = '',         
   @c_WMS_DBName4 NVARCHAR(50) = '',   
   @c_WMS_DBName5 NVARCHAR(50) = '',
   @n_threadhold int = 12,
   @c_Consignee  NVARCHAR(20) = '',
   @c_OnlyEComFlag  NVARCHAR(10) = ''
)  
AS  
BEGIN  
  SET NOCOUNT ON  
   DECLARE  @cSQL1     NVARCHAR(4000)
          ,@cSQL2     NVARCHAR(4000)
          ,@c_SQLParm NVARCHAR(4000) = ''
          ,@cSQL      NVARCHAR(MAX)
          ,@dt_CutOffdate      datetime  
          ,@c_Flag   nvarchar(10)
		   ,@n_Debug   INT
         ,@n_row   INT

   SET @c_Flag = ''
   SET @cSQL1 = ''
   SET @cSQL2 = ''
   SET @cSQL = ''
   SET @n_Debug = 0
   
   IF @c_Consignee IS NULL OR @c_Consignee  = ''
   BEGIN
      SET @c_Flag = 'ALL'
   END
    
   
   IF @c_StorerKey IS NULL OR @c_StorerKey = ''
   BEGIN
      Select  'No Storer Orders Update!!'   
      Return
   END 
   
   IF @c_WMS_DBName1 IS NULL OR @c_WMS_DBName1 = ''
   BEGIN
      Select 'No DB Update!!'   
      Return
   END
   
   IF @n_threadhold is NULL OR @n_threadhold < 0
   BEGIN
      SET @n_threadhold = 12
   END 
   
   
   Set @n_threadhold = 0 - @n_threadhold         
   Set @dt_CutOffdate = DateAdd ( month, @n_threadhold, getdate() )
   
   IF @n_Debug = '1'
   BEGIN
      PRINT Convert(char(10), @dt_CutOffdate, 112) 
   END

   DECLARE @c_DBName NVARCHAR(50) = ''

   CREATE TABLE #DBTable
   ( DBName  nvarchar(50)  )

   CREATE TABLE #HMOld_Orders
   ( rowref INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
      Orderkey  nvarchar(10),
      TrackingNo NVARCHAR(30)
        )

   IF ISNULL(RTRIM(@c_WMS_DBName1 ), '') <> '' AND EXISTS (  SELECT 1 FROM sys.databases WHERE name = @c_WMS_DBName1   )
   BEGIN
   INSERT INTO #DBTable ( DBName )
   VALUES ( @c_WMS_DBName1 )
   END 
IF ISNULL(RTRIM(@c_WMS_DBName2 ), '') <> '' AND EXISTS (  SELECT 1 FROM sys.databases WHERE name = @c_WMS_DBName2   )
   BEGIN
   INSERT INTO #DBTable ( DBName )
   VALUES ( @c_WMS_DBName2 )
   END 

   IF ISNULL(RTRIM(@c_WMS_DBName3 ), '') <> '' AND EXISTS (  SELECT 1 FROM sys.databases WHERE name = @c_WMS_DBName3   )
   BEGIN
   INSERT INTO #DBTable ( DBName )
   VALUES ( @c_WMS_DBName3 )
   END 

   IF ISNULL(RTRIM(@c_WMS_DBName4 ), '') <> '' AND EXISTS (  SELECT 1 FROM sys.databases WHERE name = @c_WMS_DBName4   )
   BEGIN
   INSERT INTO #DBTable ( DBName )
   VALUES ( @c_WMS_DBName4 )
   END 

   IF ISNULL(RTRIM(@c_WMS_DBName5 ), '') <> '' AND EXISTS (  SELECT 1 FROM sys.databases WHERE name = @c_WMS_DBName5   )
   BEGIN
   PRINT 'DB5- ' +@c_WMS_DBName5
   INSERT INTO #DBTable ( DBName )
   VALUES ( @c_WMS_DBName5 )
   END 
    

   DECLARE DBName_Itemcur CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
	SELECT DBName FROM #DBTable

	OPEN DBName_Itemcur   
	FETCH NEXT FROM DBName_Itemcur INTO @c_DBName  
	WHILE @@FETCH_STATUS = 0   
	BEGIN   
	 
    
      SET @cSQL = ''
      SET @c_SQLParm = ''

      SET @cSQL = N' USE ['+ @c_DBName + '] '  + CHAR(13)     

      SET @cSQL =  @cSQL + 
            ' Select O.Orderkey , ' + CHAR(13) +
            ' TrackingNo = CASE WHEN ISNULL(RTRIM(TrackingNo),'''' ) <> '''' THEN  TrackingNo ELSE UserDefine04 END ' + Char(13) +
				' From Orders O (nolock)  ' + Char(13) +
	 			' where O.Storerkey = @c_StorerKey  ' + Char(13) +
	 			' AND ( ( LEN(O.C_Company ) > 0 and O.C_Company <> ''*'' ) ' + Char(13) +
	 			' OR ( LEN(O.C_Contact1 ) > 0 and O.C_Contact1 <> ''*'' ) ' + Char(13) +
	 			' OR ( LEN(O.C_Contact2 ) > 0 and O.C_Contact2 <> ''*'' )  ' + Char(13) +
	 			' OR ( LEN(O.UserDefine04 ) > 0 and O.UserDefine04 <> ''*'' ) )' + Char(13)    --tlting 1.1
	 			   
   IF @c_Flag = 'ALL' 
   BEGIN
      SET @cSQL =  @cSQL + Char(13) +
   	 			' AND O.Editdate < Convert(char(8), @dt_CutOffdate, 112) '  + Char(13)    	 			
   END
   ELSE
   BEGIN
      SET @cSQL = @cSQL+ Char(13) +
             	' AND O.ConsigneeKey = ISNULL(RTRIM(@c_Consignee), '''' )   ' 
   END
 
   IF @c_OnlyEComFlag = 'E'
   BEGIN
      SET @cSQL = @cSQL+ Char(13) +
             	' AND O.DocType = ''E'' '
   END
 

   SET @c_SQLParm =  N'@c_StorerKey  NVARCHAR(15), @dt_CutOffdate DATETIME , @c_Consignee NVARCHAR(15) '  

   IF @n_Debug = 1
   BEGIN 
      PRINT 'Date Cutoff - ' + CONVERT(char(8), @dt_CutOffdate, 112)
      PRINT ' Order filter - ' + CHAR(13) + @cSQL
   END

   TRUNCATE TABLE #HMOld_Orders

   INSERT INTO #HMOld_Orders ( Orderkey , TrackingNo )       
   EXEC sp_ExecuteSQL @cSQL, @c_SQLParm,  @c_StorerKey, @dt_CutOffdate, @c_Consignee   

   SET @cSQL1 = ''
 
   IF EXISTS ( SELECT 1 FROM #HMOld_Orders )
   BEGIN

   IF @n_Debug = 1
   BEGIN
      SELECT @n_row = COUNT(1) FROM #HMOld_Orders
      PRINT ' Process #HMOld_Orders - ' + CAST (@n_row AS NVARCHAR(10))
   END
   SET @cSQL1 = N' USE ['+ @c_DBName + '] '   + CHAR(13) 

   SET @cSQL1 =  @cSQL1 +
            ' SET NOCOUNT ON ' + Char(13) +
            ' Declare @c_Orderkey nvarchar(10) ' + Char(13) +
            ' Declare @c_TrackingNo  nvarchar(30)  ' + Char(13) +
			   ' Declare @c_PickSlipNo  Nvarchar(10), @n_CartonNo INT, @c_LabelNo nvarchar(20), @c_LabelLine nvarchar(5)  '+ Char(13) +
			   ' Declare @c_NewLabelNo nvarchar(20), @n_Cnt INT '+ Char(13) +
			   ' ' + Char(13) +
            ' DECLARE Orders_Itemcur CURSOR LOCAL FAST_FORWARD READ_ONLY FOR ' + Char(13) +
		      ' Select O.Orderkey , O.TrackingNo ' + Char(13) +
				' From #HMOld_Orders O (nolock)  '  + Char(13)  + 
            ' OPEN Orders_Itemcur  ' + Char(13) +
	 			' FETCH NEXT FROM Orders_Itemcur INTO @c_Orderkey, @c_TrackingNo  ' + Char(13) +
	 			' WHILE @@FETCH_STATUS = 0  ' + Char(13) +
	 			' BEGIN  ' + Char(13) +
            ' ' + Char(13) +
            ' Delete from dbo.CartonTrack  WHERE LabelNo = @c_Orderkey AND TrackingNo = @c_TrackingNo AND @c_trackingNo <> '''' ' + Char(13) +
            ' ' + Char(13) 

   SET @cSQL1 = @cSQL1 + Char(13) + 
			' SET @c_PickSlipNo = '''' '	+ Char(13) +
			' SET @n_CartonNo = '''' '		+ Char(13) +
			' SET @c_LabelNo = '''' '		+ Char(13) +  
			' SET @c_NewLabelNo = '''' '	+ Char(13) +
			' SET @c_LabelLine = '''' '		+ Char(13) +
			' SET @n_Cnt = 0 '  + Char(13) + Char(13) +
            ' DECLARE Packdet_Itemcur CURSOR LOCAL FAST_FORWARD READ_ONLY FOR ' + Char(13) +
		      ' Select packdetail.PickSlipNo, packdetail.CartonNo, packdetail.LabelNo, packdetail.LabelLine ' + Char(13) + 
				' FROM dbo.packheader (NOLOCK)  ' + Char(13) +
            ' JOIN dbo.packdetail (NOLOCK) ON packdetail.PickSlipNo = PackHeader.PickSlipNo ' + Char(13) +
            ' WHERE packheader.orderkey = @c_Orderkey ' + Char(13) +
			' GROUP BY packdetail.PickSlipNo, packdetail.CartonNo, packdetail.LabelNo, packdetail.LabelLine ' + Char(13) +
			' ORDER BY packdetail.PickSlipNo, packdetail.CartonNo, packdetail.LabelNo, packdetail.LabelLine ' + Char(13) +
			 
	 			' OPEN Packdet_Itemcur  ' + Char(13) +
	 			' FETCH NEXT FROM Packdet_Itemcur INTO @c_PickSlipNo, @n_CartonNo, @c_LabelNo, @c_LabelLine ' + Char(13) +
	 			' WHILE @@FETCH_STATUS = 0  ' + Char(13) +
	 			' BEGIN  ' + Char(13) +
					' SET @n_Cnt = @n_Cnt + 1 '+ Char(13) +
					' SET @c_NewLabelNo = ''*'' + CAST(@n_Cnt as Nvarchar(5) ) '+ Char(13) +
					' UPDATE PackDetail ' + Char(13) +
					' SET LabelNo = @c_NewLabelNo, ArchiveCop = ArchiveCop  ' + Char(13) +
					' FROM packdetail ' + Char(13) +
					' WHERE PickSlipNo = @c_PickSlipNo' + char(13) +
					' AND CartonNo = @n_CartonNo AND LabelNo = @c_LabelNo AND LabelLine = @c_LabelLine ' + Char(13) +
	 			' FETCH NEXT FROM Packdet_Itemcur INTO @c_PickSlipNo, @n_CartonNo, @c_LabelNo, @c_LabelLine ' + Char(13) +
	 			' END ' + Char(13) +
	 			' CLOSE Packdet_Itemcur  ' + Char(13) +
	 			' DEALLOCATE Packdet_Itemcur ' + Char(13) 



   SET @cSQL1 = @cSQL1 + Char(13) + '' + Char(13) +      
            ' UPDATE dbo.packheader ' + Char(13) +
            ' SET ConsigneeKey = ''*'', ArchiveCop = packheader.ArchiveCop  ' + Char(13) +
            ' FROM packheader    ' + Char(13) +
            ' JOIN packdetail (NOLOCK) ON packdetail.PickSlipNo = dbo.PackHeader.PickSlipNo ' + Char(13) +
            ' WHERE packheader.orderkey = @c_Orderkey ' + Char(13) +
            ' ' +	char(13) +				
	 			'  Update Orders with (RowLock)  ' + Char(13) +
	 			'  Set ExternOrderKey = ''*'' ' +
            ' ,ConsigneeKey   = ''*''	 ' + Char(13) +
             ' ,BuyerPO   = ''*''	 ' + Char(13) +
            ' ,B_Address1   = ''*''	 ' + Char(13) +
            ' ,B_Address2   = ''*''	 ' + Char(13) +
            ' ,UserDefine04   = ''*''	 ' + Char(13) +
            ' ,M_Company   = ''*''	 ' + Char(13) +
            ' ,M_City   = ''*''	 ' + Char(13) +
            ' ,TrackingNo   = ''*''	 ' + Char(13) +
            ' ,C_Company   = ''*''	 ' + Char(13) +
	 			'  , C_Contact1      = ''*'' ' + Char(13)    +      
	 			'  , C_Contact2      = ''*'' ' + Char(13)  +        
	 			'  , C_Phone1        = ''*'' ' + Char(13) +         
	 			'  , Notes2          = ''*'' ' + Char(13) +      
	 			'  , C_Address1      = ''*'' ' + Char(13) +         
	 			'  , C_Address2      = ''*'' ' + Char(13)  +        
	 			'  , C_Address3      = ''*'' ' + Char(13) +         
	 			'  , C_Address4      = ''*'' ' + Char(13) +          
	 			'  , C_State         = ''*'' ' + Char(13) +          
	 			'  , C_City          = ''*'' ' + Char(13) +          
	 			'  , ArchiveCop = ArchiveCop  ' + Char(13) +
	 			'  Where orderkey = @c_Orderkey   ' + Char(13) +
        --    ' Select orderkey, trackingno, ConsigneeKey, ExternOrderKey, C_contact1 from Orders (NOLOCK) where orderkey = @c_Orderkey  ' + Char(13) +

	 			' FETCH NEXT FROM Orders_Itemcur INTO @c_Orderkey , @c_trackingNo ' + Char(13) +
	 			' END ' + Char(13) +
	 			' CLOSE Orders_Itemcur  ' + Char(13) +
	 			' DEALLOCATE Orders_Itemcur '

      IF @n_Debug = 1
      BEGIn
         PRINT @cSQL1
      END
    
      EXEC (@cSQL1) 
      END
	 	FETCH NEXT FROM DBName_Itemcur INTO @c_DBName   
	END  
	CLOSE DBName_Itemcur   
	DEALLOCATE DBName_Itemcur 
   
   	 			 
            
END  

GO
Grant execute on nsp_ConsigneeDataPriUpdate to NSQL
GO
