import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

/// A [StatefulWidget] that rebuilds when an [Observable] used inside
/// [State.build] updates.
///
/// See also:
///
/// - [Observer], which subclass this interface and delegate its `build` to a
///   callback.
/// - [StatelessObserverWidget], similar to this class, but with no [State].
abstract class StatefulObserverWidget extends StatefulWidget
    with ObserverWidgetMixin {
  /// Initializes [key], [context] and [name] for subclasses.
  const StatefulObserverWidget(
      {Key? key,
      ReactiveContext? context,
      String? name,
      ReactionCallback? onReaction})
      : _name = name,
        _context = context,
        _reactionCallback = onReaction,
        super(key: key);

  final String? _name;
  final ReactiveContext? _context;
  final ReactionCallback? _reactionCallback;

  @override
  String getName() => _name ?? '$this';

  @override
  ReactiveContext getContext() => _context ?? super.getContext();

  @override
  ReactionCallback? getReactionCallback() => _reactionCallback;

  @override
  StatefulObserverElement createElement() => StatefulObserverElement(this);

  @override
  StatefulObserverState createState();
}

abstract class StatefulObserverState<T extends StatefulObserverWidget>
    extends State<T> {
  void onInvalidate() {}
}

/// An [Element] that uses a [StatefulObserverWidget] as its configuration.
class StatefulObserverElement extends StatefulElement
    with ObserverElementMixin {
  /// Creates an element that uses the given widget as its configuration.
  StatefulObserverElement(StatefulObserverWidget widget) : super(widget);

  @override
  StatefulObserverWidget get widget => super.widget as StatefulObserverWidget;
}
