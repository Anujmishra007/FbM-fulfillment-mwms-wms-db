IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_BT_Bartender_Shipper_Label_SEP]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_BT_Bartender_Shipper_Label_SEP]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/******************************************************************************/               
/* Copyright: IDS                                                             */               
/* Purpose: BarTender Filter by ShipperKey                                    */               
/*                                                                            */               
/* Modifications log:                                                         */               
/*                                                                            */               
/* Date       Rev  Author     Purposes                                        */               
/* 2020-05-14 1.0  CSCHONG    Created(WMS-13020)                              */               
/******************************************************************************/              
                
CREATE PROC [dbo].[isp_BT_Bartender_Shipper_Label_SEP]                     
(  @c_Sparm1            NVARCHAR(250),            
   @c_Sparm2            NVARCHAR(250),            
   @c_Sparm3            NVARCHAR(250),            
   @c_Sparm4            NVARCHAR(250),            
   @c_Sparm5            NVARCHAR(250),            
   @c_Sparm6            NVARCHAR(250),            
   @c_Sparm7            NVARCHAR(250),            
   @c_Sparm8            NVARCHAR(250),            
   @c_Sparm9            NVARCHAR(250),            
   @c_Sparm10           NVARCHAR(250),      
   @b_debug             INT = 0                       
)                    
AS                    
BEGIN                    
   SET NOCOUNT ON               
   SET ANSI_NULLS OFF              
   SET QUOTED_IDENTIFIER OFF               
   SET CONCAT_NULL_YIELDS_NULL OFF                               
                            
   DECLARE                
      @c_OrderKey        NVARCHAR(10),                  
      @c_ExternOrderKey  NVARCHAR(10),            
      @c_Deliverydate    DATETIME,            
      @c_ConsigneeKey    NVARCHAR(15),            
      @c_Company         NVARCHAR(45),            
      @C_Address1        NVARCHAR(45),            
      @C_Address2        NVARCHAR(45),            
      @C_Address3        NVARCHAR(45),            
      @C_Address4        NVARCHAR(45), 
      @C_contact1        NVARCHAR(45),
      @C_Contact2        NVARCHAR(45),
      @C_City            NVARCHAR(45),
      @C_State           NVARCHAR(45),
      @c_Zip           NVARCHAR(18), 
      @C_Phone1          NVARCHAR(45),
      @C_Phone2          NVARCHAR(45),
      @C_Country         NVARCHAR(45),
      @c_c_Company       NVARCHAR(45),            
      @C_c_Address1      NVARCHAR(45),            
      @C_c_Address2      NVARCHAR(45),            
      @C_c_Address3      NVARCHAR(45),            
      @C_c_Address4      NVARCHAR(45), 
      @c_C_Contact1      NVARCHAR(45),
      @c_C_Contact2      NVARCHAR(45),
      @C_BuyerPO         NVARCHAR(20), 
      @c_C_City          NVARCHAR(45),
      @c_C_State         NVARCHAR(45),
      @c_C_Zip           NVARCHAR(18),  
      @c_C_Country       NVARCHAR(45),
      @c_C_Phone1        NVARCHAR(45),
      @c_C_Phone2        NVARCHAR(45),            
      @C_notes2          NVARCHAR(4000),            
      @c_OrderLineNo     NVARCHAR(5),            
      @c_SKU             NVARCHAR(20), 
      @c_PLOC            NVARCHAR(20),           
      @n_Qty             INT,            
      @c_PackKey         NVARCHAR(10),            
      @c_UOM             NVARCHAR(10),            
      @C_PHeaderKey      NVARCHAR(18),            
      @C_SODestination   NVARCHAR(30),          
      @n_RowNo           INT,          
      @n_SumPickDETQTY   INT,          
      @n_SumUnitPrice    INT,        
      @c_SQL             NVARCHAR(4000),      
      @c_SQLSORT         NVARCHAR(4000),      
      @c_SQLJOIN         NVARCHAR(4000),    
      @c_Udef04          NVARCHAR(80),              
      @c_TrackingNo      NVARCHAR(20),               
      @n_RowRef          INT,                       
      @c_CLong           NVARCHAR(250),             
      @c_ORDAdd          NVARCHAR(150),             
      @n_TTLPickQTY      INT,  
      @c_ShipperKey      NVARCHAR(15),
      @n_SumODORIQTY     INT,
      @c_Col45           NVARCHAR(80),
      @c_col46           NVARCHAR(80),
      @c_ExecArguments   NVARCHAR(4000),
      @b_success         INT          = 0,                                             
      @n_ErrNo           INT          = 0,                                             
      @c_ErrMsg          NVARCHAR(255)= '' ,
      @n_StartTCnt       INT,
      @n_Err             INT = 0 ,
      @n_Continue        INT                     
      
    -- SET RowNo = 0           
    SET @c_SQL = ''      
    SET @n_SumPickDETQTY = 0          
    SET @n_SumUnitPrice = 0          
            
    CREATE TABLE [#Result] (           
      [ID]    [INT] IDENTITY(1,1) NOT NULL,                          
      [Col01] [NVARCHAR] (80) NULL,            
      [Col02] [NVARCHAR] (80) NULL,            
      [Col03] [NVARCHAR] (80) NULL,            
      [Col04] [NVARCHAR] (80) NULL,            
      [Col05] [NVARCHAR] (80) NULL,            
      [Col06] [NVARCHAR] (80) NULL,            
      [Col07] [NVARCHAR] (80) NULL,            
      [Col08] [NVARCHAR] (80) NULL,            
      [Col09] [NVARCHAR] (80) NULL,            
      [Col10] [NVARCHAR] (80) NULL,            
      [Col11] [NVARCHAR] (80) NULL,            
      [Col12] [NVARCHAR] (80) NULL,            
      [Col13] [NVARCHAR] (80) NULL,            
      [Col14] [NVARCHAR] (80) NULL,            
      [Col15] [NVARCHAR] (80) NULL,            
      [Col16] [NVARCHAR] (80) NULL,            
      [Col17] [NVARCHAR] (80) NULL,            
      [Col18] [NVARCHAR] (80) NULL,            
      [Col19] [NVARCHAR] (80) NULL,            
      [Col20] [NVARCHAR] (80) NULL,            
      [Col21] [NVARCHAR] (80) NULL,            
      [Col22] [NVARCHAR] (80) NULL,            
      [Col23] [NVARCHAR] (80) NULL,            
      [Col24] [NVARCHAR] (80) NULL,            
      [Col25] [NVARCHAR] (80) NULL,            
      [Col26] [NVARCHAR] (80) NULL,            
      [Col27] [NVARCHAR] (80) NULL,            
      [Col28] [NVARCHAR] (80) NULL,            
      [Col29] [NVARCHAR] (80) NULL,            
      [Col30] [NVARCHAR] (80) NULL,            
      [Col31] [NVARCHAR] (80) NULL,            
      [Col32] [NVARCHAR] (80) NULL,            
      [Col33] [NVARCHAR] (80) NULL,            
      [Col34] [NVARCHAR] (80) NULL,            
      [Col35] [NVARCHAR] (80) NULL,            
      [Col36] [NVARCHAR] (80) NULL,            
      [Col37] [NVARCHAR] (80) NULL,            
      [Col38] [NVARCHAR] (80) NULL,            
      [Col39] [NVARCHAR] (80) NULL,            
      [Col40] [NVARCHAR] (80) NULL,            
      [Col41] [NVARCHAR] (80) NULL,            
      [Col42] [NVARCHAR] (80) NULL,            
      [Col43] [NVARCHAR] (80) NULL,            
      [Col44] [NVARCHAR] (80) NULL,            
      [Col45] [NVARCHAR] (80) NULL,            
      [Col46] [NVARCHAR] (80) NULL,            
      [Col47] [NVARCHAR] (80) NULL,            
      [Col48] [NVARCHAR] (80) NULL,            
      [Col49] [NVARCHAR] (80) NULL,            
      [Col50] [NVARCHAR] (80) NULL,           
      [Col51] [NVARCHAR] (80) NULL,            
      [Col52] [NVARCHAR] (80) NULL,            
      [Col53] [NVARCHAR] (80) NULL,            
      [Col54] [NVARCHAR] (80) NULL,            
      [Col55] [NVARCHAR] (80) NULL,            
      [Col56] [NVARCHAR] (80) NULL,            
      [Col57] [NVARCHAR] (80) NULL,            
      [Col58] [NVARCHAR] (80) NULL,            
      [Col59] [NVARCHAR] (80) NULL,            
      [Col60] [NVARCHAR] (80) NULL           
     )          
    
    CREATE TABLE [#PICK] (           
      [ID]          [INT] IDENTITY(1,1) NOT NULL,                          
      [OrderKey]    [NVARCHAR] (80) NULL,            
      [TTLPICKQTY]  [INT] NULL)    

   SET @n_StartTCnt = @@TRANCOUNT  
  
   EXEC isp_Open_Key_Cert_Orders_PI  
      @n_Err    = @n_Err    OUTPUT,  
      @c_ErrMsg = @c_ErrMsg OUTPUT  
  
   IF ISNULL(@c_ErrMsg,'') <> ''  
   BEGIN  
      SET @n_Continue = 3  
      GOTO EXIT_SP  
   END            
      
