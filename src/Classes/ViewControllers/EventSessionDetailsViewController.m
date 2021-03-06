//
//  EventSessionDetailsViewController.m
//  Greenhouse
//
//  Created by Roy Clarkson on 7/21/10.
//  Copyright 2010 VMware, Inc. All rights reserved.
//

#import "Event.h"
#import "EventSession.h"
#import "VenueRoom.h"
#import "EventSessionDetailsViewController.h"
#import "EventSessionDescriptionViewController.h"
#import "EventSessionTweetsViewController.h"
#import "EventSessionRateViewController.h"
#import "ActivityIndicatorTableViewCell.h"


@interface EventSessionDetailsViewController()

@property (nonatomic, retain) EventSessionController *eventSessionController;
@property (nonatomic, retain) ActivityIndicatorTableViewCell *favoriteTableViewCell;

- (void)setRating:(double)rating imageView:(UIImageView *)imageView;
- (void)updateFavoriteSession;

@end


@implementation EventSessionDetailsViewController

@synthesize eventSessionController;
@synthesize favoriteTableViewCell;
@synthesize event;
@synthesize session;
@synthesize arrayMenuItems;
@synthesize labelTitle;
@synthesize labelLeader;
@synthesize labelTime;
@synthesize labelLocation;
@synthesize imageViewRating1;
@synthesize imageViewRating2;
@synthesize imageViewRating3;
@synthesize imageViewRating4;
@synthesize imageViewRating5;
@synthesize tableViewMenu;
@synthesize sessionDescriptionViewController;
@synthesize sessionTweetsViewController;
@synthesize sessionRateViewController;


#pragma mark -
#pragma mark Public methods

- (void)updateRating:(double)newRating
{	
	[self setRating:newRating imageView:imageViewRating1];
	[self setRating:newRating imageView:imageViewRating2];
	[self setRating:newRating imageView:imageViewRating3];
	[self setRating:newRating imageView:imageViewRating4];
	[self setRating:newRating imageView:imageViewRating5];	
}


#pragma mark -
#pragma mark Private methods

- (void)setRating:(double)rating imageView:(UIImageView *)imageView 
{
	NSInteger number = imageView.tag;
	if (number <= rating)
	{
		imageView.image = [UIImage imageNamed:@"star.png"];
	}
	else if ((number - 1) < rating && number > rating)
	{
		imageView.image = [UIImage imageNamed:@"star-half.png"];
	}
	else 
	{
		imageView.image = [UIImage imageNamed:@"star-empty.png"];
	}
}

- (void)updateFavoriteSession
{
	[favoriteTableViewCell startAnimating];
	
	self.eventSessionController = [[EventSessionController alloc] init];
	eventSessionController.delegate = self;
	
	[eventSessionController updateFavoriteSession:session.number withEventId:event.eventId];
}


#pragma mark -
#pragma mark EventSessionControllerDelegate methods

- (void)updateFavoriteSessionDidFinishWithResults:(BOOL)isFavorite
{
	[favoriteTableViewCell stopAnimating];
	
	[eventSessionController release];
	self.eventSessionController = nil;
	
	session.isFavorite = isFavorite;
	[tableViewMenu reloadData];
}

- (void)updateFavoriteSessionDidFailWithError:(NSError *)error
{
	[favoriteTableViewCell stopAnimating];
	
	[eventSessionController release];
	self.eventSessionController = nil;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.row) 
	{
		case 0:
			[self.navigationController pushViewController:sessionDescriptionViewController animated:YES];
			break;
		case 1:
			[self.navigationController pushViewController:sessionTweetsViewController animated:YES];
			break;
		case 2:
			[self updateFavoriteSession];
			break;
		case 3:
			[self presentModalViewController:sessionRateViewController animated:YES];
			break;
		default:
			break;
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdent = @"menuCell";
	static NSString *activityCellIdent = @"activityCellIdent";
	
	UITableViewCell *cell = nil;
	
	if (indexPath.row == 2)
	{
		cell = (ActivityIndicatorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:activityCellIdent];
		
		if (cell == nil)
		{
			self.favoriteTableViewCell = [[[ActivityIndicatorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:activityCellIdent] autorelease];
			cell = favoriteTableViewCell;
		}
	}
	else 
	{
		cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
		
		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdent] autorelease];
		}
	}

	if (indexPath.row == 2)
	{
		cell.accessoryType = session.isFavorite ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	}
	else if (indexPath.row == 3)
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else 
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

	
	NSString *s = (NSString *)[arrayMenuItems objectAtIndex:indexPath.row];
	
	[cell.textLabel setText:s];
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (arrayMenuItems)
	{
		return [arrayMenuItems count];
	}
	
	return 0;
}


#pragma mark -
#pragma mark DataViewController methods

- (void)refreshView
{
	if (session)
	{
		labelTitle.text = session.title;
		labelLeader.text = session.leaderDisplay;
		
		sessionDescriptionViewController.session = session;
		sessionTweetsViewController.event = event;
		sessionTweetsViewController.session = session;
		sessionRateViewController.event = event;
		sessionRateViewController.session = session;
		sessionRateViewController.sessionDetailsViewController = self;
				
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"h:mm a"];
		NSString *formattedStartTime = [dateFormatter stringFromDate:session.startTime];
		NSString *formattedEndTime = [dateFormatter stringFromDate:session.endTime];
		[dateFormatter release];
		
		NSString *formattedTime = [[NSString alloc] initWithFormat:@"%@ - %@", formattedStartTime, formattedEndTime];
		labelTime.text = formattedTime;
		[formattedTime release];
		
		labelLocation.text = session.room.label;
		
		NSArray *items = [[NSArray alloc] initWithObjects:@"Description", @"Tweets", @"Favorite", @"Rate", nil];
		self.arrayMenuItems = items;
		[items release];

		[tableViewMenu reloadData];
		
		[self updateRating:session.rating];
	}	
}


#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.title = @"Session";
	
	self.sessionDescriptionViewController = [[EventSessionDescriptionViewController alloc] initWithNibName:nil bundle:nil];
	self.sessionTweetsViewController = [[EventSessionTweetsViewController alloc] initWithNibName:@"TweetsViewController" bundle:nil];
	self.sessionRateViewController = [[EventSessionRateViewController alloc] initWithNibName:nil bundle:nil];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
	
	self.eventSessionController = nil;
	self.favoriteTableViewCell = nil;
	self.event = nil;
	self.session = nil;
	self.arrayMenuItems = nil;
	self.labelTitle = nil;
	self.labelLeader = nil;
	self.labelTime = nil;
	self.labelLocation = nil;
	self.imageViewRating1 = nil;
	self.imageViewRating2 = nil;
	self.imageViewRating3 = nil;
	self.imageViewRating4 = nil;
	self.imageViewRating5 = nil;
	self.tableViewMenu = nil;
	self.sessionDescriptionViewController = nil;
	self.sessionTweetsViewController = nil;
	self.sessionRateViewController = nil;
}


#pragma mark -
#pragma mark NSObject methods

- (void)dealloc 
{
	[favoriteTableViewCell release];
	[event release];
	[session release];
	[arrayMenuItems release];
	[labelTitle release];
	[labelLeader release];
	[labelTime release];
	[labelLocation release];
	[imageViewRating1 release];
	[imageViewRating2 release];
	[imageViewRating3 release];
	[imageViewRating4 release];
	[imageViewRating5 release];
	[tableViewMenu release];
	[sessionDescriptionViewController release];
	[sessionTweetsViewController release];
	[sessionRateViewController release];
	
    [super dealloc];
}


@end
