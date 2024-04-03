import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:universal_html/html.dart' as html;
import 'portfolio.dart';
import 'assets_page.dart';
import 'total_portfolio_widget.dart';
import 'portfolio_storage.dart';

// la classe "HomePage" représente la page d'accueil de l'application
class HomePage extends StatefulWidget {
  final String title;
  final Portfolio? portfolio;

  // le constructeur qui a besoin d'un titre et d'un portoflio
  HomePage({Key? key, required this.title, this.portfolio}) : super(key: key);

  // cette fonction est appelée quand la page "HomePage" est créée pour la première fois
  @override
  _HomePageState createState() => _HomePageState();
}

// la classe "_HomePageState" est la classe State privée pour HomePage
class _HomePageState extends State<HomePage> {
  // liste des portefeuilles
  List<Portfolio> _portfolios = [];
  // liste des points de données pour le graphique du prix du bitcoin
  List<FlSpot> btcPriceSpots = [];

  // la clé globale pour le formulaire d'ajout de portefeuille qui distingue une boite de dialogue
  final _formKey = GlobalKey<FormState>();
  // un controleur de texte pour le nom du portefeuille
  final _portfolioNameController = TextEditingController();

  // cette fonction est appelée quand la page "HomePage" est insérée dans l'arborescence
  @override
  void initState() {
    super.initState();
    // on charge les portefeuilles et les données du graphique
    _loadPortfolios();
    _fetchGraphData();
  }

  // on récupere les données du prix du graphique du bitcoin à partir de l'api
  Future<void> _fetchGraphData() async {
    final url = 'https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=1';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> priceList = json.decode(response.body)['prices'];
      setState(() {
        btcPriceSpots = priceList.map((price) => FlSpot(price[0] as double, price[1] as double)).toList();
      });
    } else {
      throw Exception('Failed to load BTC prices');
    }
  }

  // on charge les portefeuilles à partir du stockage
  Future<void> _loadPortfolios() async {
    _portfolios = await PortfolioStorage.loadPortfolios();
    setState(() {});
  }

  // on ajoute un nouveau portefeuille à la liste des portefeuilles
  Future<void> _addPortfolio() async {
    if (_formKey.currentState!.validate()) {
      final newPortfolio = Portfolio(
        name: _portfolioNameController.text,
        change24h: 0,
        assets: [],
        value: 0,
      );
      setState(() {
        _portfolios.add(newPortfolio);
      });
      await PortfolioStorage.savePortfolios(_portfolios);
    }
  }

  // on supprime un portefeuille de la liste des portefeuilles
  Future<void> _deletePortfolio(int index) async {
    setState(() {
      _portfolios.removeAt(index);
    });
    await PortfolioStorage.savePortfolios(_portfolios);
  }

  // cette fonction construit l'arborescence des widgets pour cette page "HomePage"
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            // si les données du graphique sont chargées on affichez le graphique sinon on affichea un indicateur de progression
            btcPriceSpots.isNotEmpty
                ? Container(
              height: 200,
              child: LineChart(
                // les données du graphique linéaire
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // les données de la ligne du graphique
                    LineChartBarData(
                      spots: btcPriceSpots,
                      isCurved: true,
                      barWidth: 5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            )
                : SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
            // si la liste des portefeuilles n'est pas vide on affichee le widget "TotalPortfolioWidget"
            if (_portfolios.isNotEmpty)
              TotalPortfolioWidget(
                portfolios: _portfolios,
                symbol: '\$',
              ),
            // le widget "ListView.builder" construit une liste défilable d'éléments
            Expanded(
              child: ListView.builder(
                itemCount: _portfolios.length,
                itemBuilder: (context, index) {
                  final portfolio = _portfolios[index];
                  return ListTile(
                    title: Text(portfolio.name),
                    subtitle: Text('\$${portfolio.getTotalValue().toStringAsFixed(2)}'),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AssetsPage(portfolio: portfolio))),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deletePortfolio(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      // le widget "FloatingActionButton" affiche un bouton flottant et permet d'ajouter un portefeuille
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
        context: context,
        builder: (BuildContext context) {
      return AlertDialog(
          title: Text('Add Portfolio'),
    content: Form(
    key: _formKey,
    child: TextFormField(
    controller: _portfolioNameController,
    decoration: InputDecoration
      (
      hintText: 'Portfolio name',
    ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a portfolio name';
        }
        return null;
      },
    ),
    ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          // le bouton pour ajouter le portefeuille à la liste des portefeuilles
          ElevatedButton(
            onPressed: () {
              _addPortfolio();
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      );
        },
        ),
          child: Icon(Icons.add),
        ),
    );
  }
}
