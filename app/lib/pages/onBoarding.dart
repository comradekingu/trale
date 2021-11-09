import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/pages/home.dart';
import 'package:trale/pages/settings.dart';
import 'package:trale/widget/weightPicker.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {

  /// shared preferences instance
  final Preferences prefs = Preferences();

  late double _currentSliderValue;

  void _onIntroEnd(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const Home()),
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/$assetName', width: width);
  }

  List<bool> unitIsSelected =
    TraleUnit.values.map(
            (TraleUnit unit) => unit == TraleUnit.kg
    ).toList();

  @override
  void initState() {
    _currentSliderValue = prefs.userTargetWeight
      ?? prefs.defaultUserWeight;
    // super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TraleNotifier notifier =
      Provider.of<TraleNotifier>(context, listen: false);
    final String askingForName = prefs.userName == ''
      ? 'How shall we call you?'
      : 'Hi ' + prefs.userName + ' \u{1F44B}';

    final double _sliderLabel = (
        _currentSliderValue * notifier.unit.ticksPerStep
    ).roundToDouble() / notifier.unit.ticksPerStep;

    final PageDecoration pageDecoration = PageDecoration(
      titleTextStyle: Theme.of(context).textTheme.headline4!,
      titlePadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
        vertical: TraleTheme.of(context)!.padding,
      ),
      descriptionPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding),
      imagePadding: EdgeInsets.all(2 * TraleTheme.of(context)!.padding),
      contentMargin: EdgeInsets.zero,
      boxDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            TraleTheme.of(context)!.bg,
            TraleTheme.of(context)!.bgShade4,
          ],
        )
      ),
      footerPadding: EdgeInsets.zero,
    );

    final List<PageViewModel> pageViewModels = <PageViewModel>[
      PageViewModel(
        title: 'Welcome to trale  \u{1F642}',
        body: 'This privacy-friendly app provides a simple, yet beautiful log '
          'of your body weight.',
        image: _buildImage(
          'launcher/foreground_crop2.png',
          MediaQuery.of(context).size.width / 2,
        ),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: 'Loose weight with ease',
        body: 'Tracking body weight facilitates weight-loss. ',
        image: _buildImage(
          'launcher/foreground_crop2.png',
          MediaQuery.of(context).size.width / 2,
        ),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: 'What is your feel-good weight?',
        image: _buildImage(
          'launcher/foreground_crop2.png',
          MediaQuery.of(context).size.width / 2,
        ),
        decoration: pageDecoration.copyWith(
          descriptionPadding: EdgeInsets.zero),
        bodyWidget: Column(
          children: <Widget>[
            Text('${((_currentSliderValue * notifier.unit.ticksPerStep
                      ).roundToDouble() / notifier.unit.ticksPerStep
                     ).toStringAsFixed(notifier.unit.precision)} '
                '${notifier.unit.name}',
              style: Theme.of(context).textTheme.headline4!,
            ),
            SizedBox(height: TraleTheme.of(context)!.padding),
            Container(
              width: MediaQuery.of(context).size.width,
              child: RulerPicker(
                onValueChange: (num newValue) {
                  setState(() => _currentSliderValue = newValue.toDouble());
                },
                width: MediaQuery.of(context).size.width,
                value: _currentSliderValue,
                ticksPerStep: notifier.unit.ticksPerStep,
              ),
            ),
            SizedBox(height: TraleTheme.of(context)!.padding),
            ToggleButtons(
              renderBorder: false,
              fillColor: Colors.transparent,
              constraints: BoxConstraints(
                minWidth:  MediaQuery.of(context).size.width / 5
              ),
              children: TraleUnit.values.map(
                (TraleUnit unit) => Text(
                  unit.name,
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                    color: unit == Provider.of<TraleNotifier>(context).unit
                      ?  TraleTheme.of(context)!.accent
                      :  TraleTheme.of(context)!.bgFont
                  ),
                )
              ).toList(),
              isSelected: unitIsSelected,
              onPressed: (int index) {
                setState(() {
                  // prev unit to estimate unit scaling
                  TraleUnit prevUnit = notifier.unit;
                  unitIsSelected = TraleUnit.values.map(
                    (TraleUnit unit) => unit == TraleUnit.values[index]
                  ).toList();
                  notifier.unit = TraleUnit.values[index];

                  _currentSliderValue /=
                    (notifier.unit.scaling / prevUnit.scaling);

                  print(_currentSliderValue);
                });
              },
            ),
          ],
        ),
      ),
      PageViewModel(
        title: askingForName,
        bodyWidget: Container(
          width: 2 / 3 * MediaQuery.of(context).size.width,
          child: TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.person),
              hintText: 'What do people call you?',
              labelText: 'Name',
            ),
            initialValue: notifier.userName,
            onFieldSubmitted: (String? name) {
              setState(() => prefs.userName = name ?? '');
            },
          ),
        ),
        image: _buildImage(
          'launcher/foreground_crop2.png',
          MediaQuery.of(context).size.width / 2,
        ),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: "What's your body size",
        bodyWidget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('click')
          ],
        ),
        image: _buildImage(
          'launcher/foreground_crop2.png',
          MediaQuery.of(context).size.width / 2,
        ),
        decoration: pageDecoration,
      ),
    ];

    return IntroductionScreen(
      globalBackgroundColor: TraleTheme.of(context)!.bgShade4,
      isTopSafeArea: true,
      pages: pageViewModels,
      onDone: () {
        prefs.showOnboarding = false;
        _onIntroEnd(context);
      },
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      //rtl: true, // Display as right-to-left
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done'),
      skipColor: TraleTheme.of(context)!.bgFont,
      nextColor: TraleTheme.of(context)!.bgFont,
      doneColor: TraleTheme.of(context)!.bgFont,
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: EdgeInsets.all(2 * TraleTheme.of(context)!.padding),
      controlsPadding: EdgeInsets.symmetric(
          vertical: TraleTheme.of(context)!.padding / 2,
          horizontal: TraleTheme.of(context)!.padding),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: TraleTheme.of(context)!.bgFont,
        activeSize: const Size(22.0, 10.0),
        activeShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
        activeColor: TraleTheme.of(context)!.accent,
      ),
    );
  }
}
