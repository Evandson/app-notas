import 'package:flutter/material.dart';
import 'package:minhas_notas/helper/AnotacaoHelper.dart';
import 'package:minhas_notas/model/Anotacao.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();

  _cadastro() {
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Criar anotação"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Título",
                      hintText: "Digite o título"
                  ),
                ),
                TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                      labelText: "Descrição",
                      hintText: "Digite a Descrição"
                  ),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar"),
              ),
              FlatButton(
                onPressed: () {
                  _salvarAnotacao();
                },
                child: Text("Salvar"),
              ),
            ],
          );
        }
    );
    }
  _salvarAnotacao() async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;


    Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
    int resposta = await _db.salvarAnotacao(anotacao);

    _tituloController.clear();
    _descricaoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Anotações"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          onPressed: (){
            _cadastro();
          }
      ),
    );
  }
}
