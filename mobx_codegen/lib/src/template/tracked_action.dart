import 'package:mobx_codegen/src/template/async_action.dart';

class TrackedActionTemplate extends AsyncActionTemplate {
  TrackedActionTemplate(
      {required super.storeTemplate,
      required super.method,
      required super.hasProtected,
      required super.hasVisibleForOverriding,
      required super.hasVisibleForTesting})
      : super(isObservable: false);

  String get _actionField => '_\$${method.name}TrackedAction';

  int get _paramsNumber => method.params.toString() == ''
      ? 0
      : method.params.toString().split(', ').length;

  String get _paramsTypes => method.params
      .toString()
      .split(', ')
      .map((e) => e.split(' ').first)
      .join(', ');

  String get _paramsNames => method.params
      .toString()
      .split(', ')
      .map((e) => e.split(' ').last)
      .join(', ');

  String get _tupleType => 'Tuple$_paramsNumber<$_paramsTypes>';

  String get _tupleParams =>
      List<String>.generate(_paramsNumber, (index) => 'tuple.item${index + 1}')
          .join(', ');

  String get _methodCall => _paramsNumber == 0
      ? '() => super.${method.name}()'
      : '(tuple) => super.${method.name}($_tupleParams)';

  String get _create =>
      _paramsNumber == 0 ? 'createNoParam' : 'create<$_tupleType>';

  String get _execute => _paramsNumber == 0
      ? 'execute()'
      : 'execute(Tuple$_paramsNumber($_paramsNames))';

  @override
  String toString() => """
  late final $_actionField = TrackedAction.$_create($_methodCall, name:'${storeTemplate.parentTypeName}.${method.name}');
  TrackedActionStatus get ${method.name}Status => ${_actionField}.status;

  @override
  Future${method.returnTypeArgs} ${method.name}${method.typeParams}(${method.params}) async => $_actionField.$_execute;
  """;
}
