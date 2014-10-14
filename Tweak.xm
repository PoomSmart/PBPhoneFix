#import <substrate.h>

@interface PBEffectsView : UIView
@end

%hook UIPopoverController

+ (BOOL)_popoversDisabled
{
	// Needed for saving photos, or the app crashes.
	return NO;
}

%end

%hook PBEffectsController

- (void)loadView
{
	%orig;
	PBEffectsView *effectsView = MSHookIvar<PBEffectsView *>(self, "_effectsView");
	CGFloat factor = [UIScreen mainScreen].bounds.size.width/768.0f;
	//CGFloat factorForYToFullScreen = [UIScreen mainScreen].bounds.size.height/1024.0f;
	[effectsView setTransform:CATransform3DGetAffineTransform(CATransform3DMakeScale(factor, factor, 0))];
}

%end

static BOOL (*my__MGIsDeviceOfType)(int, int, int, int);
static BOOL (*orig__MGIsDeviceOfType)(int, int, int, int);
static BOOL new__MGIsDeviceOfType(int a1, int a2, int a3, int a4)
{
	// Just want Photo Booth to recognize the device as iPad, there are no major changes anyway.
	// The good is it removes the "Unknown device! Defaulting..." messages from the console.
	// This function checks if device is kind of iPad or not. If not iPad, the app will set the default buffers dimensions to (480x640, small) and (720x960, large).
	// I cannot specific more all those arguments, as Apple hard-coded this stuff.
	// Looks like there are no major changes with this function hooked.
	return YES;
}

%ctor
{
	void *h = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_LAZY);
	if (h != NULL) {
		MSImageRef ref = MSGetImageByName("/usr/lib/libMobileGestalt.dylib");
		my__MGIsDeviceOfType = (BOOL (*)(int, int, int, int))MSFindSymbol(ref, "_MGIsDeviceOfType");
		MSHookFunction((BOOL *)my__MGIsDeviceOfType, (BOOL *)new__MGIsDeviceOfType, (BOOL **)&orig__MGIsDeviceOfType);
	}
	%init;
}
