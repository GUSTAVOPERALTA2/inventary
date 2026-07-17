// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LotesTable extends Lotes with TableInfo<$LotesTable, Lote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaCreacionMeta = const VerificationMeta(
    'fechaCreacion',
  );
  @override
  late final GeneratedColumn<DateTime> fechaCreacion =
      GeneratedColumn<DateTime>(
        'fecha_creacion',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        clientDefault: () => DateTime.now(),
      );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, nombre, fechaCreacion, orden];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('fecha_creacion')) {
      context.handle(
        _fechaCreacionMeta,
        fechaCreacion.isAcceptableOrUnknown(
          data['fecha_creacion']!,
          _fechaCreacionMeta,
        ),
      );
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      fechaCreacion: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_creacion'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
    );
  }

  @override
  $LotesTable createAlias(String alias) {
    return $LotesTable(attachedDatabase, alias);
  }
}

class Lote extends DataClass implements Insertable<Lote> {
  final int id;
  final String nombre;
  final DateTime fechaCreacion;
  final int orden;
  const Lote({
    required this.id,
    required this.nombre,
    required this.fechaCreacion,
    required this.orden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['fecha_creacion'] = Variable<DateTime>(fechaCreacion);
    map['orden'] = Variable<int>(orden);
    return map;
  }

  LotesCompanion toCompanion(bool nullToAbsent) {
    return LotesCompanion(
      id: Value(id),
      nombre: Value(nombre),
      fechaCreacion: Value(fechaCreacion),
      orden: Value(orden),
    );
  }

  factory Lote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lote(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      fechaCreacion: serializer.fromJson<DateTime>(json['fechaCreacion']),
      orden: serializer.fromJson<int>(json['orden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'fechaCreacion': serializer.toJson<DateTime>(fechaCreacion),
      'orden': serializer.toJson<int>(orden),
    };
  }

  Lote copyWith({
    int? id,
    String? nombre,
    DateTime? fechaCreacion,
    int? orden,
  }) => Lote(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    orden: orden ?? this.orden,
  );
  Lote copyWithCompanion(LotesCompanion data) {
    return Lote(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      fechaCreacion: data.fechaCreacion.present
          ? data.fechaCreacion.value
          : this.fechaCreacion,
      orden: data.orden.present ? data.orden.value : this.orden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lote(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('orden: $orden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, fechaCreacion, orden);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lote &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.fechaCreacion == this.fechaCreacion &&
          other.orden == this.orden);
}

class LotesCompanion extends UpdateCompanion<Lote> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<DateTime> fechaCreacion;
  final Value<int> orden;
  const LotesCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
    this.orden = const Value.absent(),
  });
  LotesCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.fechaCreacion = const Value.absent(),
    this.orden = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<Lote> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<DateTime>? fechaCreacion,
    Expression<int>? orden,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (fechaCreacion != null) 'fecha_creacion': fechaCreacion,
      if (orden != null) 'orden': orden,
    });
  }

  LotesCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<DateTime>? fechaCreacion,
    Value<int>? orden,
  }) {
    return LotesCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      orden: orden ?? this.orden,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (fechaCreacion.present) {
      map['fecha_creacion'] = Variable<DateTime>(fechaCreacion.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LotesCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('orden: $orden')
          ..write(')'))
        .toString();
  }
}

