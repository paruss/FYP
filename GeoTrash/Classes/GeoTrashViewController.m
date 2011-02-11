//
//  GeoTrashViewController.m
//  GeoTrash
//
//  Created by Patrick Russell on 22/12/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GeoTrashViewController.h"
#import "MapViewController.h"
#import "Annotation.h"
#import "AnnotationViewController.h"

enum
{
    kAnnotationIndex = 10,
};

@implementation GeoTrashViewController


@synthesize theImageView ,sentPhoto, takePhoto, lat, lon, CLController, mapAnnotations, mapView, annotationViewController, cacher;
/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	CLController = [[Location alloc] init];
	CLController.delegate = self;
	[CLController.locMgr startUpdatingLocation];
	
	
	//Annotation *annotation = [[Annotation alloc] init];
   // [self.mapAnnotations insertObject:annotation atIndex:kAnnotationIndex];
   // [annotation release];
	
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    // bring back the toolbar
    [self.navigationController setToolbarHidden:NO animated:NO];
}

-(IBAction) getPhoto:(id) sender{
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	
	if((UIButton *) sender == sentPhoto) {
		picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	} else {
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
	[self presentModalViewController:picker animated:YES];
}


- (IBAction)sentGPS:(id)sender{
	
	NSURL *url;
	NSMutableURLRequest * request;

	request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	
	
	NSData *photoData= UIImageJPEGRepresentation(self.theImageView.image, 1.0);
	if (photoData == nil) {
		NSLog(@"The photo is nothing !!!");
	}
	else {
		NSLog(@"Photo inside !!!!");
	}
	
}


-(IBAction) loadMap:(id) sender{
	
	
    [super viewDidLoad];
	mapView=[[MKMapView alloc] initWithFrame:self.view.frame];
	mapView.showsUserLocation=TRUE;
	mapView.delegate=self;
	[self.view insertSubview:mapView atIndex:5];
	CLLocationManager *locationManager=[[CLLocationManager alloc] init];
	locationManager.delegate=self;
	locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
	[locationManager startUpdatingLocation];
	
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
	[temporaryBarButtonItem release];
    
	cacher = [[Cacher alloc]init];
	id number;
	number = self.cacher;
	
	//[cacher checkAndCreateDatabase];
	[number buildDatabaseFromRemoteData];
	
	
	/*
	databaseName = @"LocCache.sql";
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
	[fileManager release];
	
	sqlite3 *database;
	
	// Init the animals Array
	
	// Open the database from the users filessytem

	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
		const char *sqlStatement = "select * from LocCache";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSString *ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
				NSString *TS = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
				NSString *Lat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
				NSLog(ID);
		
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	sqlite3_close(database);
	
    */
	
    // create out annotations array (in this example only 2)
    self.mapAnnotations = [[NSMutableArray alloc] initWithCapacity:1];
    
    // annotation for the City of San Francisco
    Annotation *annotation = [[Annotation alloc] init];
    [self.mapAnnotations insertObject:annotation atIndex:0];
	[self.mapView addAnnotation:[self.mapAnnotations objectAtIndex:0]];
    [annotation release];
	
}

- (void)showDetails:(id)sender
{
    // the detail view does not want a toolbar so hide it
	//[self.view insertSubview:annotationViewController.view atIndex:6]; 
	
	AnnotationViewController *annotation= [[AnnotationViewController alloc] initWithNibName:@"AnnotationViewController" bundle:nil];
	[self.view.superview addSubview:annotation.view];
  //  [self.navigationController setToolbarHidden:YES animated:NO];
  //  self.annotationViewController.view.backgroundColor = [UIColor redColor];
    //[self.view insertSubview:annotationViewController atIndex:6];
  //  [self.navigationController pushViewController:self.annotationViewController animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // handle our two custom annotations
    //
    if ([annotation isKindOfClass:[Annotation class]]) // for Golden Gate Bridge
    {
        // try to dequeue an existing pin view first
        static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)
		[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier] autorelease];
            customPinView.pinColor = MKPinAnnotationColorPurple;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            // add a detail disclosure button to the callout which will open a new view controller page
            //
            // note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
            //  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
            //
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self
                            action:@selector(showDetails:)
                  forControlEvents:UIControlEventTouchUpInside];
            customPinView.rightCalloutAccessoryView = rightButton;
			
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    
    return nil;
}


-(IBAction) remMap:(id) sender{
	
[mapView removeFromSuperview];

}
- (void)locationUpdate:(CLLocation *)location {
//	locLabel.text = [location description];
	self.lat = [[NSString alloc]init];
	NSString *locLat;
	NSString *locLong;
	locLat  = [NSString stringWithFormat:@"%lf", location.coordinate.latitude];
	locLong  = [NSString stringWithFormat:@"%lf", location.coordinate.longitude];
	self.lat = locLat;
	self.lon = locLong;
}

- (void)locationError:(NSError *)error {
//	locLabel.text = [error description];
}
	
	- (IBAction)Update:(id)sender
	{
		NSString *latPost = self.lat;
		NSString *lonPost = self.lon;
		NSURL *url = [NSURL URLWithString:@"http://www.skynet.ie/~paruss/iPhone/Uploader.php"];
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
		[request setPostValue:lonPost forKey:@"lon"];
		[request setPostValue:latPost forKey:@"lat"];
		[request start]; 
		NSError *error = [request error];
		if (!error) {
			
			NSString *response = [request responseString];
			NSLog(@"Output", response);
		
		}
	}
	

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissModalViewControllerAnimated:YES];


	self.theImageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	
}


- (IBAction)populateLocationList:(id)sender
{
	cacher = [[Cacher alloc]init];
	id number;
	
	number = self.cacher;
	
	// Get the path to the documents directory and append the databaseName
		//[cacher checkAndCreateDatabase];
	[number starter];
	//[number locationsArray];
	
	
	
}

- (IBAction)loadFromDB:(id)sender
{
	cacher = [[Cacher alloc]init];
	id number;
	number = self.cacher;
    [number starter];
}


/*
{

	NSURL *url = [NSURL URLWithString:@"http://www.skynet.ie/~paruss/iPhone/getLocations.php"];
	//NSURL *url = [NSURL URLWithString:@"http://www.skynet.ie/~paruss/iPhone/Uploader.php"];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestFinished:)];
	[request startAsynchronous];	
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Use when fetching text data
	NSString *responseString = [request responseString];
	NSLog(@"Response: %@", responseString);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSLog(@"Fail %@", error);
}

*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	
}

@end
