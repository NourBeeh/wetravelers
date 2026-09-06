# Universal Search + AI — UX/Technical Contract (US-0)

**التاريخ:** 5 سبتمبر 2026
**المرحلة:** US-0 — تحليل وتثبيت عقد فقط. لا UI نهائي، لا Backend، لا AI integration، لا API calls، لا تغيير Recommendation Engine.
**المرجع الإلهامي:** interaction model لصندوق البحث في Messenger (iOS/Android) — الإحساس العام فقط، لا implementation داخلي ولا proprietary code.
**الحالة:** Contract مُعتمد — بانتظار موافقة صريحة لبدء US-1.

---

## 0. القرارات الأربعة المثبتة (أُقرّت من المالك)

| # | القرار | الأثر على العقد |
|---|---|---|
| D1 | **الترحيل:** تطوير v1 الموجود (`AiSmartSearchPage`) وتجميعه في `features/universal_search/` — حذف القديم بعد التكافؤ، بنمط "الحذف بموافقة" | الأقسام 13، 14، 17 |
| D2 | **حفظ الـ query:** الإغلاق لا يمسح النص؛ إعادة الفتح بـ query محفوظ → تفتح مباشرة في `TYPING` مع الاقتراحات والمؤشر في آخر النص والكيبورد طالع. Recents تتحدث عند submit فقط | الأقسام 3، 5 |
| D3 | **الميكروفون:** زرار placeholder معطّل (collapsed + expanded) — `Semantics(enabled: false)`؛ extension point موثّق لـ US-3+ (STT) بدون أي تغيير layout مستقبلًا | الأقسام 8، 9 |
| D4 | **Categories chips:** تشمل US-1 — صف 4 chips في `ACTIVE` فقط → الصفحات العمودية الموجودة (`/flights`, `/hotels`, `/cars`, `/packages`)؛ تختفي في `TYPING` | الأقسام 3، 9 |

---

## 1. Current Architecture Findings

| المجال | الوضع الحالي (مُتحقق بالفحص) |
|---|---|
| **Home** | `HomePage` → `HomeController` (`lib/features/home/presentation/home_controller.dart:54`, StateNotifier): restore snapshot فوري (Instant Home) → load شبكة → `HomeComposer.compose()` (deterministic — "Never AI-driven") يرتب sections بـ `semanticId` (`picked-for-you`, `because-you-viewed`, `complete-your-trip`, `based-on-activity`, `deals`, `discovery`) → snapshot caching per-audience (`home|snapshot|<audience>`, schema `home.snapshot.v2`) |
| **Home Ranking** | Phase 2B فقط: `RecommendationService.rank` (deterministic additive scoring: geo +1, trip_context +2, favorite +3, recent_view +4, recent_search +5, derived +5.5, stars ≤+6, budget +1.5/1.2) → **AI rerank اختياري** عبر `AiRerankClient` (`POST /ai/rerank`) id-validated، أي فشل → الترتيب deterministic. `safeAiContext()` = الشكل الوحيد المسموح يوصل AI. **قاعدة AGENTS.md صارمة: explicit 2C memories لا تدخل DerivedPreferenceProfile ولا Home Ranking** |
| **AI entry الحالي** | (1) `HomeAiSearchField` (pill + rotating aura + Hero `kAiSmartSearchHeroTag`) → `/smart-search` (root route, `ContainerTransformTransition` 320ms) → `AiSmartSearchPage` — **هذا هو v1 من Universal Search عمليًا**. (2) `/ai-chat` legacy full-screen. (3) `POST /ai/suggest` typeahead (كتالوج ثابت ثنائي اللغة، بدون LLM — متعمد). (4) `SearchIntentParser` (`lib/features/ai/domain/search_intent_parser.dart:48`) — parser عربي/إنجليزي كامل → `ParsedSearchIntent {service, origin, destination, dates, passengers}` — **موجود وغير موصّل** |
| **Product Cards** | 18 primitive في `lib/core/widgets/cards/` + feature cards: `HomeCard` dispatcher → `DiscoveryProductCard`/`DealCard`/`DestinationDiscoveryCard`/`FlightRecommendationCard`. `HomeSectionWidget`: 6 layouts (`vertical, horizontal, horizontalPeek, grid, flightRecommendationList, verticalDealList`)، 3 callbacks (`onFlightTap`, `onViewAllFlights`, `onFavorite`) |
| **Domain models** | `HomeItem` = 16 حقلًا بالضبط (id, type, title, subtitle, description, imageUrl, price, currency, rating, reviewCount, badge, highlights, tags, actionLabel, rawPrice, metadata). `HomeCardType` = 6 قيم فقط (hotel/flight/car/package/destination/deal). `HomeSection {id, title, subtitle, layout, items, isPaginated, metadata}` |
| **Search infra** | 3 StateNotifier controllers (flight/hotel/car) — offline-first (cache → network → cache-fallback)، `SearchStatus {idle, loading, success, empty, error}` موحد، cancellable بـ `RequestToken`، endpoints `POST /search/flights|hotels|cars`. `SelectedOffer` → `/booking/review` = مسار الحجز الموحد |
| **Navigation** | GoRouter 14.8.1؛ shell = 4 branches (Home/Search/Groups/Explore) + floating pill يختفي على sub-pages؛ `/smart-search` خارج الشل بـ `parentNavigatorKey: _rootNavigatorKey`. كل navigator (root + branches) ملفوف بـ `HeroController` → hero flights تعمل بين branch وroot |
| **Events** | `EventsTracker` (5 أنواع: hotel_search, hotel_view, hotel_favorite, trip_planned, booking_confirmed) — fire-and-forget, guests skipped. **إشارات التوصيات تعتمد عليها**: `hotel_search` يُطلق اليوم من `hotel_search_controller.dart:87` فقط |
| **Back/PopScope** | **صفر استخدام** لـ `PopScope`/`WillPopScope`/`SystemNavigator` في `lib/` — predictive back greenfield |
| **Responsive** | ⚠️ نظامان متعارضان: `AppBreakpoints` (480/840/1200, constraint-based) و`AdaptiveLayout` (600/900/1200, MediaQuery-based). القرار (قسم 13): US-1 يعتمد `AdaptiveLayout` للـ presentation فقط — لا refactor للنظامين |
| **Tests** | 528 passed / 6 skipped — منها 3 لصفحة v1 (`ai_smart_search_page_test.dart`) |