IF ISNULL(@c_Sparm4,'0') > '0'      
 BEGIN        
  IF @c_Sparm4='1'          
  BEGIN        
  SET @c_SQLJOIN = +' SELECT ORD.loadkey,ORD.orderkey,ORD.externorderkey,ORD.type,buyerpo,salesman,ORD.facility,STO.Secondary,'    --8      
             + CHAR(13) +         
             +'STO.Company,STO.SUSR1,STO.SUSR2,(STO.Address1+STO.Address2+STO.Address3),ORD.Notes,ORD.Notes2,ORD.Storerkey,STO.State,'  --8      
             + CHAR(13) +        
             +'STO.City,STO.Zip,STO.Contact1,STO.Phone1,STO.phone2,ORD.Consigneekey,'''','''','+ CHAR(13) +        
             +''''','''','''','''','''','''','''','''','        
             +''''',ORD.M_Company,ORD.Userdefine01,ORD.Userdefine02,ORD.Userdefine03,ORD.Userdefine04,ORD.Userdefine05,ORD.PmtTerm,'          
             + CHAR(13) +        
             +'ORD.InvoiceAmount,'''','''','         
             +'ORD.ShipperKey,'''','''','''','''',ORD.DeliveryPlace,'''', '  --50       
             +' '''','''','''','''','''','''','''','''',LOC.Logicallocation,LOC.LOC '             
             + CHAR(13) +          
             + ' FROM ORDERS ORD WITH (NOLOCK) INNER JOIN ORDERDETAIL ORDDET WITH (NOLOCK)  ON ORD.ORDERKEY = ORDDET.ORDERKEY   '     
             + ' INNER JOIN STORER STO WITH (NOLOCK) ON STO.STORERKEY = ORD.STORERKEY '      
             + ' INNER JOIN PICKDETAIL PD WITH (NOLOCK) ON PD.OrderKey = ORD.OrderKey and PD.OrderLineNumber = ORDDET.OrderLineNumber'      
             + ' INNER JOIN LOC LOC WITH (NOLOCK) ON LOC.LOC = PD.LOC '         
             + ' WHERE ORD.LoadKey = @c_Sparm1 '      
             + ' AND ORD.OrderKey = CASE WHEN ISNULL(RTRIM( @c_Sparm2),'''') <> '''' THEN  @c_Sparm2 ELSE ORD.OrderKey END'          
             + ' AND ORD.ShipperKey = CASE WHEN ISNULL(RTRIM(@c_Sparm3),'''') <> '''' THEN @c_Sparm3 ELSE ORD.ShipperKey END'          
          --   + ' AND PD.QTY = ''1'' '      
         
  END         
  ELSE        
  BEGIN         
  SET @c_SQLJOIN = +' SELECT ORD.loadkey,ORD.orderkey,ORD.externorderkey,ORD.type,buyerpo,salesman,ORD.facility,STO.Secondary,'    --8      
             + CHAR(13) +         
             +'STO.Company,STO.SUSR1,STO.SUSR2,(STO.Address1+STO.Address2+STO.Address3),ORD.Notes,ORD.Notes2,ORD.Storerkey,STO.State,'  --8      
             + CHAR(13) +        
             +'STO.City,STO.Zip,STO.Contact1,STO.Phone1,STO.phone2,ORD.Consigneekey,'''','''','+ CHAR(13) +        
             +''''','''','''','''','''','''','''','''','        
             +''''',ORD.M_Company,ORD.Userdefine01,ORD.Userdefine02,ORD.Userdefine03,ORD.Userdefine04,ORD.Userdefine05,ORD.PmtTerm,'          
             + CHAR(13) +       
             +'ORD.InvoiceAmount,'''','''','         
             +'ORD.ShipperKey,'''','''','''','''',ORD.DeliveryPlace,'''', '  --50        
             +' '''','''','''','''','''','''','''','''','''','''' '         
             + CHAR(13) +          
             + ' FROM ORDERS ORD WITH (NOLOCK) '    
             + ' INNER JOIN STORER STO WITH (NOLOCK) ON STO.STORERKEY = ORD.STORERKEY '     
             + ' WHERE ORD.LoadKey = @c_Sparm1 '      
             + ' AND ORD.OrderKey = CASE WHEN ISNULL(RTRIM(@c_Sparm2),'''') <> '''' THEN  @c_Sparm2 ELSE ORD.OrderKey END'          
             + ' AND ORD.ShipperKey = CASE WHEN ISNULL(RTRIM( @c_Sparm3),'''') <> '''' THEN  @c_Sparm3 ELSE ORD.ShipperKey END'          
  END       
 END      
 ELSE      
   BEGIN      
   SET @c_SQLJOIN = +' SELECT ORD.loadkey,ORD.orderkey,ORD.externorderkey,ORD.type,buyerpo,salesman,ORD.facility,STO.Secondary,'    --8      
             + CHAR(13) +         
             +'STO.Company,STO.SUSR1,STO.SUSR2,(STO.Address1+STO.Address2+STO.Address3),ORD.Notes,ORD.Notes2,ORD.Storerkey,STO.State,'  --8      
             + CHAR(13) +        
             +'STO.City,STO.Zip,STO.Contact1,STO.Phone1,STO.phone2,ORD.Consigneekey,'''','''','+ CHAR(13) +        
             +''''','''','''','''','''','''','''','''','        
             +''''',ORD.M_Company,ORD.Userdefine01,ORD.Userdefine02,ORD.Userdefine03,ORD.Userdefine04,ORD.Userdefine05,ORD.PmtTerm,'          
             + CHAR(13) +        
             +'ORD.InvoiceAmount,'''','''','         
             +'ORD.ShipperKey,'''','''','''','''',ORD.DeliveryPlace,'''', '  --50        
             +' '''','''','''','''','''','''','''','''','''','''' '         
             + CHAR(13) +          
             + ' FROM ORDERS ORD (NOLOCK) INNER JOIN STORER STO (NOLOCK) ON STO.STORERKEY = ORD.STORERKEY '      
             + ' WHERE ORD.LoadKey =  @c_Sparm1 '      
              + ' AND ORD.OrderKey = CASE WHEN ISNULL(RTRIM( @c_Sparm2),'''') <> '''' THEN @c_Sparm2 ELSE ORD.OrderKey END'          
             + ' AND ORD.ShipperKey = CASE WHEN ISNULL(RTRIM(@c_Sparm3),'''') <> '''' THEN @c_Sparm3 ELSE ORD.ShipperKey END'          
   END      
