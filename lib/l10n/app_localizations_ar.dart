// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'هوبر';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navSearch => 'بحث';

  @override
  String get navGroups => 'الجروبات';

  @override
  String get navExplore => 'استكشف';

  @override
  String get navAi => 'المساعد الذكي';

  @override
  String get bag => 'رحلاتي';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get back => 'رجوع';

  @override
  String get searchHint => 'رايح فين؟';

  @override
  String get aiSearchHint => 'اسأل هوبر الذكي…';

  @override
  String get aiSearchSheetHint => 'عايز تسافر فين؟';

  @override
  String get aiSearchNoSuggestions => 'مفيش اقتراحات دلوقتي. جرب صيغة تانية.';

  @override
  String get aiSearchError => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get aiSearchSuggestions => 'اقتراحات';

  @override
  String get recentSearches => 'آخر عمليات البحث';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get aiSearchEditQuery => 'تعديل';

  @override
  String aiSearchResultsFor(Object query) {
    return 'نتائج عن «$query»';
  }

  @override
  String get searchPromptTitle => 'رايح فين بعد؟';

  @override
  String get searchPromptSubtitle =>
      'خطط لرحلة مدينة، هروب للشاطئ أو ويك إند سريع.';

  @override
  String get searchAllServices => 'كل الخدمات';

  @override
  String get homeWelcome => 'أهلاً بعودتك';

  @override
  String get homeWelcomeSub => 'رحلات وأفكار مختارة لك';

  @override
  String get searchFlights => 'طيران';

  @override
  String get searchHotels => 'فنادق';

  @override
  String get searchCars => 'سيارات';

  @override
  String get searchPackages => 'باكدجات';

  @override
  String get searchTransfers => ' transfére المطار';

  @override
  String get exploreTitle => 'استكشف';

  @override
  String get exploreSubtitle => 'وجهات وعروض وتشكيلات مختارة';

  @override
  String get groupsTitle => 'الجروبات';

  @override
  String get groupsSubtitle => 'خططوا معًا وسافروا معًا';

  @override
  String get exploreDestinations => 'وجهات مشهورة';

  @override
  String get exploreDeals => 'عروض اليوم';

  @override
  String get exploreCollections => 'تشكيلات مختارة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get continueAsGuest => 'الاستكشاف كضيف';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get currency => 'العملة';

  @override
  String get wishlist => 'المفضلة';

  @override
  String get myTrips => 'رحلاتي';

  @override
  String get upcoming => 'القادمة';

  @override
  String get past => 'السابقة';

  @override
  String get readyToBook => 'جاهز للحجز؟';

  @override
  String get reviewBooking => 'مراجعة الحجز';

  @override
  String get passengerDetails => 'بيانات المسافرين';

  @override
  String get addOns => 'إضافات';

  @override
  String get payment => 'الدفع';

  @override
  String get confirmation => 'التأكيد';

  @override
  String get bookNow => 'احجز الآن';

  @override
  String get total => 'الإجمالي';

  @override
  String get continueAction => 'متابعة';

  @override
  String get adminPanel => 'لوحة الأدمن';

  @override
  String get adminContent => 'محتوى الصفحة الرئيسية';

  @override
  String get adminProviders => 'مزوّدو الخدمات (API)';

  @override
  String get adminAddSection => 'إضافة قسم';

  @override
  String get adminAddCard => 'إضافة كارت';

  @override
  String get adminEditCard => 'تعديل الكارت';

  @override
  String get adminType => 'نوع الكارت';

  @override
  String get adminTitle => 'العنوان';

  @override
  String get adminSubtitle => 'العنوان الفرعي';

  @override
  String get adminImageUrl => 'رابط الصورة';

  @override
  String get adminPrice => 'السعر';

  @override
  String get adminCurrency => 'العملة';

  @override
  String get adminRating => 'التقييم';

  @override
  String get adminBadge => 'الشارة';

  @override
  String get adminActionLabel => 'نص الزر';

  @override
  String get adminStatus => 'الحالة';

  @override
  String get adminDraft => 'مسودة';

  @override
  String get adminPublished => 'منشور';

  @override
  String get adminVisible => 'ظاهر';

  @override
  String get adminDelete => 'حذف';

  @override
  String get adminMoveUp => 'تحريك لأعلى';

  @override
  String get adminMoveDown => 'تحريك لأسفل';

  @override
  String get adminSave => 'حفظ';

  @override
  String get adminCancel => 'إلغاء';

  @override
  String get adminPreview => 'معاينة حية';

  @override
  String get adminHealthCheck => 'فحص الحالة';

  @override
  String get adminLatency => 'زمن الاستجابة';

  @override
  String get adminActive => 'نشط';

  @override
  String get adminPriority => 'الأولوية';

  @override
  String get adminRefreshRegistry => 'تطبيق التغييرات';

  @override
  String get adminEmpty => 'لا يوجد محتوى بعد. أضف أول قسم.';

  @override
  String get adminError => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get adminRetry => 'إعادة المحاولة';

  @override
  String get adminLoading => 'جارٍ التحميل…';

  @override
  String get adminSaved => 'تم الحفظ';

  @override
  String get adminFlight => 'طيران';

  @override
  String get adminHotel => 'فنادق';

  @override
  String get adminCar => 'عربيات';

  @override
  String get adminPackage => 'برامج';

  @override
  String get adminDestination => 'وجهات';

  @override
  String get adminDeal => 'عروض';
}
