import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'portfolio.dart';
import 'portfolio_storage.dart';

// on définit un type de rappel qui prend un objet "Asset" en paramètre et il ne renvoie rien
typedef AssetAddedCallback = void Function(Asset asset);

// la classe représente la page "Ajouter" une crypto
class AddAssetPage extends StatefulWidget {
  final Portfolio portfolio;
  final AssetAddedCallback onAssetAdded;

  // le constructeur pour "AddAssetPage" qui prend un objet Portfolio et un rappel en paramètre
  AddAssetPage({Key? key, required this.portfolio, required this.onAssetAdded})
      : super(key: key);

  // la fonction est appelée lorsque la page "AddAssetPage" est créée pour la premiere fois
  @override
  _AddAssetPageState createState() => _AddAssetPageState();
}

//  la classe State privée pour "AddAssetPage"
class _AddAssetPageState extends State<AddAssetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _valueController = TextEditingController();

  // cette fonction construit l'arborescence des widgets pour la page "AddAssetPage"
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // le widget "AppBar" pour afficher une barre d'outil en haut de l'écran
    appBar: AppBar(
        title: Text('Add Asset'),
      ),
      // le widget "Padding" encadre son enfant avec un espace
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // le widget "Form" crée une section du formulaire
        child: Form(
          key: _formKey,
          child: Column(
            // le widget "Column" organise ses enfants verticalement
          crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // le widget "TextFormField" affiche un champ texte
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                // la fonction "validator" est appelée quand le formulaire est validé
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _symbolController,
                decoration: InputDecoration(labelText: 'Symbol'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a symbol';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(labelText: 'Value'),
                // on spécifie le type de  saisie de texte
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  return null;
                },
              ),
              // le widget "ElevatedButton" affiche un bouton surélevé
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final asset = Asset(
                        name: _nameController.text,
                        symbol: _symbolController.text,
                        value: double.parse(_valueController.text),
                        dollars: 0);
                    widget.portfolio.addAsset(asset);
                    widget.onAssetAdded(asset);
                    PortfolioStorage.savePortfolios([
                      widget.portfolio
                    ]);
                    Navigator.pop(context);
                  }
                },
                child: Text('Add Asset'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// cette classe représente la page des crypto
class AssetsPage extends StatefulWidget {
  final Portfolio portfolio;

  // le constructeur pour "AssetsPage" qui prend un objet Portfolio en paramètre
  AssetsPage({Key? key, required this.portfolio}) : super(key: key);

  // cette fonction est appelée quand la page "AssetsPage" est crée pour la première fois
  @override
  _AssetsPageState createState() => _AssetsPageState();
}


//la classe State privée pour "AssetsPage"
class _AssetsPageState extends State<AssetsPage> {
  late Portfolio _portfolio;


  // la fonction est appelée lorsque la page "AssetsPage" est insérée dans l'arborescence
  @override
  void initState() {
    super.initState();
    _portfolio = widget.portfolio;
  }

  // la fonction supprime un actif du portefeuille
  void _deleteAsset(Asset asset) {
    setState(() {
      _portfolio.removeAsset(asset);
    });
  }

  // la fonction affiche une boîte de dialogue pour modifier les name, sympbol et la value de la crypto
  void _editAsset(Asset asset) {
    // affiche une boite de dialogue avec des champs de texte pour modifier le nom, le symbole et la valeur de l'actif
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // crée des controleurs de texte pour les champs avec les valeurs actuelles de la crypto
        final _nameController = TextEditingController(text: asset.name);
        final _symbolController = TextEditingController(text: asset.symbol);
        final _valueController = TextEditingController(text: asset.value.toString());

        return AlertDialog(
          title: Text('Edit Asset'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // champ de texte pour modifier les noms, symboles et les valeurs de la crypto
                TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
                TextField(controller: _symbolController, decoration: InputDecoration(labelText: 'Symbol')),
                TextField(controller: _valueController, decoration: InputDecoration(labelText: 'Value'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: <Widget>[
            // un bouton "Cancel" pour fermer la boîte de dialogue
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // un bouton "Save" pour mettre à jour l'actif avec les nouvelles valeurs
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  // met à jour la crypto avec les nouvelles valeurs
                  asset.name = _nameController.text;
                  asset.symbol = _symbolController.text;
                  asset.value = double.tryParse(_valueController.text) ?? asset.value;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // cette fonction met a jour les prix des cryptos
  Future<void> _updateAssetPrices() async {
    try {
      final prices = await fetchPrices(_portfolio.assets
          .map((asset) => asset.name)
          .toList());
      setState(() {
        for (final asset in _portfolio.assets) {
          final assetData = prices[asset.name.toLowerCase()];
          if (assetData != null) {
            final newValue = assetData['usd'] * asset.value;
            asset.dollars = newValue;
          }
        }
      });
    } catch (e) {
      print('Error updating asset prices: $e');
    }
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assets of ${_portfolio.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _updateAssetPrices,
          ),
        ],
      ),
      // le widget "ListView.builder" construit une liste défilable d'éléments
      body: ListView.builder(
        itemCount: _portfolio.assets.length,
        itemBuilder: (BuildContext context, int index) {
          final asset = _portfolio.assets[index];
          print(asset.value);
          print(asset.dollars);
          return ListTile(
            title: Text(asset.name),
            subtitle: Text('\$ ${asset.dollars}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editAsset(asset);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteAsset(asset);
                  },
                ),
              ],
            ),
          );
        },
      ),
      // ce bouton "FloatingActionButton" si il est pressé ouvre une nouvelle page "AddAssetPage"
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAssetPage(
                portfolio: _portfolio,
                onAssetAdded: (asset) {
                  setState(() {
                    _portfolio.addAsset(asset);
                  });
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