---

## 2. Existing Components Reusable (منع الـ duplicates)

**إعادة استخدام إلزامية — لا يُنشأ بديل لأي عنصر في القائمة دي:**

| المكوّن | المصدر | دوره في Universal Search |
|---|---|---|
| `HomeAiSearchField` + `kAiSmartSearchHeroTag` + `_RotatingAuraBorder` | `home_ai_search_field.dart` | الـ collapsed bar + مصدر الهيرو — يتطور in-place |
| `ContainerTransformTransition` + `containerTransformPage()` | `lib/core/navigation/app_transitions.dart` | افتتاح/إغلاق الحاوية — نفس الـ transition |
| `AiSmartSearchPage` (recents storage, debounce+version pattern, `_SuggestionTile`, `_SendButton`, fallback suggestions) | `ai_smart_search_page.dart` | يُهاجر ليصبح `UniversalSearchPage` (D1) |
| `aiSuggestionsServiceProvider` + `AiApiService.suggest()` | `features/ai` | typeahead كما هو |
| `kCities` / `kAirports` / `PickerEntry` | `destination_picker_sheet.dart` | مطابقة الوجهات في الاقتراحات |
| `SearchIntentParser.parse()` | `search_intent_parser.dart` | classifier الـ natural queries (wiring في US-1) |
| `aiSheetControllerProvider` + `AiHomeMapper` + `HomeSectionWidget` | `features/ai` + home | عرض نتائج AI ككروت حقيقية |
| الـ 3 search controllers + `SearchFlightsUseCase` إلخ | `features/search/application` | تنفيذ عمليات البحث — تُستدعى ولا تُعدّل |
| `SelectedOffer` → `/booking/review` | `offer_selection_provider.dart` | مسار tap النتائج — نفسه بالحرف |
| `EventsTracker` | `core/events` | call sites جديدة فقط — الـ tracker نفسه لا يُلمس |
| `_RecentTile` / recent keys `ai_search_recent/<n>` / `_kRecentLimit=8` | v1 | سجل البحث كما هو |

**أسماء متاحة (تم التحقق — صفر تصادم):** `UniversalSearch*` كاملة. **أسماء محجوزة:** `SearchBar`/`SearchAnchor` لا تُستخدم (ممنوع Material default UI حصرًا).