--END        
IF @b_debug=1      
BEGIN      
PRINT @c_SQLJOIN        
END              
            
  SET @c_SQL='INSERT INTO #Result (Col01,Col02,Col03,Col04,Col05, Col06,Col07,Col08,Col09'  + CHAR(13) +         
             +',Col10,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20,Col21,Col22'  + CHAR(13) +         
             +',Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30,Col31,Col32,Col33,Col34' + CHAR(13) +         
             +',Col35,Col36,Col37,Col38,Col39,Col40,Col41,Col42,Col43,Col44'  + CHAR(13) +         
             +',Col45,Col46,Col47,Col48,Col49,Col50,Col51,Col52,Col53,Col54'+ CHAR(13) +         
             + ',Col55,Col56,Col57,Col58,Col59,Col60) '        
  
SET @c_SQL = @c_SQL + @c_SQLJOIN      
      
--EXEC sp_executesql @c_SQL   

 SET @c_ExecArguments = N'   @c_Sparm1           NVARCHAR(80)'    
                          + ', @c_Sparm2           NVARCHAR(80) '    
                          + ', @c_Sparm3           NVARCHAR(80)'   
                     
   EXEC sp_ExecuteSql     @c_SQL     
                        , @c_ExecArguments    
                        , @c_Sparm1    
                        , @c_Sparm2   
                        , @c_Sparm3     
      
   IF @b_debug=1      
   BEGIN        
     PRINT @c_SQL        
   END      
   IF @b_debug=1      
   BEGIN      
     SELECT * FROM #Result (nolock)      
   END      
          
