import 'package:minhas_notas/model/Anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AnotacaoHelper {

  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database _db;
  static final String nomeTabela = "anotacao";

  factory AnotacaoHelper(){
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal(){
  }

  get db async {
    if(_db != null){
      return _db;
    }else{
      _db = await inicializarDB();
      return _db;
    }
  }

  _onCreate(Database db, int version) async {
    String sql = "CREATE TABLE $nomeTabela o (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo VARCHAR, descricao TEXT, data DATETIME)";
    await db.execute(sql);
  }

  inicializarDB() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados, "banco_anotacoes.db");
    
    var db = await openDatabase(localBancoDados, version: 1, onCreate: _onCreate);
    
  }

  Future<int> salvarAnotacao(Anotacao anotacao) async {
    var dados = await db;
    int resposta = await dados.insert(nomeTabela, anotacao.toMap() );
    return resposta;
  }

}