//
//  DetailViewController.h
//  Storyboard
//
//  Created by Kevin Coleman on 3/3/16.
//
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

