# Import python modules
import os
import sys
import arcpy
import subprocess

# Import Softech modules
import helpers
import model_parameters
import input_parameters

# All constant structures of data to collect SQL database statistic
sTABLEQUERY = '''SELECT TABLE_NAME,
                            COLUMN_NAME,
                            DATA_TYPE,
                            CASE
                                    WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL
                                            THEN CHARACTER_MAXIMUM_LENGTH
                                    WHEN NUMERIC_PRECISION IS NOT NULL
                                            THEN NUMERIC_PRECISION
                            END,
                            NUMERIC_SCALE,
                            IS_NULLABLE,
                            COLUMN_DEFAULT
                    FROM INFORMATION_SCHEMA.COLUMNS
                    ORDER BY TABLE_NAME'''

sINDEXQUERY = '''SELECT TBL.NAME,
                            COL_NAME(IC.OBJECT_ID, IC.COLUMN_ID),
                            I.NAME,
                            I.TYPE_DESC,
                            I.IS_UNIQUE,
                            I.IS_PRIMARY_KEY,
                            IC.KEY_ORDINAL,
                            IC.IS_INCLUDED_COLUMN
                    FROM sys.tables AS TBL
                            INNER JOIN sys.indexes I
                                    ON (I.INDEX_ID > 0 AND I.is_hypothetical = 0) AND (I.object_id = TBL.object_id)
                            INNER JOIN sys.index_columns IC
                                    ON I.OBJECT_ID = IC.OBJECT_ID AND
                                       I.INDEX_ID  = IC.INDEX_ID
                    WHERE I.OBJECT_ID = OBJECT_ID(TBL.NAME) AND I.NAME IS NOT NULL
                    ORDER BY TBL.NAME, COL_NAME(IC.OBJECT_ID, IC.COLUMN_ID), I.NAME'''

sCONSTRAINTQUERY = '''SELECT TC.TABLE_NAME,
                             COLUMN_NAME,
                             TC.CONSTRAINT_NAME,
                             CONSTRAINT_TYPE
                        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE CU
                                ON TC.CONSTRAINT_NAME = CU.CONSTRAINT_NAME
                        ORDER BY TC.TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME'''

dictSQLSCHEMA  =   {'regression_db_structure':   [['TableName,TEXT,,,128,NULLABLE',
                                                   'Fld_Column_Name,TEXT,,,128,NULLABLE',
                                                   'Fld_Data_Type,TEXT,,,128,NULLABLE',
                                                   'Fld_Len,LONG,,,,NULLABLE',
                                                   'Fld_Num_Scale,LONG,,,,NULLABLE',
                                                   'Fld_IsNull,TEXT,,,3,NULLABLE',
                                                   'Fld_Column_Defaults,TEXT,,,4000,NULLABLE'], sTABLEQUERY],
                     'regression_db_indexes':    [['TableName,TEXT,,,128,NULLABLE',
                                                   'Fld_Column_Name,TEXT,,,128,NULLABLE',
                                                   'Idx_Name,TEXT,,,128,NULLABLE',
                                                   'Idx_Type,TEXT,,,60,NULLABLE',
                                                   'Idx_is_unique,SHORT,,,,NULLABLE',
                                                   'Idx_is_primary_key,SHORT,,,,NULLABLE',
                                                   'Key_Ordinal,LONG,,,,NULLABLE',
                                                   'Fld_Is_Included,SHORT,,,,NULLABLE'], sINDEXQUERY],
                     'regression_db_constraints':[['TableName,TEXT,,,128,NULLABLE',
                                                   'Fld_Column_Name,TEXT,,,128,NULLABLE',
                                                   'Cnstr_Name,TEXT,,,128,NULLABLE',
                                                   'Cnstr_Type,TEXT,,,11,NULLABLE'], sCONSTRAINTQUERY]}
            
