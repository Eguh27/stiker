import 'package:flutter/material.dart';

/// Input kuas tanpa slop gesture: coretan mulai tepat di titik sentuh.
/// Hanya satu jari yang dipakai; jari tambahan diabaikan.
class BrushInputLayer extends StatefulWidget {
  const BrushInputLayer({
    super.key,
    required this.factor,
    required this.onStart,
    required this.onMove,
    required this.onEnd,
    required this.child,
  });

  /// Pengali dari piksel layar ke koordinat kanvas (mis. 512 / lebar layar).
  final double factor;
  final ValueChanged<Offset> onStart;
  final ValueChanged<Offset> onMove;
  final VoidCallback onEnd;
  final Widget child;

  @override
  State<BrushInputLayer> createState() => _BrushInputLayerState();
}

class _BrushInputLayerState extends State<BrushInputLayer> {
  int? _pointer;

  void _finish(PointerEvent event) {
    if (event.pointer != _pointer) return;
    _pointer = null;
    widget.onEnd();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        if (_pointer != null) return;
        _pointer = event.pointer;
        widget.onStart(event.localPosition * widget.factor);
      },
      onPointerMove: (event) {
        if (event.pointer == _pointer) {
          widget.onMove(event.localPosition * widget.factor);
        }
      },
      onPointerUp: _finish,
      onPointerCancel: _finish,
      child: widget.child,
    );
  }
}