DECLARE CUR_RowNoLoop CURSOR LOCAL FAST_FORWARD READ_ONLY FOR            
        
SELECT DISTINCT col02,col38 from #Result        
  
OPEN CUR_RowNoLoop          
  
FETCH NEXT FROM CUR_RowNoLoop INTO @c_OrderKey,@c_Udef04       
    
WHILE @@FETCH_STATUS <> -1          
BEGIN         
   IF @b_debug='1'      
   BEGIN      
      PRINT '@c_OrderKey: ' + @c_OrderKey         
   END      
   --  SELECT @n_SumPICKDETQty = SUM(QTY)          
   --  FROM PICKDETAIL PD (NOLOCK)          
   --   WHERE PD.OrderKey=@c_OrderKey    

     SET  @c_Company   = ''          
     SET  @C_Address1  = ''           
     SET  @C_Address2  = ''            
     SET  @C_Address3  = ''          
     SET  @C_Address4  = '' 
     SET  @C_contact1  = ''
     SET  @C_Contact2  = ''
     SET  @C_City      = ''
     SET  @C_State     = ''
     SET  @C_Zip       = ''
     SET  @C_Phone1    = ''
     SET  @C_Phone2    = ''
     SET  @C_Country   = ''
     SET  @c_Col45     = ''
     SET  @c_Col46     = '' 
     SET  @n_SumODORIQTY = 0
     SET  @c_Sku         = ''
     SET  @c_PLOC        = ''

     --EXEC [dbo].[isp_Create_Order_PI_Encrypted]  
     --             @c_OrderKey   =@c_OrderKey,
     --             @c_C_Contact1 =@c_C_Contact1,
     --             @c_C_Contact2 =@c_C_Contact2,
     --             @c_C_Company  =@C_Company,
     --             @c_C_Address1 =@C_C_Address1,
     --             @c_C_Address2 =@C_C_Address2,
     --             @c_C_Address3 =@C_C_Address3,
     --             @c_C_Address4 =@C_C_Address4,
     --             @c_C_City     =@C_C_City,
     --             @c_C_State    =@C_C_State,
     --             @c_C_Zip      =@C_C_Zip,
     --             @c_C_Country  =@C_C_Country,
     --             @c_C_Phone1   =@C_C_Phone1,
     --             @c_C_Phone2   =@C_C_Phone2,
     --             @b_success  = @b_success OUTPUT, 
     --             @n_ErrNo    = @n_ErrNo OUTPUT,
     --             @c_ErrMsg   = @c_ErrMsg OUTPUT   

     SELECT  @c_Company   = C_Company          
            ,@C_Address1  = C_Address1          
            ,@C_Address2  = C_Address2            
            ,@C_Address3  = C_Address3          
            ,@C_Address4  = C_Address4 
            ,@C_contact1  = C_Contact1
            ,@C_Contact2  = C_Contact2
            ,@C_City      = C_City
            ,@C_State     = C_State
            ,@c_zip       = C_Zip
            ,@C_Phone1    = C_Phone1
            ,@C_Phone2    = C_Phone2 
          --  ,@C_Country   = C_Country  
    FROM fnc_GetDecryptedOrderPI (@c_orderkey)  
    --WHERE Orderkey = @c_OrderKey
  
   SELECT @n_SumPICKDETQty = SUM(QTY),          
          @n_SumUnitPrice = SUM(QTY * ORDDET.Unitprice),
          @n_SumODORIQTY  = SUM(ORDDET.OriginalQty),
          @c_sku          = MAX(ORDDET.sku) ,
          @c_PLOC         = MAX(PD.loc)   
   FROM PICKDETAIL PD (NOLOCK) JOIN ORDERDETAIL ORDDET (NOLOCK)          
   ON PD.OrderKey = ORDDET.OrderKey and PD.OrderLineNumber = ORDDET.OrderLineNumber          
   WHERE PD.OrderKey=@c_OrderKey       

   IF  @n_SumODORIQTY = 1
   BEGIN 
       SET  @c_Col45     = @c_sku
       SET  @c_Col46     = @c_PLOC
   END

   IF ISNULL(@c_Udef04,'') = ''    
   BEGIN    
      SET @c_TrackingNo = ''    
      SET @n_RowRef = 0    

      SELECT TOP 1 @c_TrackingNo = CT.TrackingNO,    
                   @n_RowRef     = CT.RowRef    
      FROM ORDERS ORD WITH (NOLOCK)   
      JOIN CARTONTRACK CT WITH (NOLOCK) ON ORD.ShipperKey = CT.CarrierName    
      JOIN STORER STO WITH (NOLOCK) ON STO.Secondary = CT.Keyname and STO.Storerkey=ORD.Storerkey    
      WHERE ORD.OrderKey = @c_OrderKey    
      AND Isnull(CT.CarrierRef2,'')=''    
      ORDER BY CT.RowRef     
        
       IF @b_debug = '1'    
       BEGIN    
         PRINT 'Tracking no : ' + @c_TrackingNo + ' For Orderkey : ' + @c_OrderKey    
         PRINT ' RowRef No : ' + convert(varchar(10),@n_RowRef)      
       END    
  
      UPDATE ORDERS WITH (ROWLOCK)    
      SET Userdefine04 = @c_TrackingNo, TrafficCop = NULL      
      WHERE ORDERKEY = @c_OrderKey    
  
      UPDATE CARTONTRACK WITH (ROWLOCK)    
      SET LabelNo = @c_OrderKey, CarrierRef2 = 'GET'     
      WHERE RowRef = @n_RowRef    
  
      UPDATE #Result          
      SET Col38 = @c_TrackingNo                  
      WHERE Col02=@c_OrderKey     
   END    
             
   UPDATE #Result          
   SET Col23 = @c_Company,
       Col24 = @C_Address1,
       Col25 = @C_Address2,
       Col26 = @C_Address3,
       Col27 = @C_Address4,
       Col28 = @C_State,
       Col29 = @C_City,
       Col30 = @C_Zip,  
       Col31 = @C_Contact1,
       Col32 = @C_Phone1,
       Col33 = @C_Phone2, 
       Col42 = @n_SumPICKDETQty, 
       COL43 = @n_SumUnitPrice,
       Col45 = @c_col45,
       Col46 = @c_col46
   WHERE Col02=@c_OrderKey       
  

   FETCH NEXT FROM CUR_RowNoLoop INTO @c_OrderKey,@c_Udef04       
  
