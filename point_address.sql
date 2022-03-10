/*
* SQL script for pre-processing EsriPointAddress and EsriPointAddressPremiseName feature classes on SQL database.
* It creates new feature classes from the input tables/feature classes according to the requirements for reference data.
*
* Use DPM_GDM_EsriPointAddress procedure for processing EsriPointAddress and EsriPointAddressPremiseName data.
*
* Input parameters: 
*   - Country Code.
*   - Places feature class name.
*   - Street_Names table name.
*   - Addresses table name.
*   - Admin_Relations table name.
*   - Admin_Names table name.
*   - Zone_Names table name.
*   - Postal_Codes table name.
*   - Postal_Realations table name.
*   - Postal_Cities table name.
*
* Output result:
*    EsriPointAddress and EsriPointAddressPremiseName FCs for locators building
*/

SET QUOTED_IDENTIFIER ON 
DBCC TRACEON (1222,-1)

/**************************************************************************
    DPM_GDM_SelectTrnslitNeighborhoods Function
**************************************************************************/
/*    Creates temporary table with mix of zones.
    Inputs:
        @COUNTRY_CODE      - 3-letters country code,
        @LIST_FIELDS       - list fields of PointAddress table,
        @LANGCODE_TMP      - mixing language code
    Output:
        Temporary table with mixing Neighborhood names.
*/

IF EXISTS (SELECT NAME 
       FROM   sysobjects 
       WHERE  NAME = N'DPM_GDM_SelectTrnslitNeighborhoods'
       AND    TYPE = 'P')
    DROP PROCEDURE DPM_GDM_SelectTrnslitNeighborhoods
GO

CREATE PROCEDURE DPM_GDM_SelectTrnslitNeighborhoods 
            @COUNTRY_CODE NVARCHAR(3),
            @TABLE_NAME   NVARCHAR(100),
            @ZONE_NAMES_T NVARCHAR(100),
            @LIST_FIELDS  NVARCHAR(MAX),
            @LANGCODE_TMP NVARCHAR(3)
