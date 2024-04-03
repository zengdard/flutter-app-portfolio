import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'portfolio.dart';

// cette classe gère la sauvegarde et le chargement des portefeuilles dd cryptos
class PortfolioStorage {
  static const _portfoliosKey = 'portfolios';

  // on sauvegarde une liste de portefeuilles dans "SharedPreferences"
  static Future<void> savePortfolios(List<Portfolio> portfolios) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(portfolios.map((p) => p.toJson()).toList());
    print(
        "Saving portfolios: $jsonString"); // ajout d'un log pour la sauvegarde
    await prefs.setString(_portfoliosKey, jsonString);
  }

  // on charge une liste de portefeuilles depuis "SharedPreferences"
  static Future<List<Portfolio>> loadPortfolios() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_portfoliosKey);
    print(
        "Loading portfolios: $jsonString");
    if (jsonString == null) {
      return [];
    }
    final jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList.map((json) => Portfolio.fromJson(json)).toList();
  }
}