class $ArticulosTable extends Articulos
    with TableInfo<$ArticulosTable, Articulo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticulosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<int> loteId = GeneratedColumn<int>(
    'lote_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lotes (id)',
    ),
  );
  static const VerificationMeta _noSerieMeta = const VerificationMeta(
    'noSerie',
  );
  @override
  late final GeneratedColumn<String> noSerie = GeneratedColumn<String>(
    'no_serie',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<double> cantidad = GeneratedColumn<double>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fotoPathMeta = const VerificationMeta(
    'fotoPath',
  );
  @override
  late final GeneratedColumn<String> fotoPath = GeneratedColumn<String>(
    'foto_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unidadMedidaMeta = const VerificationMeta(
    'unidadMedida',
  );
  @override
  late final GeneratedColumn<String> unidadMedida = GeneratedColumn<String>(
    'unidad_medida',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _precioUnitarioMeta = const VerificationMeta(
    'precioUnitario',
  );
  @override
  late final GeneratedColumn<double> precioUnitario = GeneratedColumn<double>(
    'precio_unitario',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  customValues = GeneratedColumn<String>(
    'custom_values',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Map<String, dynamic>>($ArticulosTable.$convertercustomValues);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    loteId,
    noSerie,
    descripcion,
    cantidad,
    fotoPath,
    unidadMedida,
    precioUnitario,
    customValues,
    createdAt,
    orden,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'articulos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Articulo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lote_id')) {
      context.handle(
        _loteIdMeta,
        loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_loteIdMeta);
    }
    if (data.containsKey('no_serie')) {
      context.handle(
        _noSerieMeta,
        noSerie.isAcceptableOrUnknown(data['no_serie']!, _noSerieMeta),
      );
    } else if (isInserting) {
      context.missing(_noSerieMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descripcionMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('foto_path')) {
      context.handle(
        _fotoPathMeta,
        fotoPath.isAcceptableOrUnknown(data['foto_path']!, _fotoPathMeta),
      );
    }
    if (data.containsKey('unidad_medida')) {
      context.handle(
        _unidadMedidaMeta,
        unidadMedida.isAcceptableOrUnknown(
          data['unidad_medida']!,
          _unidadMedidaMeta,
        ),
      );
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
        _precioUnitarioMeta,
        precioUnitario.isAcceptableOrUnknown(
          data['precio_unitario']!,
          _precioUnitarioMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Articulo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Articulo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      loteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lote_id'],
      )!,
      noSerie: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}no_serie'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cantidad'],
      )!,
      fotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_path'],
      ),
      unidadMedida: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidad_medida'],
      )!,
      precioUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_unitario'],
      )!,
      customValues: $ArticulosTable.$convertercustomValues.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}custom_values'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
    );
  }

  @override
  $ArticulosTable createAlias(String alias) {
    return $ArticulosTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $convertercustomValues =
      const MapJsonConverter();
}

