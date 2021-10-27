import SwiftUI
import WidgetKit
import WMF
import UIKit

// MARK: - Widget

struct FeaturedArticleWidget: Widget {
	private let kind: String = WidgetController.SupportedWidget.featuredArticle.identifier

	public var body: some WidgetConfiguration {
		StaticConfiguration(kind: kind, provider: FeaturedArticleProvider(), content: { entry in
			FeaturedArticleView(entry: entry)
		})
		.configurationDisplayName(FeaturedArticleWidget.LocalizedStrings.widgetTitle)
		.description(FeaturedArticleWidget.LocalizedStrings.widgetDescription)
		.supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
	}
}

// MARK: - Timeline Entry

struct FeaturedArticleEntry: TimelineEntry {

	// MARK: - Properties

	var date: Date
	var content: WidgetFeaturedContent?
	var fetchError: WidgetContentFetcher.FetcherError?

	// MARK: - Computed Properties

	var hasDisplayableContent: Bool {
		return fetchError == nil && content?.featuredArticle != nil
	}

	var fetchedLanguageCode: String? {
		return content?.featuredArticle?.languageCode
	}

	var title: String {
		return (content?.featuredArticle?.displayTitle as NSString?)?.wmf_stringByRemovingHTML() ?? ""
	}

	var description: String {
		return content?.featuredArticle?.description ?? ""
	}

	var extract: String {
		return content?.featuredArticle?.extract ?? ""
	}

	var layoutDirection: LayoutDirection {
		if let direction = content?.featuredArticle?.languageDirection {
			return direction == "rtl" ? .rightToLeft : .leftToRight
		}

		return .leftToRight
	}

	var contentURL: URL? {
		guard let page = content?.featuredArticle?.contentURL.desktop.page else {
			return nil
		}

		return URL(string: page)
	}

	var imageData: Data? {
		return content?.featuredArticle?.thumbnailImageSource?.data
	}

}

// MARK: - Timeline Provider

struct FeaturedArticleProvider: TimelineProvider {
	typealias Entry = FeaturedArticleEntry

	func placeholder(in context: Context) -> FeaturedArticleEntry {
		return FeaturedArticleEntry(date: Date(), content: nil)
	}

	func getSnapshot(in context: Context, completion: @escaping (FeaturedArticleEntry) -> Void) {
		WidgetController.shared.fetchFeaturedContent(isSnapshot: context.isPreview) { result in
			let currentDate = Date()
			switch result {
			case .success(let featuredContent):
				completion(FeaturedArticleEntry(date: currentDate, content: featuredContent))
			case .failure(let fetchError):
				completion(FeaturedArticleEntry(date: currentDate, content: nil, fetchError: fetchError))
			}
		}
	}

	func getTimeline(in context: Context, completion: @escaping (Timeline<FeaturedArticleEntry>) -> Void) {
		WidgetController.shared.fetchFeaturedContent { result in
			let currentDate = Date()
			switch result {
			case .success(let featuredContent):
				completion(Timeline(entries: [FeaturedArticleEntry(date: currentDate, content: featuredContent)], policy: .after(currentDate.randomDateShortlyAfterMidnight() ?? currentDate)))
			case .failure(let fetchError):
				completion(Timeline(entries: [FeaturedArticleEntry(date: currentDate, content: nil, fetchError: fetchError)], policy: .atEnd))
			}
		}
	}
}

// MARK: - View

struct FeaturedArticleView: View {
	@Environment(\.widgetFamily) private var widgetFamily
	@Environment(\.colorScheme) private var colorScheme

	var entry: FeaturedArticleEntry

	var headerCaptionText: String {
		switch widgetFamily {
		case .systemLarge:
			return FeaturedArticleWidget.LocalizedStrings.fromLanguageWikipediaTextFor(languageCode: entry.fetchedLanguageCode)
		default:
			return FeaturedArticleWidget.LocalizedStrings.widgetTitle
		}
	}

	var headerTitleText: String {
		switch widgetFamily {
		case .systemLarge:
			return FeaturedArticleWidget.LocalizedStrings.widgetTitle
		default:
			return entry.title
		}
	}

	var backgroundImage: UIImage? {
		guard let imageData = entry.imageData else {
			return nil
		}

		return UIImage(data: imageData)
	}

	// MARK: - Nested Views

	@ViewBuilder
	var content: some View {
		switch widgetFamily {
		case .systemLarge:
			largeWidgetContent
		default:
			smallWidgetContent
		}
	}

