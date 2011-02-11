//
//  Cacher.m
//  GeoTrash
//
//  Created by Patrick Russell on 18/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Cacher.h"

static sqlite3 *database = nil;

@implementation Cacher

@synthesize locCache, delegate;


-(void)starter{
	
	databaseName = @"AnimalDatabase.sql";
	
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
	
	// Execute the "checkAndCreateDatabase" function
	[self checkAndCreateDatabase];
	
	// Query the database for all animal records and construct the "animals" array
	[self locationsArray];
	
	
}



-(void)checkAndCreateDatabase{
	
	 // Check to see if the database is already loaded to phone
	
	BOOL success;
	
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Check if the database has already been created in the users filesystem
	success = [fileManager fileExistsAtPath:databasePath];
	
	// If the database already exists then return without doing anything
	if(success) return;
	
	// If not then proceed to copy the database from the application to the users filesystem
	
	// Get the path to the database in the application package
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	
	// Copy the database from the package to the users filesystem
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
	
	[fileManager release];
	

}
	
-(void)buildDatabaseFromRemoteData{
	
		
		//sqlite3 *database;
		locCache = [[NSMutableArray alloc] init];
		
	    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	    NSString *documentsDir = [documentPaths objectAtIndex:0];
	    databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
	
		NSURL *url = [NSURL URLWithString:@"http://www.skynet.ie/~paruss/iPhone/getLocations.php"];
		ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
		[request setDelegate:self];
		[request setDidFinishSelector:@selector(requestFinished:)];
		[request startAsynchronous];	
		
	}
	
	- (void)requestFinished:(ASIHTTPRequest *)request
	{
		
		databaseName = @"LocCache.sql";
		
	    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	    NSString *documentsDir = [documentPaths objectAtIndex:0];
		databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
		// Use when fetching text data
		NSString *responseString = [request responseString];
		NSLog(@"Response: %@", responseString);
		NSArray *chunks = [responseString componentsSeparatedByString: @" "];
	    int count = [chunks count];
		
		
		while (count >= 0)
		{
			int i = 0;
			
	        int ID = [[chunks objectAtIndex:i] intValue];
			NSString *ts = [chunks objectAtIndex:i + 1];
			NSString *lat = [chunks objectAtIndex:i + 2];
			NSString *lon = [chunks objectAtIndex:i +  3];
			
			if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
				// Setup the SQL Statement and compile it for faster access
				//sqlite3_bind_text(database, 1, [ts UTF8String], -1, SQLITE_TRANSIENT)
				
				NSString *sqlStatement = [NSString stringWithFormat:@"insert into cache(id, timestamp, latitude, longitude, image) VALUES ('%i', '%d', '%d', '%d', 'a')", ID, ts, lat, lon];
				const char *cSqlStatement = [sqlStatement cStringUsingEncoding:NSASCIIStringEncoding]; 
				sqlite3_stmt *compiledStatement;
				if(sqlite3_prepare_v2(database, cSqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
					// Loop through the results and add them to the feeds array
					while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
						// Read the data from the result row
					}
				

				}
				
				else {
					NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
				}
				// Release the compiled statement from memory
				sqlite3_finalize(compiledStatement);
				
			}
			
			sqlite3_close(database);
			i++;
			count--;
			
		}
		
	}

	- (void)locationsArray
	{
	
		// Setup the database objectfile://localhost/Users/patrickrussell/Downloads/SQLiteTutorial%202/AnimalDatabase.sql
		sqlite3 *database;
		
		// Init the animals Array
		//animals = [[NSMutableArray alloc] init];
		// Open the database from the users filessytem
		if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
			// Setup the SQL Statement and compile it for faster access
			const char *sqlStatement = "select * from animals";
			sqlite3_stmt *compiledStatement;
			if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
				// Loop through the results and add them to the feeds array
				while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
					// Read the data from the result row
					NSString *aName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
					NSString *aDescription = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
					NSString *aImageUrl = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
					
					// Create a new animal object with the data from the database
				//	Animal *animal = [[Animal alloc] initWithName:aName description:aDescription url:aImageUrl];
					
					// Add the animal object to the animals Array
				//	[animals addObject:animal];
					
				//	[animal release];
				}
			}
			
			else {
				
				NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
			}

		
			
			// Release the compiled statement from memory
			sqlite3_finalize(compiledStatement);
			
		}
		sqlite3_close(database);
		
			
	}


		
		/*
		// Setup the database object
		databaseName = @"LocCache.sql";
	    	
		NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDir = [documentPaths objectAtIndex:0];
		// Init the animals Array
		locCache = [[NSMutableArray alloc] init];
		databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
		// Open the database from the users filessytem
		if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
			// Setup the SQL Statement and compile it for faster access
			const char *sqlStatement = "select * from customer";
			const char *testStat = "CREATE TABLE customer (First_Name char(50), Last_Name char(50), Address char(50), City char(50), Country char(25), Birth_Date date)";
			sqlite3_stmt *compiledStatement;
			sqlite3_stmt *testComp;
		
			if(sqlite3_prepare_v2(database, testStat, -1, &testComp, NULL) != SQLITE_OK){
				
					NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
				
				
			}
																									
			
			if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
			{
				//int step = (sqlite3_step(compiledStatement));
				// Loop through the results and add them to the feeds array
				while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
					// Read the data from the result row
					NSString *aId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
					NSString *aTs = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
					NSString *aLon = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
					NSString *aLat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
					// Create a new animal object with the data from the database
					
				    TrashPiece *trash = [[TrashPiece alloc] initWithID:aId ts:aTs lat:aLat lon:aLon];
					
					// Add the animal object to the animals Array
					[cachedItems addObject:trash];
					
					[trash release];
				}
			}
			
			else {
				
				NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
			}

			// Release the compiled statement from memory
			sqlite3_finalize(compiledStatement);
			
		    }
		sqlite3_close(database);
		
	
	}
	*/
	- (void)requestFailed:(ASIHTTPRequest *)request
	{
		NSError *error = [request error];
		NSLog(@"Fail %@", error);
	}


@end
