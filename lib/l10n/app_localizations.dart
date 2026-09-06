import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Hopper'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get navGroups;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navAi.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get navAi;

  /// No description provided for @bag.
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get bag;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get searchHint;

  /// No description provided for @aiSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Ask Hopper AI…'**
  String get aiSearchHint;

  /// No description provided for @aiSearchSheetHint.
  ///
  /// In en, this message translates to:
  /// **'Where do you want to go?'**
  String get aiSearchSheetHint;

  /// No description provided for @aiSearchNoSuggestions.
  ///
  /// In en, this message translates to:
  /// **'No suggestions right now. Try a different prompt.'**
  String get aiSearchNoSuggestions;

  /// No description provided for @aiSearchError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get aiSearchError;

  /// No description provided for @aiSearchSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get aiSearchSuggestions;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @aiSearchEditQuery.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get aiSearchEditQuery;

  /// No description provided for @aiSearchResultsFor.
  ///
  /// In en, this message translates to:
  /// **'Results for \"{query}\"'**
  String aiSearchResultsFor(Object query);

  /// No description provided for @searchPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Where to next?'**
  String get searchPromptTitle;

  /// No description provided for @searchPromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan a city break, beach escape or weekend getaway.'**
  String get searchPromptSubtitle;

  /// No description provided for @searchAllServices.
  ///
  /// In en, this message translates to:
  /// **'All services'**
  String get searchAllServices;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get homeWelcome;

  /// No description provided for @homeWelcomeSub.
  ///
  /// In en, this message translates to:
  /// **'Trips and ideas picked for you'**
  String get homeWelcomeSub;

  /// No description provided for @searchFlights.
  ///
  /// In en, this message translates to:
  /// **'Flights'**
  String get searchFlights;

  /// No description provided for @searchHotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get searchHotels;

  /// No description provided for @searchCars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get searchCars;

  /// No description provided for @searchPackages.
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get searchPackages;

  /// No description provided for @searchTransfers.
  ///
  /// In en, this message translates to:
  /// **'Airport transfer'**
  String get searchTransfers;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @exploreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Destinations, deals and collections'**
  String get exploreSubtitle;

  /// No description provided for @groupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupsTitle;

  /// No description provided for @groupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan together, travel together'**
  String get groupsSubtitle;

  /// No description provided for @exploreDestinations.
  ///
  /// In en, this message translates to:
  /// **'Popular destinations'**
  String get exploreDestinations;

  /// No description provided for @exploreDeals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s deals'**
  String get exploreDeals;

  /// No description provided for @exploreCollections.
  ///
  /// In en, this message translates to:
  /// **'Curated collections'**
  String get exploreCollections;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @myTrips.
  ///
  /// In en, this message translates to:
  /// **'My trips'**
  String get myTrips;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @readyToBook.
  ///
  /// In en, this message translates to:
  /// **'Ready to book?'**
  String get readyToBook;

  /// No description provided for @reviewBooking.
  ///
  /// In en, this message translates to:
  /// **'Review booking'**
  String get reviewBooking;

  /// No description provided for @passengerDetails.
  ///
  /// In en, this message translates to:
  /// **'Passenger details'**
  String get passengerDetails;

  /// No description provided for @addOns.
  ///
  /// In en, this message translates to:
  /// **'Add-ons'**
  String get addOns;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get bookNow;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin panel'**
  String get adminPanel;

  /// No description provided for @adminContent.
  ///
  /// In en, this message translates to:
  /// **'Home content'**
  String get adminContent;

  /// No description provided for @adminProviders.
  ///
  /// In en, this message translates to:
  /// **'API providers'**
  String get adminProviders;

  /// No description provided for @adminAddSection.
  ///
  /// In en, this message translates to:
  /// **'Add section'**
  String get adminAddSection;

  /// No description provided for @adminAddCard.
  ///
  /// In en, this message translates to:
  /// **'Add card'**
  String get adminAddCard;

  /// No description provided for @adminEditCard.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get adminEditCard;

  /// No description provided for @adminType.
  ///
  /// In en, this message translates to:
  /// **'Card type'**
  String get adminType;

  /// No description provided for @adminTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get adminTitle;

  /// No description provided for @adminSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get adminSubtitle;

  /// No description provided for @adminImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get adminImageUrl;

  /// No description provided for @adminPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get adminPrice;

  /// No description provided for @adminCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get adminCurrency;

  /// No description provided for @adminRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get adminRating;

  /// No description provided for @adminBadge.
  ///
  /// In en, this message translates to:
  /// **'Badge'**
  String get adminBadge;

  /// No description provided for @adminActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Action label'**
  String get adminActionLabel;

  /// No description provided for @adminStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get adminStatus;

  /// No description provided for @adminDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get adminDraft;

  /// No description provided for @adminPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get adminPublished;

  /// No description provided for @adminVisible.
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get adminVisible;

  /// No description provided for @adminDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminDelete;

  /// No description provided for @adminMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get adminMoveUp;

  /// No description provided for @adminMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get adminMoveDown;

  /// No description provided for @adminSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get adminSave;

  /// No description provided for @adminCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminCancel;

  /// No description provided for @adminPreview.
  ///
  /// In en, this message translates to:
  /// **'Live preview'**
  String get adminPreview;

  /// No description provided for @adminHealthCheck.
  ///
  /// In en, this message translates to:
  /// **'Health check'**
  String get adminHealthCheck;

  /// No description provided for @adminLatency.
  ///
  /// In en, this message translates to:
  /// **'Latency'**
  String get adminLatency;

  /// No description provided for @adminActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminActive;

  /// No description provided for @adminPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get adminPriority;

  /// No description provided for @adminRefreshRegistry.
  ///
  /// In en, this message translates to:
  /// **'Apply changes'**
  String get adminRefreshRegistry;

  /// No description provided for @adminEmpty.
  ///
  /// In en, this message translates to:
  /// **'No content yet. Add your first section.'**
  String get adminEmpty;

  /// No description provided for @adminError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please retry.'**
  String get adminError;

  /// No description provided for @adminRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get adminRetry;

  /// No description provided for @adminLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get adminLoading;

  /// No description provided for @adminSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get adminSaved;

  /// No description provided for @adminFlight.
  ///
  /// In en, this message translates to:
  /// **'Flight'**
  String get adminFlight;

  /// No description provided for @adminHotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get adminHotel;

  /// No description provided for @adminCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get adminCar;

  /// No description provided for @adminPackage.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get adminPackage;

  /// No description provided for @adminDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get adminDestination;

  /// No description provided for @adminDeal.
  ///
  /// In en, this message translates to:
  /// **'Deal'**
  String get adminDeal;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
