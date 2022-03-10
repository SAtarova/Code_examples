# Import system modules
import sys
import time
import os
import hashlib
import arcpy
import helpers

def GetHashByGeometry(objGeometry, nCoordinatePrecision, bPointsSorting = False):
    """ Sorts geometry by X, then by Y if it is neccessary.
        Make hash from coordinate string: 'X,Y;X1,Y1;...'.
        Output is string with hex digits of coordinate string.
        Code: SK
        Args:
            objGeometry              - geometry object
            nCoordinatePrecision     - precision for X, Y coordinate values
            bPointsSorting           - True if need to sort coordinames, othewise - False
        Return:
            sCoordinatesHash - coordinate hash
        Raises:
            1. Exception when some error occurred
    """
    try:
        listCoordinates  = []
        sCoordinatesHash = ''

        # Read every part of the feature
        for objFeaturePart in objGeometry:

            # Read every each vertex in the part
            for objVertex in objFeaturePart:

                # This object is Point
                if objVertex:
                    nX = round(objVertex.X, nCoordinatePrecision)
                    nY = round(objVertex.Y, nCoordinatePrecision)
                    listCoordinates.append([nX, nY])

        # Sort found coordinates
        if bPointsSorting:
            listCoordinates = sorted(listCoordinates, key = lambda x: (x[0], -x[1]))

        # Concatenate list of lists to string
        sCoordinates = ';'.join([','.join(map(str, listXY)) for listXY in listCoordinates])

        # Create hash for current string of coordinates
        sCoordinatesHash = hashlib.sha512(sCoordinates).hexdigest()

    except:
        helpers.PrintError("Some error occurred in GetHashByGeometry function") # Exception
        helpers.RaiseExitException() # Exception

    return sCoordinatesHash

#------------------------------------------------------------------- 

def CalculateGeomHash(sInputFC, sIDFieldName, sPathToOutputGeomDuplicates, sExpression = '', nCoordinatePrecision = 7, bPointsSorting = False):
    """ Calculates hashs for all geometry objects in the feature class.
        Geometry duplicates will be selected into separate gdb if they will be found in the feature class.
        Code: SK
        Args:
            sInputFC                            - path to feature class
            sIDFieldName                        - unique identificator field name in the feature class            
            sPathToOutputGeomDuplicates         - path to selected features for geometrical duplicates
            sExpression                         - expression to filter neccessary records from input feature class to calculate hashes
            nCoordinatePrecision                - precision of coordinates (how many digits need to use after point to match geometry)
            bPointsSorting                      - True if need to sort coordinames, othewise - False            
        Return:
            dictInputHashs - dictionary with {Coordinate hash: [unique identificator,
                                                                list of unique identificators for same geometry,
                                                                list of unique identificators for same jeometry in joined feature class,
                                                                matched geometry number]}
        Raises:
            1. Exception when some error occurred
    """
    try:
        dictInputHashs           = {}
        bIsPresentGeomDuplicates = False

        # Open cursor to read geometry
        objSearchCursor = arcpy.da.SearchCursor(sInputFC, ["SHAPE@", sIDFieldName]) # Exception
        
        # Read every record
        for tupleRow in objSearchCursor:

            # Get hash from geometry
            sCoordinatesHash = GetHashByGeometry(tupleRow[0], nCoordinatePrecision, bPointsSorting) # Exception            

            # Check ID value for duplicate          
            if sCoordinatesHash in dictInputHashs:
                dictInputHashs[sCoordinatesHash][1].append(tupleRow[1])
                bIsPresentGeomDuplicates = True

            # Add hash and ID values into dictionary 
            else:
                dictInputHashs[sCoordinatesHash]    = [0, [], [], 0]
                dictInputHashs[sCoordinatesHash][0] = tupleRow[1]            

        del tupleRow, objSearchCursor

        # Select geometry duplicates into separate gdb
        if bIsPresentGeomDuplicates:
            helpers.CreateFileGDB(os.path.dirname(sPathToOutputGeomDuplicates), os.path.basename(sPathToOutputGeomDuplicates)) # Exception

            # Define ID field type
            listFieldType = [objField.type for objField in arcpy.ListFields(sInputFC) if objField.name == sIDFieldName]

            # Get duplicate IDs
            listID = ''
            for sGeomHash in dictInputHashs:
                listID += dictInputHashs[sGeomHash][0]
                for sDuplID in dictInputHashs[sGeomHash][1]:
                    listID += sDuplID

            # Select duplicate features
            sResultFCName = 'conflict_join_IDs'
            helpers.CopyFCToGDB(sInputFC, sPathToOutputGeomDuplicates, sResultFCName, sIDFieldName + " IN ('" + "','".join(listID) + "')") # Exception                

    except:
        helpers.PrintError("Some error occurred in CalculateGeomHash function") # Exception
        helpers.RaiseExitException() # Exception

    finally:
        if 'objSearchCursor' in locals(): del objSearchCursor

    return dictInputHashs