END -- While           
CLOSE CUR_RowNoLoop          
DEALLOCATE CUR_RowNoLoop        
    
SET @c_ORDAdd = ''    
DECLARE CUR_UpdateRec CURSOR LOCAL FAST_FORWARD READ_ONLY FOR            
SELECT DISTINCT col02   
FROM #Result        
  
OPEN CUR_UpdateRec          
  
FETCH NEXT FROM CUR_UpdateRec INTO @c_OrderKey       
    
WHILE @@FETCH_STATUS <> -1          
BEGIN     
   SET @c_ShipperKey = ''  
   SET @c_ORDAdd = ''  
        
   --SELECT @c_ORDAdd = RTRIM(ORD.C_State) + ' ' + RTRIM(ORD.C_City) + ' ' + RTRIM(ORD.C_Address1)      
   --FROM ORDERS ORD WITH (NOLOCK)    
   --WHERE ORD.Orderkey =   @c_OrderKey   
SELECT @c_ORDAdd =RTRIM(C_State) + ' ' + RTRIM(C_City) + ' ' + RTRIM(C_Address1)   
FROM fnc_GetDecryptedOrderPI (@c_orderkey)    
  
   IF @b_debug = '1'    
   BEGIN     
      PRINT ' ORD address combine : ' + @c_ORDAdd + ' with orderkey : ' + @c_OrderKey    
   END  
    
   SET @c_CLong = ''  
   SELECT TOP 1  
      @c_CLong = C.Long    
   FROM Codelkup C WITH (NOLOCK)   
   LEFT OUTER JOIN ORDERS ORD WITH (NOLOCK) ON ORD.ShipperKey = C.Short    
   WHERE ORD.Orderkey =  @c_OrderKey    
   AND C.Listname='COURIERMAP'   
   AND C.UDF01='ELABEL'      
   AND C.Notes like N'%' + @c_ORDAdd + '%'      
  
   IF @b_debug = '1'    
   BEGIN     
      PRINT ' codelkup long : ' + @c_CLong + ' with orderkey : ' + @c_OrderKey    
   END    
    
   UPDATE #Result WITH (ROWLOCK)      
      SET Col50= @c_CLong      
   WHERE Col02=@c_OrderKey      
    
   FETCH NEXT FROM CUR_UpdateRec INTO @c_OrderKey       
  
