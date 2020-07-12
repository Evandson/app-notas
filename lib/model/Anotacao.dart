class Anotacao {
  int id;
  String titulo;
  String descricao;
  String data;
  int status;

  Anotacao(this.titulo, this.descricao, this.data, this.status);

  Anotacao.fromMap(Map map) {
    this.id = map["id"];
    this.titulo = map["titulo"];
    this.descricao = map["descricao"];
    this.data = map["data"];
    this.status = map["status"];
  }

  Map toMap(){
    Map<String, dynamic> map = {
      "titulo" : this.titulo,
      "descricao" : this.descricao,
      "data" : this.data,
      "status" : this.status,
    };

    if(this.id != null){
      map["id"] = this.id;
    }
    return map;
  }
}