#-------------------------------------------------------------------    

def MatchDataByGeomHash(sSourceFC, sJoinFC, sSourceIDFieldName, sJoinedIDFieldName, sSourceExpression = '', sJoinedExpression = '', nCoordinatePrecision = 7, bPointsSorting  = False):
    """ Adds unique identificator into source feature class from joined feature class to link these two geometry.
        Uses matched geometry for links.
        Code: SK
        Args:
            sSourceFC                - source feature class
            sJoinFC                  - joined feature class
            sSourceIDFieldName       - unique identificator field name in the source feature class
            sJoinedIDFieldName       - unique identificator field name in the joined feature class
            sSourceExpression        - expression to use only neccessary records from source layer to matching
            sJoinedExpression        - expression to use only neccessary records from joined layer to matching
            nCoordinatePrecision     - precision of coordinates (how many digits need to use after point to match geometry)
            bPointsSorting           - True if need to sort coordinames, othewise - False
        Raises:
            1. Exception when some error occurred
    """
    try:
        objBuildTime = time.time()    

        # Check input parameters
        helpers.CheckInputParameters(sSourceFC, 'arcpyExists') # Exception
        helpers.CheckInputParameters(sJoinFC,   'arcpyExists') # Exception

        # Check inputs are feature classes
        sSourceType = arcpy.Describe(sSourceFC).dataType
        if sSourceType != 'FeatureClass':
            helpers.PrintError("Source " + sSourceFC + " is not a feature class") # Exception
            helpers.RaiseExitException() # Exception
        sJoinedType = arcpy.Describe(sJoinFC).dataType
        if sJoinedType != 'FeatureClass':
            helpers.PrintError("Source " + sJoinFC + " is not a feature class") # Exception
            helpers.RaiseExitException() # Exception

        # Check input fields are present
        objJoinedFields = arcpy.ListFields(sJoinFC, sJoinedIDFieldName)
        if len(objJoinedFields) == 0:
            helpers.PrintError("Field " + sJoinedIDFieldName + " is absent in joined feature class") # Exception
            helpers.RaiseExitException() # Exception
        objSourceFields = arcpy.ListFields(sSourceFC, sSourceIDFieldName)        
        if len(objSourceFields) == 0:
            helpers.PrintError("Field " + sSourceIDFieldName + " is absent in joined feature class") # Exception
            helpers.RaiseExitException() # Exception

        helpers.PrintMessage('Calculate geometry hash for joined feature class')

        # Create empty additional fgdb with results of analysis
        sResultGDBPath = sSourceFC.split('.gdb')[0] + '_analysis.gdb'
        helpers.CreateFileGDB(os.path.dirname(sResultGDBPath), os.path.basename(sResultGDBPath)) # Exception
        
        # Calculate geometry hash for joined feature class
        dictJoinedHashs = CalculateGeomHash(sJoinFC, sJoinedIDFieldName, sResultGDBPath, sJoinedExpression, nCoordinatePrecision, bPointsSorting) # Exception        

        # Add ID joined field into source feature class
        listJoinedFields     = [(objField.name, objField.type, objField.precision, objField.scale, objField.length, objField.isNullable) for objField in objJoinedFields]
        listJoinedFields     = [sFieldComp for tupleJoinField in listJoinedFields for sFieldComp in tupleJoinField]
        listJoinedFields[-1] = True # Fix isNullable property for shp format
        listFieldToAdd       =  [','.join(map(str, listJoinedFields))]
        helpers.HelpersClass.AddFieldToTable(sSourceFC, [','.join(map(str, listJoinedFields))]) # Exception

        dictSourceUnmatchedHashs = {}

        helpers.PrintMessage('Open cursor to read source geometry')        

        # Open cursor to read source geometry
        objUpdateCursor = arcpy.da.UpdateCursor(sSourceFC, ["SHAPE@", sSourceIDFieldName, sJoinedIDFieldName], sSourceExpression) # Exception
        
        # Read every record
        for tupleRow in objUpdateCursor:            

            # Get hash from geometry
            sSourceCoordinatesHash = GetHashByGeometry(tupleRow[0], nCoordinatePrecision, bPointsSorting) # Exception

            # Geometries are matched
            if sSourceCoordinatesHash in dictJoinedHashs:
                dictJoinedHashs[sSourceCoordinatesHash][2].append(str(tupleRow[1]))
                dictJoinedHashs[sSourceCoordinatesHash][3] += 1
                tupleRow[2] = dictJoinedHashs[sSourceCoordinatesHash][0]
                objUpdateCursor.updateRow(tupleRow) # Exception

            # Unmatched geometry was found
            else:
                dictSourceUnmatchedHashs[str(tupleRow[1])] = sSourceCoordinatesHash            

        del tupleRow, objUpdateCursor

        helpers.PrintMessage('Select data for analysis')
        helpers.PrintMessage('Total count of not mapped geometry: ' + str(len(dictSourceUnmatchedHashs)))

        # Select data for analysis from intersected dictionary
        for sJoinedHash in dictJoinedHashs:
            listConflictSourceID       = [sID for sJoinedHash in dictJoinedHashs for sID in dictJoinedHashs[sJoinedHash][2] if dictJoinedHashs[sJoinedHash][3] > 1]
            listUnmatchedJoinedID      = [sID for sJoinedHash in dictJoinedHashs for sID in dictJoinedHashs[sJoinedHash][1] if dictJoinedHashs[sJoinedHash][3] == 0]
            listConflictSourceJoinedID = [sID for sJoinedHash in dictJoinedHashs for sID in dictJoinedHashs[sJoinedHash][2] if dictJoinedHashs[sJoinedHash][3] == 1 and len(dictJoinedHashs[sJoinedHash][1]) > 0]

            # Converasion IDs to string 
            listConflictSourceID       = '\',\''.join(map(str, listConflictSourceID))
            listConflictSourceJoinedID = '\',\''.join(map(str, listConflictSourceJoinedID))
            listUnmatchedJoinedID      = '\',\''.join(map(str, listUnmatchedJoinedID))
            
            # Select source conflict data into separate feature class            
            if listConflictSourceID:
                sResultFCName = 'conflict_source_IDs'
                helpers.CopyFCToGDB(sSourceFC, sResultGDBPath, sResultFCName, sSourceIDFieldName + ' IN (\'' + listConflictSourceID + '\')') # Exception

            # Select joined unmatched data into separate feature class
            if listUnmatchedJoinedID:
                sResultFCName = 'unmatched_join_IDs'
                helpers.CopyFCToGDB(sJoinFC, sResultGDBPath, sResultFCName, sJoinedIDFieldName + ' IN (\'' + listUnmatchedJoinedID + '\')') # Exception

            # Select matched data with duplicates in joined feature class
            if listConflictSourceJoinedID:
                sResultFCName = 'conflict_source_join_IDs'
                helpers.CopyFCToGDB(sSourceFC, sResultGDBPath, sResultFCName, sSourceIDFieldName + ' IN (\'' + listConflictSourceJoinedID + '\')') # Exception            

        # Select source unmatched data into separate feature class
        sResultFCName = 'unmatched_source_IDs'
        if dictSourceUnmatchedHashs:
            helpers.CopyFCToGDB(sSourceFC, sResultGDBPath, sResultFCName, sSourceIDFieldName + ' IN (\'' + '\',\''.join([sSourceID for sSourceID in dictSourceUnmatchedHashs]) + '\')') # Exception

        objBuildTime = time.time() - objBuildTime
        helpers.PrintMessage("\t\t=== Execution time " + helpers.FormatTimeString(objBuildTime) + " ===")
        
    except:
        helpers.PrintError("Some error occurred in MatchDataByGeomHash function") # Exception
        helpers.RaiseExitException() # Exception

    finally:
        if 'objUpdateCursor' in locals(): del objUpdateCursor

#-------------------------------------------------------------------     