---

## 3. Search State Machine

الحالات الثمانية كافية. **قرار:** `AI_INTERPRETING` ليست حالة — flag على `SEARCHING` (يعرض shimmer + سطر "✦ Hopper AI بيدور…").

```
CLOSED ──tap──▶ OPENING ──320ms──▶ ACTIVE ◀──clear── TYPING
                                    │  ▲               │ submit / AI-idea
                                    │  └──keystroke────┤
                                    │                   ▼
                                    │              SEARCHING ──▶ RESULTS
                                    │                  │            │ chip
                                    │                  ▼            ▼
                                    └──────────── AI_RESULT (follow-up → SEARCHING)
◀── CLOSING ◀── back/query-close من: ACTIVE, TYPING, RESULTS, AI_RESULT
```

| State | UI ظاهر | Focus/Keyboard | Query | Back | Gestures/Animation | Transitions مسموحة |
|---|---|---|---|---|---|---|
| `CLOSED` | Home feed + collapsed bar | — | محفوظ (D2) | عادي (Home) | الـ aura تدور | →`OPENING` (tap منطقة النص **فقط**) |
| `OPENING` | container transform + scrim + محتوى reveal | `requestFocus` مع انطلاق الهيرو (`addPostFrameCallback` في initState) | كما هو | إلغاء = `CLOSING` فوري | hero flight 320ms + كيبورد يطلع بالتوازي | →`ACTIVE` |
| `ACTIVE` | Recents → Categories chips (D4) → AI-idea row | focused، كيبورد مفتوح | فارغ | keyboard-first ثم `CLOSING` | scroll عادي | →`TYPING` (keystroke)؛ chip → صفحة vertical (خروج) |
| `TYPING` | Suggestions لحظية + AI-idea row؛ chips **مخفية** (D4) | focused | نص ≥0 | keyboard-first ثم `CLOSING` | debounce 400ms | →`SEARCHING` (submit/intent/AI-idea)؛ →`ACTIVE` (مسح) |
| `SEARCHING` | shimmer sections + AI badge لو natural | **unfocused** — الكيبورد يقفل | مُرسَل | cancel request → نتائج جزئية أو `ACTIVE` | cancellation بالـ version pattern | →`RESULTS` / `AI_RESULT` |
| `RESULTS` | Product sections (`HomeSectionWidget`) | unfocused | مُرسَل | `CLOSING` | tap كارت → `/booking/review` | →`TYPING` (تعديل الحقل)؛ →`SEARCHING` (re-run) |
| `AI_RESULT` | سطر سردي واحد + sections + follow-up chips | unfocused | مُرسَل | `CLOSING` | chips = patches | →`SEARCHING` (chip) |
| `CLOSING` | عكس الافتتاح | unfocus أول frame | **يُحفظ** (D2) | — | hero flight عكسي 320ms | →`CLOSED` |

**إعادة الفتح بعد حفظ query (D2):** لو query محفوظ غير فارغ → الصفحة تفتح مباشرة في `TYPING` (لا `ACTIVE`) — الاقتراحات live، المؤشر في آخر النص، الكيبورد طالع.

---

## 4. Opening Animation Contract