	var smallWidgetContent: some View {
		headerData
			.background(Color(colorScheme == .light ? Theme.light.colors.paperBackground : Theme.dark.colors.paperBackground))
	}

	var largeWidgetContent: some View {
		GeometryReader { proxy in
			VStack(spacing: 0) {
				headerData
					.frame(height: proxy.size.height / 2.25)
					.clipped()
				bodyData
			}
		}
		.background(Color(colorScheme == .light ? Theme.light.colors.paperBackground : Theme.dark.colors.paperBackground))
	}

	var headerData: some View {
		ZStack {
			headerBackground
			VStack(alignment: .leading, spacing: 4) {
				Spacer()
				HStack {
					Text(headerCaptionText)
						.font(.caption2)
						.fontWeight(.bold)
						.foregroundColor(.white)
						.readableShadow(intensity: 0.8)
					Spacer()
				}
				HStack {
					Text(headerTitleText)
						.font(.headline)
						.foregroundColor(.white)
						.readableShadow(intensity: 0.8)
					Spacer()
				}
			}
			.padding()
			.background(
				Rectangle()
					.foregroundColor(.black)
					.mask(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .center, endPoint: .bottom))
					.opacity(0.35)
			)
		}
	}

	var bodyData: some View {
		VStack(alignment: .leading, spacing: 4) {
			HStack {
				Text(entry.title)
					.foregroundColor(Color(colorScheme == .light ? Theme.light.colors.primaryText : Theme.dark.colors.primaryText))
					.font(.custom("Georgia", size: 21, relativeTo: .title))
				Spacer()
			}
			HStack {
				Text(entry.description)
					.foregroundColor(Color(colorScheme == .light ? Theme.light.colors.secondaryText : Theme.dark.colors.secondaryText))
					.font(.caption)
				Spacer()
			}
			Spacer()
				.frame(height: 8)
			HStack {
				Text(entry.extract)
					.foregroundColor(Color(colorScheme == .light ? Theme.light.colors.primaryText : Theme.dark.colors.primaryText))
					.font(.caption)
					.lineLimit(5)
					.lineSpacing(4)
					.truncationMode(.tail)
			}
		}
		.padding()
	}

	@ViewBuilder
	var headerBackground: some View {
		GeometryReader { proxy in
			if let backgroundImage = backgroundImage {
				Image(uiImage: backgroundImage)
					.resizable()
					.aspectRatio(contentMode: .fill)
			} else {
				ZStack {
					Rectangle()
						.foregroundColor(Color(UIColor("318CDB")))
					Text(entry.extract)
						.font(.headline)
						.fontWeight(.semibold)
						.lineSpacing(6)
						.foregroundColor(Color.black.opacity(0.15))
						.frame(width: proxy.size.width * 1.25, height: proxy.size.height * 2, alignment: .topLeading)
						.padding(EdgeInsets(top: 16, leading: 10, bottom: 0, trailing: 0))
				}
			}
		}
	}

	func noContent(message: String) -> some View {
		Rectangle()
			.foregroundColor(Color(UIColor.base30))
			.overlay(
				Text(message)
					.font(.caption)
					.bold()
					.multilineTextAlignment(.leading)
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
					.foregroundColor(.white)
					.padding()
			)
	}

	@ViewBuilder
	var widgetBody: some View {
		if entry.hasDisplayableContent {
			content
				.overlay(FeaturedArticleOverlayView())
		} else if entry.fetchError == .unsupportedLanguage {
			noContent(message: FeaturedArticleWidget.LocalizedStrings.widgetLanguageFailure)
		} else {
			noContent(message: FeaturedArticleWidget.LocalizedStrings.widgetContentFailure)
		}
	}

	// MARK: - Body

	var body: some View {
		widgetBody
			.widgetURL(entry.contentURL)
			.environment(\.layoutDirection, entry.layoutDirection)
			.flipsForRightToLeftLayoutDirection(true)
	}
}

struct FeaturedArticleOverlayView: View {
	var body: some View {
		VStack(alignment: .trailing) {
			HStack(alignment: .top) {
				Spacer()
				Image("W")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(height: 16, alignment: .trailing)
					.foregroundColor(.white)
					.padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 16))
					.readableShadow()
			}
			Spacer()
			.readableShadow()
			.padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 45))
		}
		.foregroundColor(.white)
	}
}
