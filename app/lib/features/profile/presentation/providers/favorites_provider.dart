import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:app/features/auth/presentation/providers/auth_provider.dart';

const String apiBaseURL = "http://localhost:8080";

const Map<String, String> mlbIdToUuid = {
  '144': '0594b0b4-9a5e-4a90-bb4b-324e62a22f3e', // ATL
  '137': '0a685da3-334e-451a-9645-0d65b7a1510e', // SF
  '147': '196c2e38-4ceb-4eb5-ac9f-3e8f800e8b2b', // NYY
  '135': '1b72a262-ed6b-4450-86cc-9c6063b46865', // SD
  '119': '275ce5b8-6238-4737-a316-568e21a7337f', // LAD
  '145': '2b2b24df-ed5e-421a-a99b-0081079d8c97', // CWS
  '136': '2b634b53-7411-4142-bd24-766786c07886', // SEA
  '134': '2c61db32-d79f-4bbb-be36-6286c757754b', // PIT
  '118': '3fbfe9fa-6b85-4074-a89c-851532f81515', // KC
  '117': '4a67bef8-9086-4e5b-9799-7360e2098650', // HOU
  '113': '51c6a876-6b02-48d8-b432-8507c3046788', // CIN
  '115': '55942c63-ef80-415d-92a8-1250868f0003', // COL
  '120': '5bd3b57f-e6ad-4da6-8d5a-60586e372776', // WSH
  '139': '76295027-651f-4c7e-8fe1-6967b5870005', // TB
  '138': '76b7719f-9780-48e3-9502-3f6e80c86815', // STL
  '114': '84773d2a-a7cb-492a-bbc3-689e22544254', // CLE
  '158': 'add5ecfb-810d-4069-8968-072089606865', // MIL
  '133': 'b30acc5d-e6db-40e1-bee3-764789512345', // OAK
  '116': 'b6ca535f-af62-454f-90f6-52467b73656c', // DET
  '121': 'b8697995-5f2f-4d3a-826d-6246b73b656c', // NYM
  '108': 'bf6e3edd-bb60-4f28-857e-6246b73a656c', // LAA
  '143': 'c98f9d32-4708-4d03-8153-6246b739656c', // PHI
  '110': 'dedba3f5-3c3f-485a-800e-6246b738656c', // BAL
  '140': 'e4353f7e-4309-491d-86d3-6246b737656c', // TEX
  '109': 'e70ca877-9e4b-46f6-bc95-6246b736656c', // ARI
  '142': 'e9348ef5-3751-4eef-b51c-6246b735656c', // MIN
  '111': 'f060d54b-fc6b-417d-8b1b-6246b734656c', // BOS
  '141': 'f3b2f17e-f3f8-40fc-a6eb-6246b733656c', // TOR
  '112': 'fa22f3f5-8d1a-48ec-822e-6246b732656c', // CHC
  '146': 'fb774163-4b6d-47a7-be4c-6246b731656c', // MIA
};

final favoritesProvider = FutureProvider<Set<String>>((ref) async {
  // THE FIX: We use ref.watch on the auth state stream!
  // Now, anytime a user logs in or out, this provider automatically destroys
  // its cache and recalculates for the new user.
  final user = ref.watch(authStateProvider).value;

  // If no one is logged in, immediately return an empty set
  if (user == null) return {};

  final token = await user.getIdToken();
  final response = await http.get(
    Uri.parse('$apiBaseURL/favorites'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<dynamic> favoritesList = data['favorites'] ?? [];

    final Set<String> selectedMlbIds = {};
    for (var fav in favoritesList) {
      String uuid = fav['teamId'].toString();
      String? mlbId = mlbIdToUuid.entries
          .where((e) => e.value == uuid)
          .map((e) => e.key)
          .firstOrNull;

      if (mlbId != null) selectedMlbIds.add(mlbId);
    }
    return selectedMlbIds;
  }
  return {};
});