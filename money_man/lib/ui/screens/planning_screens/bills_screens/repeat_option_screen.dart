import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_man/core/models/super_icon_model.dart';
import 'package:money_man/ui/widgets/expandable_widget.dart';

class RepeatOptionScreen extends StatefulWidget {
  const RepeatOptionScreen({Key key}) : super(key: key);

  @override
  _RepeatOptionScreenState createState() => _RepeatOptionScreenState();
}

class _RepeatOptionScreenState extends State<RepeatOptionScreen> {
  List<String> frequencyList;
  int selectedFrequencyIndex;

  String freqType;

  int rangeAmount;
  DateTime beginDateTime;
  DateTime endDateTime;
  int repeatTime;

  bool expandOption;
  int selectedOption;

  bool expandTypeOption;
  int selectedTypeOption;

  @override
  void initState() {
    // TODO: implement initState

    // Này là để lấy Frequency đang chọn để quyết định đơn vị của rangeAmount là ngày, tuần, tháng hay là năm.
    frequencyList = ['daily', 'weekly', 'monthly', 'yearly'];
    selectedFrequencyIndex = 0;

    // Biến để lưu chuỗi đơn vị cho rangeAmount.
    freqType = 'day';

    // Biến để lưu các giá trị tùy chọn.
    rangeAmount = 1;
    beginDateTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    endDateTime = beginDateTime.add(Duration(days: 1));
    repeatTime = 1;

    // Biến triggẻ để xử lý các tùy chọn.
    expandOption = false;
    selectedOption = 0;

    // Biến trigger để xử lý chọn loại lặp lại.
    expandTypeOption = false;
    selectedTypeOption = 1;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF111111),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Color(0xFF1c1c1c),
          elevation: 0.0,
          leading: CloseButton(
            onPressed: () {
                Navigator.of(context).pop();
            },
          ),
          title: Text('Repeat Options',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 17.0,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              )),
          centerTitle: true,
        ),
        body: ListView(
          physics:
          BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          children: [
            Container(
                color: Colors.grey[900],
                margin: EdgeInsets.only(top: 30.0),
                child: Column(
                  children: [
                    // Phần chọn Frequency
                    Column(
                          children: [
                            // Nút ấn để expand phần chọn Frequency
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (selectedOption != 1) {
                                      selectedOption = 1;
                                      expandOption = true;
                                    }
                                    else
                                      expandOption = !expandOption;
                                  });
                                },
                                child: buildFrequencyOption(display: 'Repeat ' + frequencyList[selectedFrequencyIndex])
                            ),

                            // Phần expand để chọn Frequency
                            ExpandableWidget(
                              expand: selectedOption != 1 ? false : expandOption,
                              child: Container(
                                height: 160,
                                decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    border: Border(
                                        bottom: BorderSide(
                                          color: Colors.white12,
                                          width: 0.5,
                                        )
                                    )
                                ),
                                child: CupertinoTheme(
                                  data: CupertinoThemeData(
                                      brightness: Brightness.dark,
                                      textTheme: CupertinoTextThemeData(
                                          pickerTextStyle: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w500,
                                          )
                                      )
                                  ),
                                  child: CupertinoPicker.builder(
                                      childCount: frequencyList.length,
                                      itemExtent: 30,
                                      scrollController: FixedExtentScrollController(initialItem: selectedFrequencyIndex),
                                      onSelectedItemChanged: (index) {
                                        setState(() {
                                          selectedFrequencyIndex = index;
                                          freqType = getFreqTypeString(selectedFrequencyIndex);
                                        });
                                      },
                                      itemBuilder: (context, index) {
                                        return Center(
                                          child: Text(
                                              'Repeat ' + frequencyList[index],
                                          ),
                                        );
                                      }
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),

                    // Phần chọn Range Amount
                    Column(
                          children: [
                            // Nút ấn để expand phần chọn Range Amount
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (selectedOption != 2) {
                                      selectedOption = 2;
                                      expandOption = true;
                                    }
                                    else
                                      expandOption = !expandOption;
                                  });
                                },
                                child: buildRangeOption(
                                    display: rangeAmount.toString() + ' ' + freqType + ((rangeAmount == 1) ? '' : 's')
                                )
                            ),

                            // Phần expand để chọn Range Amount
                            ExpandableWidget(
                              expand: selectedOption != 2 ? false : expandOption,
                              child: Container(
                                height: 160,
                                decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    border: Border(
                                        bottom: BorderSide(
                                          color: Colors.white12,
                                          width: 0.5,
                                        )
                                    )
                                ),
                                child: CupertinoTheme(
                                  data: CupertinoThemeData(
                                      brightness: Brightness.dark,
                                      textTheme: CupertinoTextThemeData(
                                          pickerTextStyle: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w500,
                                          )
                                      )
                                  ),
                                  child: CupertinoPicker.builder(
                                      itemExtent: 30,
                                      scrollController: FixedExtentScrollController(initialItem: rangeAmount - 1),
                                      onSelectedItemChanged: (index) {
                                        setState(() {
                                          rangeAmount = index + 1;
                                        });
                                      },
                                      itemBuilder: (context, index) {
                                        if (index >= 0) {
                                          return Center(
                                            child: Text(
                                                (index + 1).toString() + ' ' + freqType + ((index == 0) ? '' : 's'),
                                            ),
                                          );
                                        }
                                      }
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),

                    // Phần chọn Begin Date
                    Column(
                      children: [
                        // Nút ấn để expand phần chọn Begin Date
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                if (selectedOption != 3) {
                                  selectedOption = 3;
                                  expandOption = true;
                                }
                                else
                                  expandOption = !expandOption;
                              });
                            },
                            child: buildBeginDateOption(display: DateFormat('dd/MM/yyyy').format(beginDateTime))
                        ),

                        // Phần expand để chọn Begin Date
                        ExpandableWidget(
                          expand: selectedOption != 3 ? false : expandOption,
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                                color: Colors.grey[900],
                                border: Border(
                                    bottom: BorderSide(
                                      color: Colors.white12,
                                      width: 0.5,
                                    )
                                )
                            ),
                            child: CupertinoTheme(
                              data: CupertinoThemeData(
                                brightness: Brightness.dark,
                                textTheme: CupertinoTextThemeData(
                                  dateTimePickerTextStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                  )
                                )
                              ),
                              child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.date,
                                  initialDateTime: beginDateTime,
                                  onDateTimeChanged: (val) {
                                    setState(() {
                                      beginDateTime = val;
                                      endDateTime = beginDateTime.add(Duration(days: 1));
                                    });
                                  }),
                            ),
                          ),
                        )
                      ],
                    ),
                  ]
                )
            ),

            // Phần dưới này là phần chọn loại lặp lại.
            Container(
                color: Colors.grey[900],
                margin: EdgeInsets.only(top: 30.0),
                child: Column(
                    children: [

                      // Đây là phần chọn type Forever.
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTypeOption = 1;
                            });
                          },
                          child: buildForeverOption(selected: selectedTypeOption == 1)
                      ),

                      // Đây là phần chọn type Until.
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selectedTypeOption != 2) {
                                selectedTypeOption = 2;
                                expandTypeOption = true;
                              }
                              else
                                expandTypeOption = !expandTypeOption;
                            });
                          },
                          child: buildEndingDateOption(display: DateFormat('dd/MM/yyyy').format(endDateTime), selected: selectedTypeOption == 2)
                      ),
                      ExpandableWidget(
                        expand: selectedTypeOption != 2 ? false : expandTypeOption,
                        child: Container(
                          height: 160,
                          decoration: BoxDecoration(
                              color: Colors.grey[900],
                              border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white12,
                                    width: 0.5,
                                  )
                              )
                          ),
                          child: CupertinoTheme(
                            data: CupertinoThemeData(
                                brightness: Brightness.dark,
                                textTheme: CupertinoTextThemeData(
                                    dateTimePickerTextStyle: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                    )
                                )
                            ),
                            child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.date,
                                minimumDate: beginDateTime,
                                initialDateTime: endDateTime,
                                onDateTimeChanged: (val) {
                                  setState(() {
                                    endDateTime = val;
                                  });
                                }),
                          ),
                        ),
                      ),


                      // Đây là phần chọn type Until.
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selectedTypeOption != 3) {
                                selectedTypeOption = 3;
                                expandTypeOption = true;
                              }
                              else
                                expandTypeOption = !expandTypeOption;
                            });
                          },
                          child: buildRepeatTimeOption(
                              display: repeatTime.toString() + ' time' + (repeatTime == 1 ? '' : 's'),
                              selected: selectedTypeOption == 3
                          )
                      ),
                      ExpandableWidget(
                        expand: selectedTypeOption != 3 ? false : expandTypeOption,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                              color: Colors.grey[900],
                              border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white12,
                                    width: 0.5,
                                  )
                              )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80.0,
                                child: TextFormField(
                                  initialValue: repeatTime.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      repeatTime = int.parse(value);
                                    });
                                  },
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 15.0,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  keyboardAppearance: Brightness.dark,
                                  keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                                  decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 0),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide: BorderSide(
                                            color: Colors.white24,
                                            width: 0.5,
                                          )
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide: BorderSide(
                                            color: Colors.white24,
                                            width: 0.5,
                                          )
                                      ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                  'time(s)',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]
                )
            ),
          ],
        ));
  }

  Widget buildFrequencyOption({@required String display}) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 12, 15, 12),
      decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border(
              bottom: BorderSide(
                color: Colors.white12,
                width: 0.5,
              )
          )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Frequency',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              )),
          Text(display,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: Colors.white38,
              )),
        ],
      ),
    );
  }

  Widget buildRangeOption({@required String display}) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 12, 15, 12),
      decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border(
              bottom: BorderSide(
                color: Colors.white12,
                width: 0.5,
              )
          )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Every',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              )),
          Text(display,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: Colors.white38,
              )),
        ],
      ),
    );
  }

  Widget buildBeginDateOption({@required String display}) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 12, 15, 12),
      decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border(
              bottom: BorderSide(
                color: Colors.white12,
                width: 0.5,
              )
          )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('From',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              )),
          Text(display,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: Colors.white38,
              )),
        ],
      ),
    );
  }

  Widget buildForeverOption({@required bool selected}) {
    return Container(
        padding: EdgeInsets.fromLTRB(15, 12, 15, 12),
        decoration: BoxDecoration(
            color: Colors.grey[900],
            border: Border(
                bottom: BorderSide(
                  color: Colors.white12,
                  width: 0.5,
                )
            )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Forever',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                )),
            !selected ? Container() : Icon(Icons.check, color: Color(0xFF4FCC5C), size: 20.0),
            ],
        ),
    );
  }

  Widget buildEndingDateOption({@required String display, @required bool selected}) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 12, 15, 12),
      decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border(
              bottom: BorderSide(
                color: Colors.white12,
                width: 0.5,
              )
          )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Until',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              )),
          !selected ? Container() : Text(display,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: Colors.white38,
              )),
          !selected ? Container() : Icon(Icons.check, color: Color(0xFF4FCC5C), size: 20.0),
        ],
      ),
    );
  }

  Widget buildRepeatTimeOption({@required String display, @required selected}) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 12, 15, 12),
      decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border(
              bottom: BorderSide(
                color: Colors.white12,
                width: 0.5,
              )
          )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('For',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              )),
          !selected ? Container() : Text(display,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: Colors.white38,
              )),
          !selected ? Container() : Icon(Icons.check, color: Color(0xFF4FCC5C), size: 20.0),
        ],
      ),
    );
  }

  String getFreqTypeString(int indexFreq) {
    switch (indexFreq)
    {
      case 0:
        return 'day';
        break;
      case 1:
        return 'week';
        break;
      case 2:
        return 'month';
        break;
      case 3:
        return 'year';
        break;
    }
  }
}
