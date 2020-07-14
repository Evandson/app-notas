import 'package:flutter/material.dart';
import 'package:minhas_notas/Home.dart';
import 'package:minhas_notas/helper/AnotacaoHelper.dart';
import 'package:minhas_notas/model/Anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Lixeira extends StatefulWidget {
  @override
  _LixeiraState createState() => _LixeiraState();
}

class _LixeiraState extends State<Lixeira> {

  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = List<Anotacao>();


  _formatData(String data){
    initializeDateFormatting("pt_BR");

    var f = DateFormat("dd/MM/yy");
    //var f = DateFormat.yMd("pt_BR");

    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = f.format(dataConvertida);

    return dataFormatada;

  }

  _listarAnotacoesLixeira() async {

    List anotacoesListadas = await _db.listarAnotacoesLixeira();

    List<Anotacao> listaTemp = List<Anotacao>();
    for( var item in anotacoesListadas ){

      Anotacao anotacao = Anotacao.fromMap( item );
      listaTemp.add( anotacao );

    }

    setState(() {
      _anotacoes = listaTemp;
    });
    listaTemp = null;

  }

  _excluirAnotacao(int id) async {

    await _db.excluirAnotacao(id);

    _listarAnotacoesLixeira();

  }

  _restaurarAnotacao ({Anotacao anotacaoEsc}) async{

    int statusAtual = 0;//lixeira
    anotacaoEsc.status = statusAtual;
    int resultado = await _db.atulizarAnotacao(anotacaoEsc);

    _listarAnotacoesLixeira();
  }

  @override
  void initState() {
    super.initState();
    _listarAnotacoesLixeira();
  }

  Widget criarItemLista(context, index){
    final anotacao = _anotacoes[index];

    return Dismissible(
      child: ListTile(
        title: Text(anotacao.titulo, style: TextStyle(fontSize: 18),),
        subtitle: Text("${_formatData(anotacao.data)} - ${anotacao.descricao}") ,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
                onTap: (){
                  _restaurarAnotacao(anotacaoEsc: anotacao);

                  final snackbar = SnackBar(
                    duration: Duration(seconds: 1),
                    content:  Text("Restaurada para o início"),
                  );

                  Scaffold.of(context).showSnackBar(snackbar);
                },
                child: Padding(padding: EdgeInsets.only(right: 5),
                  child: Icon(
                    Icons.restore_from_trash,
                    color: Colors.green,
                  ),
                )
            )
          ],
        ),
      ),

      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        _excluirAnotacao(anotacao.id);

        final snackbar = SnackBar(
          duration: Duration(seconds: 1),
          content:  Text("Anotação excluída"),
        );

        Scaffold.of(context).showSnackBar(snackbar);

      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.delete_forever,
              color: Colors.white,
            )
          ],
        ),
      ),

      secondaryBackground: Container(
        color: Colors.red,
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete_forever,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: Text("Lixeira",
                style:
                TextStyle(
                    color: Colors.white
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.home, color: Colors.white,),
                onPressed: () => Navigator.pushReplacement
                  (context,
                    MaterialPageRoute
                      (builder: (context) => Home())),
              ),
              centerTitle: true,
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                      itemCount: _anotacoes.length,
                      itemBuilder: criarItemLista
                  ),
                )
              ],
            )
        )
    );
  }
}