| البند | القيمة | السبب |
|---|---|---|
| **Duration** | **320ms** | ضمن النطاق الإدراكي 250–350ms؛ الكيبورد يطلع بالتوازي فيحس أسرع. **قيد مصدر Flutter (`heroes.dart:477`): الـ hero flight مربوط بمدة الـ route animation — لا مدة مستقلة للهيرو** → القيمة تُعرف مرة واحدة في `ContainerTransformTransition` |
| **Curves** | hero: `fastOutSlowIn` (Material arc default = cubic-bezier(0.4,0,0.2,1))؛ scrim: linear داخل نافذته | منحنى Material القياسي المطلوب، ذيل ناعم |
| **Starting bounds** | pill الهوم: h≈60 (12+36+12)، radius=pill، هوامش `AppSpacing.lg` | القياس الحالي لـ `HomeAiSearchField` |
| **Ending bounds** | حقل الهيدر: عرض كامل − md×2، h≈52، radius=pill | القياس الحالي للهيدر |
| **Size/position/radius** | interpolation كامل عبر `MaterialRectArcTween` (قوس رأسي) | سلوك الهيرو الافتراضي مع MaterialApp |
| **Scrim** | أبيض (`AppColors.background` — هوية Pure White Premium) يذوب حتى **65%** من الرحلة، **مربوط بالاتجاه**: push 1→0، pop معكوس | إصلاح "فجوة السكون" الموثقة في الجولة الخامسة |
| **Content reveal** | من **40%**: fade + slide-up 16px | يتبع الحاوية بعد استقرارها البصري |
| **Focus/keyboard timing** | `requestFocus` في `initState` بـ `addPostFrameCallback` + حماية `mounted` | Instant responsiveness — الكيبورد يبدأ مع انطلاق الهيرو |
| **⚠️ قاعدة Handoff (إصلاح الشكوى المسجّلة)** | الكبسولة الطائرة لحظة t=1 **pixel-identical** للهيدر: نفس bgColor، نفس borderWidth، نفس layout الداخلي. **الخلل الموثق حاليًا:** shuttle=`surface` + حلقة 2px، هيدر=`surfaceSecondary` + border 1px → snap مرئي | أول بند تنفيذ في US-1 |

---

## 5. Closing Animation Contract

- نفس المدة (320ms) والمنحنى (`fastOutSlowIn`) معكوسين — reverseTransitionDuration = transitionDuration.
- **الترتيب الزمني:**
  1. **Frame 0:** `unfocus()` أول شيء → الكيبورد ينزل بالتوازي مع الحاوية (لا انتظار)
  2. **0→200ms:** نتائج/محتوى fade-out (opacity reversal لـ content reveal)
  3. **الرحلة كاملة:** الحاوية تتقلص من bounds الهيدر إلى bounds الـ pill (نفس `kAiSmartSearchHeroTag` — نفس العنصر يرجع بصريًا لمكانه)
  4. **النهاية:** focus release نهائي بعد `AnimationStatus.completed`
- **Query preservation (D2):** النص **لا يُمسح** — يبقى في controller state؛ `TYPING` re-entry عند الفتح القادم.
- **Back button أثناء الإغلاق:** غير فعال (الإغلاق غير قابل للإلغاء — مدته قصيرة).
- **Recents:** تتحدث عند **submit فقط** — لا تُسجل عمليات كتابة لم تُرسل.

---

## 6. Keyboard Contract

- الحقل مثبّت أعلى الصفحة (خارج الـ scroll) → **لا viewInsets docking pain** — البنية تتجنب مشاكل الـ bottom-sheet نهائيًا.
- الحالة الوحيدة الحساسة: قائمة الاقتراحات/النتائج تحتاج `MediaQuery.viewInsets.bottom` كـ bottom padding داخلي (AnimatedPadding بـ `AppMotion.normal`) كي لا يختفي آخر سطر خلف الكيبورد.
- `TextInputAction.search` + `keyboardType.text` (ثابتان من الجولات السابقة).
- **قاعدة unfocus:** عند دخول `SEARCHING` (مشاهدة النتائج أهم من الكتابة).
- **إعادة الفتح (D2):** الكيبورد يطلع فورًا (autofocus + query محفوظ في آخر موضع).

---

## 7. Back/Gesture Contract (Platform-aware)

| المنصة | السلوك |
|---|---|
| **iOS** | root-navigator pop → **swipe-back يعمل natively** مع `CustomTransitionPage` (متأكد). أول swipe والكيبورد مفتوح: `PopScope` يمنع (canPop=false مرة واحدة) **يقفل الكيبورد فقط** ثم يسمح بالثانية |
| **Android** | system back نفس منطق `PopScope` (keyboard-first). Predictive-back friendly لأن كل شيء route-based (go_router root route، لا overlays مستعصية). **Predictive back animation الكاملة = US-2+** (تحتاج دعم أعمق) — موثقة كـ extension |
| **Desktop/Web** | زرار ✕/back + مفتاح Esc = `CLOSING` |

- `PopScope`: greenfield مؤكد (صفر استخدام حاليًا) — يُضاف لـ `UniversalSearchPage` فقط.
- البنية تجعل predictive-back ممكنًا مستقبلًا: الإغلاق = pop على route حقيقي، لا حالة عالمية مخفية.

---

## 8. Search Bar UI Contract (Collapsed)

