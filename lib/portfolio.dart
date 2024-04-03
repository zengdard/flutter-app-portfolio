  import 'package:path_provider/path_provider.dart';
  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'package:fl_chart/fl_chart.dart';


  // cette fonction récupère les prix des cryptos à partir de l'api de Coingecko
  Future<Map<String, dynamic>> fetchPrices(List<String> ids) async {
    // construit l'url de l'api en utilisant cette chaine
    final String joinedIds = ids.join(',');
    // on effectue une requete GET à l'aide de la bibliotheque http de flutter
    final String url =
        'https://api.coingecko.com/api/v3/simple/price?ids=$joinedIds&vs_currencies=usd';
    print(url);
    try {
      final response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');
      // si la réponse à le statut 200 elle imprime le corps de la réponse et le retourne sous forme d'objet json
      if (response.statusCode == 200) {
        print(response.body);
        return json.decode(response.body);
        // sinon elle lève une exception avec le statut de la réponse
      } else {
        throw Exception(
            'Failed to load prices with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch prices: $e');
    }
  }

  // la classe prend en compte le nom, les variations sur 24h, la liste des cryptos, la valeur total du portefeuille
  class Portfolio {
    final String name;
    final double change24h;
    List<Asset> assets;
    double value = 0;

    // le constructeur pour la classe "Portfolio"
    Portfolio(
        {required this.name,
        required this.change24h,
        required this.assets,
        value});

    // on ajoute une crypto au portefeuille
    void addAsset(Asset asset) {

      int index = assets.indexWhere((existingAsset) => existingAsset.name == asset.name);

      if (index == -1) {
        assets.add(asset);
      } else {
        assets[index].symbol = asset.symbol;
        assets[index].value = asset.value;
      }
    }

    // on supprime une crypto du portefeuille
    void removeAsset(Asset asset) {
      assets.remove(asset);
    }

    // on met à jour la valeur totale du portefeuille
    void updateValue(double newValue) {
      value = newValue;
    }

    // on crée une instance de Portfolio à partir d'un objet json qui est enregistré dans un répertoire web
    factory Portfolio.fromJson(Map<String, dynamic> json) {
      return Portfolio(
        name: json['name'],
        change24h: json['change24h'],
        assets: (json['assets'] as List)
            .map((assetJson) => Asset.fromJson(assetJson))
            .toList(),
        value: json['value'],
      );
    }

    // on met à jour la liste des cryptos du portefeuille
    void updateAssetsList(List<Asset> newAssets) {
      assets = newAssets;
    }

    // on calcule la valeur totale du portefeuille en dollar
    double getTotalValue() {
      return assets.fold(0, (total, asset) => total + asset.dollars);
    }

    // on met à jour les valeurs des cryptos du portefeuille en fonction d'un facteur donné
    Portfolio updateAssetValues(double factor) {
      final updatedAssets = <Asset>[];

      for (final asset in assets) {
        updatedAssets.add(Asset(
            name: asset.name,
            symbol: asset.symbol,
            value: asset.value,
            dollars: asset.value * factor));
      }

      return Portfolio(
        name: name,
        change24h: change24h,
        assets: updatedAssets,
        value: value,
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'name': name,
        'change24h': change24h,
        'assets': assets.map((asset) => asset.toJson()).toList(),
        'value': value,
      };
    }
  }

  // la classe "Asset" représente une crypto
  class Asset {
    String name;
    String symbol;
    double value;
    double _dollars;

    // le constructeur pour Asset
    Asset({
      required this.name,
      required this.symbol,
      required this.value,
      required double dollars,
    }) : _dollars = dollars;

    // getteur pour la valeur de la crypto en dollar
    double get dollars => _dollars;

    // seteur pour la valeur de la crypto en dollar
    set dollars(double newValue) {
      _dollars = newValue;
    }

    // on crée une instance de "Asset" à partir d'un objet json
    factory Asset.fromJson(Map<String, dynamic> json) {
      return Asset(
        name: json['name'],
        symbol: json['symbol'],
        value: json['value'],
        dollars: json['dollars'],
      );
    }

    // on convertit l'instance d'"Asset" en objet json
    Map<String, dynamic> toJson() {
      return {
        'name': name,
        'symbol': symbol,
        'value': value,
        'dollars': dollars,
      };
    }

    // on récuper les prix historiques du bitcoin à partir d'une api
    Future<List<FlSpot>> fetchBTCPrices() async {
      final url = 'https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=1';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> priceList = json.decode(response.body)['prices'];
        return priceList.map((price) => FlSpot(
          price[0] / 3600000, // Convertir timestamp en heures pour l'exemple
          price[1],
        )).toList();
      } else {
        throw Exception('Failed to load BTC prices');
      }
    }

  }
