import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'portfolio.dart';

// la classe représente la page "Ajouter" une crypto
class AddAssetPage extends StatefulWidget {
  final Portfolio portfolio;

  // c'est le constructeur pour AddAssetPage, c'est lui qui prend un objet "portfolio" en parametre
  AddAssetPage({Key? key, required this.portfolio}) : super(key: key);

  // la fonction est appelée quand la page "AddAssetPage" est crée pour la première fois
  @override
  _AddAssetPageState createState() => _AddAssetPageState();
}

// la classe "State" est privée pour la fonction "AddAssetPage"
class _AddAssetPageState extends State<AddAssetPage> {
  final _formKey = GlobalKey<FormState>();   // création d'une clé globale qui identifie de manière unique le widget "Form" et permet la validation du formulaire
  // créer des "TextEditingController" pour le nom, le symbole et la valeur de la crypto
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _valueController = TextEditingController();

  // cette fonction construit l'arborescence des widgets pour la page AddAssetPage
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // le widget "AppBar" pour afficher une barre d'outil en haut de l'écran
    appBar: AppBar(
        title: Text('Add Asset'),
      ),
      // le widget Padding pour encadrer son enfant avec un espace
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // le widget "Form" qui crée une section d'un formulaire
        child: Form(
          key: _formKey,
          child: Column(
            // le widget "Column" qui organise les enfants de manière verticale
          crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // le widget "TextFormField" affiche un champ de saisie de texte
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name (bitcoin)'),
                // la fonction "validator"  est appelée lorsque le formulaire est validé
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _symbolController,
                decoration: InputDecoration(labelText: 'Symbol (BTC)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a symbol';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(labelText: 'Quantité (1)'),
                // on spécifie le type de saisie de texte
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
              // le widget "ElevatedButton" affiche un bouton surélevée
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final asset = Asset(
                      name: _nameController.text,
                      symbol: _symbolController.text,
                      value: double.parse(_valueController.text),
                      dollars: 0,
                    );
                    // on ajoute la crypto au portfolio
                    widget.portfolio.addAsset(asset);
                    // on ferme la page "Ajouter" d'une crypto et on revient à la page précédente
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