```
[ ✦  اسأل أو ابحث…                       (🎙 placeholder معطّل) ]
```

| العنصر | القيمة |
|---|---|
| **Leading** | sparkle بنفسجي `Icons.auto_awesome_rounded` 24px — **شكلي بالكامل** (لا AI button منفصل — طلب صريح) |
| **Placeholder** | `aiSearchHint` — typography `bodyLarge`، `textSecondary α0.7` |
| **Tap target** | **منطقة النص فقط** (`InkWell` داخل `Expanded` — قرار الجولة الخامسة). الأيقونات شكلية |
| **Height / radius / padding** | 60 (12+36+12) / `AppRadius.pill` / أفقي `AppSpacing.md` |
| **Trailing** | دائرة 36px بأيقونة mic بلون `textTertiary α0.35` — `Semantics(button: true, enabled: false, label: 'البحث الصوتي — قريبًا')` — **placeholder معطّل (D3)** |
| **الضوء الدوار (aura)** | signature — يبقى خارج الهيرو (كما هو)، قابل للإطفاء بـ flag للـ US-2+ (أداء/تخصيص) |
| **Clear / loading** | لا ينطبقا على الـ collapsed — حالات الـ expanded فقط |
| **A11y** | `Semantics(button: true, label: aiSearchHint)` — الهدف ≥48px عموديًا عبر ارتفاع الصف كاملًا |

---

## 9. Suggestions Contract (Expanded — ترتيب العرض)

```
Search Header (حقل حقيقي + back + send + mic معطّل + clear)
↓ Recent searches (≤8، مسح فردي/كلي)
↓ Categories chips (4: طيران/فنادق/عربيات/بكدجات) — ACTIVE فقط (D4)
↓ Suggestions (live)
↓ AI-idea row (سطر واحد دائمًا في TYPING)
↓ Results (بعد الإرسال — تحل محل كل ما فوقها عدا الـ header)
```

**قواعد الظهور (visibility rules):**

| الحالة | Header | Recent | Categories | Suggestions | AI-idea | Results |
|---|---|---|---|---|---|---|
| `ACTIVE` (فاضي) | ✓ | ✓ (أو AI-ideas لو فارغة) | ✓ (D4) | ✗ | ✓ (defaults) | ✗ |
| `TYPING` | ✓ | ✗ | ✗ (D4) | ✓ live | ✓ | ✗ |
| `SEARCHING` | ✓ | ✗ | ✗ | ✗ | ✗ | shimmer |
| `RESULTS`/`AI_RESULT` | ✓ (+ chip "تعديل" للرجوع لـ TYPING) | ✗ | ✗ | ✗ | ✗ | ✓ |

- **Suggestions مصادرها (ترتيب الدمج):** (1) مطابقات `kCities`/`kAirports`، (2) `aiSuggestionsServiceProvider` (debounce 400ms + version-cancel + fail-silent)، (3) fallback محلي ثنائي اللغة.
- **AI-idea row:** "✦ اسأل Hopper AI عن «{query}»" → تفسير AI (قسم 10). في `ACTIVE` تظهر default ideas.
- **Category chip tap** → `context.go` للصفحة العمودية الموجودة — خروج من Universal Search (مقصود — نفس نمط Messenger للنطاقات).

---

## 10. Search vs AI Contract

**قاعدة التصنيف (contract فقط في US-0 — الـ wiring في US-1):**

| الـ query | المسار |
|---|---|
| "Dubai" — قصير/كلمات مفتاحية/مطابق وجهة | **Search مباشر** → نتائج universal أو vertical |
| "عايز فندق رخيص في دبي 3 ليالي" — عامية/جملة سفر/مقاصد متعددة (تواريخ+ميزانية+ناس) | **AI interpretation** → structured intent |

**العقد الصارم:**
- AI **لا يعرض نصًا فقط أبدًا**. المسار: `SearchIntentParser.parse()` → `StructuredTravelIntent`:
  ```dart
  { type: flightSearch|hotelSearch|carSearch|packageSearch,
    origin?, destination?, dates?{from,to}, guests?, budget?{min,max} }
  ```
- الـ intent يملأ `*SearchParams` الموجودة → الـ controllers الموجودة → **كروت حقيقية**.
- الفشل: نتائج deterministic، أو "مفيش نتائج" + follow-up chips — **لا نص مجرد**.
- **لا يُنفذ parser جديد** — `SearchIntentParser` موجود؛ US-1 يوصّله فقط.

