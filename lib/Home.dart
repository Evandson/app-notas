import 'package:flutter/material.dart';
import 'package:minhas_notas/Arquivo.dart';
import 'package:minhas_notas/Lixeira.dart';
import 'package:minhas_notas/helper/AnotacaoHelper.dart';
import 'package:minhas_notas/model/Anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = List<Anotacao>();

  _cadastro( {Anotacao anotacao} ){

    String texto = "";
    if(anotacao == null){//salvar
      _tituloController.text = "";
      _descricaoController.text = "";
      texto = "Salvar";
    }else{//atualizar
      _tituloController.text = anotacao.titulo;
      _descricaoController.text = anotacao.descricao;
      texto = "Atualizar";
    }

    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("$texto anotação"),
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
                      hintText: "Digite a descrição"
                  ),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar")
              ),
              FlatButton(
                  onPressed: (){

                    _salvarAtualizarAnotacao(anotacaoEsc: anotacao);
                    Navigator.pop(context);
                  },
                  child: Text(texto)
              )
            ],
          );
        }
    );
  }

  /*_confirmarExcluir( {Anotacao anotacao} ){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Deseja excluir anotação?"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar")
              ),
              FlatButton(
                  onPressed: (){

                    _excluirAnotacao(anotacao.id);
                    Navigator.pop(context);
                  },
                  child: Text("Excluir", style: TextStyle(color: Colors.red),)
              )
            ],
          );
        }
    );
  }*/

  _formatData(String data){
    initializeDateFormatting("pt_BR");

    var f = DateFormat("dd/MM/yy");
    //var f = DateFormat.yMd("pt_BR");

    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = f.format(dataConvertida);

    return dataFormatada;

  }

  _listarAnotacoes() async {

    List anotacoesListadas = await _db.listarAnotacoes();

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

  _salvarAtualizarAnotacao({Anotacao anotacaoEsc}) async {

    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    if (anotacaoEsc == null) {//salvar
      Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString(), 0);
      int resultado = await _db.salvarAnotacao(anotacao);
    }else{//atualizar
      anotacaoEsc.titulo = titulo;
      anotacaoEsc.descricao = descricao;
      anotacaoEsc.data = DateTime.now().toString();
      int resultado = await _db.atulizarAnotacao(anotacaoEsc);
    }

    _tituloController.clear();
    _descricaoController.clear();

    _listarAnotacoes();

  }

  _moverAnotacaoParaLixeira ({Anotacao anotacaoEsc}) async{

    int statusAtual = 1;//lixeira
    anotacaoEsc.status = statusAtual;
    int resultado = await _db.atulizarAnotacao(anotacaoEsc);

    _listarAnotacoes();
  }

  _moverAnotacaoParaArquivo ({Anotacao anotacaoEsc}) async{

    int statusAtual = 2;//arquivo
    anotacaoEsc.status = statusAtual;
    int resultado = await _db.atulizarAnotacao(anotacaoEsc);

    _listarAnotacoes();
  }

  @override
  void initState() {
    super.initState();
    _listarAnotacoes();
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
                  _cadastro(anotacao: anotacao);
                },
                child: Padding(padding: EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.edit,
                    color: Colors.blue,
                  ),
                )
            ),
            GestureDetector(
              onTap: (){
                _moverAnotacaoParaArquivo(anotacaoEsc:anotacao );

                final snackbar = SnackBar(
                  duration: Duration(seconds: 1),
                  content:  Text("Anotação arquivada"),
                );

                Scaffold.of(context).showSnackBar(snackbar);
              },
              child: Padding(padding: EdgeInsets.only(right: 0),
                child: Icon(
                  Icons.archive,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),

      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        _moverAnotacaoParaLixeira(anotacaoEsc: anotacao);

        final snackbar = SnackBar(
          duration: Duration(seconds: 1),
          content:  Text("Movida para lixeira"),
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
              Icons.delete,
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
              Icons.delete,
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
            title: Text("Anotações",
              style:
              TextStyle(
                  color: Colors.white
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.delete, color: Colors.white,),
              onPressed: () => Navigator.pushReplacement
                (context,
                  MaterialPageRoute
                    (builder: (context) => Lixeira())),
            ),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.note,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pushReplacement
                  (context,
                    MaterialPageRoute(builder: (context) => Arquivo())),
              )
            ],
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
          ),

          floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              child: Icon(Icons.add),
              onPressed: (){
                _cadastro();
              }
          ),
        )
    );
  }
}
