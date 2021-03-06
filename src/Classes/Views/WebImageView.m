//
//  WebImageView.m
//  Greenhouse
//
//  Created by Roy Clarkson on 8/12/10.
//  Copyright 2010 VMware. All rights reserved.
//

#import "WebImageView.h"


@implementation WebImageView

@synthesize imageUrl;

- (id)initWithURL:(NSURL *)url
{
	if ((self = [super initWithImage:nil]))
	{
		self.imageUrl = url;
		[self startImageDownload];
	}
	
	return self;
}

- (void)startImageDownload
{
	DLog(@"%@", imageUrl);
	
	// cancel any current downloads to prevent memory leaks
	[self cancelImageDownload];
		
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:imageUrl];
    _urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[request release];
	
	if (_urlConnection)
	{
		_receivedData = [[NSMutableData data] retain];
	}
}

- (void)cancelImageDownload
{
	if (_urlConnection)
	{
		[_urlConnection cancel];
		[_urlConnection release];
		_urlConnection = nil;
	}
	
	if (_receivedData)
	{
		[_receivedData release];
		_receivedData = nil;
	}
}


#pragma mark -
#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_receivedData release];
	_receivedData = nil;
    [_urlConnection release];
	_urlConnection = nil;
	
	DLog(@"Connection failed! Error - %@ %@",
		 [error localizedDescription],
		 [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_urlConnection release];
	_urlConnection = nil;
	
	DLog(@"Succeeded! Received %d bytes of data", [_receivedData length]);
		
    UIImage *downloadedImage = [[UIImage alloc] initWithData:_receivedData];
	[_receivedData release];
	_receivedData = nil;
	self.image = downloadedImage;
	[downloadedImage release];    
}


#pragma mark -
#pragma mark NSObject methods

- (void)dealloc
{
	[self cancelImageDownload];
	
	[super dealloc];
}

@end