---

## 11. Unified Results Contract

- **Adapter لكل vertical (ملف واحد):** `FlightOffer/HotelOffer/CarOffer/TravelPackageOffer → HomeItem` — الـ metadata تحمل `providerOfferId`/`providerName` إلخ (نفس عقد الـ live validation في HomeController).
- **العرض:** `HomeSectionWidget` بالـ layouts الموجودة — flights → `flightRecommendationList`، الباقي → `vertical`/`grid`. **لا card system جديد** (قاعدة صارمة).
- **Tap:** `SelectedOffer` (الموجود) → `/booking/review` — نفس مسار الحجز بالحرف.
- **Destinations/Deals:** داخل نتائج universal كـ sections مستقلة بـ `HomeCardType` الموجودة.
- **قيد صارم:** Universal Search **يجب** إطلاق `hotel_search` (وإخواته عند توفرهم) بنفس payloads عبر `EventsTracker` — وإلا تجوّع Recommendation Engine. Call sites جديدة فقط.

---

## 12. AI Follow-up Contract

بعد `AI_RESULT`: سطر سردي واحد ("لقيتلك 12 فندق مناسب.") + sections + follow-up chips:

`[أرخص | أفخم | قريب من X | مقارنة | غيّر التواريخ]`

- **الـ chip = patch على الـ StructuredTravelIntent** (budget ↓ / stars ↑ / location refinement / dates) → إعادة `SEARCHING` — **ليس شاتًا حرًا أبدًا**.
- المستخدم **لا يخرج من Universal Search** في الحلقة كلها.
- "Compare" = معرّفة في الـ contract فقط (US-2+).
- كل follow-up يظل بالعقد الصارم: نتائج كروت، لا نص مجرد.

---

## 13. Proposed Flutter Architecture

```
lib/features/universal_search/
├── application/
│   ├── universal_search_controller.dart   # StateNotifier<UniversalSearchState>
│   ├── universal_search_state.dart        # state machine + query + intent + results
│   └── search_intent_classifier.dart      # QueryKind: simple | natural (wiring فقط)
├── domain/
│   └── structured_travel_intent.dart      # immutable intent model
├── presentation/
│   ├── pages/universal_search_page.dart   # تطوير/ترحيل AiSmartSearchPage (D1)
│   └── widgets/                           # suggestions list, categories chips,
│                                           # ai-idea row, narrative, follow-up chips
└── data/
    └── offer_to_home_item_adapters.dart    # 4 adapters → HomeItem
```

**Controller responsibilities (الحد الأدنى):** current state، query (+ preservation D2)، focusNode، recents، suggestions (versioned)، search intent، AI intent/narrative، result sections، selected result، dismissal.

**قواعد معمارية:**
- لا يُعدّل `HomeController`/composer/ranking — Universal Search **مستهلك** فقط.
- Responsive: `AdaptiveLayout` للـ presentation فقط (لا refactor للنظامين المتعارضين — موثّق كخطر).
- Mobile: full-screen. Tablet: full-screen مع `AdaptiveLayout` للتقسيم الداخلي. Desktop (≥1200): full-screen مبدئيًا — عرض مقيد بـ 840px في المنتصف كـ bounded surface (قرار قابل للمراجعة في US-2).

---

## 14. Files to be Created in US-1

| الملف | الغرض |
|---|---|
| `docs/universal-search-ux-contract.md` | **هذا الملف** (US-0) |
| `lib/features/universal_search/application/universal_search_controller.dart` | state machine controller |
| `lib/features/universal_search/application/universal_search_state.dart` | الحالات + الـ transitions |
| `lib/features/universal_search/application/search_intent_classifier.dart` | simple vs natural |
| `lib/features/universal_search/domain/structured_travel_intent.dart` | intent model |
| `lib/features/universal_search/presentation/pages/universal_search_page.dart` | ترحيل + تطوير v1 (D1) |
| `lib/features/universal_search/presentation/widgets/` (4–6 widgets) | chips, ai-idea row, narrative, follow-ups |
| `lib/features/universal_search/data/offer_to_home_item_adapters.dart` | النتائج adapters |
| `lib/features/universal_search/application/universal_search_providers.dart` | providers |
| `test/features/universal_search/universal_search_state_machine_test.dart` | transitions مسموحة/ممنوعة |
| `test/features/universal_search/offer_to_home_item_adapters_test.dart` | تطابق الحقول |
| `test/features/universal_search/universal_search_page_test.dart` | ترحيل تغطية v1 + الجديد |