class clsSQLDatabase():
    """ Creates object of SQL database with defined name as class' parameter.
        And makes ArcGIS connection to the SQL database.
        The SQL database and its ArcGIS connection is live as long as 'del' command don't run for this object instance.
        ArcGIS connection is live as long as 'del' command or DetachDatabase() method don't run for this object instance.
        
        The object has next methods to work with the SQL database:
            DetachDatabase()
            ExecuteSQLQuery(sInSQLExpression)
            GetDatabaseSize()
            GetDatabaseStrucure()
            GetLogSize()
            ShrinkDatabase()
            ShrinkLog()
            
        And it has some hidden methods:
            _clsSQLDatabase__AttachDatabase()
            _clsSQLDatabase__CreateSQLDatabase()
            _clsSQLDatabase__CreateSqlConnection()
            _clsSQLDatabase__DropDatabase()
            _clsSQLDatabase__IsDatabaseExist()
            _clsSQLDatabase__RemoveSqlConnection()
            _clsSQLDatabase__WorkWithSqlDatabase()
    """
    def __init__(self, sServerName, sDatabaseName, sSqlDataFilePath = '', sSqlLogFilePath = '', nInitialDatabaseSize = 0):
        """ Initialize common class parameters.
            Creates new empty database or attaches existing database.
            Connections entry objects to existing database.
            Args:
                Required parameters:
                    sServerName   - name of SQL server ('sql-server1', 'Index', ect.) .
                    sDatabaseName - name of database on the server ('HERE2018Q3_OneGDM', ect.).
                    
                Optional parameters which necessary for a database creation and attaching:
                    sSqlDataFilePath     - path to .mdf file (to attach database) or to folder where it will be (to create database).
                    sSqlLogFilePath      - path to .ldf file (to attach database) or to folder where it will be (to create database).
                    nInitialDatabaseSize - initial size of a database in Gb. It's necessary for database creation.
            Raises:
                Some error occurred.
        """
        try:
            # Check server and database name are not empty
            helpers.CheckInputParameters(sServerName,   'isNotEmptStr') # Exception
            helpers.CheckInputParameters(sDatabaseName, 'isNotEmptStr') # Exception
            
            # Save server and database name names
            self.sServerName   = sServerName
            self.sDatabaseName = sDatabaseName

            # Check server exists
            if subprocess.call("ping " + self.sServerName + " -n 1", shell = True) != 0:
                helpers.PrintError('Server with defined name has been not found in the local network.') # Exception
                helpers.RaiseExitException() # Exception
            
            VendorParams = model_parameters.VendorModelParameters

            # Common parameters
            self.sLogFolderPath       = VendorParams.FolderSettings.sLogFolderPath
            self.sTemporaryFolderPath = VendorParams.FolderSettings.sTemporaryFolderPath
            self.sSQLCMDUtilityPath   = VendorParams.InputParameters.sSQLCMDUtilityPath
            self.sLOGFileExtension    = VendorParams.sLOGFileExtension
            self.dictSQLSchema        = dictSQLSCHEMA

            # ArcGIS parameters
            self.sArcGisConnectionFolder = VendorParams.sArcGisConnectionFolder
            self.sSDEConnExtension       = VendorParams.sSDEConnExtension

            # Constants
            self.sConnInstance = "SQL_SERVER"            # Database type
            self.sAuthType     = "OPERATING_SYSTEM_AUTH" # Authorization mode

            # Create or attach a database if one isn't exists
            if not self.__IsDatabaseExist():
                
                # Check data and log database file\folder are not empty
                helpers.PrintWarning('%s database is not exist. Paths to SQL database and log database files(to attach detached database)\\folders(to create new database) \
must be present in the clsSQLDatabase object creation (third and fourth parameters).' % self.sDatabaseName)
                helpers.CheckInputParameters(sSqlDataFilePath,'isNotEmptStr') # Exception
                helpers.CheckInputParameters(sSqlLogFilePath, 'isNotEmptStr') # Exception

                # Save data and log database file\folder
                self.sSqlDataFilePath = sSqlDataFilePath
                self.sSqlLogFilePath  = sSqlLogFilePath
                self.sMDFFileExtension = VendorParams.sMDFFileExtension
                self.sLDFFileExtension = VendorParams.sLDFFileExtension

                # Attach database if data and log database files are exists and have necessary extension
                if (os.path.isfile(self.sSqlDataFilePath) and os.path.isfile(self.sSqlLogFilePath) and
                    os.path.splitext(self.sSqlDataFilePath)[-1] == self.sMDFFileExtension and os.path.splitext(self.sSqlLogFilePath)[-1] == self.sLDFFileExtension):
                    self.__AttachDatabase()   # Exception

                # Create database if data and log folders for new database are exists
                else:            
                    self.nInitialDatabaseSize = nInitialDatabaseSize
                    self.__InitialCreateDatabase() # Exception

            # Define connection name and connection path          
            self.sConnFileName           = self.sDatabaseName + self.sSDEConnExtension  # Output sde connection file name
            self.sSdeConnectionFilePath  = os.path.join(self.sArcGisConnectionFolder, self.sConnFileName) 
                            
            # Create ArcGIS connection to the database. Existing connection with same name will be removed.         
            self.__CreateSqlConnection() # Exception

            helpers.PrintMessage('SQL database object was initialized:')
            helpers.PrintMessage('\tServer     name - ' + self.sServerName)
            helpers.PrintMessage('\tDatabase   name - ' + self.sDatabaseName)
            helpers.PrintMessage('\tConnection name - ' + self.sSdeConnectionFilePath)

        except:
            tb = sys.exc_info()[2]
            print('Line ' + str(tb.tb_lineno))
            print(str(sys.exc_info()[:2]))
            helpers.PrintError("Some error occurred with initialization sql database") # Exception
            helpers.RaiseExitException() # Exception
    #-------------------------------------------------------------------
    
    def __DeleteDatabase(self):
        """ Removes sql database and connection to one with object deletion.
            Raises:
                1. Error with connection removing
                2. Error with database removing
                3. Error with SQLCMD utility
        """
        try:                        
            # Remove existing connection
            if arcpy.Exists(self.sSdeConnectionFilePath):
                self.__RemoveSqlConnection() # Exception

            # Remove sql database
            if self.__IsDatabaseExist(): # Exception
                self.__DropDatabase() # Exception

        except:
            tb = sys.exc_info()[2]
            print('Line ' + str(tb.tb_lineno))
            print(str(sys.exc_info()[:2]))
            helpers.PrintError("Some error occurred with database object removing") # Exception
            helpers.RaiseExitException() # Exception
    #-------------------------------------------------------------------
    def __InitialCreateDatabase(self):
        """ Creates database if it is not exist when class is initial.
            Raises:
                1. Error execution of database creation
                2. Fifth parameter in the clsSQLDatabase object is not present
                3. Paths to data and log file are not present
        """
        try:
            if os.path.isdir(self.sSqlDataFilePath) and os.path.isdir(self.sSqlLogFilePath):                    

                # Initial size of database should be required parameter for database creation
                if self.nInitialDatabaseSize > 0:
                    self.__CreateSQLDatabase() # Exception

                else:
                    helpers.PrintError('Initial size of the database is necessary to create database (fifth parameter in the clsSQLDatabase object).') # Exception
                    helpers.RaiseExitException() # Exception
            else:
                helpers.PrintError('Incorrect input parameters. Please, take care third and fourth class\' parameters must be \
any existing folders to create a database \
or paths to the existing mdf/ldf files to attach them on MS SQL server.') # Exception
                helpers.RaiseExitException() # Exception

        except:
            tb = sys.exc_info()[2]
            print('Line ' + str(tb.tb_lineno))
            print(str(sys.exc_info()[:2]))
            helpers.PrintError("Some error occurred database creation") # Exception
            helpers.RaiseExitException() # Exception
    #-------------------------------------------------------------------

    def ExecuteSQLQuery(self, sInSQLExpression):
        """ Executes sql query in the SQL database.
            Args:
                sInSQLExpression - sql query need to execute
            Raises:
                1. Error execution of sql query
                2. Error in ArcSDESQLExecute method
        """
        try:
            # Connect to a database
            classSDEConnection = arcpy.ArcSDESQLExecute(self.sSdeConnectionFilePath) # Exception

            # Execute query
            Result = classSDEConnection.execute(sInSQLExpression) # Exception

        except:
            tb = sys.exc_info()[2]
            print('Line ' + str(tb.tb_lineno))
            print(str(sys.exc_info()[:2]))
            helpers.PrintError("Some error occurred in CreateSQLDatabase") # Exception
            helpers.RaiseExitException() # Exception

        return Result
    #-------------------------------------------------------------------

    def GetDatabaseStrucure(self, sOutputGDBFile):
        """ Selects table, indexes, constraint structures and places them within gdb table.
            Args:
                 - Path to output GDB where artifacts with statistics should be stored
            Raises:
                1. Error execution of sql query
                2. Error working ArcGIS tools
                3. Insert cursor error
        """
        try:
            # Select table, indexes, constraint structures           
            for sStatistic in dictSQLSCHEMA:                

                # Get SQL structure
                listTableStructures  = self.ExecuteSQLQuery(dictSQLSCHEMA[sStatistic][1]) # Exception
                
                # Create empty gdb with results of testing if it's not exist.
                if not helpers.HelpersClass.IsLayerExists(sOutputGDBFile):
                    helpers.CreateFileGDB(os.path.dirname(sOutputGDBFile), os.path.basename(sOutputGDBFile))

                # Prepare output table
                sPathToTableStatistics = os.path.join(sOutputGDBFile, sStatistic)
                helpers.DeleteItem(sPathToTableStatistics) # Exception   
                helpers.CreateTable(sOutputGDBFile, sStatistic)      # Exception       
                helpers.HelpersClass.AddFieldToTable(sPathToTableStatistics, dictSQLSCHEMA[sStatistic][0]) # Exception
                cursorTableStatistics = arcpy.da.InsertCursor(sPathToTableStatistics, [sField.split(',')[0] for sField in dictSQLSCHEMA[sStatistic][0]]) # Exception

                if type(listTableStructures) is list:
                    
                    # Place output result into output table
                    for listTableStructure in listTableStructures:

                        # Replace NULL values to 0
                        nIndex = 0
                        for Value in listTableStructure:
                            if Value is None:
                                listTableStructure[nIndex] = 0
                            nIndex += 1
                                
                        tupleToInsert = tuple(listTableStructure)                    
                        cursorTableStatistics.insertRow(tupleToInsert) # Exception

                del cursorTableStatistics

            helpers.PrintMessage('\tDatabase structure information from %s was collected.' % (self.sDatabaseName))

        except:
            tb = sys.exc_info()[2]
            print('Line ' + str(tb.tb_lineno))
            print(str(sys.exc_info()[:2]))
            helpers.PrintError("Some error occurred in CreateSQLDatabase") # Exception
            helpers.RaiseExitException() # Exception

        finally:
            if 'cursorTableStatistics' in dir():
                del cursorTableStatistics
    #-------------------------------------------------------------------

    def __CreateSQLDatabase(self):
        """ Creates SQL database with initial name when any class instance is created and the database with this name is absent.            
            Raises:
                1. Error execution of command sting
        """
        try:
            # Get sql script parameters
            sCreateDatabaseSQLScriptPath          = os.path.normpath(model_parameters.VendorModelParameters.NTSQLScripts.sCreateDatabaseSQLScriptPath)
            listCreateDatabaseSQLScriptParameters = model_parameters.VendorModelParameters.NTSQLScripts.listCreateDatabaseSQLScriptParameters
            sSQLScriptLogFile                     = os.path.join(self.sLogFolderPath, os.path.basename(sCreateDatabaseSQLScriptPath) + self.sLOGFileExtension)
            listCreateDatabaseSQLParameterValues  = [os.path.normpath(self.sSqlDataFilePath), os.path.normpath(self.sSqlLogFilePath), self.sDatabaseName, str(self.nInitialDatabaseSize)]

            # Form command line to run
            sCommandString = "call \"" + self.sSQLCMDUtilityPath + "\" -S " + self.sServerName + " -d master -v "

            for sCreateDatabaseSQLScriptParameter in listCreateDatabaseSQLScriptParameters:
                sCommandString += sCreateDatabaseSQLScriptParameter+ "=\"'" + listCreateDatabaseSQLParameterValues[listCreateDatabaseSQLScriptParameters.index(sCreateDatabaseSQLScriptParameter)] + "'\" "

            sCommandString += "-i \"" + sCreateDatabaseSQLScriptPath + "\" -o \"" + sSQLScriptLogFile + "\" -b"

            # Run sql script to create new database
            nRectCode = subprocess.call(sCommandString, shell = True) # Exception

            if nRectCode <> 0:
                helpers.PrintError('Database can\'t be created. See %s for more information.' % sSQLScriptLogFile)
                helpers.RaiseExitException() # Exception

        except:
            tb = sys.exc_info()[2]
            print('Line ' + str(tb.tb_lineno))
            print(str(sys.exc_info()[:2]))
            helpers.PrintError("Some error occurred in CreateSQLDatabase") # Exception
            helpers.RaiseExitException() # Exception
    #-------------------------------------------------------------------

    def __CreateSqlConnection(self):
        """ Function to create connection file to SQL SERVER.
            The connection will has same name as input parameter - sDatabaseName.

            Return:
                ArcGIS connection name to the database
            Raises:
                1. Connection can't be removed
                2. Connection can't be created
                3. Connection created with errors
        """
        try:
            # Remove existing connection
            if arcpy.Exists(self.sSdeConnectionFilePath):
                self.__RemoveSqlConnection()  # Exception

            # Create connection file
            arcpy.CreateDatabaseConnection_management(self.sArcGisConnectionFolder,
                                                      self.sConnFileName,
                                                      self.sConnInstance,
                                                      self.sServerName,
                                                      self.sAuthType,
                                                      database=self.sDatabaseName)  # Exception

            # Check connection serviceability
            objDesc = arcpy.Describe(self.sSdeConnectionFilePath) # Exception

            # Try to get connection properties
            try:
                objConnectionProperties = objDesc.connectionProperties

            # AttributeError if input parameter isn't exists
            except AttributeError:
                helpers.PrintError("Input Connection was not created.") # Exception
                helpers.RaiseExitException() # Exception

            helpers.PrintMessage('ArcGIS "%s" connection was created.' % (self.sSdeConnectionFilePath))

        except:
            tb = sys.exc_info()[2]
            print('Line ' + str(tb.tb_lineno))
            print(str(sys.exc_info()[:2]))
            helpers.PrintError("Some error occurred in __CreateSqlConnection") # Exception
            helpers.RaiseExitException() # Exception
    #-------------------------------------------------------------------

    def __RemoveSqlConnection(self):
        """ Removes existing connection to sql database
            Raises:
                1. Remove connection file from ArcGIS environment folder
        """
        try:
            arcpy.env.workspace = self.sSdeConnectionFilePath
            try:
                # Connection could not be deleted: ArcGIS issue - http://support.esri.com/en/bugs/nimbus/TklNMTAxMjIw
                arcpy.Delete_management(self.sSdeConnectionFilePath) # Exception

            except:
                # Get path to folder with applications settings
                sCurrentApplFolder       = os.environ.data['APPDATA']

                # Get path to ArcGIS version
                dictArcGisInstallInfo    = helpers.HelpersClass.GetArcGISVersion() # Exception
                sVersionArcGis           = str(dictArcGisInstallInfo['BaseVersion'])

                # Make path to connection file to remove
                sDatabaseConnectionPath  = os.path.join(sCurrentApplFolder, r'ESRI\Desktop' + sVersionArcGis + r'\ArcCatalog', self.sConnFileName)

                # Remove existing connection
                os.remove(sDatabaseConnectionPath) # Exception
                helpers.PrintMessage('Existing ArcGIS "%s" connection was closed.' % (self.sSdeConnectionFilePath))

        except:
            helpers.PrintError("Some error occurred in __RemoveSqlConnection") # Exception
            helpers.RaiseExitException() # Exception
    #-------------------------------------------------------------------

    def __AttachDatabase(self):
        """ Attaches existing .mdf and .ldf files to MS SQL.
            Raises:
                some error occurred in the __WorkWithSqlDatabase function
        """
        try:
            # Form strings
            sAction = "CREATE DATABASE    " + self.sDatabaseName + " ON \
                            ( FILENAME = '" + self.sSqlDataFilePath + "' ), \
                            ( FILENAME = '" + self.sSqlLogFilePath + "' ) \
                           FOR ATTACH\n"
            sScriptName = 'AttachDatabase'

            # Run execution
            self.__WorkWithSqlDatabase(sAction, sScriptName) # Exception
            helpers.PrintMessage('%s database was attached successfully.' % self.sDatabaseName)

        except:
            tb = sys.exc_info()[2]
            print('Line ' + str(tb.tb_lineno))
            print(str(sys.exc_info()[:2]))
            helpers.PrintError("Some error occurred in AttachDatabase") # Exception
            helpers.RaiseExitException() # Exception
    #-------------------------------------------------------------------

    def DetachDatabase(self) :
        """ Detaches the database from MS SQL.
            Raises:
                1. Error in input parameters
                2. Some error occurred
        """
        try:
            # Form strings
            sAction     = "ALTER DATABASE " + self.sDatabaseName + " \
                           SET SINGLE_USER WITH ROLLBACK IMMEDIATE\n \
                           EXEC master.dbo.sp_detach_db @dbname = N'" + self.sDatabaseName + "'\n"
            sScriptName = 'DetachDatabase'

            # Run execution
            self.__WorkWithSqlDatabase(sAction, sScriptName) # Exception
            helpers.PrintMessage('%s database was detached from %s.' % (self.sDatabaseName, self.sServerName))

            # Remove connect to the detached database
            if arcpy.Exists(self.sSdeConnectionFilePath):
                self.__RemoveSqlConnection()

        except:
            tb = sys.exc_info()[2]
            print('Line ' + str(tb.tb_lineno))
            print(str(sys.exc_info()[:2]))
            helpers.PrintError("Some error occurred in DetachDatabase") # Exception
            helpers.RaiseExitException() # Exception
    #-------------------------------------------------------------------

    def __DropDatabase(self) :
        """ Removes the database (.mdf and .ldf files).
            Raises:
                1. Error in input parameters
                2. Some error occurred
        """
        try:
            # Form strings
            sAction     = "ALTER DATABASE " + self.sDatabaseName + " SET SINGLE_USER WITH ROLLBACK IMMEDIATE\nDROP DATABASE " + self.sDatabaseName + "\n"
            sScriptName = 'DropDatabase'

            # Run execution
            self.__WorkWithSqlDatabase(sAction, sScriptName) # Exception
            helpers.PrintMessage('%s database was removed.' % self.sDatabaseName)

        except:
            tb = sys.exc_info()[2]
            print('Line ' + str(tb.tb_lineno))
            print(str(sys.exc_info()[:2]))
            helpers.PrintError("Some error occurred in DropDatabase") # Exception
            helpers.RaiseExitException() # Exception
    #-------------------------------------------------------------------

    def GetDatabaseSize(self) :
        """ Returns size of the database (.mdf file).
            Returns:
                nSizeOfDatabase - Size of database in Gb.
            Raises:
                1. Error in input parameters
                2. Some error occurred
        """
        try:
            # Form strings
            sAction     = "SELECT size * 8 / 1024 / 1024 FROM sys.master_files WHERE name = N'" + self.sDatabaseName + "' AND type = 0\n"
            sScriptName = 'GetDatabaseSize'

            # Run execution
            nSizeOfDatabase = self.__WorkWithSqlDatabase(sAction, sScriptName) # Exception
            helpers.PrintMessage('%s database size is %s Gb' % (self.sDatabaseName, nSizeOfDatabase))

        except:
            tb = sys.exc_info()[2]
            print('Line ' + str(tb.tb_lineno))
            print(str(sys.exc_info()[:2]))
            helpers.PrintError("Some error occurred in GetDatabaseSize.") # Exception
            helpers.RaiseExitException() # Exception

        return nSizeOfDatabase
    #-------------------------------------------------------------------

    def GetLogSize(self) :
        """ Returns log file size of the database (.ldf file).
            Returns:
                nSizeOfLog    - Size of log file of the database in Gb.
            Raises:
                1. Error in input parameters
                2. Some error occurred
        """
        try:
            # Form strings
            sAction     = "SELECT m.size * 8 / 1024 / 1024 FROM sys.master_files m JOIN sys.databases d ON d.database_id = m.database_id WHERE d.name = N'" + self.sDatabaseName + "' AND m.type = 1\n"
            sScriptName = 'GetLogSize'

            # Run execution
            nSizeOfLog = self.__WorkWithSqlDatabase(sAction, sScriptName) # Exception
            helpers.PrintMessage('%s database log is %s Gb.' % (self.sDatabaseName, nSizeOfLog))

        except:
            tb = sys.exc_info()[2]
            print('Line ' + str(tb.tb_lineno))
            print(str(sys.exc_info()[:2]))
            helpers.PrintError("Some error occurred in GetLogSize") # Exception
            helpers.RaiseExitException() # Exception

        return nSizeOfLog
    #-------------------------------------------------------------------

    def ShrinkDatabase(self) :
        """ Shrinks the database to reduce its size.
            Raises:
                1. Error in input parameters
                2. Some error occurred
        """
        try:
            # Form strings
            sAction     = "DBCC SHRINKDATABASE(N'" + self.sDatabaseName + "')\n"
            sScriptName = 'ShrinkDatabase'

            # Run execution
            self.__WorkWithSqlDatabase(sAction, sScriptName) # Exception
            helpers.PrintMessage('%s database was shrinked successfully.' % self.sDatabaseName)

        except:
            tb = sys.exc_info()[2]
            print('Line ' + str(tb.tb_lineno))
            print(str(sys.exc_info()[:2]))
            helpers.PrintError("Some error occurred in ShrinkDatabase") # Exception
            helpers.RaiseExitException() # Exception
    #-------------------------------------------------------------------

    def ShrinkLog(self) :
        """ Shrinks log file of the database to reduce its size.
            Raises:
                1. Error in input parameters
                2. Some error occurred
        """
        try:
            # Form strings
            sAction     = "USE " + self.sDatabaseName + "\nDBCC SHRINKFILE (N'" + self.sDatabaseName + "_log' , 0, TRUNCATEONLY)\n"
            sScriptName = 'ShrinkLog'

            # Run execution
            self.__WorkWithSqlDatabase(sAction, sScriptName) # Exception
            helpers.PrintMessage('Log of %s database was shrinked successfully.' % self.sDatabaseName)

        except:
            tb = sys.exc_info()[2]
            print('Line ' + str(tb.tb_lineno))
            print(str(sys.exc_info()[:2]))
            helpers.PrintError("Some error occurred in ShrinkLog") # Exception
            helpers.RaiseExitException() # Exception
    #-------------------------------------------------------------------

    def __IsDatabaseExist(self) :
        """ Checks presence of database on server.
            Returns:
                sIsExist - will be 1 if database is existed and 0 otherwise.
            Raises:
                1. Error in input parameters
                2. Some error occurred
        """
        try:
            # Form strings
            sAction     = "SELECT name FROM sys.databases WHERE name = N'" + self.sDatabaseName + "'"
            sScriptName = '__IsDatabaseExist'

            # Run execution
            sIsExist = self.__WorkWithSqlDatabase(sAction, sScriptName) # Exception
            helpers.PrintMessage('Is %s database exist on %s? : %s' % (self.sDatabaseName, self.sServerName, 'Yes' if sIsExist == 1 else 'No'))

        except:
            tb = sys.exc_info()[2]
            print('Line ' + str(tb.tb_lineno))
            print(str(sys.exc_info()[:2]))
            helpers.PrintError("Some error occurred in __IsDatabaseExist") # Exception
            helpers.RaiseExitException() # Exception

        return sIsExist
    #-------------------------------------------------------------------


    def __WorkWithSqlDatabase(self, sAction, sWhatShouldDo):
        """ Works with SQL database according action as input parameter.
            The method uses SQLCMD utility to run queries to database.
            ArcGIS connection isn't necessary for it.
            Args:
                sAction                      - sql query to execute
                sWhatShouldDo                - what action should execute with database or connection
            Returns:
                nSizeValue    - Size of database or log file of the database in Gb.
                                Actually for 'GetDatabaseSize', 'GetLogSize' and '__IsDatabaseExist' actions only.
                                Will be 0 for all other actions.
                                Will be 1 for '__IsDatabaseExist' if database is existed.
            Raises:
                1. Some error occurred
        """
        try:
            # Create temporary sql script
            sTmpSQLScriptName = os.path.join(os.path.normpath(self.sTemporaryFolderPath), 'Temp' + sWhatShouldDo + 'SqlDatabase.sql')
            OutFile           = open(sTmpSQLScriptName, 'w') # Exception
            nSizeValue        = 0

            # Write sql begin section
            sSqlCommands = helpers.GenerateSqlSection(1)
            OutFile.write(sSqlCommands) # Exception

            # Write sql check section
            sSqlCommands = helpers.GenerateSqlSection(2)
            OutFile.write(sSqlCommands) # Exception

            # Write action
            OutFile.write(sAction) # Exception

            # Write sql check section
            sSqlCommands = helpers.GenerateSqlSection(2)
            OutFile.write(sSqlCommands) # Exception

            # Write sql end section
            sSqlCommands = helpers.GenerateSqlSection(3)
            OutFile.write(sSqlCommands) # Exception

            OutFile.close() # Exception

            # Form command line to run
            sSQLScriptLogFile = os.path.join(self.sLogFolderPath, os.path.basename(sTmpSQLScriptName) + self.sLOGFileExtension)
            sCommandString    = "call \"" + self.sSQLCMDUtilityPath + "\" -S " + self.sServerName + " -d master -i \"" + os.path.normpath(sTmpSQLScriptName) + "\" -o \"" + sSQLScriptLogFile + "\" -b"

            # Run sql script
            nRectCode = subprocess.call(sCommandString, shell = True) # Exception

            if nRectCode <> 0:
                helpers.PrintError('Action can\'t be execution for database. See %s for more information.' % sSQLScriptLogFile)
                helpers.RaiseExitException() # Exception

            # Get size of database or log file
            if sWhatShouldDo in ['GetDatabaseSize', 'GetLogSize', '__IsDatabaseExist']:
                objTempStorage = open(sSQLScriptLogFile, 'r')
                nCount = 0

                # Read log file
                for sLine in objTempStorage:
                    nCount += 1
                    sLine = sLine[:-1].replace(' ', '' )

                    # Read third line to get size of database or log file
                    if nCount == 3:

                        # If third string is empty - the database is not found in sys.master_files
                        if sLine == '' and sWhatShouldDo != '__IsDatabaseExist':
                            helpers.PrintError('Database %s is not exists on the %s' % (self.sDatabaseName, self.sServerName)) # Exception
                            helpers.RaiseExitException() # Exception

                        # Value of size is found
                        else:
                            try:
                                nSizeValue = int(sLine)

                            # Set return code to 1 if database is exist for __IsDatabaseExist action
                            except ValueError:
                                if sLine != '':
                                    nSizeValue = 1
                            break
                objTempStorage.close()

        except:
            tb = sys.exc_info()[2]
            print('Line ' + str(tb.tb_lineno))
            print(str(sys.exc_info()[:2]))
            helpers.PrintError("Some error occurred in __WorkWithSqlDatabase") # Exception
            helpers.RaiseExitException() # Exception

        return nSizeValue