//
//  AddWordsViewController.m
//  flashcards
//
//  Created by Charles Konkol on 4/17/13.
//  Copyright (c) 2013 RVC Student. All rights reserved.
//

#import "AddWordsViewController.h"
#import "FMDatabase.h"
#import "FMResultSet.h"


@implementation AddWordsViewController
@synthesize txtAddWords;
@synthesize AddWordsPicker;
@synthesize ScrollView;
@synthesize playAudio;
@synthesize stopAudio;
@synthesize recordAudio;

NSString *FilePath;
NSString *WordIDs;
int intWordsID;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self LoadDB];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

}
- (void) LoadDB
{
    listOfData = [[NSMutableArray alloc] init];
    listOfNameID = [[NSMutableArray alloc] init];
	// Do any additional setup after loading the view.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"cards.sqlite"];
    NSLog(@"Path: %@",path);
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    [database open];
    [database beginTransaction];
    NSLog(@"Path: %@",@"OPenEd DB");
	// Do any additional setup after loading the view, typically from a nib.
    // Do any additional setup after loading the view, typically from a nib.
    FMResultSet *results = [database executeQuery:@"select * from FlashName"];
    while([results next]) {
        NSString *Nameid = [results stringForColumn:@"NameID"] ;
        NSString *title = [results stringForColumn:@"title"] ;
        NSString *StrTitles =  [NSString stringWithFormat:@"ID:%@  --- %@", Nameid, title];
        NSLog(@"Titles: %@",StrTitles);
        [listOfNameID addObject:Nameid];
        [listOfData addObject:StrTitles];
        
    }
    [results close]; //VERY IMPORTANT!
    [database commit];
    [database close];
    NSLog(@"Closed: %@",@"DBClosed");
    [AddWordsPicker reloadAllComponents];
    [AddWordsPicker selectRow:0 inComponent:0 animated:YES];

}
-(void)dismissKeyboard {
    [txtAddWords resignFirstResponder];
}
-(IBAction) doneEditing:(id) sender {
    [sender resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [AddWordsPicker release];
    [txtAddWords release];
    [ScrollView release];
    [super dealloc];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGPoint scrollPoint = CGPointMake(0, textField.frame.origin.y);
    [ScrollView setContentOffset:scrollPoint animated:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [ScrollView setContentOffset:CGPointZero animated:YES];
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    CGPoint scrollPoint = CGPointMake(0, textView.frame.origin.y);
    [ScrollView setContentOffset:scrollPoint animated:YES];
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    [ScrollView setContentOffset:CGPointZero animated:YES];
}

//PickerViewController.m
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}
//PickerViewController.m
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [listOfData count];
}
//PickerViewController.m
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [listOfData objectAtIndex:row];
}
//PickerViewController.m
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    WordIDs=[listOfNameID objectAtIndex:row];
    NSLog(@"Selected Flash Card: %@. Index of selected Flash Card: %i", WordIDs, row);
}
- (IBAction)btnAddWords:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"cards.sqlite"];
    NSLog(@"Path: %@",path);
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    [database open];
        NSLog(@"Path: %@",@"OPenEd DB");
      NSLog(@"Path: %@",@"OPenEd trans");
	    [database executeUpdate: @"INSERT INTO FlashWords (WordsID,Word,AudioName,NameID) VALUES (NULL,?,?,?)",
     txtAddWords.text, @"AudioFileName", WordIDs,nil];
     intWordsID =[database lastInsertRowId];
     [self InitializeAudioFile: [NSString stringWithFormat:@"%d%@", intWordsID, @".m4a"]];
     NSLog(@"WordsID: %d",intWordsID);
    [database close];
    txtAddWords.Text =@"";
    [self dismissKeyboard];

}
- (void) DeleteWordList
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"cards.sqlite"];
    NSLog(@"Path: %@",path);
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    [database open];
   
    NSString *sql = [NSString stringWithFormat:@"Delete FROM FlashName WHERE NameID = %@", WordIDs,nil];
    [database executeUpdate:sql];

    [database close];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Success!"
                                                    message: @"WordList Deleted"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
   


}
//Function to load audio file
- (void) InitializeAudioFile:(NSString *)filename;
{
    // Disable Stop/Play button when application launches
    [stopAudio setEnabled:NO];
    [playAudio setEnabled:NO];
    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               filename,
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
     FilePath=[outputFileURL absoluteString];
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];

    
}


//Audio
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [recordAudio setTitle:@"Record" forState:UIControlStateNormal];
    
    [stopAudio setEnabled:NO];
    [playAudio setEnabled:YES];
}
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
- (IBAction)playAudio:(id)sender
{
    if (!recorder.recording){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
    }
}
- (IBAction)recordAudio:(id)sender
{
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        [recordAudio setTitle:@"Pause" forState:UIControlStateNormal];
        
    } else {
        
        // Pause recording
        [recorder pause];
        [recordAudio setTitle:@"Record" forState:UIControlStateNormal];
    }
    
    [stopAudio setEnabled:YES];
    [playAudio setEnabled:NO];
}
- (IBAction)btnDelete:(id)sender {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:FilePath error:NULL];
     [self DeleteWordList];
     [self LoadDB];
}

- (IBAction)stopAudio:(id)sender
{
    [recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    
}

@end