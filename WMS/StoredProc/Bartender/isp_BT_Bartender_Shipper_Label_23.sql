IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_BT_Bartender_Shipper_Label_23]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[isp_BT_Bartender_Shipper_Label_23]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO 

/******************************************************************************/         
/* Copyright: LFL                                                             */         
/* Purpose: BarTender Filter by ShipperKey                                    */         
/*                                                                            */         
/* Modifications log:                                                         */         
/*                                                                            */         
/* Date       Rev  Author     Purposes                                        */         
/* 2021-09-01 1.0  WLChooi    Created (WMS-17815)                             */
/******************************************************************************/        
          
CREATE PROC [dbo].[isp_BT_Bartender_Shipper_Label_23]               
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
                      
   DECLARE @n_RowNo             INT,  
           @n_SumPickDetQty     INT,  
           @n_SumUnitPrice      INT,  
           @c_SQL               NVARCHAR(4000),  
           @c_SQLSORT           NVARCHAR(4000),
           @c_SQLJOIN           NVARCHAR(4000), 
           @n_RowRef            INT,    
           @c_condition         NVARCHAR(150),         
           @c_condition1        NVARCHAR(150),
           @c_condition2        NVARCHAR(150),
           @c_StorerKey         NVARCHAR(15),
           @c_ExecStatements    NVARCHAR(4000),     
           @c_ExecArguments     NVARCHAR(4000),
           @c_UDF01             NVARCHAR(80),
           @c_OrderKey          NVARCHAR(10),
           @c_Shipperkey        NVARCHAR(80),
           @c_Pickslipno        NVARCHAR(10), 
           @c_CartonNo          NVARCHAR(10)

   DECLARE @n_Qty              INT,
           @n_Cube             FLOAT,
           @n_TotalPrice       FLOAT,
           @n_TotalWgt         FLOAT

   DECLARE @c_SKU01            NVARCHAR(80)      
         , @c_Qty01            NVARCHAR(80)  
         , @c_SKU02            NVARCHAR(80)     
         , @c_Qty02            NVARCHAR(80)  
         , @c_SKU03            NVARCHAR(80)    
         , @c_Qty03            NVARCHAR(80)  
         , @c_SKU04            NVARCHAR(80)     
         , @c_Qty04            NVARCHAR(80)  
         , @c_SKU05            NVARCHAR(80)    
         , @c_Qty05            NVARCHAR(80)  
         , @c_SKU06            NVARCHAR(80)     
         , @c_Qty06            NVARCHAR(80) 
         , @c_SKU07            NVARCHAR(80)    
         , @c_Qty07            NVARCHAR(80) 
         , @c_SKU08            NVARCHAR(80)     
         , @c_Qty08            NVARCHAR(80) 
         , @c_SKU09            NVARCHAR(80)    
         , @c_Qty09            NVARCHAR(80) 
         , @c_SKU              NVARCHAR(80)  
         , @c_Qty              NVARCHAR(80)   
         , @c_LabelNo          NVARCHAR(20)  
         , @n_intFlag          INT = 1   
         , @n_CntRec           INT = 1
         , @n_TTLpage          INT = 1        
         , @n_CurrentPage      INT = 1 
         , @n_MaxLine          INT = 9
         , @c_Col51            NVARCHAR(80)

    -- SET RowNo = 0     
    SET @c_SQL = ''        
    SET @n_SumPickDetQty = 0            
    SET @n_SumUnitPrice = 0  
    
    SET @c_StorerKey = ''          
    SET @c_condition1 =''        
    SET @c_condition2 = '' 
  
    CREATE TABLE [#Result] (     
      [ID]    [INT] IDENTITY(1, 1) NOT NULL,                    
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

   CREATE TABLE #TMP_SKU (
      [SKU]             [NVARCHAR] (20) NULL,  
      [Qty]             [INT] NULL,  
      [TotalPrice]      [FLOAT]  NULL,  
      [TotalWgt]        [FLOAT]  NULL
   )

   CREATE TABLE #Temp_SKUDetail (  
       [ID]             [INT] IDENTITY(1,1) NOT NULL,         
       [Orderkey]     [NVARCHAR] (80) NULL,                          
       [SKU]            [NVARCHAR] (80) NULL,  
       [Qty]            [NVARCHAR] (80) NULL,  
       [Retreive]       [NVARCHAR] (80) NULL  
   )  

   SET @c_condition  = ''
   SET @c_condition1 = '' 
   SET @c_condition2 = ''

   IF ISNULL(@c_Sparm5,'') <> '' AND ISNULL(@c_Sparm6,'') <> ''
   BEGIN
   	SET @c_condition = ' AND PD.CartonNo >= CONVERT(INT,@c_Sparm5) AND PD.CartonNo <= CONVERT(INT,@c_Sparm6 )'
   END    

   IF ISNULL(RTRIM(@c_Sparm2),'') <> ''
   BEGIN
   	SET @c_condition1 = 'AND ORD.OrderKey = RTRIM(@c_Sparm2)'
   END   
   
   IF ISNULL(RTRIM(@c_Sparm3),'') <> ''
   BEGIN
   	SET @c_condition2 = 'AND ORD.ShipperKey = RTRIM(@c_Sparm3)'
   END 

   SET @c_SQLJOIN = ' SELECT DISTINCT ORD.Loadkey, ORD.Orderkey, ORD.ExternOrderKey, ORD.Type, ORD.BuyerPO, ' + CHAR(13)  --5    
                  + ' ORD.Salesman, ORD.Facility, TRIM(ISNULL(ORD.Notes,'''')), '''', ORD.Storerkey, ' + CHAR(13)  --10    
                  + ' ORD.Consigneekey, ORD.C_Company, TRIM(ISNULL(ORD.C_Address1,'''')), TRIM(ISNULL(ORD.C_Address2,'''')), TRIM(ISNULL(ORD.C_Address3,'''')), ' + CHAR(13)  --15
                  + ' TRIM(ISNULL(ORD.C_Address4,'''')), TRIM(ISNULL(ORD.C_State,'''')), TRIM(ISNULL(ORD.C_City,'''')), TRIM(ISNULL(ORD.C_Zip,'''')), TRIM(ISNULL(ORD.C_Contact1,'''')), ' + CHAR(13)  --20
                  + ' TRIM(ISNULL(ORD.C_Phone1,'''')), TRIM(ISNULL(ORD.C_Phone2,'''')), TRIM(ISNULL(ORD.M_Company,'''')), '''', TRIM(ISNULL(ORD.UserDefine02,'''')), ' + CHAR(13)   --25
                  + ' TRIM(ISNULL(ORD.UserDefine04,'''')), TRIM(ISNULL(ORD.UserDefine05,'''')), TRIM(ISNULL(ORD.PmtTerm,'''')), CAST(ORD.InvoiceAmount AS NVARCHAR), '''', ' + CHAR(13)  --30
                  + ' '''', ORD.Shipperkey, TRIM(ISNULL(ORD.DeliveryPlace,'''')), TRIM(ISNULL(ORD.M_Address1,'''')), TRIM(ISNULL(ORD.M_Address2,'''')), ' + CHAR(13)   --35
                  + ' TRIM(ISNULL(ORD.M_City,'''')), '''', TRIM(ISNULL(ORD.Priority,'''')), TRIM(ISNULL(ORD.UserDefine10,'''')), '''', ' + CHAR(13)  --40
                  + ' '''', '''', '''', '''', '''', '''', '''', '''', PD.LabelNo, ORD.UserDefine04, ' + CHAR(13)  --50
                  + ' '''', '''', '''', '''', '''', '''', '''', PH.Pickslipno, PD.CartonNo, ''CN'' ' --60
                  + ' FROM ORDERS ORD WITH (NOLOCK) ' + CHAR(13) 
                  + ' JOIN PACKHEADER PH WITH (NOLOCK) ON PH.Orderkey = ORD.Orderkey ' + CHAR(13) 
                  + ' JOIN PACKDETAIL PD WITH (NOLOCK) ON PD.Pickslipno = PH.Pickslipno ' + CHAR(13) 
                  + ' WHERE ORD.Loadkey = @c_Sparm1 '

   SET @c_SQL = 'INSERT INTO #Result (Col01,Col02,Col03,Col04,Col05, Col06,Col07,Col08,Col09'  + CHAR(13) +   
              + ',Col10,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20,Col21,Col22'  + CHAR(13) +   
              + ',Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30,Col31,Col32,Col33,Col34' + CHAR(13) +   
              + ',Col35,Col36,Col37,Col38,Col39,Col40,Col41,Col42,Col43,Col44'  + CHAR(13) +   
              + ',Col45,Col46,Col47,Col48,Col49,Col50,Col51,Col52,Col53,Col54'+ CHAR(13) +   
              + ',Col55,Col56,Col57,Col58,Col59,Col60) '  

   SET @c_SQL = @c_SQL + @c_SQLJOIN +  CHAR(13) + @c_condition + CHAR(13) + @c_condition1  + CHAR(13) + @c_condition2 

   SET @c_ExecArguments = N' @c_Sparm1           NVARCHAR(80)'   
                        + ', @c_Sparm2           NVARCHAR(80)'    
                        + ', @c_Sparm3           NVARCHAR(80)'
                        + ', @c_Sparm4           NVARCHAR(80)'
                        + ', @c_Sparm5           NVARCHAR(80)' 				
                        + ', @c_Sparm6           NVARCHAR(80)' 									 
					 
   EXEC sp_ExecuteSql @c_SQL     
                    , @c_ExecArguments    
                    , @c_Sparm1
                    , @c_Sparm2  
                    , @c_Sparm3
                    , @c_Sparm4
                    , @c_Sparm5
                    , @c_Sparm6

   IF @b_debug = 1
   BEGIN  
      PRINT @c_SQL  
   END 

   --By Order Update
   DECLARE CUR_UpdateRec CURSOR LOCAL FAST_FORWARD READ_ONLY FOR              
   SELECT DISTINCT Col02   
   FROM #Result          
   
   OPEN CUR_UpdateRec            
   
   FETCH NEXT FROM CUR_UpdateRec INTO @c_OrderKey
    
   WHILE @@FETCH_STATUS <> -1            
   BEGIN      
      SELECT @c_StorerKey  = OH.Storerkey
           , @c_Shipperkey = OH.ShipperKey
      FROM ORDERS OH (NOLOCK)
      WHERE OH.Orderkey = @c_Orderkey 

      SET @c_UDF01 = '' 
      SELECT TOP 1 @c_UDF01 = C.UDF01  
      FROM Codelkup C WITH (NOLOCK)    
      WHERE C.Short = @c_Shipperkey              
      AND C.Storerkey = @c_StorerKey            
      AND C.Listname = 'WSCourier'   

      UPDATE #Result 
      SET   Col09 = @c_UDF01
      WHERE Col02 = @c_OrderKey  

      INSERT INTO #TMP_SKU ( SKU, Qty, TotalPrice, TotalWgt)
      SELECT PD.SKU, SUM(PD.Qty), SUM(PD.Qty) * MAX(OD.UnitPrice), SUM(PD.Qty * ISNULL(S.STDGROSSWGT,0.00))
      FROM PICKDETAIL PD (NOLOCK)
      JOIN ORDERS OH WITH (NOLOCK) ON OH.OrderKey = PD.OrderKey
      JOIN SKU S WITH (NOLOCK) ON S.StorerKey = PD.Storerkey AND S.SKU = PD.SKU
      CROSS APPLY (SELECT TOP 1 UnitPrice FROM ORDERDETAIL (NOLOCK)
                   WHERE OrderKey = PD.OrderKey AND SKU = PD.SKU
                   AND Storerkey = PD.Storerkey) AS OD
      WHERE PD.OrderKey = @c_OrderKey
      GROUP BY PD.SKU

      INSERT INTO #Temp_SKUDetail (Orderkey, SKU, Qty, Retreive)
      SELECT PD.OrderKey
           , TRIM(PD.SKU) 
           , SUM(PD.Qty)
           , 'N'  
      FROM PICKDETAIL PD WITH (NOLOCK)
      WHERE PD.OrderKey = @c_Orderkey     
      GROUP BY PD.OrderKey, TRIM(PD.SKU)
      ORDER BY PD.OrderKey, TRIM(PD.SKU) 
      
      SET @c_SKU01  = ''  
      SET @c_Qty01  = ''  
      SET @c_SKU02  = ''  
      SET @c_Qty02  = ''  
      SET @c_SKU03  = ''  
      SET @c_Qty03  = ''  
      SET @c_SKU04  = ''  
      SET @c_Qty04  = ''  
      SET @c_SKU05  = ''  
      SET @c_Qty05  = ''  
      SET @c_SKU06  = ''  
      SET @c_Qty06  = ''  
      SET @c_SKU07  = ''  
      SET @c_Qty07  = ''  
      SET @c_SKU08  = ''  
      SET @c_Qty08  = ''  
      SET @c_SKU09  = ''  
      SET @c_Qty09  = ''  
      
      IF @b_debug = 1  
         SELECT * FROM #Temp_SKUDetail  
      
      SELECT @n_CntRec = COUNT (1)    
      FROM #Temp_SKUDetail  
      WHERE Orderkey = @c_OrderKey  
      AND Retreive = 'N'  
      
      SET @n_TTLpage =  FLOOR(@n_CntRec / @n_MaxLine ) + CASE WHEN @n_CntRec % @n_MaxLine > 0 THEN 1 ELSE 0 END     
      
      WHILE @n_intFlag <= @n_CntRec               
      BEGIN  
         IF @n_intFlag > @n_MaxLine AND (@n_intFlag % @n_MaxLine) = 1  
         BEGIN   
            SET @n_CurrentPage = @n_CurrentPage + 1  
      
            IF (@n_CurrentPage > @n_TTLpage)     
            BEGIN    
               BREAK;    
            END  
           
            INSERT INTO #Result (Col01,Col02,Col03,Col04,Col05,Col06,Col07,Col08,Col09                     
           ,Col10,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20,Col21,Col22                   
           ,Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30,Col31,Col32,Col33,Col34                    
           ,Col35,Col36,Col37,Col38,Col39,Col40,Col41,Col42,Col43,Col44                     
           ,Col45,Col46,Col47,Col48,Col49,Col50,Col51,Col52,Col53,Col54                   
           ,Col55,Col56,Col57,Col58,Col59,Col60)     
            SELECT TOP 1 Col01,Col02,Col03,Col04,Col05,Col06,Col07,Col08,Col09                     
                        ,Col10,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20,Col21,Col22                   
                        ,Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30,Col31,Col32,Col33,Col34                    
                        ,Col35,Col36,Col37,Col38,Col39,'','','','',''                     
                        ,'','','','',Col49,Col50,Col51,Col52,Col53,Col54                   
                        ,Col55,Col56,Col57,Col58,Col59,Col60  
            FROM #Result WHERE Col60 <> ''  
      
            SET @c_SKU01  = ''  
            SET @c_Qty01  = ''  
            SET @c_SKU02  = ''  
            SET @c_Qty02  = ''  
            SET @c_SKU03  = ''  
            SET @c_Qty03  = ''  
            SET @c_SKU04  = ''  
            SET @c_Qty04  = ''  
            SET @c_SKU05  = ''  
            SET @c_Qty05  = ''  
            SET @c_SKU06  = ''  
            SET @c_Qty06  = ''  
            SET @c_SKU07  = ''  
            SET @c_Qty07  = ''  
            SET @c_SKU08  = ''  
            SET @c_Qty08  = ''  
            SET @c_SKU09  = ''  
            SET @c_Qty09  = ''  
         END  
      
         SELECT  @c_SKU = SKU      
               , @c_Qty = Qty  
         FROM #Temp_SKUDetail   
         WHERE ID = @n_intFlag  
      
         IF (@n_intFlag % @n_MaxLine) = 1
         BEGIN   
            SET @c_SKU01      = @c_SKU              
            SET @c_Qty01      = @c_Qty  
         END     
         ELSE IF (@n_intFlag % @n_MaxLine) = 2  
         BEGIN     
            SET @c_SKU02      = @c_SKU        
            SET @c_Qty02      = @c_Qty        
         END    
         ELSE IF (@n_intFlag % @n_MaxLine) = 3  
         BEGIN     
            SET @c_SKU03      = @c_SKU        
            SET @c_Qty03      = @c_Qty      
         END   
         ELSE IF (@n_intFlag % @n_MaxLine) = 4  
         BEGIN     
            SET @c_SKU04      = @c_SKU        
            SET @c_Qty04      = @c_Qty        
         END   
         ELSE IF (@n_intFlag % @n_MaxLine) = 5 
         BEGIN     
            SET @c_SKU05      = @c_SKU        
            SET @c_Qty05      = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 6  
         BEGIN     
            SET @c_SKU06      = @c_SKU        
            SET @c_Qty06      = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 7  
         BEGIN     
            SET @c_SKU07      = @c_SKU        
            SET @c_Qty07      = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 8  
         BEGIN     
            SET @c_SKU08      = @c_SKU        
            SET @c_Qty08      = @c_Qty        
         END 
         ELSE IF (@n_intFlag % @n_MaxLine) = 0
         BEGIN     
            SET @c_SKU09      = @c_SKU              
            SET @c_Qty09      = @c_Qty      
         END       
         
         UPDATE #Result  
         SET   Col40 = CASE WHEN TRIM(ISNULL(@c_SKU01,'')) <> '' THEN TRIM(@c_SKU01) + '*' + TRIM(@c_Qty01) ELSE '' END 
             , Col41 = CASE WHEN TRIM(ISNULL(@c_SKU02,'')) <> '' THEN TRIM(@c_SKU02) + '*' + TRIM(@c_Qty02) ELSE '' END       
             , Col42 = CASE WHEN TRIM(ISNULL(@c_SKU03,'')) <> '' THEN TRIM(@c_SKU03) + '*' + TRIM(@c_Qty03) ELSE '' END          
             , Col43 = CASE WHEN TRIM(ISNULL(@c_SKU04,'')) <> '' THEN TRIM(@c_SKU04) + '*' + TRIM(@c_Qty04) ELSE '' END          
             , Col44 = CASE WHEN TRIM(ISNULL(@c_SKU05,'')) <> '' THEN TRIM(@c_SKU05) + '*' + TRIM(@c_Qty05) ELSE '' END          
             , Col45 = CASE WHEN TRIM(ISNULL(@c_SKU06,'')) <> '' THEN TRIM(@c_SKU06) + '*' + TRIM(@c_Qty06) ELSE '' END       
             , Col46 = CASE WHEN TRIM(ISNULL(@c_SKU07,'')) <> '' THEN TRIM(@c_SKU07) + '*' + TRIM(@c_Qty07) ELSE '' END        
             , Col47 = CASE WHEN TRIM(ISNULL(@c_SKU08,'')) <> '' THEN TRIM(@c_SKU08) + '*' + TRIM(@c_Qty08) ELSE '' END          
             , Col48 = CASE WHEN TRIM(ISNULL(@c_SKU09,'')) <> '' THEN TRIM(@c_SKU09) + '*' + TRIM(@c_Qty09) ELSE '' END          
         WHERE ID = @n_CurrentPage
      
         UPDATE #Temp_SKUDetail  
         SET Retreive = 'Y'  
         WHERE ID = @n_intFlag  
      
         SET @n_intFlag = @n_intFlag + 1  
        
         IF @n_intFlag > @n_CntRec    
         BEGIN    
            BREAK;    
         END    
      END
         
      SELECT @n_Qty        = SUM(TS.Qty)
           , @n_TotalPrice = SUM(TS.TotalPrice)
           , @n_TotalWgt   = SUM(TS.TotalWgt)
      FROM #TMP_SKU TS
      
      SELECT TOP 1 @c_Pickslipno = R.Col58
      FROM #Result R
      WHERE R.Col02 = @c_OrderKey

      SELECT @n_Cube   = ISNULL(PIF.[Cube],0.00)
      FROM PACKINFO PIF WITH (NOLOCK)
      WHERE PIF.PickSlipNo = @c_Pickslipno
      
      UPDATE #Result 
      SET   Col24 = @n_Cube
          , Col30 = @n_Qty
          , Col31 = @n_TotalPrice
          , Col37 = @n_TotalWgt
      WHERE Col58 = @c_Pickslipno  

      FETCH NEXT FROM CUR_UpdateRec INTO @c_OrderKey     
   END      
   CLOSE CUR_UpdateRec            
   DEALLOCATE CUR_UpdateRec

   SELECT @c_Col51 = COUNT(DISTINCT LabelNo)
   FROM PACKDETAIL (NOLOCK)
   WHERE PickSlipNo = @c_Pickslipno

   UPDATE #Result 
   SET   Col51 = @c_Col51
   WHERE Col58 = @c_Pickslipno  

   SELECT * FROM #Result WITH (NOLOCK)

   EXIT_SP:       
                               
END -- procedure     
GO
GRANT EXECUTE ON [dbo].[isp_BT_Bartender_Shipper_Label_23] TO nSQL
GO
   