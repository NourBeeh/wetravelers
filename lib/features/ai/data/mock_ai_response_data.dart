import 'package:wetravellers/features/ai/application/ai_response_source.dart';
import 'package:wetravellers/features/ai/domain/ai_response.dart';

/// Local mock payload in the documented AI response contract.
///
/// Demonstrates mixed content: narrative text, several section layouts
/// (horizontalPeek / vertical / grid / horizontal) across every card type the
/// HomeCard engine already knows, plus explicit `order` hints to prove the
/// mapper honours ordering. No network — purely a local data source.
const Map<String, dynamic> mockAiResponseJson = <String, dynamic>{
  'text': 'Here’s a quick plan for your trip — hotels, flights and some '
      'ideas for what to do.',
  'metadata': <String, dynamic>{
    'queryId': 'mock-1',
    'model': 'wetravellers-mock-model',
    'source': 'local-mock',
  },
  'sections': <Map<String, dynamic>>[
    // Filled out of order on purpose: the mapper must re-sort by `order`
    // into Hotels -> Flights -> Destinations -> Deals.
    <String, dynamic>{
      'id': 's-flights',
      'title': 'Best Flight Options',
      'subtitle': 'Non-stop shown first',
      'layout': 'vertical',
      'order': 2,
      'items': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'f1',
          'type': 'flight',
          'title': 'Qatar Airways',
          'subtitle': 'DXB → CDG · direct',
          'price': 235,
          'currency': 'USD',
          'rating': 4.8,
          'badge': 'Fastest',
          'data': <String, dynamic>{'route': 'Dubai → Paris'},
        },
        <String, dynamic>{
          'id': 'f2',
          'type': 'flight',
          'title': 'Emirates',
          'subtitle': 'DXB → CDG · 1 stop',
          'price': 169,
          'currency': 'USD',
          'rating': 4.6,
          'data': <String, dynamic>{'route': 'Dubai → Paris'},
        },
        <String, dynamic>{
          'id': 'f3',
          'type': 'flight',
          'title': 'Air France',
          'subtitle': 'DXB → CDG · 1 stop',
          'price': 210,
          'currency': 'USD',
          'rating': 4.4,
          'data': <String, dynamic>{'route': 'Dubai → Paris'},
        },
      ],
    },
    <String, dynamic>{
      'id': 's-hotels',
      'title': 'Recommended Hotels',
      'subtitle': 'Best match for your dates',
      'layout': 'horizontalPeek',
      'order': 1,
      'items': <Map<String, dynamic>>[
        // `order` values are intentionally shuffled to prove explicit ordering.
        <String, dynamic>{
          'id': 'h1',
          'type': 'hotel',
          'title': 'Grand Palm Marina',
          'subtitle': 'Downtown · 4★',
          'price': 320,
          'currency': 'USD',
          'rating': 4.6,
          'reviewCount': 214,
          'badge': 'Top pick',
          'imageUrl': 'https://picsum.photos/seed/grand-palm/400/300',
          'highlights': <String>['Free breakfast', 'Pool'],
          'tags': <String>['4-star', 'Ocean view'],
          'order': 3,
          'actionLabel': 'Book now',
          'actions': <Map<String, dynamic>>[
            <String, dynamic>{
              'type': 'book',
              'label': 'Book',
              'payload': <String, dynamic>{'offerId': 'h1'},
            },
          ],
          'data': <String, dynamic>{'city': 'Paris'},
        },
        <String, dynamic>{
          'id': 'h2',
          'type': 'hotel',
          'title': 'Azure Bay Hotel',
          'subtitle': 'Riverside · 5★',
          'price': 275,
          'currency': 'USD',
          'rating': 4.8,
          'reviewCount': 189,
          'badge': 'Popular',
          'imageUrl': 'https://picsum.photos/seed/azure-bay/400/300',
          'order': 1,
          'data': <String, dynamic>{'city': 'Paris'},
        },
        <String, dynamic>{
          'id': 'h3',
          'type': 'hotel',
          'title': 'Skyline Inn',
          'subtitle': 'Near station · 3★',
          'price': 190,
          'currency': 'USD',
          'rating': 4.2,
          'reviewCount': 97,
          'imageUrl': 'https://picsum.photos/seed/skyline-inn/400/300',
          'order': 2,
          'data': <String, dynamic>{'city': 'Paris'},
        },
      ],
    },
    <String, dynamic>{
      'id': 's-deals',
      'title': 'Unmissable Deals',
      'layout': 'horizontal',
      'order': 4,
      'items': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'd1',
          'type': 'deal',
          'title': 'City Break Deal',
          'price': 450,
          'currency': 'USD',
          'imageUrl': 'https://picsum.photos/seed/city-deal/400/300',
        },
        <String, dynamic>{
          'id': 'p1',
          'type': 'package',
          'title': 'Paris Package',
          'subtitle': 'Flights + hotel',
          'price': 1290,
          'currency': 'USD',
          'badge': 'Best value',
          'imageUrl': 'https://picsum.photos/seed/paris-package/400/300',
        },
        <String, dynamic>{
          'id': 'c1',
          'type': 'car',
          'title': 'Premium SUV',
          'price': 78,
          'currency': 'USD',
          'imageUrl': 'https://picsum.photos/seed/suv/400/300',
          'actions': <Map<String, dynamic>>[
            <String, dynamic>{'type': 'view', 'label': 'Rent'},
          ],
          'data': <String, dynamic>{'type': 'SUV'},
        },
      ],
    },
    <String, dynamic>{
      'id': 's-destinations',
      'title': 'Top Destinations',
      'layout': 'grid',
      'order': 3,
      'items': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'dst1',
          'type': 'destination',
          'title': 'Santorini',
          'imageUrl': 'https://picsum.photos/seed/santorini/400/300',
        },
        <String, dynamic>{
          'id': 'dst2',
          'type': 'destination',
          'title': 'Kyoto',
          'imageUrl': 'https://picsum.photos/seed/kyoto/400/300',
        },
        <String, dynamic>{
          'id': 'dst3',
          'type': 'destination',
          'title': 'Reykjavík',
          'imageUrl': 'https://picsum.photos/seed/reykjavik/400/300',
        },
      ],
    },
  ],
};

/// Parses the local mock payload into the typed AI contract.
AiResponse buildMockAiResponse() => AiResponse.fromMap(mockAiResponseJson);

/// Temporary in-process implementation of [AiResponseSource].
///
/// Mimics a short round-trip so the loading state is visible, then returns the
/// local mock payload with the submitted prompt echoed into the intro text —
/// no network, no backend.
class MockAiResponseSource implements AiResponseSource {
  const MockAiResponseSource();

  @override
  Future<AiResponse> generate(String prompt) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final base = buildMockAiResponse();
    final trimmed = prompt.trim();
    final intro = base.text ?? '';
    return AiResponse(
      text: 'Here’s a plan for “$trimmed” — $intro',
      sections: base.sections,
      metadata: <String, dynamic>{...base.metadata, 'prompt': trimmed},
    );
  }
}