AS  
    -- Add identification column
    EXEC DPM_GDM_AddCounter @TABLE_NAME
    IF @@Error<>0 GOTO QuitWithText
                       
    -- Select all Zone_Names
    EXEC('SELECT OBJECTID,
                ' + @LIST_FIELDS + ',
                SA.Country_ID, 
                SA.SIDE, 
                SA.PLACE_ZONE_ID,  
                ZN.ZONE_NAME AS NeighborhoodZone_z, 
                ZN.ZONE_ID   AS ZONE_ID_z  
            INTO ' + @COUNTRY_CODE + '_POINTADDRESS_MIX 
            FROM ' + @TABLE_NAME + ' SA WITH(NOLOCK) 
                LEFT JOIN ' + @ZONE_NAMES_T + ' ZN WITH(NOLOCK) ON SA.PLACE_ZONE_ID = ZN.ZONE_ID 
            WHERE Adm_LanguageCode IS NULL AND ZN.LANGUAGE_CODE = ''' + @LANGCODE_TMP + '''')
    IF @@Error<>0 GOTO QuitWithText
    
    PRINT ''
    PRINT 'Procedure DPM_GDM_SelectTrnslitNeighborhoods was well done:'
    PRINT 'Finish time: ' + CONVERT(VARCHAR(100), GETDATE())
    RETURN 0
    
    QuitWithText:
      RAISERROR('SCRIPT was terminated!', 16, 1)
      RETURN 1 

GO

/**************************************************************************
    DPM_GDM_CountryLanguageMix Function
**************************************************************************/
/*    Converts language code which is absent for admin zones to a present language code.
    Inputs:
        @COUNTRY_CODE     - 3-letters country code,
        @LANGUAGE_CODE    - Current language code,
        @PLACES_T         - Places table name,
        @AREA_MAIN_NAMES_T- area_Names table with main names,
        @ZONE_NAMES_T     - Zone_Names table,
        @COUNTRY_ID       - Current country ID.
    Outputs:
        @LANGCODE_LIST    - string with output language codes which may be present within admin zones
*/

IF EXISTS (SELECT NAME 
       FROM   sysobjects 
       WHERE  NAME = N'DPM_GDM_CountryLanguageMix'
       AND    TYPE = 'P')
    DROP PROCEDURE DPM_GDM_CountryLanguageMix
GO

CREATE PROCEDURE DPM_GDM_CountryLanguageMix 
            @COUNTRY_CODE      NVARCHAR(3),
            @LANGUAGE_CODE     NVARCHAR(3),
            @TABLE_NAME        NVARCHAR(100),
            @PLACES_T          NVARCHAR(100),
            @ADMIN_RELATIONS_T NVARCHAR(100),
            @AREA_MAIN_NAMES_T NVARCHAR(100),
            @ZONE_NAMES_T      NVARCHAR(100),
            @COUNTRY_ID        BIGINT                    
AS 
    DECLARE @LANGCODES_LIST    NVARCHAR(50),
            @LANGCODE_TMP      NVARCHAR(3),
            @CURRENT_USER      NVARCHAR(50),
            @STR               NVARCHAR(MAX),
            @COUNT             INT,
            @LIST_FIELDS       NVARCHAR(MAX),
            @LIST_FIELDS_2     NVARCHAR(MAX),
            @EXCLUDE_FIELDS    NVARCHAR(MAX),
            @COUNT_FOR_ADD     BIGINT            
            
    SET     @CURRENT_USER   = RTRIM(CONVERT(CHAR(30), CURRENT_USER))
    
    SET @STR = 'SELECT @COUNT = COUNT(*) FROM ' + @TABLE_NAME + ' WITH(NOLOCK) WHERE Adm_LanguageCode IS NULL'
    EXEC sp_executesql     @STR, N'@COUNT INT OUT', @COUNT = @COUNT OUT
    IF @@Error<>0 GOTO QuitWithText
    
    PRINT 'Count records for MIX: ' + cast(@COUNT as nvarchar(10))
    
    IF @COUNT > 0 
    BEGIN
        
        EXEC DPM_GDM_LanguagesForMix @COUNTRY_CODE, @LANGCODES_LIST = @LANGCODES_LIST OUTPUT
        IF @@Error<>0 GOTO QuitWithText
        
        -- Define MIX language and update admin zones 
        WHILE @LANGCODES_LIST <> ''
        BEGIN
            IF CHARINDEX(',', @LANGCODES_LIST) <> 0
            BEGIN
                SET @LANGCODE_TMP   = LTRIM(RTRIM(SUBSTRING(@LANGCODES_LIST, 1, CHARINDEX(',', @LANGCODES_LIST) - 1)))
                SET @LANGCODES_LIST = SUBSTRING(@LANGCODES_LIST, LEN(@LANGCODE_TMP) + 2, LEN(@LANGCODES_LIST) - LEN(@LANGCODE_TMP) + 2)
            END
            ELSE
            BEGIN
                SET @LANGCODE_TMP   = LTRIM(RTRIM(@LANGCODES_LIST))
                SET @LANGCODES_LIST = ''
            END            
            
            -- Check exists admin zones for current language
            SET @STR = 'SELECT @COUNT = COUNT(*) 
                        FROM     ' + @TABLE_NAME        + ' PA  WITH(NOLOCK)                             
                            JOIN ' + @ADMIN_RELATIONS_T + ' ARL WITH(NOLOCK) ON PA.ADMIN_ID    = ARL.ADMIN_ID 
                            JOIN ' + @AREA_MAIN_NAMES_T + ' CN  WITH(NOLOCK) ON ARL.COUNTRY_ID = CN.ADMIN_NAME_ID
                            WHERE Adm_LanguageCode IS NULL AND CN.LANGUAGE_CODE   =  ''' + @LANGCODE_TMP + '''' 
            EXEC sp_executesql     @STR, N'@COUNT INT OUT', @COUNT = @COUNT OUT
            IF @@Error<>0 GOTO QuitWithText
                        
            IF @COUNT > 0 
            BEGIN
                DECLARE @TABLE_NAME_T NVARCHAR(100)
                SET @TABLE_NAME_T = @COUNTRY_CODE + '_POINTADDRESS_MIX'
                
                EXEC DPM_GDM_CheckExistsTable @TABLE_NAME_T
                IF @@Error<>0 GOTO QuitWithText 
                
                SET @EXCLUDE_FIELDS = 'OBJECTID, Country_ID, SIDE, NeighborhoodZone_z, ZoneType, ZONE_ID_z, PLACE_ZONE_ID'
                SET @LIST_FIELDS    = ''
                
                EXEC DPM_GDM_CreateListFields @TABLE_NAME, @EXCLUDE_FIELDS, @LIST_FIELDS OUTPUT
                IF @@Error<>0 GOTO QuitWithText
                
                EXEC DPM_GDM_SelectTrnslitNeighborhoods @COUNTRY_CODE, @TABLE_NAME, @ZONE_NAMES_T, @LIST_FIELDS, @LANGCODE_TMP
                IF @@Error<>0 GOTO QuitWithText                            
                
                -- Define presenting zone values to add 
                SET @STR = 'SELECT @COUNT = COUNT(*) FROM ' + @COUNTRY_CODE + '_POINTADDRESS_MIX'
                EXEC sp_executesql     @STR, N'@COUNT INT OUT', @COUNT = @COUNT OUT
                IF @@Error<>0 GOTO QuitWithText                
                
                IF @COUNT > 0
                BEGIN
                    PRINT 'Count records with adding zones: ' + cast(@COUNT_FOR_ADD as nvarchar(10))    
                    
                    -- Cut records with empty Adm_LanguageCode into temporary table for Zones
                    EXEC('DELETE FROM ' + @TABLE_NAME + '  
                            WHERE   Adm_LanguageCode IS NULL AND 
                                    OBJECTID IN (SELECT OBJECTID FROM ' + @COUNTRY_CODE + '_POINTADDRESS_MIX)')
                    IF @@Error<>0 GOTO QuitWithText
                        
                    -- Insert joined records with empty Adm_LanguageCode and all them zones            
                    EXEC('INSERT INTO ' + @TABLE_NAME + '(' + @LIST_FIELDS + ', Country_ID, SIDE, NeighborhoodZone_z, ZONE_ID_z, PLACE_ZONE_ID) 
                            SELECT ' + @LIST_FIELDS + ', Country_ID, SIDE, NeighborhoodZone_z, ZONE_ID_z, PLACE_ZONE_ID 
                            FROM ' + @COUNTRY_CODE + '_POINTADDRESS_MIX')
                    IF @@Error<>0 GOTO QuitWithText    
                END   
            
                -- Update admin zones with Mix language
                SET @STR = 'UPDATE ' + @TABLE_NAME + ' SET 
                            Adm_LanguageCode       = ''' + @LANGCODE_TMP + ''',
                            Adm_LanguageCode2      = ' + @CURRENT_USER + '.DPM_GDM_GetLanguage2(''' + @LANGCODE_TMP + '''),                        
                            CountryName            = CN.ADMIN_NAME,
                            Territory              = TR.ADMIN_NAME,                        
                            AdminArea              = AN.ADMIN_NAME,
                            DependentAdminArea     = DN.ADMIN_NAME,
                            DependentAdminAreaPreferred  = 
                                                    CASE
                                                        WHEN DN.IS_PRIMARY = 1 THEN ''Y''
                                                        WHEN DN.IS_PRIMARY = 0 THEN ''N''                            
                                                    END,
                            SubAdminArea           = UN.ADMIN_NAME,
                            SubAdminAreaPreferred  = 
                                                    CASE
                                                        WHEN UN.IS_PRIMARY = 1 THEN ''Y''
                                                        WHEN UN.IS_PRIMARY = 0 THEN ''N''                            
                                                    END,
                            LocalityName           = LN.ADMIN_NAME,
                            LocalityNamePreferred  = 
                                                    CASE
                                                        WHEN LN.IS_PRIMARY = 1 THEN ''Y''
                                                        WHEN LN.IS_PRIMARY = 0 THEN ''N''                            
                                                    END, 
                            MetroArea             = MT.ADMIN_NAME,
                            NeighborhoodArea      = NA.ADMIN_NAME                                              
                        FROM ' + @TABLE_NAME + ' SA
                                LEFT JOIN ' + @AREA_MAIN_NAMES_T + ' CN WITH(NOLOCK) ON CN.LANGUAGE_CODE = ''' + @LANGCODE_TMP + ''' AND SA.Country_ID         = CN.ADMIN_NAME_ID AND CN.NAME_TYPE <> 2 
                                LEFT JOIN ' + @AREA_MAIN_NAMES_T + ' TR WITH(NOLOCK) ON TR.LANGUAGE_CODE = ''' + @LANGCODE_TMP + ''' AND Territory_ID          = TR.ADMIN_NAME_ID AND TR.NAME_TYPE <> 2 
                                LEFT JOIN ' + @AREA_MAIN_NAMES_T + ' AN WITH(NOLOCK) ON AN.LANGUAGE_CODE = ''' + @LANGCODE_TMP + ''' AND AdminArea_ID          = AN.ADMIN_NAME_ID AND AN.NAME_TYPE <> 2 
                                LEFT JOIN ' + @AREA_MAIN_NAMES_T + ' DN WITH(NOLOCK) ON DN.LANGUAGE_CODE = ''' + @LANGCODE_TMP + ''' AND DependentAdminArea_ID = DN.ADMIN_NAME_ID AND DN.NAME_TYPE <> 2
                                LEFT JOIN ' + @AREA_MAIN_NAMES_T + ' UN WITH(NOLOCK) ON UN.LANGUAGE_CODE = ''' + @LANGCODE_TMP + ''' AND SubAdminArea_ID       = UN.ADMIN_NAME_ID AND UN.NAME_TYPE <> 2 
                                LEFT JOIN ' + @AREA_MAIN_NAMES_T + ' LN WITH(NOLOCK) ON LN.LANGUAGE_CODE = ''' + @LANGCODE_TMP + ''' AND LocalityName_ID       = LN.ADMIN_NAME_ID AND LN.NAME_TYPE <> 2 
                                LEFT JOIN ' + @AREA_MAIN_NAMES_T + ' MT WITH(NOLOCK) ON MT.LANGUAGE_CODE = ''' + @LANGCODE_TMP + ''' AND MetroArea_ID          = MT.ADMIN_NAME_ID AND MT.NAME_TYPE <> 2 
                                LEFT JOIN ' + @AREA_MAIN_NAMES_T + ' NA WITH(NOLOCK) ON NA.LANGUAGE_CODE = ''' + @LANGCODE_TMP + ''' AND NeighborhoodArea_ID   = NA.ADMIN_NAME_ID AND NA.NAME_TYPE <> 2 
                        WHERE Adm_LanguageCode IS NULL' 
                EXEC (@STR)
                IF @@Error<>0 GOTO QuitWithText
                
                EXEC('DROP TABLE ' + @COUNTRY_CODE + '_POINTADDRESS_MIX')
                IF @@Error<>0 GOTO QuitWithText
            END
        END
    END
    
    PRINT ''
    PRINT 'Procedure DPM_GDM_CountryLanguageMix was well done:'
    PRINT 'Finish time: ' + CONVERT(VARCHAR(100), GETDATE())
    RETURN 0
    
    QuitWithText:
      RAISERROR('SCRIPT was terminated!', 16, 1)
      RETURN 1
GO

/**************************************************************************
    DPM_GDM_UpdateAdminWithoutMainNAME_ID Procedure
**************************************************************************/
/*  Updates admin fields with missed values. 
    It may be because language is not transliteration and
    NAME_ID is not mains.
    Inputs:
        @COUNTRY_CODE     - Input Country Code,
        @ADMIN_RELATIONS_T- Admin_Relations table name,
        @ADMIN_NAMES_T    - Admin_Names table,
        @PLACES_T         - Places table.
*/

IF EXISTS (SELECT NAME 
       FROM   sysobjects 
       WHERE  NAME = N'DPM_GDM_UpdateAdminWithoutMainNAME_ID'
       AND    TYPE = 'P')
    DROP PROCEDURE DPM_GDM_UpdateAdminWithoutMainNAME_ID
GO

CREATE PROCEDURE DPM_GDM_UpdateAdminWithoutMainNAME_ID 
            @COUNTRY_CODE      NVARCHAR(3),
            @COUNTRY_ID        BIGINT, 
            @TABLE_NAME        NVARCHAR(100),
            @ADMIN_RELATIONS_T NVARCHAR(100),
            @ADMIN_NAMES_T     NVARCHAR(100),
            @PLACES_T          NVARCHAR(100),
            @ZONE_NAMES_T      NVARCHAR(100)
                    
AS 
    DECLARE @STR        NVARCHAR(MAX),
            @COUNT      BIGINT,
            @COUNT_ADMIN       BIGINT, 
            @ADDITIONAL_QUERY NVARCHAR(200)            
    
    EXEC DPM_FGDB_CreateIndex @TABLE_NAME, 'Adm_LanguageCode', 'ADMIN_ID, LanguageCode'
    IF @@Error<>0 GOTO QuitWithText
  
    -- Check if records with not transliteration language is exists for country
    SET @STR = 'SELECT @COUNT = COUNT(*) FROM ' + @TABLE_NAME + ' PA WITH(NOLOCK) 
                    JOIN ' + @ADMIN_NAMES_T + ' AN WITH(NOLOCK) 
                        ON PA.Country_ID = AN.ADMIN_NAME_ID
                    WHERE CountryName IS NULL AND AN.LANGUAGE_CODE = LanguageCode' 
    EXEC sp_executesql     @STR, N'@COUNT INT OUT', @COUNT = @COUNT OUT
    IF @@Error<>0 GOTO QuitWithText

    -- Check if records by Admin with not transliteration language is exists
    SET @STR = 'SELECT @COUNT = COUNT(*) FROM ' + @TABLE_NAME + ' PA WITH(NOLOCK)                   
                    JOIN ' + @ADMIN_NAMES_T + ' AN WITH(NOLOCK) 
                        ON PA.AdminArea_ID = AN.ADMIN_NAME_ID
                    WHERE AdminArea IS NULL AND AN.LANGUAGE_CODE = LanguageCode' 
    EXEC sp_executesql  @STR, N'@COUNT INT OUT', @COUNT = @COUNT_ADMIN OUT
    IF @@Error<>0 GOTO QuitWithText
    
    IF @COUNT > 0 OR @COUNT_ADMIN > 0
    BEGIN 
    
        -- Create temporary table for update
        EXEC DPM_GDM_CheckExistsTable 'DPM_TEMP_UPDATE_ZONES'
        IF @@Error<>0 GOTO QuitWithText

        EXEC(N'SELECT * INTO DPM_TEMP_UPDATE_ZONES 
                FROM ' + @TABLE_NAME + ' WITH(NOLOCK) 
                WHERE CountryName IS NULL OR 
                      AdminArea   IS NULL')
        IF @@Error<>0 GOTO QuitWithText
              
        -- Update admin zones for not transliterate language
        IF @COUNTRY_CODE <> 'ARE'
            SET @ADDITIONAL_QUERY = ', 
                    NeighborhoodZone_z    = ZN.ZONE_NAME,
                    ZONE_ID_z             = ZN.ZONE_NAME_ID '
                    
        EXEC(N'UPDATE DPM_TEMP_UPDATE_ZONES SET 
                    Adm_LanguageCode      = AN.LANGUAGE_CODE,
                    Adm_LanguageCode2     = LanguageCode2, 
                    CountryName           = CN.ADMIN_NAME,  
                    Territory             = TR.ADMIN_NAME,                                  
                    AdminArea             = AN.ADMIN_NAME,
                    DependentAdminArea    = DN.ADMIN_NAME,
                    DependentAdminAreaPreferred = 
                                            CASE
                                                WHEN DN.IS_PRIMARY = 1 THEN ''Y''
                                                WHEN DN.IS_PRIMARY = 0 THEN ''N''                            
                                            END,
                    SubAdminArea          = UN.ADMIN_NAME,
                    SubAdminAreaPreferred = 
                                            CASE
                                                WHEN UN.IS_PRIMARY = 1 THEN ''Y''
                                                WHEN UN.IS_PRIMARY = 0 THEN ''N''                            
                                            END,
                    LocalityName          = LN.ADMIN_NAME,
                    LocalityNamePreferred = 
                                            CASE
                                                WHEN LN.IS_PRIMARY = 1 THEN ''Y''
                                                WHEN LN.IS_PRIMARY = 0 THEN ''N''                            
                                            END,
                    MetroArea             = MT.ADMIN_NAME, 
                    NeighborhoodArea      = NZ.ADMIN_NAME
                    ' + @ADDITIONAL_QUERY + '                 
                FROM DPM_TEMP_UPDATE_ZONES SA 
                        LEFT JOIN ' + @ADMIN_NAMES_T + ' CN WITH(NOLOCK) ON CN.ADMIN_NAME_ID      = ' + @COUNTRY_ID + ' AND CN.LANGUAGE_CODE = LanguageCode AND CN.NAME_TYPE <> 2
                        LEFT JOIN ' + @ADMIN_NAMES_T + ' AN WITH(NOLOCK) ON AdminArea_ID          = AN.ADMIN_NAME_ID    AND AN.LANGUAGE_CODE = LanguageCode AND AN.NAME_TYPE <> 2 
                        LEFT JOIN ' + @ADMIN_NAMES_T + ' TR WITH(NOLOCK) ON Territory_ID          = TR.ADMIN_NAME_ID    AND TR.LANGUAGE_CODE = LanguageCode AND TR.NAME_TYPE <> 2 
                        LEFT JOIN ' + @ADMIN_NAMES_T + ' DN WITH(NOLOCK) ON DependentAdminArea_ID = DN.ADMIN_NAME_ID    AND DN.LANGUAGE_CODE = LanguageCode AND DN.NAME_TYPE <> 2 
                        LEFT JOIN ' + @ADMIN_NAMES_T + ' UN WITH(NOLOCK) ON SubAdminArea_ID       = UN.ADMIN_NAME_ID    AND UN.LANGUAGE_CODE = LanguageCode AND UN.NAME_TYPE <> 2 
                        LEFT JOIN ' + @ADMIN_NAMES_T + ' LN WITH(NOLOCK) ON LocalityName_ID       = LN.ADMIN_NAME_ID    AND LN.LANGUAGE_CODE = LanguageCode AND LN.NAME_TYPE <> 2
                        LEFT JOIN ' + @ADMIN_NAMES_T + ' MT WITH(NOLOCK) ON MetroArea_ID          = MT.ADMIN_NAME_ID    AND MT.LANGUAGE_CODE = LanguageCode AND MT.NAME_TYPE <> 2
                        LEFT JOIN ' + @ADMIN_NAMES_T + ' NZ WITH(NOLOCK) ON NeighborhoodArea_ID   = NZ.ADMIN_NAME_ID    AND NZ.LANGUAGE_CODE = LanguageCode AND NZ.NAME_TYPE <> 2   
                        FULL JOIN ' + @ZONE_NAMES_T  + ' ZN WITH(NOLOCK) ON SA.PLACE_ZONE_ID      = ZN.ZONE_ID          AND ZN.LANGUAGE_CODE = LanguageCode ')
        IF @@Error<>0 GOTO QuitWithText 

        EXEC DPM_FGDB_CreateIndex 'DPM_TEMP_UPDATE_ZONES', 'LINK_ID', ''
        IF @@Error<>0 GOTO QuitWithText 
        EXEC DPM_FGDB_CreateIndex 'DPM_TEMP_UPDATE_ZONES', 'POINT_ADDRESS_ID', ''
        IF @@Error<>0 GOTO QuitWithText 
        EXEC DPM_FGDB_CreateIndex 'DPM_TEMP_UPDATE_ZONES', 'LanguageCode', ''
        IF @@Error<>0 GOTO QuitWithText
        EXEC DPM_FGDB_CreateIndex @TABLE_NAME, 'LINK_ID', ''
        IF @@Error<>0 GOTO QuitWithText 
        EXEC DPM_FGDB_CreateIndex @TABLE_NAME, 'POINT_ADDRESS_ID', ''
        IF @@Error<>0 GOTO QuitWithText 
        EXEC DPM_FGDB_CreateIndex @TABLE_NAME, 'LanguageCode', ''
        IF @@Error<>0 GOTO QuitWithText
        
        -- Update finally table
        IF @COUNTRY_CODE <> 'ARE'
            SET @ADDITIONAL_QUERY = ',
                    NeighborhoodZone_z    = TU.NeighborhoodZone_z,
                    ZONE_ID_z             = TU.ZONE_ID_z '
                    
        EXEC(N'UPDATE ' + @TABLE_NAME + '   
                SET Adm_LanguageCode      = TU.Adm_LanguageCode, 
                    Adm_LanguageCode2     = TU.Adm_LanguageCode2, 
                    CountryName           = TU.CountryName, 
                    Territory             = TU.Territory, 
                    AdminArea             = TU.AdminArea,
                    DependentAdminArea    = TU.DependentAdminArea,
                    DependentAdminAreaPreferred = TU.DependentAdminAreaPreferred,
                    SubAdminArea          = TU.SubAdminArea,
                    SubAdminAreaPreferred = TU.SubAdminAreaPreferred,
                    LocalityName          = TU.LocalityName,
                    LocalityNamePreferred = TU.LocalityNamePreferred,
                    MetroArea             = TU.MetroArea,
                    NeighborhoodArea      = TU.NeighborhoodArea
                    ' + @ADDITIONAL_QUERY + '                     
                FROM ' + @TABLE_NAME + ' SA JOIN DPM_TEMP_UPDATE_ZONES TU 
                        ON  SA.LINK_ID          = TU.LINK_ID AND 
                            SA.POINT_ADDRESS_ID = TU.POINT_ADDRESS_ID AND 
                            SA.LanguageCode     = TU.LanguageCode') 
        IF @@Error<>0 GOTO QuitWithText
        
        -- Drop temporary table
        EXEC('DROP TABLE DPM_TEMP_UPDATE_ZONES') 
        IF @@Error<>0 GOTO QuitWithText    
    END
    
    EXEC DPM_FGDB_CreateIndex @TABLE_NAME, 'ZONE_ID_z', ''
    IF @@Error<>0 GOTO QuitWithText
    EXEC DPM_FGDB_CreateIndex @TABLE_NAME, 'MetroArea_ID', ''
    IF @@Error<>0 GOTO QuitWithText
    EXEC DPM_FGDB_CreateIndex @TABLE_NAME, 'NeighborhoodArea_ID', ''
    IF @@Error<>0 GOTO QuitWithText

    -- Update neighborhood zones for not transliterate language from third data if absent language in country
    EXEC(N'UPDATE ' + @TABLE_NAME + ' SET 
                MetroArea          = MT.ADMIN_NAME, 
                NeighborhoodArea   = NZ.ADMIN_NAME,                          
                NeighborhoodZone_z = ZN.ZONE_NAME                 
            FROM          ' + @TABLE_NAME    + ' SA WITH(NOLOCK) 
                LEFT JOIN ' + @ADMIN_NAMES_T + ' MT WITH(NOLOCK) ON MetroArea_ID        = MT.ADMIN_NAME_ID  AND MT.LANGUAGE_CODE = LanguageCode AND MT.NAME_TYPE <> 2
                LEFT JOIN ' + @ADMIN_NAMES_T + ' NZ WITH(NOLOCK) ON NeighborhoodArea_ID = NZ.ADMIN_NAME_ID  AND NZ.LANGUAGE_CODE = LanguageCode AND NZ.NAME_TYPE <> 2  
                LEFT JOIN ' + @ZONE_NAMES_T  + ' ZN WITH(NOLOCK) ON SA.ZONE_ID_z        = ZN.ZONE_ID        AND ZN.LANGUAGE_CODE = LanguageCode  
            WHERE (NeighborhoodArea   IS NULL AND NeighborhoodArea_ID IS NOT NULL) OR
                  (MetroArea          IS NULL AND MetroArea_ID        IS NOT NULL) OR
                  (NeighborhoodZone_z IS NULL AND ZN.ZONE_NAME        IS NOT NULL)')
    IF @@Error<>0 GOTO QuitWithText  
    
    PRINT 'Procedure DPM_GDM_UpdateAdminWithoutMainNAME_ID was well done:'
    PRINT 'Finish time: ' + CONVERT(VARCHAR(100), GETDATE())
    PRINT ''
    RETURN 0
    
    QuitWithText:
      RAISERROR('SCRIPT was terminated!', 16, 1)
      RETURN 1
GO

/**************************************************************************
    DPM_GDM_AdminAbbrevation Procedure
**************************************************************************/
/*    Adds values into Right\LeftAdminAreaAbbr fields.
    Inputs:
        @ADMIN_NAMES_T   - Admin_Names table,
        @COUNTRY_CODE   - Input Country Code
*/

IF EXISTS (SELECT NAME 
       FROM   sysobjects 
       WHERE  NAME = N'DPM_GDM_AdminAbbrevation'
       AND    TYPE = 'P')
    DROP PROCEDURE DPM_GDM_AdminAbbrevation
GO

CREATE PROCEDURE DPM_GDM_AdminAbbrevation 
                    @TABLE_NAME    NVARCHAR(100),
                    @ADMIN_NAMES_T NVARCHAR(50),
                    @COUNTRY_CODE  NVARCHAR(3)
                    
AS 
    DECLARE @STR        NVARCHAR(MAX),
            @PARAMETERS NVARCHAR(200),
            @COUNT      BIGINT,
            @ADMIN_ABBR NVARCHAR(100),
            @COUNT_ABBR BIGINT
    
    EXEC('ALTER TABLE ' + @TABLE_NAME + '  
            ADD AdminAreaAbbr NVARCHAR(15)')
    IF @@Error<>0 GOTO QuitWithText
    
    SET @ADMIN_ABBR = 'DPM_TEMP_ABBREVATIONS'
    EXEC DPM_GDM_CheckExistsTable @ADMIN_ABBR
    IF @@Error<>0 GOTO QuitWithText
    
    EXEC('SELECT * INTO ' + @ADMIN_ABBR + ' 
            FROM ' + @ADMIN_NAMES_T + ' WITH(NOLOCK) 
            WHERE NAME_TYPE = 2')
    SET @COUNT_ABBR = @@ROWCOUNT  
    
    IF @COUNT_ABBR > 0
    BEGIN 
        EXEC DPM_FGDB_CreateIndex @TABLE_NAME, 'LanguageCode', ''
        IF @@Error<>0 GOTO QuitWithText
        EXEC DPM_FGDB_CreateIndex @TABLE_NAME, 'AdminArea_ID', ''
        IF @@Error<>0 GOTO QuitWithText      
		EXEC DPM_FGDB_CreateIndex @ADMIN_ABBR, 'LANGUAGE_CODE', ''
		IF @@Error<>0 GOTO QuitWithText 
		EXEC DPM_FGDB_CreateIndex @ADMIN_ABBR, 'ADMIN_NAME_ID', ''
		IF @@Error<>0 GOTO QuitWithText
    
		-- Add Admin Abbrevations
			EXEC(N'UPDATE ' + @TABLE_NAME + '  
				SET AdminAreaAbbr = ADMIN_NAME
					FROM  ' + @ADMIN_ABBR + ' AN WITH(NOLOCK) 
					WHERE  ' + @TABLE_NAME + '.LanguageCode = AN.LANGUAGE_CODE AND 
						   ' + @TABLE_NAME + '.AdminArea_ID = ADMIN_NAME_ID ')
		IF @@Error<>0 GOTO QuitWithText
    
        -- Define presence of empty abbrevations within StreetAddress table
        SET @STR = 'SELECT @COUNT = COUNT(*) 
                    FROM ' + @TABLE_NAME + ' WITH(NOLOCK)   
                    WHERE AdminAreaAbbr IS NULL'
        SET @PARAMETERS = N'@COUNT BIGINT OUTPUT'
        EXEC sp_executesql @STR, @PARAMETERS, @COUNT = @COUNT OUTPUT
        
        IF @COUNT > 0
        BEGIN
			EXEC DPM_FGDB_CreateIndex @TABLE_NAME, 'POINT_ADDRESS_ID', ''
			IF @@Error<>0 GOTO QuitWithText
			EXEC DPM_FGDB_CreateIndex @TABLE_NAME, 'AdminAreaAbbr', ''
			IF @@Error<>0 GOTO QuitWithText

			-- Update empty AdminAbbrevation with preferred values
					EXEC('UPDATE B 
							SET B.AdminAreaAbbr = A.AdminAreaAbbr      
							FROM ' + @TABLE_NAME + ' A JOIN ' + @TABLE_NAME + ' B 
								ON A.POINT_ADDRESS_ID = B.POINT_ADDRESS_ID
							WHERE B.AdminAreaAbbr IS NULL AND 
								  A.AdminAreaAbbr IS NOT NULL')
			IF @@Error<>0 GOTO QuitWithText
    
			-- Update admin abbrevations with only translitiration languge code 
			EXEC(N'UPDATE ' + @TABLE_NAME + ' 
					SET AdminAreaAbbr = ADMIN_NAME
					FROM  ' + @ADMIN_ABBR + ' AN JOIN ' + @TABLE_NAME + ' SA 
							ON SA.AdminArea_ID = ADMIN_NAME_ID 
					WHERE AdminAreaAbbr IS NULL')
			IF @@Error<>0 GOTO QuitWithText
        END
    END
    
    EXEC('DROP TABLE ' + @ADMIN_ABBR + '')
    IF @@Error<>0 GOTO QuitWithText
    
    PRINT 'Procedure DPM_GDM_AdminAbbrevation was well done:'
    PRINT 'Finish time: ' + CONVERT(VARCHAR(100), GETDATE())
    PRINT ''
    RETURN 0
    
    QuitWithText:
      RAISERROR('SCRIPT was terminated!', 16, 1)
      RETURN 1
GO  

/**************************************************************************
    DPM_GDM_UpdateNeighborhoodField  Procedure
**************************************************************************/
/*    Creates temporary zone table with necessery structure.
    Inputs:
        @COUNTRY_CODE    - Country code
        @POSTAL_CITIES_T - Name of Postal_Cities table.
    Output:
        PointAddress table will be updated.
*/

IF EXISTS (SELECT NAME FROM sysobjects 
    WHERE  NAME = N'DPM_GDM_UpdateNeighborhoodField' AND TYPE = 'P')
    DROP PROCEDURE DPM_GDM_UpdateNeighborhoodField
GO

CREATE PROCEDURE DPM_GDM_UpdateNeighborhoodField
        @COUNTRY_CODE    NVARCHAR(3),
        @TABLE_NAME      NVARCHAR(100),
        @POSTAL_CITIES_T NVARCHAR(100)
        
AS
    DECLARE @TABLE_NAME_T NVARCHAR(100),
            @SQLSTR1 NVARCHAR(MAX)
            
    SET @TABLE_NAME_T = @TABLE_NAME + '_temp'
    EXEC DPM_GDM_CheckExistsTable @TABLE_NAME_T
    IF @@Error<>0 GOTO QuitWithText 
    
    EXEC DPM_GDM_CheckExistsTable 'DPM_TEMP_ALL_ZONES'
    IF @@Error<>0 GOTO QuitWithText    

    -- Create temporary table    
    EXEC('CREATE TABLE DPM_TEMP_ALL_ZONES
                (POINT_ADDRESS_ID1   BIGINT, 
                 LINK_ID1            BIGINT, 
                 LanguageCodeForJoin NVARCHAR(3), 
                 NeighborhoodZone    NVARCHAR(100),
                 ZONE_ID             BIGINT)')
    IF @@Error<>0 GOTO QuitWithText
    
    IF @COUNTRY_CODE IN ('CAN', 'USA', 'GUM', 'DEU')
    BEGIN
        -- Insert Locality data into temporary table
        EXEC('INSERT INTO DPM_TEMP_ALL_ZONES(POINT_ADDRESS_ID1, LINK_ID1, LanguageCodeForJoin, NeighborhoodZone, ZONE_ID) 
                SELECT POINT_ADDRESS_ID, LINK_ID, Adm_LanguageCode, LocalityName, LocalityName_ID  
                FROM ' + @TABLE_NAME + ' WITH(NOLOCK)  
                WHERE LocalityName  IS NOT NULL')
        IF @@Error<>0 GOTO QuitWithText
        
        IF @COUNTRY_CODE <> 'DEU'
        BEGIN 
        -- Insert SubAdmin data into temporary table if Locality is empty
        SET @SQLSTR1 = 'INSERT INTO DPM_TEMP_ALL_ZONES(POINT_ADDRESS_ID1, LINK_ID1, LanguageCodeForJoin, NeighborhoodZone, ZONE_ID) 
                SELECT POINT_ADDRESS_ID, LINK_ID, Adm_LanguageCode, SubAdminArea, SubAdminArea_ID  
                    FROM ' + @TABLE_NAME + ' WITH(NOLOCK)  
                    WHERE SubAdminArea IS NOT NULL'              
                
            -- if Locality is empty         
        IF @COUNTRY_CODE = 'USA'
        BEGIN
                EXEC(@SQLSTR1 + ' AND LocalityName IS NULL')
            IF @@Error<>0 GOTO QuitWithText
        END
            -- else
        ELSE
        BEGIN
            EXEC(@SQLSTR1)
            IF @@Error<>0 GOTO QuitWithText
        END       
    END
    END
    -- Exclude Metro and Neigborhood data for CAN, USA, GUM  
    IF @COUNTRY_CODE NOT IN ('CAN', 'USA', 'GUM')
    BEGIN
        -- Insert Metro data into temporary table
        EXEC('INSERT INTO DPM_TEMP_ALL_ZONES(POINT_ADDRESS_ID1, LINK_ID1, LanguageCodeForJoin, NeighborhoodZone, ZONE_ID) 
                SELECT POINT_ADDRESS_ID, LINK_ID, Adm_LanguageCode, MetroArea, MetroArea_ID 
                FROM ' + @TABLE_NAME + ' WITH(NOLOCK) 
                WHERE MetroArea  IS NOT NULL')
        IF @@Error<>0 GOTO QuitWithText
        
        -- Insert Neighborhood data into temporary table
        EXEC('INSERT INTO DPM_TEMP_ALL_ZONES(POINT_ADDRESS_ID1, LINK_ID1, LanguageCodeForJoin, NeighborhoodZone, ZONE_ID) 
                SELECT POINT_ADDRESS_ID, LINK_ID, Adm_LanguageCode, NeighborhoodArea, NeighborhoodArea_ID
                FROM ' + @TABLE_NAME + ' WITH(NOLOCK) 
                WHERE NeighborhoodArea  IS NOT NULL')
        IF @@Error<>0 GOTO QuitWithText
    END
    
    -- Exclude Zones from MEX country
    IF @COUNTRY_CODE NOT IN ('MEX', 'CAN', 'ZWE')
    BEGIN        
        -- Insert Zones data into temporary table
        EXEC('INSERT INTO DPM_TEMP_ALL_ZONES(POINT_ADDRESS_ID1, LINK_ID1, LanguageCodeForJoin, NeighborhoodZone, ZONE_ID) 
                SELECT POINT_ADDRESS_ID, LINK_ID, Adm_LanguageCode, NeighborhoodZone_z, ZONE_ID_z 
                FROM ' + @TABLE_NAME + ' WITH(NOLOCK) 
                WHERE NeighborhoodZone_z  IS NOT NULL')
        IF @@Error<>0 GOTO QuitWithText
    END
    
    IF @COUNTRY_CODE IN ('DNK', 'ISL', 'NOR', 'USA', 'CAN', 'GUM')
    BEGIN        
        
        -- Insert Postal City Locality data into temporary table
        SET @SQLSTR1 = 'INSERT INTO DPM_TEMP_ALL_ZONES(POINT_ADDRESS_ID1, LINK_ID1, LanguageCodeForJoin, NeighborhoodZone, ZONE_ID) 
                SELECT POINT_ADDRESS_ID, LINK_ID, Adm_LanguageCode, PCY.POSTAL_CITY, PCY.POSTAL_CITY_ID  
                FROM ' + @TABLE_NAME + ' EPA WITH(NOLOCK) JOIN ' + @POSTAL_CITIES_T + ' PCY WITH(NOLOCK) 
                    ON EPA.POSTAL_CITY_ID = PCY.POSTAL_CITY_ID' 
                    
        IF @COUNTRY_CODE IN ('USA')
        BEGIN        
            EXEC(@SQLSTR1)
            IF @@Error<>0 GOTO QuitWithText 
        END
        ELSE
        BEGIN
            EXEC(@SQLSTR1 + ' AND PCY.IS_PRIMARY = 1')
            IF @@Error<>0 GOTO QuitWithText
        END
    END
    
    DECLARE @EXCLUDE_FIELDS NVARCHAR(MAX),
            @LIST_FIELDS    NVARCHAR(MAX)
            
    -- Remove duplicates from DPM_TEMP_ALL_ZONES table
    DECLARE @LIST_EXCLUDE_FIELDS NVARCHAR(200)
    IF @COUNTRY_CODE IN ('EST', 'CZE')
        SET @LIST_EXCLUDE_FIELDS = 'ZONE_ID'
    ELSE
        SET @LIST_EXCLUDE_FIELDS = 'LanguageCodeForJoin, ZONE_ID'
    EXEC DPM_GDM_RemoveDuplicates 'DPM_TEMP_ALL_ZONES', @LIST_EXCLUDE_FIELDS
    IF @@Error<>0 GOTO QuitWithText
    
    -- Create list of output fields for main table - exclude NeighborhoodZone_z  
    SET @EXCLUDE_FIELDS     = 'Shape, OBJECTID, NeighborhoodArea, NeighborhoodArea_ID, NeighborhoodZone_z, ZONE_ID_z'
    IF @COUNTRY_CODE IN ('USA', 'CAN', 'GUM')
        SET @EXCLUDE_FIELDS = @EXCLUDE_FIELDS + ', POSTAL_CITY_ID' 
                           
    EXEC DPM_GDM_CreateListFields @TABLE_NAME, @EXCLUDE_FIELDS, @LIST_FIELDS OUTPUT
    IF @@Error<>0 GOTO QuitWithText
    
    -- Add all zones into PointAddress table
    EXEC('SELECT Shape,  
                 ' + @LIST_FIELDS + ', 
                 NeighborhoodZone, 
                 ZONE_ID  
            INTO ' + @TABLE_NAME_T + '  
            FROM ' + @TABLE_NAME + ' ESA WITH(NOLOCK) LEFT JOIN 
                 DPM_TEMP_ALL_ZONES  TT  WITH(NOLOCK) 
                ON  ESA.POINT_ADDRESS_ID = TT.POINT_ADDRESS_ID1 AND 
                    ESA.LINK_ID          = TT.LINK_ID1 AND 
                    ESA.Adm_LanguageCode = TT.LanguageCodeForJoin')
    IF @@Error<>0 GOTO QuitWithText
               
    EXEC('DROP TABLE DPM_TEMP_ALL_ZONES')
    IF @@Error<>0 GOTO QuitWithText
    
    -- Delete temporary table
    EXEC('DROP TABLE ' + @TABLE_NAME)
    IF @@Error<>0 GOTO QuitWithText
    
    -- Remove duplicates from PointAddress table
    EXEC DPM_GDM_RemoveDuplicates @TABLE_NAME_T, 'Shape, OBJECTID, SIDE'
    IF @@Error<>0 GOTO QuitWithText

    PRINT ''
    PRINT 'Procedure DPM_GDM_UpdateNeighborhoodField was well done:'
    PRINT 'Finish time: ' + CONVERT(VARCHAR(100), GETDATE())
    
    RETURN 0
    
    QuitWithText:
      RAISERROR('SCRIPT was terminated!', 16, 1)
      RETURN 1
GO          

/**************************************************************************
    DPM_GDM_MainSelect Procedure
**************************************************************************/
/*    Creates EsriPointAddress feature class for reference data.
    Inputs:
        @COUNTRY_CODE      - Country Code.
        @PLACES_T          - Places feature class name.
        @STREETS_NAMES_T   - Street_Names table name.
        @ADDRESSES_T       - Address_Ranges table name.
        @ADMIN_RELATIONS_T - Admin_Relations table name.
        @AREA_MAIN_NAMES_T - Area_Names table name with main names only.
        @POSTAL_CODES_T    - Postal_Codes table name.
        @POSTAL_RELATIONS_T- Postal_Relations table name.
        @NUMBER_VERSION    - Number of version.
        @COUNTRY_ID        - Country ID.
        @LANGUAGE_CODE     - Current language code. 
    Output:
        EsriPointAddress feature class.
    
*/

IF EXISTS (SELECT NAME FROM sysobjects 
    WHERE  NAME = N'DPM_GDM_MainSelect' AND TYPE = 'P')
    DROP PROCEDURE DPM_GDM_MainSelect
GO

CREATE PROCEDURE DPM_GDM_MainSelect
        @COUNTRY_CODE       NVARCHAR(3),
        @PLACES_T           NVARCHAR(100),
        @TABLE_NAME         NVARCHAR(100),
        @STREETS_NAMES_T    NVARCHAR(100),
        @ADDRESSES_T        NVARCHAR(100),
        @ADMIN_RELATIONS_T  NVARCHAR(100),
        @AREA_MAIN_NAMES_T  NVARCHAR(100),
        @POSTAL_CODES_T     NVARCHAR(100),
        @POSTAL_RELATIONS_T NVARCHAR(100),
        @POSTAL_CITIES_T    NVARCHAR(100), 
        @ZONE_NAMES_T       NVARCHAR(100), 
        @NUMBER_VERSION     TINYINT,
        @COUNTRY_ID         BIGINT,
        @LANGUAGE_CODE      NVARCHAR(3)
AS

    DECLARE @CURRENT_USER   NVARCHAR(50),
            @ADDRESSES_TEMP NVARCHAR(100),
            @ADDITIONAL_QUERY  NVARCHAR(100),
            @ADDITIONAL_QUERY1 NVARCHAR(100)
            
    SET     @CURRENT_USER   = RTRIM(CONVERT(CHAR(30), CURRENT_USER))
    SET     @ADDRESSES_TEMP = 'DPM_TEMP_ADDRESSES'
    
    EXEC DPM_GDM_CheckExistsTable @TABLE_NAME
    IF @@Error<>0 GOTO QuitWithText 
    
    -- Set additional queries for some counties
    SET @ADDITIONAL_QUERY = ''
    SET @ADDITIONAL_QUERY1 = ''
    IF @COUNTRY_CODE IN ('ARE', 'AUT', 'AZE', 'BIH', 'BGR', 'CZE', 'EGY', 'EST', 'HRV', 
                         'HUN', 'ISR', 'LTU', 'LVA', 'SVN', 'THA', 'TUR', 'TWN', 
                         'ROU', 'RUS', 'SVK', 'VNM')
        SET @ADDITIONAL_QUERY = 'AND AR.LANGUAGE_CODE = SN.LANGUAGE_CODE '
    IF @COUNTRY_CODE = 'BEL'
        SET @ADDITIONAL_QUERY1 = 'AND AN00.IS_PRIMARY = 1 '
    
    -- Create smaller temporary tables
    EXEC DPM_GDM_CheckExistsTable 'DPM_TEMP_ADM_REL'
    IF @@Error<>0 GOTO QuitWithText
    
    EXEC(N'SELECT * INTO DPM_TEMP_ADM_REL FROM ' + @ADMIN_RELATIONS_T + ' WITH(NOLOCK) 
            WHERE COUNTRY_ID = ' + @COUNTRY_ID + '')
    IF @@Error<>0 GOTO QuitWithText
    
    PRINT 'Select places: ' + CONVERT(VARCHAR(100), GETDATE()) 
    EXEC DPM_GDM_CheckExistsTable 'DPM_TEMP_PLACES'
    IF @@Error<>0 GOTO QuitWithText
    
    EXEC(N'SELECT * INTO DPM_TEMP_PLACES FROM ' + @PLACES_T + ' WITH(NOLOCK) 
            WHERE OBJECT_TYPE IN (2, 5) AND 
                  ADMIN_ID IN (SELECT ADMIN_ID FROM DPM_TEMP_ADM_REL WITH(NOLOCK))')
    IF @@Error<>0 GOTO QuitWithText
    PRINT 'Finish: ' + CONVERT(VARCHAR(100), GETDATE())
    
    PRINT 'Select addresses: ' + CONVERT(VARCHAR(100), GETDATE())
    EXEC DPM_GDM_CheckExistsTable 'DPM_TEMP_ADDRESSES'
    IF @@Error<>0 GOTO QuitWithText
    
    EXEC(N'SELECT * INTO DPM_TEMP_ADDRESSES FROM ' + @ADDRESSES_T + ' WITH(NOLOCK)  
            WHERE ADDRESS_TYPE = 1 AND 
                  ADDRESS_ID IN (SELECT ADDRESS_ID FROM DPM_TEMP_PLACES WITH(NOLOCK))')
    IF @@Error<>0 GOTO QuitWithText
    PRINT 'Finish: ' + CONVERT(VARCHAR(100), GETDATE())
    
    EXEC DPM_FGDB_CreateIndex 'DPM_TEMP_ADDRESSES', 'ADDRESS_ID', ''
    IF @@Error<>0 GOTO QuitWithText
    EXEC DPM_FGDB_CreateIndex 'DPM_TEMP_PLACES', 'ADDRESS_ID', ''
    IF @@Error<>0 GOTO QuitWithText
    EXEC DPM_FGDB_CreateIndex 'DPM_TEMP_PLACES', 'ADMIN_ID', ''
    IF @@Error<>0 GOTO QuitWithText
    EXEC DPM_FGDB_CreateIndex 'DPM_TEMP_ADM_REL', 'ADMIN_ID', ''
    IF @@Error<>0 GOTO QuitWithText
    EXEC DPM_FGDB_CreateIndex 'ZONE_NAMES', 'ZONE_ID', 'LANGUAGE_CODE'
    IF @@Error<>0 GOTO QuitWithText
    
    -- Select neccessery values into output FC from input tables
    PRINT 'Main select: ' + CONVERT(VARCHAR(100), GETDATE())
    EXEC (N'SELECT 
        --P.SHAPE,  -- points without offset, placed in their source location       
        GEOMETRY::Point(ISNULL(P.RouteX, 0), ISNULL(P.RouteY, 0), 4326) -- offset points to street segments 
                                   AS SHAPE, 
        P.SOURCE_ID                AS POINT_ADDRESS_ID,         
        AR.STREET_SEGMENT_ID       AS LINK_ID, 
        
        -- Add house number components
        AR.ADDRESS_FROM            AS PremiseNumber,
        AR.BUILDING_NAME           AS PremiseName,
        CASE
            WHEN AR.SIDE = 1 THEN ''R''
            WHEN AR.SIDE = 2 THEN ''L''
            ELSE ''''
        END                        AS SIDE,
        
        -- Add street name components
        SN.FULL_STREET_NAME        AS ThoroughfareFullName,
        SN.STREET_PREFIX_DIR       AS ThoroughfarePreDirection,
        SN.STREET_PREFIX_TYPE      AS ThoroughfareLeadingType,
        SN.STREET_NAME             AS ThoroughfareName,
        SN.STREET_TYPE             AS ThoroughfareTrailingType,
        SN.STREET_DIR              AS ThoroughfarePostDirection,
        CASE
            WHEN AR.IS_PRIMARY = 1 AND 
                 SN.NAME_TYPE  = 1 
				THEN ''Y''
				ELSE ''N''
        END                        AS StreetPreferred,
		CASE
            WHEN AR.IS_PRIMARY = 1 
				THEN ''B''            
				ELSE ''''
        END                        AS AddressType,
        
        -- Add language codes
        SN.LANGUAGE_CODE           AS LanguageCode,
        ' + @CURRENT_USER + '.DPM_GDM_GetLanguage2(SN.LANGUAGE_CODE) 
                                   AS LanguageCode2, 
        AN.LANGUAGE_CODE           AS Adm_LanguageCode,
        ' + @CURRENT_USER + '.DPM_GDM_GetLanguage2(AN.LANGUAGE_CODE) 
                                   AS Adm_LanguageCode2,                                   
        -- Add admin zones
        PC.POSTAL_CODE             AS PostalCodeNumber, 
        AN.ADMIN_NAME              AS CountryName,
        ''' + @COUNTRY_CODE + '''  AS CountryCode,
        AN00.ADMIN_NAME            AS Territory,
        AN1.ADMIN_NAME             AS AdminArea,
        AN2.ADMIN_NAME             AS DependentAdminArea,
        CASE
            WHEN AN2.IS_PRIMARY = 1 THEN ''Y''
            WHEN AN2.IS_PRIMARY = 0 THEN ''N''
        END                        AS DependentAdminAreaPreferred,
        AN3.ADMIN_NAME             AS SubAdminArea,
        CASE
            WHEN AN3.IS_PRIMARY = 1 THEN ''Y''
            WHEN AN3.IS_PRIMARY = 0 THEN ''N''
        END                        AS SubAdminAreaPreferred,
        AN4.ADMIN_NAME             AS LocalityName,
        CASE
            WHEN AN4.IS_PRIMARY = 1 THEN ''Y''
            WHEN AN4.IS_PRIMARY = 0 THEN ''N''
        END                        AS LocalityNamePreferred,
        AN5.ADMIN_NAME             AS MetroArea,
        AN6.ADMIN_NAME             AS NeighborhoodArea,
        ZN.ZONE_NAME               AS NeighborhoodZone_z,
        
        -- Add coordinates fields
        P.RouteY                   AS DisplayLat,
        P.RouteX                   AS DisplayLon,
        P.RouteX -0.0001           AS XMIN,
        P.RouteY -0.0001           AS YMIN,
        P.RouteX +0.0001           AS XMAX,
        P.RouteY +0.0001           AS YMAX,
        1                          AS EXTENT, 
        
        -- Add admin zone IDs
        ARL.COUNTRY_ID             AS Country_ID, 
        ARL.TERRITORY_ID           AS Territory_ID,
        ARL.REGION_ID              AS AdminArea_ID,
        ARL.SUBREGION_ID           AS DependentAdminArea_ID,
        ARL.CITY_ID                AS SubAdminArea_ID,
        ARL.DISTRICT_ID            AS LocalityName_ID,
        ARL.METRO_ID               AS MetroArea_ID,
        ARL.NEIGHBORHOOD_ID        AS NeighborhoodArea_ID,
        PR.POSTAL_CODE_ID          AS PostalCode_ID,
        ZN.ZONE_NAME_ID            AS ZONE_ID_z,
        ARL.DISTRICT_ID            AS ADMIN_PLACE_ID, 

        -- Add not required fields
        P.ZONE_ID                  AS PLACE_ZONE_ID,
        P.OBJECT_TYPE              AS OBJECT_TYPE,
        PCY.POSTAL_CITY_ID         AS POSTAL_CITY_ID,
        P.ADMIN_ID                 AS ADMIN_ID,
        P.POSTAL_EXT_ID            AS POSTAL_EXT_ID,
        PR.POSTAL_ID               AS POSTAL_ID   
        
    INTO ' + @TABLE_NAME + '          
    FROM DPM_TEMP_PLACES P WITH(NOLOCK) 
      JOIN      DPM_TEMP_ADDRESSES         AR   WITH(NOLOCK) ON P.ADDRESS_ID       = AR.ADDRESS_ID  
      JOIN      ' + @STREETS_NAMES_T + '   SN   WITH(NOLOCK) ON AR.STREET_NAME_ID  = SN.STREET_NAME_ID ' + @ADDITIONAL_QUERY + '
      LEFT JOIN DPM_TEMP_ADM_REL           ARL  WITH(NOLOCK) ON ARL.ADMIN_ID       = P.ADMIN_ID 
      LEFT JOIN ' + @AREA_MAIN_NAMES_T + ' AN00 WITH(NOLOCK) ON AN00.ADMIN_NAME_ID = ARL.TERRITORY_ID    AND AR.LANGUAGE_CODE = AN00.LANGUAGE_CODE AND AN00.NAME_TYPE <> 2 ' + @ADDITIONAL_QUERY1 + '
      LEFT JOIN ' + @AREA_MAIN_NAMES_T + ' AN   WITH(NOLOCK) ON AN.ADMIN_NAME_ID   = ARL.COUNTRY_ID      AND AR.LANGUAGE_CODE = AN.LANGUAGE_CODE   AND AN.NAME_TYPE  <> 2
      LEFT JOIN ' + @AREA_MAIN_NAMES_T + ' AN1  WITH(NOLOCK) ON AN1.ADMIN_NAME_ID  = ARL.REGION_ID       AND AR.LANGUAGE_CODE = AN1.LANGUAGE_CODE  AND AN1.NAME_TYPE <> 2                               
      LEFT JOIN ' + @AREA_MAIN_NAMES_T + ' AN2  WITH(NOLOCK) ON AN2.ADMIN_NAME_ID  = ARL.SUBREGION_ID    AND AR.LANGUAGE_CODE = AN2.LANGUAGE_CODE  AND AN2.NAME_TYPE <> 2 
      LEFT JOIN ' + @AREA_MAIN_NAMES_T + ' AN3  WITH(NOLOCK) ON AN3.ADMIN_NAME_ID  = ARL.CITY_ID         AND AR.LANGUAGE_CODE = AN3.LANGUAGE_CODE  AND AN3.NAME_TYPE <> 2 
      LEFT JOIN ' + @AREA_MAIN_NAMES_T + ' AN4  WITH(NOLOCK) ON AN4.ADMIN_NAME_ID  = ARL.DISTRICT_ID     AND AR.LANGUAGE_CODE = AN4.LANGUAGE_CODE  AND AN4.NAME_TYPE <> 2 
      LEFT JOIN ' + @AREA_MAIN_NAMES_T + ' AN5  WITH(NOLOCK) ON AN5.ADMIN_NAME_ID  = ARL.METRO_ID        AND AR.LANGUAGE_CODE = AN5.LANGUAGE_CODE  AND AN5.NAME_TYPE <> 2 
      LEFT JOIN ' + @AREA_MAIN_NAMES_T + ' AN6  WITH(NOLOCK) ON AN6.ADMIN_NAME_ID  = ARL.NEIGHBORHOOD_ID AND AR.LANGUAGE_CODE = AN6.LANGUAGE_CODE  AND AN6.NAME_TYPE <> 2
      FULL JOIN ' + @ZONE_NAMES_T      + ' ZN   WITH(NOLOCK) ON P.ZONE_ID          = ZN.ZONE_ID          AND AR.LANGUAGE_CODE = ZN.LANGUAGE_CODE   
      LEFT JOIN ' + @POSTAL_RELATIONS_T +' PR   WITH(NOLOCK) ON P.POSTAL_ID        = PR.POSTAL_ID        AND PR.POSTAL_TYPE   = 1                  
      LEFT JOIN ' + @POSTAL_CODES_T    + ' PC   WITH(NOLOCK) ON PR.POSTAL_CODE_ID  = PC.POSTAL_CODE_ID   AND PC.IS_PRIMARY    = 1 
      LEFT JOIN ' + @POSTAL_CITIES_T   + ' PCY  WITH(NOLOCK) ON PC.POSTAL_CITY_ID  = PCY.POSTAL_CITY_ID  AND PCY.IS_PRIMARY   = 1  
    WHERE P.VERSION_ID = ' + @NUMBER_VERSION + ' AND 
          --P.ORG_ID     = 1 AND 
          P.USAGE_TYPE NOT IN (6, 8)') 
    IF @@Error<>0 GOTO QuitWithText
    PRINT 'Finish: ' + CONVERT(VARCHAR(100), GETDATE())
    
    -- Create additional table for NZL postprocessing
    IF @COUNTRY_CODE = 'NZL'
    BEGIN
        EXEC('SELECT * INTO DPM_TEMP_PLACES_NEW 
                FROM DPM_TEMP_PLACES P WITH(NOLOCK) 
                WHERE P.USAGE_TYPE = 8')
        IF @@Error<>0 GOTO QuitWithText
    END
    
    EXEC('DROP TABLE DPM_TEMP_PLACES')
    IF @@Error<>0 GOTO QuitWithText
        
    -- Remove auxilary tables
    EXEC('DROP TABLE DPM_TEMP_ADDRESSES')
    IF @@Error<>0 GOTO QuitWithText
    EXEC('DROP TABLE DPM_TEMP_ADM_REL')
    IF @@Error<>0 GOTO QuitWithText

    -- Update empty ADMIN_PLACE_ID with SubAdmin values (fields are using in SWE)
    EXEC('UPDATE ' + @TABLE_NAME + ' 
            SET ADMIN_PLACE_ID = SubAdminArea_ID
            WHERE LocalityName_ID IS NULL')
    IF @@Error<>0 GOTO QuitWithText
    
    -- Update empty PremiseName
    EXEC('UPDATE ' + @TABLE_NAME + ' 
            SET PremiseName = ''''
            WHERE PremiseName IS NULL')
    IF @@Error<>0 GOTO QuitWithText
    
    -- Update empty PremiseNumber
    EXEC('UPDATE ' + @TABLE_NAME + ' 
            SET PremiseNumber = ''''
            WHERE PremiseNumber IS NULL')
    IF @@Error<>0 GOTO QuitWithText

    PRINT ''
    PRINT 'Procedure DPM_GDM_MainSelect was well done:'
    PRINT 'Finish time: ' + CONVERT(VARCHAR(100), GETDATE())
    
    RETURN 0
    
    QuitWithText:
      RAISERROR('SCRIPT was terminated!', 16, 1)
      RETURN 1
GO

/**************************************************************************
    DPM_GDM_PointAddressPostproc Procedure
**************************************************************************/
/*    Adds neccessery fields for same countries.
    Inputs:
        @COUNTRY_CODE      - Country Code.
        @AREA_MAIN_NAMES_T - SubAdmin_Names table name.
        @POSTAL_CODES_T    - Postal_Codes table name.
        @POSTAL_CITIES_T   - Postal_Cities table name.
    Output:
        Additional fields will be added into EsriPointAddress 
        
*/

IF EXISTS (SELECT NAME FROM sysobjects 
    WHERE  NAME = N'DPM_GDM_PointAddressPostproc' AND TYPE = 'P')
    DROP PROCEDURE DPM_GDM_PointAddressPostproc
GO

CREATE PROCEDURE DPM_GDM_PointAddressPostproc
        @COUNTRY_CODE      NVARCHAR(3),
        @TABLE_NAME        NVARCHAR(100),
        @POSTAL_CODES_T    NVARCHAR(100),
        @POSTAL_CITIES_T   NVARCHAR(100),
        @AREA_MAIN_NAMES_T NVARCHAR(100),
        @PLACES_T          NVARCHAR(100),
        @AREA_RELATIONS_T  NVARCHAR(100),
        @ADMIN_NAMES_T     NVARCHAR(100)
AS
    IF @COUNTRY_CODE = 'DNK'
    BEGIN
        EXEC('ALTER TABLE ' + @TABLE_NAME + ' ADD PostDist NVARCHAR(75)')
        IF @@Error<>0 GOTO QuitWithText
        
        -- Update PostDist field for DNK
        EXEC(N'UPDATE ' + @TABLE_NAME + ' SET PostDist = POSTAL_CITY 
                FROM  ' + @POSTAL_CODES_T  + ' PC  WITH(NOLOCK) JOIN 
                      ' + @POSTAL_CITIES_T + ' PCY WITH(NOLOCK) 
                    ON PC.POSTAL_CITY_ID = PCY.POSTAL_CITY_ID 
                WHERE  
                    PCY.IS_PRIMARY = 1 AND 
                    ' + @TABLE_NAME + '.PostalCode_ID = PC.POSTAL_CODE_ID ')
        IF @@Error<>0 GOTO QuitWithText
        
        -- Remove Neighborhood data - it's duplicate of PostDist field
        EXEC(N'UPDATE ' + @TABLE_NAME + ' SET 
                NeighborhoodZone = NULL,
                ZONE_ID          = NULL')
        IF @@Error<>0 GOTO QuitWithText        
    END
    
    IF @COUNTRY_CODE = 'NZL'
    BEGIN
        EXEC('ALTER TABLE ' + @TABLE_NAME + '  
                ADD MAJOR_NAME  NVARCHAR(100)')
        IF @@Error<>0 GOTO QuitWithText
        
        EXEC DPM_GDM_CheckExistsTable 'DPM_TEMP_PLACES_8'
        IF @@Error<>0 GOTO QuitWithText
        
        -- Create additional table for easy join        
        EXEC('SELECT P.SOURCE_ID,
                     AN.LANGUAGE_CODE,
                     AN.ADMIN_NAME,
                     AN.IS_PRIMARY 
                INTO DPM_TEMP_PLACES_8 
                FROM DPM_TEMP_PLACES_NEW      P   WITH(NOLOCK) JOIN 
                    ' + @AREA_RELATIONS_T + ' ARL WITH(NOLOCK) 
                     ON ARL.ADMIN_ID = P.ADMIN_ID JOIN 
                     ' + @ADMIN_NAMES_T + '   AN  WITH(NOLOCK) 
                     ON AN.ADMIN_NAME_ID = ARL.DISTRICT_ID AND
                        AN.NAME_TYPE <> 2')
        IF @@Error<>0 GOTO QuitWithText
        
        EXEC('DROP TABLE DPM_TEMP_PLACES_NEW')
        IF @@Error<>0 GOTO QuitWithText
        
        -- Preparation additional tables
        DECLARE @TABLE_NAME1 NVARCHAR(100)        
        SET @TABLE_NAME1 = @TABLE_NAME + '1'
        EXEC DPM_GDM_CheckExistsTable @TABLE_NAME1
        IF @@Error<>0 GOTO QuitWithText 
        
        -- Update SUBURB_NAME field for NZL
        EXEC(N'SELECT A.*, 
                      P.ADMIN_NAME AS SUBURB_NAME,
                      CASE
                        WHEN P.IS_PRIMARY = 1 THEN ''Y''
                        ELSE ''N''
                      END           AS SuburbPreferred 
                INTO ' + @TABLE_NAME1 + '                  
                FROM ' + @TABLE_NAME + ' A WITH(NOLOCK) LEFT JOIN 
                     DPM_TEMP_PLACES_8   P WITH(NOLOCK) 
                     ON A.POINT_ADDRESS_ID = P.SOURCE_ID AND 
                        A.Adm_LanguageCode = P.LANGUAGE_CODE')                      
        IF @@Error<>0 GOTO QuitWithText
        
        EXEC('DROP TABLE DPM_TEMP_PLACES_8')
        IF @@Error<>0 GOTO QuitWithText
                 
        -- Rewrite original table with temporary table from last query        
        EXEC('DROP TABLE ' + @TABLE_NAME)
        IF @@Error<>0 GOTO QuitWithText
        EXEC sp_rename @TABLE_NAME1, @TABLE_NAME
        IF @@Error<>0 GOTO QuitWithText
        
        -- Update MAJOR_NAME field for NZL
        EXEC(N'UPDATE ' + @TABLE_NAME + '  
                SET MAJOR_NAME = SubAdminArea')                    
        IF @@Error<>0 GOTO QuitWithText
    END
    
    IF @COUNTRY_CODE = 'SWE'
    BEGIN
        EXEC('ALTER TABLE ' + @TABLE_NAME + ' ADD PAZone NVARCHAR(75)')
        IF @@Error<>0 GOTO QuitWithText
        
        -- Update PAZone field for SWE
        EXEC(N'UPDATE ' + @TABLE_NAME + ' SET PAZone = POSTAL_CITY 
                FROM  ' + @POSTAL_CODES_T  + ' PC  WITH(NOLOCK) JOIN 
                      ' + @POSTAL_CITIES_T + ' PCY WITH(NOLOCK) 
                    ON PC.POSTAL_CITY_ID = PCY.POSTAL_CITY_ID 
                WHERE  
                    PCY.IS_PRIMARY = 1 AND 
                    ' + @TABLE_NAME + '.PostalCode_ID = PC.POSTAL_CODE_ID ')
        IF @@Error<>0 GOTO QuitWithText
    END
    
    IF @COUNTRY_CODE IN ('CAN', 'USA', 'GUM')
    BEGIN
        EXEC('ALTER TABLE ' + @TABLE_NAME + '  
                ADD City          NVARCHAR(100),
                    CityPreferred NVARCHAR(1)')
        IF @@Error<>0 GOTO QuitWithText
                
        EXEC DPM_FGDB_DropIndex @TABLE_NAME, 'NeighborhoodZone'
        IF @@Error<>0 GOTO QuitWithText
              
        -- Update City field 
        EXEC(N'UPDATE ' + @TABLE_NAME + '  
                SET City = NeighborhoodZone')
        IF @@Error<>0 GOTO QuitWithText
        
        EXEC DPM_FGDB_CreateIndex @TABLE_NAME, 'ZONE_ID', ''
        IF @@Error<>0 GOTO QuitWithText

        -- Update City preferred field 
        IF @COUNTRY_CODE = 'USA'
        BEGIN
            EXEC(N'UPDATE ' + @TABLE_NAME + '  
                    SET CityPreferred  = ''P''
                    WHERE ZONE_ID IN (SELECT POSTAL_CITY_ID FROM ' + @POSTAL_CITIES_T + ' WITH(NOLOCK) 
                                        WHERE IS_PRIMARY = 1)')
            IF @@Error<>0 GOTO QuitWithText  
        END             
        ELSE
        BEGIN                   
            EXEC(N'UPDATE ' + @TABLE_NAME + '  
                    SET CityPreferred = ''N'' 
                    WHERE ZONE_ID IN (SELECT POSTAL_CITY_ID FROM ' + @POSTAL_CITIES_T + ' WITH(NOLOCK) )')
            IF @@Error<>0 GOTO QuitWithText 
            
            EXEC DPM_FGDB_CreateIndex @TABLE_NAME, 'NeighborhoodZone', ''
            IF @@Error<>0 GOTO QuitWithText
                        
            EXEC('UPDATE ' + @TABLE_NAME + '  
                    SET CityPreferred = ''Y'' 
                    WHERE ZONE_ID IN (SELECT POSTAL_CITY_ID FROM ' + @POSTAL_CITIES_T + ' WITH(NOLOCK) 
                                        WHERE IS_PRIMARY = 1)') 
            IF @@Error<>0 GOTO QuitWithText 
        END
        
        EXEC DPM_FGDB_DropIndex @TABLE_NAME, 'ZONE_ID'
        IF @@Error<>0 GOTO QuitWithText
        
        EXEC DPM_FGDB_CreateIndex @TABLE_NAME, 'CityPreferred', 'City'
        IF @@Error<>0 GOTO QuitWithText
        
        -- Set default city preferred values
        EXEC(N'UPDATE ' + @TABLE_NAME + '  
                SET CityPreferred = ''Y'' 
                WHERE CityPreferred IS NULL AND 
                      City IS NOT NULL')
        IF @@Error<>0 GOTO QuitWithText
        
        EXEC DPM_FGDB_DropIndex @TABLE_NAME, 'CityPreferred'
        IF @@Error<>0 GOTO QuitWithText
    END
    
    PRINT ''
    PRINT 'Procedure DPM_GDM_PointAddressPostproc was well done:'
    PRINT 'Finish time: ' + CONVERT(VARCHAR(100), GETDATE())
    RETURN 0
    
    QuitWithText:
      RAISERROR('SCRIPT was terminated!', 16, 1)
      RETURN 1
GO

/**************************************************************************
    DPM_GDM_AUS_Postprocessing Procedure
**************************************************************************/
/*      Mixes DEPADMIN\SUBADMIN\LOCALITY fields.
    Inputs:
        @COUNTRY_CODE  - Country Code.
        @COUNTRY_ID    - Country ID.
        @ADMIN_NAMES_T - Area_Names table.
    Output:
        DEPADMIN\SUBADMIN\LOCALITY fields will have new content. 
        
*/

IF EXISTS (SELECT NAME FROM sysobjects 
    WHERE  NAME = N'DPM_GDM_AUS_Postprocessing' AND TYPE = 'P')
    DROP PROCEDURE DPM_GDM_AUS_Postprocessing
GO

CREATE PROCEDURE DPM_GDM_AUS_Postprocessing
        @COUNTRY_CODE NVARCHAR(3),
        @COUNTRY_ID   BIGINT, 
        @ACTUAL_NAME       NVARCHAR(100),
        @ADMIN_NAMES_T     NVARCHAR(100),
        @ADMIN_RELATIONS_T NVARCHAR(100)
        
AS
    DECLARE @TEMP_AUS_LOWADMIN NVARCHAR(100),
            @TEMP_JOINED       NVARCHAR(100), 
            @EXCLUDE_FIELDS    NVARCHAR(1000),
            @LIST_FIELDS       NVARCHAR(MAX)
       
    SET @TEMP_AUS_LOWADMIN = 'DPM_TEMP_AUS_LOWADMIN'
    SET @TEMP_JOINED       = 'DPM_TEMP_AUS_JOINED'
    
    -- Remove temporary table for joined data 
    EXEC DPM_GDM_CheckExistsTable @TEMP_JOINED
    IF @@Error<>0 GOTO QuitWithText
    
    -- Drop temporary table with mixed SUBADMIN\LOCALITY if it is exists
    EXEC DPM_GDM_CheckExistsTable @TEMP_AUS_LOWADMIN
    IF @@Error<>0 GOTO QuitWithText                           
    
    -- Select data for Neghborhood zones into temporary table
    EXEC('SELECT AN.ADMIN_NAME    AS LocalityName_T,
                 AN.ADMIN_NAME_ID AS LocalityName_ID_T,
                 CASE
                    WHEN AN.IS_PRIMARY = 1 THEN ''L''
                    ELSE ''A''
                  END             AS LocalityNamePreferred_T,
                 AR.ADMIN_ID   AS ADMIN_ID_T 
            INTO ' + @TEMP_AUS_LOWADMIN + '  
          FROM ' + @ADMIN_RELATIONS_T + ' AR WITH(NOLOCK) LEFT JOIN 
               ' + @ADMIN_NAMES_T + '     AN WITH(NOLOCK) 
                    ON AR.NEIGHBORHOOD_ID = AN.ADMIN_NAME_ID
          WHERE AR.COUNTRY_ID = ' + @COUNTRY_ID)
    IF @@Error<>0 GOTO QuitWithText 

    -- Insert data for Subadmin zones into temporary table
    EXEC('INSERT INTO ' + @TEMP_AUS_LOWADMIN + ' 
                (LocalityName_T, 
                 LocalityName_ID_T, 
                 LocalityNamePreferred_T, 
                 ADMIN_ID_T)
          SELECT SubAdminArea ,
                 SubAdminArea_ID,
                 SubAdminAreaPreferred,
                 ADMIN_ID  
          FROM ' + @ACTUAL_NAME + ' WITH(NOLOCK) 
          WHERE SubAdminArea IS NOT NULL')
    IF @@Error<>0 GOTO QuitWithText
    
    -- Insert data for DepAdmin zones into temporary table
    EXEC('INSERT INTO ' + @TEMP_AUS_LOWADMIN + ' 
                (LocalityName_T,
                 LocalityName_ID_T,
                 LocalityNamePreferred_T,
                 ADMIN_ID_T)
          SELECT DependentAdminArea,
                 DependentAdminArea_ID,
                 DependentAdminAreaPreferred,
                 ADMIN_ID   
          FROM ' + @ACTUAL_NAME + ' WITH(NOLOCK) 
          WHERE SubAdminArea       IS NULL AND 
                DependentAdminArea IS NOT NULL')
    IF @@Error<>0 GOTO QuitWithText
    
    -- Remove duplicates from temporary table
    EXEC DPM_GDM_RemoveDuplicates @TEMP_AUS_LOWADMIN, 'LocalityName_ID_T, LocalityNamePreferred_T' 
    IF @@Error<>0 GOTO QuitWithText

    -- Remove all localities - NAME_ID is NULL in the Locality_Names for AUS country and all already added are wrong 
    EXEC(N'UPDATE ' + @ACTUAL_NAME + '  
            SET LocalityName          = NULL,
                LocalityName_ID       = NULL,
                LocalityNamePreferred = NULL')  
    
    -- Create list with neccesery fields
    SET @EXCLUDE_FIELDS = 'OBJECTID, SHAPE, LocalityName, LocalityName_ID, LocalityNamePreferred,                           
                           NeighborhoodZone, ZONE_ID'
    SET @LIST_FIELDS = ''
    EXEC DPM_GDM_CreateListFields @ACTUAL_NAME, @EXCLUDE_FIELDS, @LIST_FIELDS OUTPUT    
    IF @@Error<>0 GOTO QuitWithText
    
    -- Remove duplicates from PointAddress table
    EXEC DPM_GDM_RemoveDuplicates @ACTUAL_NAME, @EXCLUDE_FIELDS
    IF @@Error<>0 GOTO QuitWithText

    -- Insert mixed lowest zone records into PointAddress table
    EXEC(N'SELECT SHAPE, 
                  ' + @LIST_FIELDS + ', 
                  LA.LocalityName_T     AS LocalityName, 
                  LA.LocalityName_ID_T  AS LocalityName_ID, 
                  LocalityNamePreferred_T AS LocalityNamePreferred 
            INTO ' + @TEMP_JOINED + ' 
            FROM ' + @ACTUAL_NAME + '       EPA WITH(NOLOCK) LEFT JOIN 
                 ' + @TEMP_AUS_LOWADMIN + ' LA  WITH(NOLOCK) ON EPA.ADMIN_ID = LA.ADMIN_ID_T')                  
    IF @@Error<>0 GOTO QuitWithText
       
    EXEC('DROP TABLE ' + @TEMP_AUS_LOWADMIN)
    IF @@Error<>0 GOTO QuitWithText
      
    EXEC('DROP TABLE ' + @ACTUAL_NAME)
    IF @@Error<>0 GOTO QuitWithText
    
    EXEC sp_rename @TEMP_JOINED, @ACTUAL_NAME
    IF @@Error<>0 GOTO QuitWithText

    PRINT ''
    PRINT 'Procedure DPM_GDM_AUS_Postprocessing was well done:'
    PRINT 'Finish time: ' + CONVERT(VARCHAR(100), GETDATE())
    RETURN 0
    
    QuitWithText:
      RAISERROR('SCRIPT was terminated!', 16, 1)
      RETURN 1
GO

/**************************************************************************
    DPM_GDM_UpdateLocalityZone Procedure
**************************************************************************/
/*      Shifts admin zones for some countries.
    Inputs:
        @COUNTRY_CODE - Country Code.
    Output:
        PointAddress table will be updated. 
*/

IF EXISTS (SELECT NAME 
       FROM   sysobjects 
       WHERE  NAME = N'DPM_GDM_UpdateLocalityZone'
       AND    TYPE = 'P')
    DROP PROCEDURE DPM_GDM_UpdateLocalityZone
GO

CREATE PROCEDURE DPM_GDM_UpdateLocalityZone
            @COUNTRY_CODE      NVARCHAR(3),
            @TABLE_NAME        NVARCHAR(100),
            @ADMIN_RELATIONS_T NVARCHAR(100),
            @ADMIN_NAMES_T     NVARCHAR(100)

AS
    DECLARE @ADD_QUERY         NVARCHAR(100),
            @STR               NVARCHAR(MAX),
            @COUNT             INT
    
    -- Check if present one language for country
    SET @STR = 'SELECT @COUNT = COUNT(DISTINCT Adm_LanguageCode) FROM ' + @TABLE_NAME + ' WITH(NOLOCK)' 
    EXEC sp_executesql @STR, N'@COUNT INT OUT', @COUNT = @COUNT OUT
    IF @@Error<>0 GOTO QuitWithText

    IF @COUNT = 1
    SET @ADD_QUERY = 'AND AN.IS_PRIMARY = 1'
    ELSE
        SET @ADD_QUERY = ''
        
    -- Update Locality field with values from NEIGHBORHOOD 
    EXEC(N'UPDATE ' + @TABLE_NAME + '  
            SET LocalityName    = ADMIN_NAME,
                LocalityName_ID = ADMIN_NAME_ID,
                LocalityNamePreferred = CASE
                                            WHEN AN.IS_PRIMARY = 1 THEN ''Y''
                                            ELSE ''N''
                                        END  
            FROM ' + @TABLE_NAME + ' SA 
                JOIN ' + @ADMIN_RELATIONS_T + ' ARL  
                    ON SA.ADMIN_ID = ARL.ADMIN_ID 
                JOIN ' + @ADMIN_NAMES_T + ' AN 
                    ON ARL.NEIGHBORHOOD_ID = AN.ADMIN_NAME_ID AND
                       SA.Adm_LanguageCode = AN.LANGUAGE_CODE ' + @ADD_QUERY + '')
    IF @@Error<>0 GOTO QuitWithText
    
    -- Delete presented Locality in Zone
    EXEC('DELETE FROM ' + @TABLE_NAME + '  
            WHERE LocalityName = NeighborhoodZone AND
                  POINT_ADDRESS_ID IN (SELECT POINT_ADDRESS_ID FROM ' + @TABLE_NAME + ' GROUP BY POINT_ADDRESS_ID, LINK_ID, LanguageCode HAVING COUNT(*) > 1) AND 
                  ZONE_ID = LocalityName_ID')                
    IF @@Error<>0 GOTO QuitWithText
    
    -- Remove data from Zone if ZONE_ID is absent
    EXEC('UPDATE ' + @TABLE_NAME + '  
            SET NeighborhoodZone = NULL,
                ZONE_ID          = NULL 
            WHERE PLACE_ZONE_ID IS NULL')
    IF @@Error<>0 GOTO QuitWithText    

    -- Update CityPrefferered for no Zone
    IF @COUNTRY_CODE IN ('CAN', 'USA', 'GUM')
    BEGIN
        EXEC('UPDATE ' + @TABLE_NAME + '  
                SET CityPreferred  = ''Y''
                WHERE ZONE_ID IS NULL AND
                      City IS NOT NULL')
        IF @@Error<>0 GOTO QuitWithText
    END

    PRINT ''
    PRINT 'Procedure DPM_GDM_UpdateLocalityZone was well done:'
    PRINT 'Finish time: ' + CONVERT(VARCHAR(100), GETDATE())
    RETURN 0
        
    QuitWithText:
      RAISERROR('SCRIPT was terminated!', 16, 1)
      RETURN 1
GO

/***************************************************************************
    DPM_GDM_BRA_UpdatePostalCodes Procedure
**************************************************************************/
/*    Updates PostalCodeNumbers field for BRA, using postal extentions.
    Inputs:
        EsriPointAddress for modification.
    Output:
        EsriPointAddress will be updated.
    
*/    

IF EXISTS (SELECT NAME FROM sysobjects 
    WHERE  NAME = N'DPM_GDM_BRA_UpdatePostalCodes' AND TYPE = 'P')
    DROP PROCEDURE DPM_GDM_BRA_UpdatePostalCodes
GO

CREATE PROCEDURE DPM_GDM_BRA_UpdatePostalCodes
        @TABLE_NAME   NVARCHAR(100),
        @POSTAL_EXT_T NVARCHAR(100)
        
AS

    EXEC(N'UPDATE ' + @TABLE_NAME + '  
            SET PostalCodeNumber = CONCAT(PostalCodeNumber, ''-'', POSTAL_EXT)
            FROM ' + @TABLE_NAME + ' AP JOIN
                 ' + @POSTAL_EXT_T + ' PE
                 ON PE.POSTAL_CODE_ID = AP.PostalCode_ID AND
                    PE.POSTAL_EXT_ID  = AP.POSTAL_EXT_ID')
    IF @@Error<>0 GOTO QuitWithText

    PRINT ''
    PRINT 'Procedure DPM_GDM_BRA_UpdatePostalCodes was well done:'
    PRINT 'Finish time: ' + CONVERT(VARCHAR(100), GETDATE())
    RETURN 0
    
    QuitWithText:
      RAISERROR('SCRIPT was terminated!', 16, 1)
      RETURN 1
GO

/***************************************************************************
    DPM_GDM_CYM_UpdatePostalCodes Procedure
**************************************************************************/
/*    Updates Left\Right PostalCodeNumbers fields for CYM, excluding part after hyphen.
    Inputs:
        @COUNTRY_CODE - 3-letter country code.
    Output:
        EsriStreetAddress will be updated.
    
*/    

IF EXISTS (SELECT NAME FROM sysobjects 
    WHERE  NAME = N'DPM_GDM_CYM_UpdatePostalCodes' AND TYPE = 'P')
    DROP PROCEDURE DPM_GDM_CYM_UpdatePostalCodes
GO

CREATE PROCEDURE DPM_GDM_CYM_UpdatePostalCodes
                   @TABLE_NAME NVARCHAR(100)        
AS

    EXEC(N'UPDATE ' + @TABLE_NAME + '  
            SET PostalCodeNumber = SUBSTRING(PostalCodeNumber, 1, CHARINDEX(PostalCodeNumber, ''-''))')
    IF @@Error<>0 GOTO QuitWithText        

    PRINT ''
    PRINT 'Procedure DPM_GDM_CYM_UpdatePostalCodes was well done:'
    PRINT 'Finish time: ' + CONVERT(VARCHAR(100), GETDATE())
    RETURN 0
    
    QuitWithText:
      RAISERROR('SCRIPT was terminated!', 16, 1)
      RETURN 1
GO

/***************************************************************************
    DPM_GDM_CreateDuplicatesPostalCodes Procedure
**************************************************************************/
/*    Updates PostalCodeNumbers field, creating duplicates with and without leading letter.
    Inputs:
        @TABLE_NAME       - PointAddress table name
        @POSTAL_CODES     - Postal_Codes table name
        @POSTAL_RELATIONS - Postal_Relations table name
    Output:
        EsriPointAddress will be updated.    
*/    

IF EXISTS (SELECT NAME FROM sysobjects 
    WHERE  NAME = N'DPM_GDM_CreateDuplicatesPostalCodes' AND TYPE = 'P')
    DROP PROCEDURE DPM_GDM_CreateDuplicatesPostalCodes
GO

CREATE PROCEDURE DPM_GDM_CreateDuplicatesPostalCodes
                   @TABLE_NAME       NVARCHAR(100),
                   @POSTAL_CODES     NVARCHAR(100),
                   @POSTAL_RELATIONS NVARCHAR(100)        
AS
    DECLARE @TABLE_NAME_1 NVARCHAR(100)
    SET @TABLE_NAME_1 = @TABLE_NAME + '_TEMP'
    
    EXEC('ALTER TABLE ' + @TABLE_NAME + ' DROP COLUMN PostalCodeNumber')
    IF @@Error<>0 GOTO QuitWithText 

    EXEC('SELECT PA.*, PC.POSTAL_CODE AS PostalCodeNumber, PR.POSTAL_TYPE
            INTO ' + @TABLE_NAME_1 + ' 
            FROM ' + @TABLE_NAME + ' PA 
                LEFT JOIN ' + @POSTAL_RELATIONS + ' PR 
                    ON PA.POSTAL_ID = PR.POSTAL_ID 
                LEFT JOIN ' + @POSTAL_CODES + ' PC 
                    ON PR.POSTAL_CODE_ID = PC.POSTAL_CODE_ID 
            WHERE PR.POSTAL_TYPE IN (1, 2)')
    IF @@Error<>0 GOTO QuitWithText   
    
    EXEC('DROP TABLE ' + @TABLE_NAME) 
    IF @@Error<>0 GOTO QuitWithText
    
    EXEC sp_rename @TABLE_NAME_1, @TABLE_NAME
    IF @@Error<>0 GOTO QuitWithText

    PRINT ''
    PRINT 'Procedure DPM_GDM_CreateDuplicatesPostalCodes was well done:'
    PRINT 'Finish time: ' + CONVERT(VARCHAR(100), GETDATE())
    RETURN 0
    
    QuitWithText:
      RAISERROR('SCRIPT was terminated!', 16, 1)
      RETURN 1
GO

/**************************************************************************
    DPM_GDM_EsriPointAddress Procedure
**************************************************************************/
/*    Creates EsriPointAddress and EsriPointAddressPremiseName feature classes for reference data.
    Inputs:
        @COUNTRY_CODE      - Country Code.
        @PLACES_T          - Streets feature class name.
        @STREETS_NAMES_T   - Street_Names table name.
        @ADDRESSES_T       - Addresses table name.
        @ADMIN_RELATIONS_T - Admin_Relations table name.
        @ADMIN_NAMES_T     - Area_Names table name.
        @ZONE_NAMES_T      - Zone_Names table name.
        @POSTAL_CODES_T    - Postal_Codes table name.
        @POSTAL_RELATIONS_T- Postal_Relations table name.
        @POSTAL_CITIES_T   - Postal_Cities table name.
        @STREET_ZONES_T    - Street_Zones table name.
    Output:
        EsriPointAddress
        EsriPointAddressPremiseName
        
*/

IF EXISTS (SELECT NAME FROM sysobjects 
    WHERE  NAME = N'DPM_GDM_EsriPointAddress' AND TYPE = 'P')
    DROP PROCEDURE DPM_GDM_EsriPointAddress
GO

CREATE PROCEDURE DPM_GDM_EsriPointAddress
        @COUNTRY_CODE       NVARCHAR(3),
        @PLACES_T           NVARCHAR(100),
        @TABLE_NAME         NVARCHAR(100),        
        @STREETS_NAMES_T    NVARCHAR(100),
        @ADDRESSES_T        NVARCHAR(100),
        @ADMIN_RELATIONS_T  NVARCHAR(100),
        @ADMIN_NAMES_T      NVARCHAR(100),
        @ZONE_NAMES_T       NVARCHAR(100),
        @POSTAL_CODES_T     NVARCHAR(100),
        @POSTAL_RELATIONS_T NVARCHAR(100),
        @POSTAL_CITIES_T    NVARCHAR(100),
        @POSTAL_EXT_T       NVARCHAR(100),
        @COUNT_PART         NVARCHAR(3)
AS
    -- Declare users variable
    DECLARE @NUMBER_VERSION     TINYINT,
            @COUNTRY_ID         BIGINT,
            @LANGUAGE_CODE      NVARCHAR(3),
            @AREA_MAIN_NAMES_T  NVARCHAR(100),
            @TABLE_NAME_T       NVARCHAR(100),
            @TABLE_NAME_PREMISE NVARCHAR(100)

    -- Declare functions variable        
    DECLARE @SQLSTR             NVARCHAR(MAX),
            @PARAMETERS         NVARCHAR(MAX),
            @RET_CODE           TINYINT
                   
    SET @NUMBER_VERSION = 4
    SET @TABLE_NAME_T = @TABLE_NAME + '_temp'

    PRINT ''
    PRINT 'Start DPM_GDM_EsriPointAddress: ' + CONVERT(NVARCHAR(100), GETDATE())

    -- Find country attributes
    SET @SQLSTR = N'SELECT  @COUNTRY_ID    = COUNTRY_ID, 
                            @LANGUAGE_CODE = LANGUAGE_CODE
                    FROM ' + @ADMIN_NAMES_T + ' WITH(NOLOCK) 
                    WHERE   COUNTRY_CODE   = ''' + @COUNTRY_CODE + ''' AND 
                            IS_PRIMARY     = 1 AND
                            NAME_TYPE      = 1 AND
                            ADMIN_TYPE     = 1'
    SET @PARAMETERS = N'@COUNTRY_ID BIGINT OUTPUT, @LANGUAGE_CODE NVARCHAR(3) OUTPUT'
    EXEC sp_executesql @SQLSTR, @PARAMETERS, @COUNTRY_ID = @COUNTRY_ID OUTPUT, @LANGUAGE_CODE = @LANGUAGE_CODE OUTPUT
    IF @@Error<>0 GOTO QuitWithText

    -- Find main names for transliteration
    SET @AREA_MAIN_NAMES_T = 'DPM_TEMP_AREA'
    EXEC DPM_GDM_CheckExistsTable @AREA_MAIN_NAMES_T 
    IF @@Error<>0 GOTO QuitWithText
            
    IF @@Error<>0 GOTO QuitWithText
    SET @SQLSTR = N'SELECT * INTO ' + @AREA_MAIN_NAMES_T + ' 
            FROM  ' + @ADMIN_NAMES_T + ' WITH(NOLOCK) 
            WHERE NAME_ID IN 
                (SELECT NAME_ID FROM ' + @ADMIN_NAMES_T + ' WITH(NOLOCK) 
                 WHERE COUNTRY_ID    = ' + CAST(@COUNTRY_ID as NVARCHAR(19)) + ' AND 
                       LANGUAGE_CODE = ''' + @LANGUAGE_CODE + ''' AND
                       IS_PRIMARY    = 1 AND
                       NAME_TYPE     = 1)'
    EXEC(@SQLSTR)                   
    IF @@Error<>0 GOTO QuitWithText

    -- Create indexes
    EXEC DPM_FGDB_CreateIndex @AREA_MAIN_NAMES_T, 'ADMIN_NAME_ID', ''
    IF @@Error<>0 GOTO QuitWithText
    EXEC DPM_FGDB_CreateIndex @ADMIN_NAMES_T, 'ADMIN_NAME_ID', 'LANGUAGE_CODE, ADMIN_NAME, NAME_TYPE'
    IF @@Error<>0 GOTO QuitWithText
    EXEC DPM_FGDB_CreateIndex @POSTAL_RELATIONS_T, 'POSTAL_ID', ''
    IF @@Error<>0 GOTO QuitWithText
    EXEC DPM_FGDB_CreateIndex @POSTAL_CODES_T, 'POSTAL_CODE_ID', ''
    IF @@Error<>0 GOTO QuitWithText
    EXEC DPM_FGDB_CreateIndex @POSTAL_CITIES_T, 'POSTAL_CITY_ID', ''
    IF @@Error<>0 GOTO QuitWithText    

    -- Selection base table
    EXEC @RET_CODE = DPM_GDM_MainSelect @COUNTRY_CODE, @PLACES_T, @TABLE_NAME, @STREETS_NAMES_T, @ADDRESSES_T, @ADMIN_RELATIONS_T, @AREA_MAIN_NAMES_T, @POSTAL_CODES_T, 
                                        @POSTAL_RELATIONS_T, @POSTAL_CITIES_T, @ZONE_NAMES_T, @NUMBER_VERSION, @COUNTRY_ID, @LANGUAGE_CODE
    IF   @RET_CODE <> 0 GOTO QuitWithText

    -- Updating admin fields with not transliterated language
    EXEC @RET_CODE = DPM_GDM_UpdateAdminWithoutMainNAME_ID  @COUNTRY_CODE, @COUNTRY_ID, @TABLE_NAME, @ADMIN_RELATIONS_T, @ADMIN_NAMES_T, @PLACES_T, @ZONE_NAMES_T
    IF   @RET_CODE <> 0 GOTO QuitWithText

    -- Updating records with transliterated languages
    EXEC @RET_CODE = DPM_GDM_CountryLanguageMix @COUNTRY_CODE, @LANGUAGE_CODE, @TABLE_NAME, @PLACES_T, @ADMIN_RELATIONS_T, @AREA_MAIN_NAMES_T, @ZONE_NAMES_T, @COUNTRY_ID
    IF   @RET_CODE <> 0 GOTO QuitWithText

    -- Mix admin zone languages for empty admin names
    EXEC @RET_CODE = DPM_GDM_MixingEmptyAdmins @TABLE_NAME, @ADMIN_NAMES_T
    IF @RET_CODE<>0 GOTO QuitWithText

    -- Updating Neighborhood zone - mix Zones, Metro and Neighborhood values
    EXEC @RET_CODE = DPM_GDM_UpdateNeighborhoodField @COUNTRY_CODE, @TABLE_NAME, @POSTAL_CITIES_T
    IF   @RET_CODE <> 0 GOTO QuitWithText

    -- Adding additional fields for DNK, NZL, SWE, CAN, USA, GUM
    EXEC @RET_CODE = DPM_GDM_PointAddressPostproc @COUNTRY_CODE, @TABLE_NAME_T, @POSTAL_CODES_T, @POSTAL_CITIES_T, @AREA_MAIN_NAMES_T, @PLACES_T, @ADMIN_RELATIONS_T, @ADMIN_NAMES_T
    IF   @RET_CODE <> 0 GOTO QuitWithText

    -- Drop temporary tables with main admin name IDs
    EXEC('DROP TABLE ' + @AREA_MAIN_NAMES_T)
    IF @@Error<>0 GOTO QuitWithText

    -- Specific logic for AUS
    IF @COUNTRY_CODE = 'AUS'
    BEGIN
        EXEC @RET_CODE = DPM_GDM_AUS_Postprocessing @COUNTRY_CODE, @COUNTRY_ID, @TABLE_NAME_T, @ADMIN_NAMES_T, @ADMIN_RELATIONS_T 
        IF   @RET_CODE <> 0 GOTO QuitWithText
    END

    -- Shift admin zones for some countries
    EXEC @RET_CODE = DPM_GDM_ShiftAdminZonesTable @TABLE_NAME_T
    IF   @RET_CODE <> 0 GOTO QuitWithText  

    -- Updating Locality and Neiborhood mixed values 
    IF @COUNTRY_CODE IN ('BGD', 'BRN', 'GUM', 'HKG', 'KHM', 'LKA', 'MAC', 'MDV', 'MNG', 'NPL', 
                         'PHL', 'VNM', 'ALB', 'AND', 'AZE', 'BIH', 'BLR', 'BSB', 'CUN', 'CYP', 
                         'ESP', 'FRO', 'GEO', 'GIB', 'GGY', 'IMN', 'IRL', 'ISL', 'JEY', 'KAZ', 
                         'KGZ', 'KOS', 'LIE', 'LUX', 'MDA', 'MKD', 'MLT', 'MNE', 'NCY', 'ROU', 
                         'SMR', 'SRB', 'UKR', 'UZB', 'VAT', 'AGO', 'BDI', 'BEN', 'BFA', 'BHR', 
                         'BWA', 'CAF', 'CIV', 'CMR', 'COG', 'COM', 'CPV', 'DJI', 'ERI', 'ETH', 
                         'GAB', 'GHA', 'GIN', 'GMB', 'GNB', 'GNQ', 'IRQ', 'ISR', 'JOR', 'KEN', 
                         'KWT', 'LBN', 'LBR', 'LBY', 'LSO', 'MAR', 'MDG', 'MLI', 'MOZ', 'MRT', 
                         'MUS', 'MWI', 'MYT', 'NAM', 'NER', 'NGA', 'OMN', 'PSE', 'QAT', 'REU', 
                         'RWA', 'SAU', 'SEN', 'SHN', 'SLE', 'SOM', 'STP', 'SWZ', 'SYC', 'TCD', 
                         'TGO', 'TUN', 'TZA', 'UGA', 'ZMB', 'ZWE', 'BHS', 'BLZ', 'BMU', 'ASM', 
                         'FJI', 'MNP', 'CRI', 'CUB', 'CYM', 'DOM', 'GTM', 'HND', 'JAM', 'NIC', 
                         'PAN', 'PRI', 'SLV', 'TCA', 'VGB', 'ABW', 'ATG', 'BLM', 'BOL', 
                         'BRB', 'ECU', 'FLK', 'GLP', 'GUF', 'GUY', 'KNA', 'MTQ', 'PER', 'PRY', 
                         'SGS', 'SUR', 'TTO', 'URY', 'VCT', 'EGY')
    BEGIN
        EXEC @RET_CODE = DPM_GDM_UpdateLocalityZone @COUNTRY_CODE, @TABLE_NAME_T, @ADMIN_RELATIONS_T, @ADMIN_NAMES_T 
        IF   @RET_CODE <> 0 GOTO QuitWithText
    END

    -- Adding Admin abbrevations
    EXEC @RET_CODE = DPM_GDM_AdminAbbrevation @TABLE_NAME_T, @ADMIN_NAMES_T, @COUNTRY_CODE
    IF   @RET_CODE <> 0 GOTO QuitWithText

    IF @COUNTRY_CODE = 'ARE'
    BEGIN
        EXEC(N'UPDATE ' + @TABLE_NAME_T + ' SET CountryName = ''United Arab Emirates'' WHERE LanguageCode = ''ENG''')
        IF @@Error<>0 GOTO QuitWithText
    END

    IF @COUNTRY_CODE = 'BRA'
    BEGIN
        EXEC @RET_CODE = DPM_GDM_BRA_UpdatePostalCodes @TABLE_NAME_T, @POSTAL_EXT_T
        IF   @RET_CODE <> 0 GOTO QuitWithText
    END

    IF @COUNTRY_CODE = 'CYM'
    BEGIN
        EXEC @RET_CODE = DPM_GDM_CYM_UpdatePostalCodes @TABLE_NAME_T
        IF   @RET_CODE <> 0 GOTO QuitWithText
    END

    IF @COUNTRY_CODE = 'ARG'
    BEGIN
        EXEC @RET_CODE = DPM_GDM_CreateDuplicatesPostalCodes @TABLE_NAME_T, @POSTAL_CODES_T, @POSTAL_RELATIONS_T
        IF   @RET_CODE <> 0 GOTO QuitWithText
    END
    
    -- Remove duplicates from PointAddress    
    EXEC DPM_GDM_RemoveDuplicates @TABLE_NAME_T, 'Shape, OBJECTID'
    IF @@Error<>0 GOTO QuitWithText

    EXEC DPM_GDM_CheckExistsTable @TABLE_NAME
    IF @@Error<>0 GOTO QuitWithText

    SET @TABLE_NAME_PREMISE = SUBSTRING(@TABLE_NAME, 1, LEN(@TABLE_NAME) - LEN(@COUNT_PART)) + 'PremiseName' + @COUNT_PART

    EXEC DPM_GDM_CheckExistsTable @TABLE_NAME_PREMISE
    IF @@Error<>0 GOTO QuitWithText

    -- Selection EsriPointAddress
    -- AND OBJECT_TYPE = 5 - NEW IN GDM 
    EXEC(N'SELECT * INTO ' + @TABLE_NAME + ' FROM ' + @TABLE_NAME_T + ' WITH(NOLOCK) WHERE (PremiseName Like '''') OR (PremiseName IS NULL)')
    IF @@Error<>0 GOTO QuitWithText

    -- Selection EsriPointAddressPremiseName 
    -- PremiseName <> '''' AND OBJECT_TYPE = 2 - NEW IN GDM: DATA HAS OBJECT_TYPE = 5, NOT 2. 
    EXEC(N'SELECT * INTO ' + @TABLE_NAME_PREMISE + ' FROM ' + @TABLE_NAME_T + ' WITH(NOLOCK) WHERE (PremiseName Not Like '''') AND (PremiseName IS NOT NULL)') 
    IF @@Error<>0 GOTO QuitWithText

        EXEC('DROP TABLE ' + @TABLE_NAME_T)
    IF @@Error<>0 GOTO QuitWithText

    DECLARE @COUNT BIGINT

    --Drop EsriPointAddress feature class if it is empty
        SET @SQLSTR = N'SELECT @COUNT = COUNT(*) FROM ' + @TABLE_NAME
    SET @PARAMETERS = N'@COUNT BIGINT OUTPUT'
    EXEC sp_executesql @SQLSTR, @PARAMETERS, @COUNT = @COUNT OUTPUT
    IF @@Error<>0 GOTO QuitWithText

    IF @COUNT = 0
    BEGIN
            EXEC('DROP TABLE ' + @TABLE_NAME)
        IF @@Error<>0 GOTO QuitWithText
    END

    --Drop EsriPointAddressPremiseName feature class if it is empty
        SET @SQLSTR = N'SELECT @COUNT = COUNT(*) FROM ' + @TABLE_NAME_PREMISE
    SET @PARAMETERS = N'@COUNT BIGINT OUTPUT'
    EXEC sp_executesql @SQLSTR, @PARAMETERS, @COUNT = @COUNT OUTPUT
    IF @@Error<>0 GOTO QuitWithText

    IF @COUNT = 0
    BEGIN
            EXEC('DROP TABLE ' + @TABLE_NAME_PREMISE)
        IF @@Error<>0 GOTO QuitWithText
    END

    /* SQL script was finished/terminated */
    PRINT ''
    PRINT 'Script was well done:'
    PRINT 'Finish script time: ' + convert(varchar(100), getdate())
    RETURN 0
        
    QuitWithText:
      RAISERROR('SCRIPT was terminated!', 16, 1)
      RETURN 1
GO
    
/*************************************************************************
    DPM_GDM_SelectAction Procedure
**************************************************************************/
/*    Selects action to do: 
      if USA - split and processing by parts, 
      else - run processing as is.
    Inputs:
        @COUNTRY_CODE      - Country Code.
        @PLACES_T          - Streets feature class name.
        @STREETS_NAMES_T   - Street_Names table name.
        @ADDRESSES_T       - Addresses table name.
        @ADMIN_RELATIONS_T - Admin_Relations table name.
        @ADMIN_NAMES_T     - Area_Names table name.
        @ZONE_NAMES_T      - Zone_Names table name.
        @POSTAL_CODES_T    - Postal_Codes table name.
        @POSTAL_RELATIONS_T- Postal_Relations table name.
        @POSTAL_CITIES_T   - Postal_Cities table name.
        @STREET_ZONES_T    - Street_Zones table name.
    Output:
        EsriStreetAddress
        
*/

IF EXISTS (SELECT NAME FROM sysobjects 
    WHERE  NAME = N'DPM_GDM_SelectAction' AND TYPE = 'P')
    DROP PROCEDURE DPM_GDM_SelectAction
GO

CREATE PROCEDURE DPM_GDM_SelectAction
        @COUNTRY_CODE       NVARCHAR(3),
        @PLACES_T           NVARCHAR(100),
        @STREETS_NAMES_T    NVARCHAR(100),
        @ADDRESSES_T        NVARCHAR(100),
        @ADMIN_RELATIONS_T  NVARCHAR(100),
        @ADMIN_NAMES_T      NVARCHAR(100),
        @ZONE_NAMES_T       NVARCHAR(100),
        @POSTAL_CODES_T     NVARCHAR(100),
        @POSTAL_RELATIONS_T NVARCHAR(100),
        @POSTAL_CITIES_T    NVARCHAR(100),
        @POSTAL_EXT_T       NVARCHAR(100)

AS
    PRINT ''
    PRINT 'Script was started:'
    PRINT CONVERT(NVARCHAR(100), GETDATE())
    
    -- Declare functions variable        
    DECLARE @SQLSTR             NVARCHAR(MAX),
            @PARAMETERS         NVARCHAR(MAX),
            @RET_CODE           TINYINT,
            @COUNT_PART         NVARCHAR(3), 
            @TABLE_NAME         NVARCHAR(100),
            @TABLE_NAME_PREMISE NVARCHAR(100)
    
    SET @TABLE_NAME         = @COUNTRY_CODE + '_EsriPointAddress'
    SET @TABLE_NAME_PREMISE = @COUNTRY_CODE + '_EsriPointAddressPremiseName'
    SET @COUNT_PART         = ''
    
    -- Processing for USA  
    IF @COUNTRY_CODE IN ('USA', 'AUS')
    BEGIN
        DECLARE @COUNT_PARTS    INT,
                @CURRENT_PART   INT,                
                @TABLE_NAME_SUF NVARCHAR(100),
                @PLACES_PART    NVARCHAR(100)

        -- Drop indexes within full Places table for quickest splitting
        EXEC DPM_FGDB_DropIndex @PLACES_T, 'ADDRESS_ID'
        IF @@Error<>0 GOTO QuitWithText
        
        EXEC DPM_FGDB_DropIndex @PLACES_T, 'OBJECT_TYPE'
        IF @@Error<>0 GOTO QuitWithText
        
        -- Split Streets by parts
        EXEC @COUNT_PARTS = DPM_GDM_SplitByParts @PLACES_T
        IF @COUNT_PARTS = 0 GOTO QuitWithText
        
        SET @CURRENT_PART = 1       
        
        -- Processing every part of Streets separatly
        WHILE @CURRENT_PART <= @COUNT_PARTS
        BEGIN
            SET @COUNT_PART     = CAST(@CURRENT_PART AS NVARCHAR(3))
            
            PRINT '-----------------------------------------------'
            PRINT 'Processed part: ' + @COUNT_PART
            PRINT '-----------------------------------------------'
                
            SET @TABLE_NAME_SUF = @TABLE_NAME + CAST(@CURRENT_PART AS NVARCHAR(3))
            SET @PLACES_PART    = @PLACES_T   + CAST(@CURRENT_PART AS NVARCHAR(3))
            
            EXEC DPM_FGDB_CreateIndex @PLACES_PART, 'ADDRESS_ID', ''
            IF @@Error<>0 GOTO QuitWithText
            
            EXEC DPM_FGDB_CreateIndex @PLACES_PART, 'OBJECT_TYPE', ''
            IF @@Error<>0 GOTO QuitWithText
            
            -- Processing EsriStreetAddress
            EXEC @RET_CODE = DPM_GDM_EsriPointAddress @COUNTRY_CODE, @PLACES_PART, @TABLE_NAME_SUF, @STREETS_NAMES_T, @ADDRESSES_T, @ADMIN_RELATIONS_T, @ADMIN_NAMES_T, @ZONE_NAMES_T, @POSTAL_CODES_T,
                                                    @POSTAL_RELATIONS_T, @POSTAL_CITIES_T, @POSTAL_EXT_T, @COUNT_PART
            IF   @RET_CODE <> 0 GOTO QuitWithText
            
            -- Remove splited Streets' part            
            EXEC('DROP TABLE ' + @PLACES_PART)
            IF @@Error<>0 GOTO QuitWithText
            
            SET @CURRENT_PART = 1 + @CURRENT_PART
        END
        
        -- Merge all parts of PointAddress to one finishing feature class
        EXEC @RET_CODE = DPM_GDM_MergeParts @TABLE_NAME, @COUNT_PARTS
        IF   @RET_CODE <> 0 GOTO QuitWithText
        
        -- Merge all parts of PointAddressPremiseNames to one finishing feature class
        EXEC @RET_CODE = DPM_GDM_MergeParts @TABLE_NAME_PREMISE, @COUNT_PARTS
        IF   @RET_CODE <> 0 GOTO QuitWithText                             
    END
    
    -- Processing for other countries
    ELSE
    BEGIN                         
        EXEC @RET_CODE = DPM_GDM_EsriPointAddress @COUNTRY_CODE, @PLACES_T, @TABLE_NAME, @STREETS_NAMES_T, @ADDRESSES_T, @ADMIN_RELATIONS_T, @ADMIN_NAMES_T, @ZONE_NAMES_T, @POSTAL_CODES_T,
                                                @POSTAL_RELATIONS_T, @POSTAL_CITIES_T, @POSTAL_EXT_T, @COUNT_PART    
        IF   @RET_CODE <> 0 GOTO QuitWithText 
    END

    /* SQL script was finished/terminated */
    PRINT ''
    PRINT 'Script was well done:'
    PRINT 'Finish script time: ' + convert(varchar(100), getdate())
    RETURN 0
        
    QuitWithText:
      RAISERROR('SCRIPT was terminated!', 16, 1)
      RETURN 1
GO
    
/* end of declaration DPM_GDM_EsriPointAddress_temp procedure */

/********************************************************************
    DPM_GDM_SelectAction
     - $(CountryCode)        - Code of processing country  
     - $(PlacesTable)        - Name of Places table
     - $(StreetNamesTable)   - Name of Street_Names table
     - $(AddressesTable)     - Name of Addresses table
     - $(AdminRelationsTable)- Name of Admin_Relations table
     - $(AdminNamesTable)    - Name of Admin_Names table
     - $(ZoneNamesTable)     - Name of Zone_Names table
     - $(PostalCodesTable)   - Name of Postal_Codes table
     - $(PostalRelationsTable)- Name of Postal_Relations table
     - $(PostalCitiesTable)  - Name of Postal_Cities table

    @ret_code = 0    - Script was finished successfully
    @ret_code = 1    - Script was terminated with errors

********************************************************************/

DECLARE @ret_code int
EXECUTE @ret_code = DPM_GDM_SelectAction $(CountryCode), $(PlacesTable), $(StreetNamesTable), $(AddressRangesTable), $(AdminRelationsTable), $(AdminNamesTable), 
                    $(ZoneNamesTable), $(PostalCodesTable), $(PostalRelationsTable), $(PostalCitiesTable), $(PostalExtTable)
:EXIT(SELECT @ret_code)
GO

--EXEC DPM_GDM_SelectAction 'AUT', 'Places', 'Street_Names', 'Addresses', 'Admin_Relations', 'Admin_Names', 'Zone_Names', 
--'Postal_Codes', 'Postal_Relations', 'Postal_Cities', 'Postal_Ext'
--GO

--EXEC DPM_GDM_SelectAction 'ARE', 'T_Places', 'T_Street_Names', 'T_Addresses', 'T_Admin_Relations', 'T_Admin_Names', 'T_Zone_Names', 'T_Postal_Codes', 
--                            'T_Postal_Relations', 'T_Postal_Cities', 'T_Postal_Ext'
--GO