END -- While        
    --      
CLOSE CUR_UpdateRec          
DEALLOCATE CUR_UpdateRec      
    
   
INSERT INTO #PICK (OrderKey,TTLPICKQTY)    
SELECT DISTINCT col02,convert(INT,col42)    
FROM #RESULT WITH (NOLOCK)    
       
     
IF @b_Debug = '1'  
BEGIN  
    PRINT '#PICK'
    PRINT '@c_Sparm4a : ' + @c_Sparm4
    SELECT '#PICK', *  
    FROM   #PICK WITH (NOLOCK)  
END    
-- IF ISNULL(@c_Sparm4 ,0) = 0 
--BEGIN
--SET @c_Sparm4 = 0
    
--END 

IF ISNULL(@c_Sparm4 ,0) <> 0 
BEGIN  
    IF @c_Sparm4 = '1'  
    BEGIN  
       
        SELECT R.*   
        FROM   #Result R WITH (NOLOCK)  
               INNER JOIN #PICK P WITH (NOLOCK)  
                    ON  P.Orderkey = R.Col02  
        WHERE  ISNULL(Col38 ,'') <> '' 
        AND    P.TTLPICKQTY = 1  
        ORDER BY col59,col60,col02    
    END  
    ELSE    
    IF @c_Sparm4 > '1'  
    BEGIN  

        SELECT R.*   
        FROM   #Result R WITH (NOLOCK)  
        INNER JOIN #PICK P WITH (NOLOCK) ON  P.Orderkey = R.Col02  
        WHERE  ISNULL(Col38 ,'') <> '' 
        AND    P.TTLPICKQTY > 1  
        ORDER BY col02  
    END  
END  
ELSE  
BEGIN  

    SELECT *  
    FROM   #Result WITH (NOLOCK)  
    WHERE  ISNULL(Col38 ,'') <> '' 
    ORDER BY Col02  
END                 

EXIT_SP:             
                                  
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_BT_Bartender_Shipper_Label_SEP] TO nSQL 
GO
