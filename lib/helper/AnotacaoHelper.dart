import 'package:minhas_notas/model/Anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AnotacaoHelper {

  static final String tabela = "anotacao";
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database _db;

  factory AnotacaoHelper(){
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal(){
  }

  get db async {

    if( _db != null ){
      return _db;
    }else{
      _db = await inicializarDB();
      return _db;
    }
  }

  _onCreate(Database db, int version) async {

    String sql = "CREATE TABLE $tabela ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "titulo VARCHAR, "
        "descricao TEXT, "
        "data DATETIME,"
        "status INTEGER)";
    await db.execute(sql);

  }

  inicializarDB() async {

    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados, "minhas_anotacoes2.db");

    var db = await openDatabase(localBancoDados, version: 1, onCreate: _onCreate );
    return db;

  }

  Future<int> salvarAnotacao(Anotacao anotacao) async {

    var dados = await db;
    int resposta = await dados.insert(tabela, anotacao.toMap() );
    return resposta;

  }

  listarAnotacoes() async {

    var dados = await db;
    String sql = "SELECT * FROM $tabela WHERE status = 0 ORDER BY data DESC ";
    List anotacoes = await dados.rawQuery( sql );
    return anotacoes;

  }

  listarAnotacoesLixeira() async {

    var dados = await db;
    String sql = "SELECT * FROM $tabela WHERE status = 1 ORDER BY data DESC ";
    List anotacoes = await dados.rawQuery( sql );
    return anotacoes;

  }

  listarAnotacoesArquivo() async {

    var dados = await db;
    String sql = "SELECT * FROM $tabela WHERE status = 2 ORDER BY data DESC ";
    List anotacoes = await dados.rawQuery( sql );
    return anotacoes;

  }

  Future<int> atulizarAnotacao(Anotacao anotacao) async{

    var dados = await db;
    return await dados.update(
        tabela,
        anotacao.toMap(),
        where: "id = ?",
        whereArgs: [anotacao.id]
    );
  }

  Future<int> excluirAnotacao(int id) async {

    var dados = await db;
    return await dados.delete(
        tabela,
        where: "id = ?",
        whereArgs: [id]
    );
  }

}