**تعديلات جوّية محدودة:** `go_router_config.dart` (استبدال route واحد: `/smart-search` → `UniversalSearchPage`)، `home_ai_search_field.dart` (mic placeholder D3 فقط)، حذف `ai_smart_search_page.dart` + tests القديمة **بعد التكافؤ وبموافقة صريحة** (D1).

## 15. Files that should NOT be modified (محرم لمس)

- `home_controller.dart` / `home_composer.dart` / `home_page.dart` (إلا mic placeholder في الـ field فقط)
- `recommendation_service.dart` / `home_personalization_orchestrator.dart` / `ai_rerank_client.dart` / أي Phase 2B/2C memory
- كل `lib/core/widgets/cards/` (18 ملفًا) — استهلاك فقط
- الـ 3 search controllers + repositories + use cases — استدعاء فقط
- booking flow كاملًا / `SelectedOffer` / `/booking/review`
- `events_tracker.dart` (call sites جديدة فقط) / backend كله في US-1
- `AppTheme` / `AppColors` / tokens — استهلاك فقط
- **Home Ranking + Recommendation Engine + Trip/TripItem systems = محرم لمس نهائيًا**

## 16. Risks

1. **Handoff snap** (شكوى مسجّلة): shuttle≠target في bgColor/border → أول بند US-1 (pixel-identical)
2. **أحداث البحث:** إن لم تُطلق events من Universal Search → تجوّع Recommendation Engine (معالج في قسم 11)
3. **Responsive مزدوج:** `AppBreakpoints` (480/840) vs `AdaptiveLayout` (600/900) — قرارنا: AdaptiveLayout للـ presentation فقط؛ أي refactor شامل ممنوع
4. **كتالوج `/ai/suggest` ثابت:** تغطية typeahead محدودة — الـ fallback المحلي يغطي الفجوة
5. **Predictive back** على أندرويد API قديمة: fallback عادي، الـ animation الكاملة US-2+
6. **Regression على 528 tests:** منها 3 لـ v1 تُهاجر — يجب أن تبقى الخضراء خضراء بعد الترحيل
7. **مستندات قديمة تقول experience/story:** `HomeCardType` الحقيقي = 6 قيم فقط — الـ contract يعتمد الكود لا المستندات

## 17. Test Plan for US-1

- **Unit:** state machine (كل transition مسموحة/ممنوعة — جدول القسم 3)، adapters (تطابق الحقول الـ 16 + metadata)، classifier، debounce+cancellation (النمط الموجود)، query preservation (D2)
- **Widget:** open/close pump contracts (320ms + الدفعات المطلوبة للـ fade transition)، keyboard-first back (`PopScope`)، a11y semantics (زرار البحث، live region للنتائج، mic disabled)، أهداف ≥48px، chips ظهور/اختفاء (ACTIVE vs TYPING)
- **Integration:** intent عربي → sections؛ tap كارت → `/booking/review`؛ chip follow-up → re-SEARCHING
- **Regression:** `flutter analyze` + `flutter test` كاملة (528+) خضراء — لا استثناءات

## 18. Final Recommendation

**طوّر الـ v1 الموجود ولا تبنِ من الصفر** — 70% من المكوّنات جاهزة ومختبرة (pill+hero+transition+recents+suggestions+AI results). ترتيب تنفيذ US-1:

1. **إصلاح handoff snap** (pixel-identical shuttle) — الشكوى المسجّلة
2. **State machine + controller** (بنية `features/universal_search/`)
3. **ترحيل v1** داخل البنية الجديدة (D1) + حذف القديم بموافقة
4. **Results adapters** (4 offers → HomeItem)
5. **Intent wiring** (`SearchIntentParser` → params → controllers)
6. **Events firing** + Categories chips (D4) + mic placeholder (D3) + query preservation (D2)

**Backend: صفر تغييرات في US-1.**

---

*US-0 مكتمل — عقد مثبّت. US-1 لا يبدأ إلا بموافقة صريحة.*
