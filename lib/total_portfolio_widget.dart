import 'package:flutter/material.dart';
import 'portfolio.dart';

// cette classe représente un widget qui affiche la valeur totale de tout les portefeuilles
class TotalPortfolioWidget extends StatelessWidget {
  final List<Portfolio> portfolios;
  final String symbol;

  // le constructeur pour "TotalPortfolioWidget"
  TotalPortfolioWidget({required this.portfolios, required this.symbol});

  // on calcule la valeur totale de tous les portefeuilles
  double _calculateTotalValue() {
    return portfolios.fold(
      0,
      (total, portfolio) => total + portfolio.getTotalValue(),
    );
  }

  // on calcule la variation totale de tous les portefeuilles sur les dernières 24 heures
  double _calculateTotalChange() {
    return portfolios.fold(
      0,
      (total, portfolio) => total + portfolio.change24h,
    );
  }

  // on construit l'interface utilisateur du widget
  @override
  Widget build(BuildContext context) {
    final totalValue = _calculateTotalValue();
    final totalChange = _calculateTotalChange();
    print(totalChange);
    // retourne un widget "Card" contenant un widget "ListTile" avec la valeur totale qui indique la variation totale
    return Card(
      child: ListTile(
        title: Text('Total Portfolio'),
        subtitle: Text('\$ $totalValue'),
        trailing: totalChange >= 0
            ? Icon(
                Icons.trending_up,
                color: Colors.green,
              )
            : Icon(
                Icons.trending_down,
                color: Colors.red,
              ),
      ),
    );
  }
}
