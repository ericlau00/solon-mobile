import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Solon/app_localizations.dart';

class CreateEvent extends StatefulWidget {
  final Function _addEvent;
  CreateEvent(this._addEvent);

  @override
  _CreateEventState createState() => _CreateEventState(_addEvent);
}

class _CreateEventState extends State<CreateEvent> {
  List<Step> form = [];
  // final _formKey = GlobalKey<FormState>();
  final Function addEvent;
  FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  static var titleController = TextEditingController();
  static var descriptionController = TextEditingController();
  static var timeController = TextEditingController();
  static var controllers = [
    titleController,
    descriptionController,
    timeController
  ];

  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  int currentStep = 0;
  bool complete = false;

  goTo(int step) {
    setState(() => {currentStep = step});
    if (step == 2) _selectDate(context);
  }

  _CreateEventState(this.addEvent);

  Future<Null> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2020),
    );

    if (picked != null) {
      print('Date selected: ${_date.toString()}');
      _selectTime(context);
      setState(() {
        _date = picked;
      });
    }
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );

    if (picked != null) {
      print('Time selected: ${_time.toString()}');
      setState(() {
        _time = picked;
      });
    }
    timeController.text =
        "Event occurs on ${new DateFormat.yMMMMd("en_US").add_jm().format(_date)}";
  }

  @override
  Widget build(BuildContext context) {
    form = [
      Step(
        title: Text(AppLocalizations.of(context).translate('title')),
        isActive: currentStep == 0 ? true : false,
        state: currentStep == 0 ? StepState.editing : StepState.complete,
        content: TextFormField(
          autofocus: true,
          decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('title')),
          controller: titleController,
          autovalidate: true,
          validator: (value) {
            if (value.isEmpty) {
              return AppLocalizations.of(context).translate('pleaseEnterATitle');
            }
            return null;
          },
        ),
      ),
      Step(
        title: Text(AppLocalizations.of(context).translate('description')),
        isActive: currentStep == 1 ? true : false,
        state: currentStep == 1
            ? StepState.editing
            : currentStep < 1 ? StepState.disabled : StepState.complete,
        content: TextFormField(
          autofocus: true,
          focusNode: myFocusNode,
          decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('description')),
          controller: descriptionController,
          autovalidate: true,
          validator: (value) {
            if (value.isEmpty) {
              return AppLocalizations.of(context).translate('pleaseEnterADescription');
            }
            return null;
          },
        ),
      ),
      Step(
        title: Text(AppLocalizations.of(context).translate('dateAndTime')),
        isActive: currentStep == 2 ? true : false,
        state: currentStep == 2
            ? StepState.editing
            : currentStep < 2 ? StepState.disabled : StepState.complete,
        content: Column(
          children: <Widget>[
            TextFormField(
              autofocus: true,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('dateAndTime')),
              controller: timeController,
              autovalidate: true,
              validator: (value) {
                if (value.isEmpty) {
                  return AppLocalizations.of(context).translate('pleaseChooseADateAndTime');
                }
                return null;
              },
            ),
            RaisedButton(
              child: Text(AppLocalizations.of(context).translate('selectDateAndTime')),
              onPressed: () => _selectDate(context),
            ),
          ],
        ),
      )
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('createAnEvent')),
      ),
      body: Stepper(
        // key: _formKey,
        steps: form,
        currentStep: currentStep,
        onStepContinue: () => {
          currentStep + 1 != form.length
              ? {
                  if (controllers[currentStep].text.length > 0)
                    {
                      goTo(currentStep + 1),
                      FocusScope.of(context).requestFocus(myFocusNode)
                    }
                }
              : {
                  setState(() => complete = true),
                  addEvent(titleController.text, descriptionController.text,
                      _date, _time),
                  titleController.text = '',
                  descriptionController.text = '',
                  timeController.text = '',
                  Navigator.pop(context),
                }
        },
        onStepCancel: () => {
          if (currentStep > 0) {goTo(currentStep - 1)}
        },
        onStepTapped: (step) => goTo(step),
      ),
    );
  }
}
