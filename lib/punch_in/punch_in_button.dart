
// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';

import '../models/punch_in.dart';

class PunchInButton extends StatefulWidget {
  final PunchIn punchedIn;
  final Function onPressed;

  const PunchInButton({super.key, required this.punchedIn, required this.onPressed});

  @override
  State<StatefulWidget> createState() {
    return PunchInButtonState(punchedIn, onPressed);
  }
}

class PunchInButtonState extends State<PunchInButton> with SingleTickerProviderStateMixin {
  final PunchIn punchedIn;
  final Function onPressed;
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: false);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  PunchInButtonState(this.punchedIn, this.onPressed);

  bool get _isPunchedIn => punchedIn.type == PunchInType.In;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    punchedIn.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => onPressed(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width / 1.5,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: _isPunchedIn ? Colors.green[50] : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                ),
                if (_isPunchedIn)
                  ScaleTransition(
                    scale: _animation,
                    child: Container(
                      height: MediaQuery.of(context).size.height / 2,
                      width: MediaQuery.of(context).size.width / 1.5,
                      decoration: BoxDecoration(
                        color: Colors.green[100]!.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                Column(
                  children: [
                    const Icon(
                      Icons.fingerprint_rounded,
                      size: 64,
                    ),
                    const Divider(
                      height: 10,
                      color: Colors.transparent,
                    ),
                    Text(
                      _isPunchedIn ? "You are punched in!" : "You are punched out!",
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}