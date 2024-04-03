import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// cette classe représente le graphique du prix du bitcoin
class BitcoinPriceChart extends StatefulWidget {
  // la fonction est appelée quand la page "BitcoinPriceChart" est créée pour la première fois
  @override
  _BitcoinPriceChartState createState() => _BitcoinPriceChartState();
}

//la classe "State" privée pour "BitcoinPriceChart"
class _BitcoinPriceChartState extends State<BitcoinPriceChart> {
  // on récupère les prix du bitcoin à partir d'une api et les convertis en une list de FlSpot
  Future<List<FlSpot>> fetchBTCPrices() async {
    final url = 'https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=1';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> priceList = json.decode(response.body)['prices'];
      // convertit chaque prix en un objet FlSpot avec le timestamp (en heures) et le prix en dollar
      return priceList.map((price) => FlSpot(
        (price[0] as double) / 3600000,
        price[1] as double,
      )).toList();
    } else {
      throw Exception('Failed to load BTC prices');
    }
  }

  // la fonction construit l'arborescence des widgets pour la page "BitcoinPriceChart"
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bitcoin Price Chart'),
      ),
      //"FutureBuilder" construit l'interface utilisateur en fonction du résultat de la requete
      body: FutureBuilder<List<FlSpot>>(
        future: fetchBTCPrices(),
        builder: (context, snapshot) {
          // si la requete est en cours on affiche un indicateur de progression circulaire
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
            // si la requete a échoué on affiche un message d'erreur
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
            // si la requete a réussi et qu il y a des données on affiche le graphique
          } else if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: LineChart(
                // les données du graphique linéaire
              LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // les onnées de la ligne du graphique
                    LineChartBarData(
                      spots: snapshot.data!,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            );
            // si la requete a réussi mais qu'il n'y a pas de données on affichez un message
          } else {
            return Center(child: Text('No data'));
          }
        },
      ),
    );
  }
}