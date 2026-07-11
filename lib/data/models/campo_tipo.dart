/// Tipo de dato de un campo configurable (custom_field_definitions.tipo).
enum CampoTipo { texto, entero, decimal, fecha, lista }

extension CampoTipoLabel on CampoTipo {
  String get label => switch (this) {
        CampoTipo.texto => 'Texto',
        CampoTipo.entero => 'Entero',
        CampoTipo.decimal => 'Decimal',
        CampoTipo.fecha => 'Fecha',
        CampoTipo.lista => 'Lista',
      };
}
