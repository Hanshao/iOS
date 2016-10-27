#import "VideoFilteringBenchmarkController.h"

@implementation VideoFilteringBenchmarkController

#pragma mark -
#pragma mark Benchmarks

- (void)runBenchmark;
{
    videoFilteringDisplayController = [[VideoFilteringDisplayController alloc] initWithNibName:@"VideoFilteringDisplayController" bundle:nil];
    videoFilteringDisplayController.delegate = self;

//    [self presentModalViewController:videoFilteringDisplayController animated:YES];
    [self presentViewController:videoFilteringDisplayController animated:YES completion:nil];
}

- (void)finishedTestWithAverageTimesForCPU:(CGFloat)cpuTime coreImage:(CGFloat)coreImageTime gpuImage:(CGFloat)gpuImageTime;
{
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    processingTimeForCPURoutine = cpuTime;
    processingTimeForCoreImageRoutine = coreImageTime;
    processingTimeForGPUImageRoutine = gpuImageTime;
    
    [self.tableView reloadData];
}

@end