class Articulo extends DataClass implements Insertable<Articulo> {
  final int id;
  final int loteId;
  final String noSerie;
  final String descripcion;
  final double cantidad;
  final String? fotoPath;
  final String unidadMedida;
  final double precioUnitario;
  final Map<String, dynamic> customValues;
  final DateTime createdAt;
  final int orden;
  const Articulo({
    required this.id,
    required this.loteId,
    required this.noSerie,
    required this.descripcion,
    required this.cantidad,
    this.fotoPath,
    required this.unidadMedida,
    required this.precioUnitario,
    required this.customValues,
    required this.createdAt,
    required this.orden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lote_id'] = Variable<int>(loteId);
    map['no_serie'] = Variable<String>(noSerie);
    map['descripcion'] = Variable<String>(descripcion);
    map['cantidad'] = Variable<double>(cantidad);
    if (!nullToAbsent || fotoPath != null) {
      map['foto_path'] = Variable<String>(fotoPath);
    }
    map['unidad_medida'] = Variable<String>(unidadMedida);
    map['precio_unitario'] = Variable<double>(precioUnitario);
    {
      map['custom_values'] = Variable<String>(
        $ArticulosTable.$convertercustomValues.toSql(customValues),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['orden'] = Variable<int>(orden);
    return map;
  }

  ArticulosCompanion toCompanion(bool nullToAbsent) {
    return ArticulosCompanion(
      id: Value(id),
      loteId: Value(loteId),
      noSerie: Value(noSerie),
      descripcion: Value(descripcion),
      cantidad: Value(cantidad),
      fotoPath: fotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPath),
      unidadMedida: Value(unidadMedida),
      precioUnitario: Value(precioUnitario),
      customValues: Value(customValues),
      createdAt: Value(createdAt),
      orden: Value(orden),
    );
  }

  factory Articulo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Articulo(
      id: serializer.fromJson<int>(json['id']),
      loteId: serializer.fromJson<int>(json['loteId']),
      noSerie: serializer.fromJson<String>(json['noSerie']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      cantidad: serializer.fromJson<double>(json['cantidad']),
      fotoPath: serializer.fromJson<String?>(json['fotoPath']),
      unidadMedida: serializer.fromJson<String>(json['unidadMedida']),
      precioUnitario: serializer.fromJson<double>(json['precioUnitario']),
      customValues: serializer.fromJson<Map<String, dynamic>>(
        json['customValues'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      orden: serializer.fromJson<int>(json['orden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'loteId': serializer.toJson<int>(loteId),
      'noSerie': serializer.toJson<String>(noSerie),
      'descripcion': serializer.toJson<String>(descripcion),
      'cantidad': serializer.toJson<double>(cantidad),
      'fotoPath': serializer.toJson<String?>(fotoPath),
      'unidadMedida': serializer.toJson<String>(unidadMedida),
      'precioUnitario': serializer.toJson<double>(precioUnitario),
      'customValues': serializer.toJson<Map<String, dynamic>>(customValues),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'orden': serializer.toJson<int>(orden),
    };
  }

  Articulo copyWith({
    int? id,
    int? loteId,
    String? noSerie,
    String? descripcion,
    double? cantidad,
    Value<String?> fotoPath = const Value.absent(),
    String? unidadMedida,
    double? precioUnitario,
    Map<String, dynamic>? customValues,
    DateTime? createdAt,
    int? orden,
  }) => Articulo(
    id: id ?? this.id,
    loteId: loteId ?? this.loteId,
    noSerie: noSerie ?? this.noSerie,
    descripcion: descripcion ?? this.descripcion,
    cantidad: cantidad ?? this.cantidad,
    fotoPath: fotoPath.present ? fotoPath.value : this.fotoPath,
    unidadMedida: unidadMedida ?? this.unidadMedida,
    precioUnitario: precioUnitario ?? this.precioUnitario,
    customValues: customValues ?? this.customValues,
    createdAt: createdAt ?? this.createdAt,
    orden: orden ?? this.orden,
  );
  Articulo copyWithCompanion(ArticulosCompanion data) {
    return Articulo(
      id: data.id.present ? data.id.value : this.id,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      noSerie: data.noSerie.present ? data.noSerie.value : this.noSerie,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      fotoPath: data.fotoPath.present ? data.fotoPath.value : this.fotoPath,
      unidadMedida: data.unidadMedida.present
          ? data.unidadMedida.value
          : this.unidadMedida,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
      customValues: data.customValues.present
          ? data.customValues.value
          : this.customValues,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      orden: data.orden.present ? data.orden.value : this.orden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Articulo(')
          ..write('id: $id, ')
          ..write('loteId: $loteId, ')
          ..write('noSerie: $noSerie, ')
          ..write('descripcion: $descripcion, ')
          ..write('cantidad: $cantidad, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('unidadMedida: $unidadMedida, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('customValues: $customValues, ')
          ..write('createdAt: $createdAt, ')
          ..write('orden: $orden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    loteId,
    noSerie,
    descripcion,
    cantidad,
    fotoPath,
    unidadMedida,
    precioUnitario,
    customValues,
    createdAt,
    orden,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Articulo &&
          other.id == this.id &&
          other.loteId == this.loteId &&
          other.noSerie == this.noSerie &&
          other.descripcion == this.descripcion &&
          other.cantidad == this.cantidad &&
          other.fotoPath == this.fotoPath &&
          other.unidadMedida == this.unidadMedida &&
          other.precioUnitario == this.precioUnitario &&
          other.customValues == this.customValues &&
          other.createdAt == this.createdAt &&
          other.orden == this.orden);
}

class ArticulosCompanion extends UpdateCompanion<Articulo> {
  final Value<int> id;
  final Value<int> loteId;
  final Value<String> noSerie;
  final Value<String> descripcion;
  final Value<double> cantidad;
  final Value<String?> fotoPath;
  final Value<String> unidadMedida;
  final Value<double> precioUnitario;
  final Value<Map<String, dynamic>> customValues;
  final Value<DateTime> createdAt;
  final Value<int> orden;
  const ArticulosCompanion({
    this.id = const Value.absent(),
    this.loteId = const Value.absent(),
    this.noSerie = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.unidadMedida = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.customValues = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.orden = const Value.absent(),
  });
  ArticulosCompanion.insert({
    this.id = const Value.absent(),
    required int loteId,
    required String noSerie,
    required String descripcion,
    required double cantidad,
    this.fotoPath = const Value.absent(),
    this.unidadMedida = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    required Map<String, dynamic> customValues,
    this.createdAt = const Value.absent(),
    this.orden = const Value.absent(),
  }) : loteId = Value(loteId),
       noSerie = Value(noSerie),
       descripcion = Value(descripcion),
       cantidad = Value(cantidad),
       customValues = Value(customValues);
  static Insertable<Articulo> custom({
    Expression<int>? id,
    Expression<int>? loteId,
    Expression<String>? noSerie,
    Expression<String>? descripcion,
    Expression<double>? cantidad,
    Expression<String>? fotoPath,
    Expression<String>? unidadMedida,
    Expression<double>? precioUnitario,
    Expression<String>? customValues,
    Expression<DateTime>? createdAt,
    Expression<int>? orden,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (loteId != null) 'lote_id': loteId,
      if (noSerie != null) 'no_serie': noSerie,
      if (descripcion != null) 'descripcion': descripcion,
      if (cantidad != null) 'cantidad': cantidad,
      if (fotoPath != null) 'foto_path': fotoPath,
      if (unidadMedida != null) 'unidad_medida': unidadMedida,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
      if (customValues != null) 'custom_values': customValues,
      if (createdAt != null) 'created_at': createdAt,
      if (orden != null) 'orden': orden,
    });
  }

  ArticulosCompanion copyWith({
    Value<int>? id,
    Value<int>? loteId,
    Value<String>? noSerie,
    Value<String>? descripcion,
    Value<double>? cantidad,
    Value<String?>? fotoPath,
    Value<String>? unidadMedida,
    Value<double>? precioUnitario,
    Value<Map<String, dynamic>>? customValues,
    Value<DateTime>? createdAt,
    Value<int>? orden,
  }) {
    return ArticulosCompanion(
      id: id ?? this.id,
      loteId: loteId ?? this.loteId,
      noSerie: noSerie ?? this.noSerie,
      descripcion: descripcion ?? this.descripcion,
      cantidad: cantidad ?? this.cantidad,
      fotoPath: fotoPath ?? this.fotoPath,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      customValues: customValues ?? this.customValues,
      createdAt: createdAt ?? this.createdAt,
      orden: orden ?? this.orden,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<int>(loteId.value);
    }
    if (noSerie.present) {
      map['no_serie'] = Variable<String>(noSerie.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<double>(cantidad.value);
    }
    if (fotoPath.present) {
      map['foto_path'] = Variable<String>(fotoPath.value);
    }
    if (unidadMedida.present) {
      map['unidad_medida'] = Variable<String>(unidadMedida.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<double>(precioUnitario.value);
    }
    if (customValues.present) {
      map['custom_values'] = Variable<String>(
        $ArticulosTable.$convertercustomValues.toSql(customValues.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticulosCompanion(')
          ..write('id: $id, ')
          ..write('loteId: $loteId, ')
          ..write('noSerie: $noSerie, ')
          ..write('descripcion: $descripcion, ')
          ..write('cantidad: $cantidad, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('unidadMedida: $unidadMedida, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('customValues: $customValues, ')
          ..write('createdAt: $createdAt, ')
          ..write('orden: $orden')
          ..write(')'))
        .toString();
  }
}

class $CustomFieldDefinitionsTable extends CustomFieldDefinitions
    with TableInfo<$CustomFieldDefinitionsTable, CustomFieldDefinition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomFieldDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CampoTipo, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CampoTipo>($CustomFieldDefinitionsTable.$convertertipo);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> opciones =
      GeneratedColumn<String>(
        'opciones',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>(
        $CustomFieldDefinitionsTable.$converteropcionesn,
      );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    clientDefault: () => true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    tipo,
    opciones,
    orden,
    activo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_field_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomFieldDefinition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    } else if (isInserting) {
      context.missing(_ordenMeta);
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomFieldDefinition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomFieldDefinition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      tipo: $CustomFieldDefinitionsTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      opciones: $CustomFieldDefinitionsTable.$converteropcionesn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}opciones'],
        ),
      ),
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
    );
  }

  @override
  $CustomFieldDefinitionsTable createAlias(String alias) {
    return $CustomFieldDefinitionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CampoTipo, String, String> $convertertipo =
      const EnumNameConverter<CampoTipo>(CampoTipo.values);
  static TypeConverter<List<String>, String> $converteropciones =
      const StringListJsonConverter();
  static TypeConverter<List<String>?, String?> $converteropcionesn =
      NullAwareTypeConverter.wrap($converteropciones);
}

class CustomFieldDefinition extends DataClass
    implements Insertable<CustomFieldDefinition> {
  final int id;
  final String nombre;
  final CampoTipo tipo;
  final List<String>? opciones;
  final int orden;
  final bool activo;
  const CustomFieldDefinition({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.opciones,
    required this.orden,
    required this.activo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    {
      map['tipo'] = Variable<String>(
        $CustomFieldDefinitionsTable.$convertertipo.toSql(tipo),
      );
    }
    if (!nullToAbsent || opciones != null) {
      map['opciones'] = Variable<String>(
        $CustomFieldDefinitionsTable.$converteropcionesn.toSql(opciones),
      );
    }
    map['orden'] = Variable<int>(orden);
    map['activo'] = Variable<bool>(activo);
    return map;
  }

  CustomFieldDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return CustomFieldDefinitionsCompanion(
      id: Value(id),
      nombre: Value(nombre),
      tipo: Value(tipo),
      opciones: opciones == null && nullToAbsent
          ? const Value.absent()
          : Value(opciones),
      orden: Value(orden),
      activo: Value(activo),
    );
  }

  factory CustomFieldDefinition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomFieldDefinition(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      tipo: $CustomFieldDefinitionsTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      opciones: serializer.fromJson<List<String>?>(json['opciones']),
      orden: serializer.fromJson<int>(json['orden']),
      activo: serializer.fromJson<bool>(json['activo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'tipo': serializer.toJson<String>(
        $CustomFieldDefinitionsTable.$convertertipo.toJson(tipo),
      ),
      'opciones': serializer.toJson<List<String>?>(opciones),
      'orden': serializer.toJson<int>(orden),
      'activo': serializer.toJson<bool>(activo),
    };
  }

  CustomFieldDefinition copyWith({
    int? id,
    String? nombre,
    CampoTipo? tipo,
    Value<List<String>?> opciones = const Value.absent(),
    int? orden,
    bool? activo,
  }) => CustomFieldDefinition(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    tipo: tipo ?? this.tipo,
    opciones: opciones.present ? opciones.value : this.opciones,
    orden: orden ?? this.orden,
    activo: activo ?? this.activo,
  );
  CustomFieldDefinition copyWithCompanion(
    CustomFieldDefinitionsCompanion data,
  ) {
    return CustomFieldDefinition(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      opciones: data.opciones.present ? data.opciones.value : this.opciones,
      orden: data.orden.present ? data.orden.value : this.orden,
      activo: data.activo.present ? data.activo.value : this.activo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomFieldDefinition(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('tipo: $tipo, ')
          ..write('opciones: $opciones, ')
          ..write('orden: $orden, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, tipo, opciones, orden, activo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomFieldDefinition &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.tipo == this.tipo &&
          other.opciones == this.opciones &&
          other.orden == this.orden &&
          other.activo == this.activo);
}

class CustomFieldDefinitionsCompanion
    extends UpdateCompanion<CustomFieldDefinition> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<CampoTipo> tipo;
  final Value<List<String>?> opciones;
  final Value<int> orden;
  final Value<bool> activo;
  const CustomFieldDefinitionsCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.tipo = const Value.absent(),
    this.opciones = const Value.absent(),
    this.orden = const Value.absent(),
    this.activo = const Value.absent(),
  });
  CustomFieldDefinitionsCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required CampoTipo tipo,
    this.opciones = const Value.absent(),
    required int orden,
    this.activo = const Value.absent(),
  }) : nombre = Value(nombre),
       tipo = Value(tipo),
       orden = Value(orden);
  static Insertable<CustomFieldDefinition> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? tipo,
    Expression<String>? opciones,
    Expression<int>? orden,
    Expression<bool>? activo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (tipo != null) 'tipo': tipo,
      if (opciones != null) 'opciones': opciones,
      if (orden != null) 'orden': orden,
      if (activo != null) 'activo': activo,
    });
  }

  CustomFieldDefinitionsCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<CampoTipo>? tipo,
    Value<List<String>?>? opciones,
    Value<int>? orden,
    Value<bool>? activo,
  }) {
    return CustomFieldDefinitionsCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      opciones: opciones ?? this.opciones,
      orden: orden ?? this.orden,
      activo: activo ?? this.activo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $CustomFieldDefinitionsTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (opciones.present) {
      map['opciones'] = Variable<String>(
        $CustomFieldDefinitionsTable.$converteropcionesn.toSql(opciones.value),
      );
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomFieldDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('tipo: $tipo, ')
          ..write('opciones: $opciones, ')
          ..write('orden: $orden, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LotesTable lotes = $LotesTable(this);
  late final $ArticulosTable articulos = $ArticulosTable(this);
  late final $CustomFieldDefinitionsTable customFieldDefinitions =
      $CustomFieldDefinitionsTable(this);
  late final LotesDao lotesDao = LotesDao(this as AppDatabase);
  late final ArticulosDao articulosDao = ArticulosDao(this as AppDatabase);
  late final CustomFieldDefinitionsDao customFieldDefinitionsDao =
      CustomFieldDefinitionsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    lotes,
    articulos,
    customFieldDefinitions,
  ];
}

typedef $$LotesTableCreateCompanionBuilder =
    LotesCompanion Function({
      Value<int> id,
      required String nombre,
      Value<DateTime> fechaCreacion,
      Value<int> orden,
    });
typedef $$LotesTableUpdateCompanionBuilder =
    LotesCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<DateTime> fechaCreacion,
      Value<int> orden,
    });

final class $$LotesTableReferences
    extends BaseReferences<_$AppDatabase, $LotesTable, Lote> {
  $$LotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ArticulosTable, List<Articulo>>
  _articulosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.articulos,
    aliasName: 'lotes__id__articulos__lote_id',
  );

  $$ArticulosTableProcessedTableManager get articulosRefs {
    final manager = $$ArticulosTableTableManager(
      $_db,
      $_db.articulos,
    ).filter((f) => f.loteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_articulosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LotesTableFilterComposer extends Composer<_$AppDatabase, $LotesTable> {
  $$LotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> articulosRefs(
    Expression<bool> Function($$ArticulosTableFilterComposer f) f,
  ) {
    final $$ArticulosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articulos,
      getReferencedColumn: (t) => t.loteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticulosTableFilterComposer(
            $db: $db,
            $table: $db.articulos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LotesTableOrderingComposer
    extends Composer<_$AppDatabase, $LotesTable> {
  $$LotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LotesTable> {
  $$LotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  Expression<T> articulosRefs<T extends Object>(
    Expression<T> Function($$ArticulosTableAnnotationComposer a) f,
  ) {
    final $$ArticulosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articulos,
      getReferencedColumn: (t) => t.loteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticulosTableAnnotationComposer(
            $db: $db,
            $table: $db.articulos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LotesTable,
          Lote,
          $$LotesTableFilterComposer,
          $$LotesTableOrderingComposer,
          $$LotesTableAnnotationComposer,
          $$LotesTableCreateCompanionBuilder,
          $$LotesTableUpdateCompanionBuilder,
          (Lote, $$LotesTableReferences),
          Lote,
          PrefetchHooks Function({bool articulosRefs})
        > {
  $$LotesTableTableManager(_$AppDatabase db, $LotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<DateTime> fechaCreacion = const Value.absent(),
                Value<int> orden = const Value.absent(),
              }) => LotesCompanion(
                id: id,
                nombre: nombre,
                fechaCreacion: fechaCreacion,
                orden: orden,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                Value<DateTime> fechaCreacion = const Value.absent(),
                Value<int> orden = const Value.absent(),
              }) => LotesCompanion.insert(
                id: id,
                nombre: nombre,
                fechaCreacion: fechaCreacion,
                orden: orden,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$LotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({articulosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (articulosRefs) db.articulos],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (articulosRefs)
                    await $_getPrefetchedData<Lote, $LotesTable, Articulo>(
                      currentTable: table,
                      referencedTable: $$LotesTableReferences
                          ._articulosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LotesTableReferences(db, table, p0).articulosRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.loteId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LotesTable,
      Lote,
      $$LotesTableFilterComposer,
      $$LotesTableOrderingComposer,
      $$LotesTableAnnotationComposer,
      $$LotesTableCreateCompanionBuilder,
      $$LotesTableUpdateCompanionBuilder,
      (Lote, $$LotesTableReferences),
      Lote,
      PrefetchHooks Function({bool articulosRefs})
    >;
typedef $$ArticulosTableCreateCompanionBuilder =
    ArticulosCompanion Function({
      Value<int> id,
      required int loteId,
      required String noSerie,
      required String descripcion,
      required double cantidad,
      Value<String?> fotoPath,
      Value<String> unidadMedida,
      Value<double> precioUnitario,
      required Map<String, dynamic> customValues,
      Value<DateTime> createdAt,
      Value<int> orden,
    });
typedef $$ArticulosTableUpdateCompanionBuilder =
    ArticulosCompanion Function({
      Value<int> id,
      Value<int> loteId,
      Value<String> noSerie,
      Value<String> descripcion,
      Value<double> cantidad,
      Value<String?> fotoPath,
      Value<String> unidadMedida,
      Value<double> precioUnitario,
      Value<Map<String, dynamic>> customValues,
      Value<DateTime> createdAt,
      Value<int> orden,
    });

final class $$ArticulosTableReferences
    extends BaseReferences<_$AppDatabase, $ArticulosTable, Articulo> {
  $$ArticulosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LotesTable _loteIdTable(_$AppDatabase db) =>
      db.lotes.createAlias('articulos__lote_id__lotes__id');

  $$LotesTableProcessedTableManager get loteId {
    final $_column = $_itemColumn<int>('lote_id')!;

    final manager = $$LotesTableTableManager(
      $_db,
      $_db.lotes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_loteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ArticulosTableFilterComposer
    extends Composer<_$AppDatabase, $ArticulosTable> {
  $$ArticulosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noSerie => $composableBuilder(
    column: $table.noSerie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidadMedida => $composableBuilder(
    column: $table.unidadMedida,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>,
    Map<String, dynamic>,
    String
  >
  get customValues => $composableBuilder(
    column: $table.customValues,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  $$LotesTableFilterComposer get loteId {
    final $$LotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loteId,
      referencedTable: $db.lotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotesTableFilterComposer(
            $db: $db,
            $table: $db.lotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticulosTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticulosTable> {
  $$ArticulosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noSerie => $composableBuilder(
    column: $table.noSerie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidadMedida => $composableBuilder(
    column: $table.unidadMedida,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customValues => $composableBuilder(
    column: $table.customValues,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  $$LotesTableOrderingComposer get loteId {
    final $$LotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loteId,
      referencedTable: $db.lotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotesTableOrderingComposer(
            $db: $db,
            $table: $db.lotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticulosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticulosTable> {
  $$ArticulosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get noSerie =>
      $composableBuilder(column: $table.noSerie, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<String> get fotoPath =>
      $composableBuilder(column: $table.fotoPath, builder: (column) => column);

  GeneratedColumn<String> get unidadMedida => $composableBuilder(
    column: $table.unidadMedida,
    builder: (column) => column,
  );

  GeneratedColumn<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  get customValues => $composableBuilder(
    column: $table.customValues,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  $$LotesTableAnnotationComposer get loteId {
    final $$LotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loteId,
      referencedTable: $db.lotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotesTableAnnotationComposer(
            $db: $db,
            $table: $db.lotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticulosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticulosTable,
          Articulo,
          $$ArticulosTableFilterComposer,
          $$ArticulosTableOrderingComposer,
          $$ArticulosTableAnnotationComposer,
          $$ArticulosTableCreateCompanionBuilder,
          $$ArticulosTableUpdateCompanionBuilder,
          (Articulo, $$ArticulosTableReferences),
          Articulo,
          PrefetchHooks Function({bool loteId})
        > {
  $$ArticulosTableTableManager(_$AppDatabase db, $ArticulosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticulosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticulosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticulosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> loteId = const Value.absent(),
                Value<String> noSerie = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<double> cantidad = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
                Value<String> unidadMedida = const Value.absent(),
                Value<double> precioUnitario = const Value.absent(),
                Value<Map<String, dynamic>> customValues = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> orden = const Value.absent(),
              }) => ArticulosCompanion(
                id: id,
                loteId: loteId,
                noSerie: noSerie,
                descripcion: descripcion,
                cantidad: cantidad,
                fotoPath: fotoPath,
                unidadMedida: unidadMedida,
                precioUnitario: precioUnitario,
                customValues: customValues,
                createdAt: createdAt,
                orden: orden,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int loteId,
                required String noSerie,
                required String descripcion,
                required double cantidad,
                Value<String?> fotoPath = const Value.absent(),
                Value<String> unidadMedida = const Value.absent(),
                Value<double> precioUnitario = const Value.absent(),
                required Map<String, dynamic> customValues,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> orden = const Value.absent(),
              }) => ArticulosCompanion.insert(
                id: id,
                loteId: loteId,
                noSerie: noSerie,
                descripcion: descripcion,
                cantidad: cantidad,
                fotoPath: fotoPath,
                unidadMedida: unidadMedida,
                precioUnitario: precioUnitario,
                customValues: customValues,
                createdAt: createdAt,
                orden: orden,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ArticulosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({loteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (loteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.loteId,
                                referencedTable: $$ArticulosTableReferences
                                    ._loteIdTable(db),
                                referencedColumn: $$ArticulosTableReferences
                                    ._loteIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ArticulosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticulosTable,
      Articulo,
      $$ArticulosTableFilterComposer,
      $$ArticulosTableOrderingComposer,
      $$ArticulosTableAnnotationComposer,
      $$ArticulosTableCreateCompanionBuilder,
      $$ArticulosTableUpdateCompanionBuilder,
      (Articulo, $$ArticulosTableReferences),
      Articulo,
      PrefetchHooks Function({bool loteId})
    >;
typedef $$CustomFieldDefinitionsTableCreateCompanionBuilder =
    CustomFieldDefinitionsCompanion Function({
      Value<int> id,
      required String nombre,
      required CampoTipo tipo,
      Value<List<String>?> opciones,
      required int orden,
      Value<bool> activo,
    });
typedef $$CustomFieldDefinitionsTableUpdateCompanionBuilder =
    CustomFieldDefinitionsCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<CampoTipo> tipo,
      Value<List<String>?> opciones,
      Value<int> orden,
      Value<bool> activo,
    });

class $$CustomFieldDefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomFieldDefinitionsTable> {
  $$CustomFieldDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CampoTipo, CampoTipo, String> get tipo =>
      $composableBuilder(
        column: $table.tipo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get opciones => $composableBuilder(
    column: $table.opciones,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomFieldDefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomFieldDefinitionsTable> {
  $$CustomFieldDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opciones => $composableBuilder(
    column: $table.opciones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomFieldDefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomFieldDefinitionsTable> {
  $$CustomFieldDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CampoTipo, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get opciones =>
      $composableBuilder(column: $table.opciones, builder: (column) => column);

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);
}

class $$CustomFieldDefinitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomFieldDefinitionsTable,
          CustomFieldDefinition,
          $$CustomFieldDefinitionsTableFilterComposer,
          $$CustomFieldDefinitionsTableOrderingComposer,
          $$CustomFieldDefinitionsTableAnnotationComposer,
          $$CustomFieldDefinitionsTableCreateCompanionBuilder,
          $$CustomFieldDefinitionsTableUpdateCompanionBuilder,
          (
            CustomFieldDefinition,
            BaseReferences<
              _$AppDatabase,
              $CustomFieldDefinitionsTable,
              CustomFieldDefinition
            >,
          ),
          CustomFieldDefinition,
          PrefetchHooks Function()
        > {
  $$CustomFieldDefinitionsTableTableManager(
    _$AppDatabase db,
    $CustomFieldDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomFieldDefinitionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CustomFieldDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CustomFieldDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<CampoTipo> tipo = const Value.absent(),
                Value<List<String>?> opciones = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<bool> activo = const Value.absent(),
              }) => CustomFieldDefinitionsCompanion(
                id: id,
                nombre: nombre,
                tipo: tipo,
                opciones: opciones,
                orden: orden,
                activo: activo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                required CampoTipo tipo,
                Value<List<String>?> opciones = const Value.absent(),
                required int orden,
                Value<bool> activo = const Value.absent(),
              }) => CustomFieldDefinitionsCompanion.insert(
                id: id,
                nombre: nombre,
                tipo: tipo,
                opciones: opciones,
                orden: orden,
                activo: activo,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomFieldDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomFieldDefinitionsTable,
      CustomFieldDefinition,
      $$CustomFieldDefinitionsTableFilterComposer,
      $$CustomFieldDefinitionsTableOrderingComposer,
      $$CustomFieldDefinitionsTableAnnotationComposer,
      $$CustomFieldDefinitionsTableCreateCompanionBuilder,
      $$CustomFieldDefinitionsTableUpdateCompanionBuilder,
      (
        CustomFieldDefinition,
        BaseReferences<
          _$AppDatabase,
          $CustomFieldDefinitionsTable,
          CustomFieldDefinition
        >,
      ),
      CustomFieldDefinition,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LotesTableTableManager get lotes =>
      $$LotesTableTableManager(_db, _db.lotes);
  $$ArticulosTableTableManager get articulos =>
      $$ArticulosTableTableManager(_db, _db.articulos);
  $$CustomFieldDefinitionsTableTableManager get customFieldDefinitions =>
      $$CustomFieldDefinitionsTableTableManager(
        _db,
        _db.customFieldDefinitions,
      );
}
