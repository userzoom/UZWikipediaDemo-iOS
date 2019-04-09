@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface WMFLocalizedDateFormatStrings : NSObject

+ (NSString *)yearsAgoForWikiLanguage:(nullable NSString *)language;

@end

@interface NSDate (WMFRelativeDate)

- (NSString *)wmf_localizedRelativeDateStringFromLocalDateToNow; // to now

- (NSString *)wmf_localizedRelativeDateStringFromLocalDateToLocalDate:(NSDate *)date;

- (NSString *)wmf_localizedRelativeDateFromMidnightUTCDate;

@end

NS_ASSUME_NONNULL_END
