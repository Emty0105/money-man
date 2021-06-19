import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:money_man/core/models/event_model.dart';
import 'package:money_man/core/models/super_icon_model.dart';
import 'package:money_man/core/models/wallet_model.dart';
import 'package:money_man/core/services/firebase_firestore_services.dart';
import 'package:money_man/ui/screens/wallet_selection_screens/wallet_account_screen.dart';
import 'package:money_man/ui/style.dart';
import 'package:money_man/ui/widgets/custom_alert.dart';
import 'package:money_man/ui/widgets/icon_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/src/intl/date_format.dart';

class EditEventScreen extends StatefulWidget {
  Event currentEvent;
  Wallet eventWallet;
  EditEventScreen({Key key, this.currentEvent, this.eventWallet}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _EditEventScreen();
  }
}
class _EditEventScreen extends State<EditEventScreen>
    with TickerProviderStateMixin {
  Event _currentEvent;
  Wallet _eventWallet;
  DateTime endDate;

  String iconPath ;

  String currencySymbol = 'Viet Nam Dong';

  String nameEvent;
  DateTime formatTransDate;
  @override
  void initState() {
    _currentEvent = widget.currentEvent;
    _eventWallet = widget.eventWallet;
    endDate = _currentEvent.endDate;
    iconPath = _currentEvent.iconPath;
    currencySymbol = _eventWallet.currencyID;
    nameEvent = _currentEvent.name;
    formatTransDate = DateTime(widget.currentEvent.endDate.year,
        widget.currentEvent.endDate.month, widget.currentEvent.endDate.day);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final _firestore = Provider.of<FirebaseFireStoreService>(context);
    return Scaffold(
      backgroundColor: Colors.black26,
      appBar: AppBar(
        leadingWidth: 380,
        elevation: 0,
        backgroundColor: Color(0xff1a1a1a),
        leading: TextButton(
          child: Row(
            children: [
              const Icon(Icons.arrow_back_ios_outlined,
                  color: Colors.white, size: 16.0),
            ],
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Edit event',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            )
        ),
        actions: [
          TextButton(
              onPressed: () async {
                if (_currentEvent == null) {
                  _showAlertDialog('Please pick your wallet!');
                } else if (nameEvent == null) {
                  _showAlertDialog('Please enter name!');
                } else if (iconPath == null) {
                  _showAlertDialog('Please pick category');
                } else {
                     _currentEvent.name = nameEvent;
                     _currentEvent.endDate = endDate;
                     _currentEvent.iconPath = iconPath;
                     _currentEvent.isFinished =   (endDate.year < DateTime
                         .now()
                         .year) ? true :
                     (endDate.month < DateTime
                         .now()
                         .month) ? true :
                     (endDate.day < DateTime
                         .now()
                         .day) ? true : false;
                     _currentEvent.walletId = _currentEvent.id;
                  await _firestore.updateEvent(_currentEvent, _eventWallet);
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.transparent,
              )
          )
        ],
      ),
      body: Container(
          color: Colors.black26,
          child: Form(
            child: buildInput(),
          )

      ),
    );
  }
  Widget buildInput() {
    return ListView(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              color: Colors.grey[900],
              margin: EdgeInsets.symmetric(vertical: 35.0, horizontal: 0.0),
              child: Column(
                children: [
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: SuperIcon(
                          iconPath: iconPath,
                          size: 49.0,
                        ),
                        onPressed: () async {
                          var data = await showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => IconPicker(),
                          );
                          if (data != null) {
                            setState(() {
                              iconPath = data;
                            });
                          }
                        },
                        iconSize: 70,
                        color: Color(0xff8f8f8f),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(right: 50),
                          width: 250,
                          child: TextFormField(
                            initialValue: _currentEvent.name,
                            autocorrect: false,
                            keyboardType: TextInputType.name,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                            ),
                            decoration: InputDecoration(
                              errorBorder: UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.red, width: 1),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.white60, width: 1),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.white60, width: 3),
                              ),
                              labelText: 'Name event',
                              labelStyle: TextStyle(
                                  color: Colors.white60, fontSize: 15),
                            ),
                            onChanged: (value) => nameEvent = value,
                            validator: (value) {
                              if (value == null || value.length == 0)
                                return 'Name is empty';
                              return (value != null && value.contains('@'))
                                  ? 'Do not use the @ char.'
                                  : null;
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(
                    thickness: 0.05,
                    color: Colors.white,
                  ),
                  ListTile(
                    dense: true,
                    leading:
                    Icon(Icons.calendar_today, color: Colors.white54, size: 28.0),
                    title: TextFormField(
                      onTap: () async {
                        DatePicker.showDatePicker(context,
                            currentTime:
                            endDate == null ? formatTransDate : endDate,
                            showTitleActions: true, onConfirm: (date) {
                              if (date != null) {
                                setState(() {
                                  endDate = date;
                                  _currentEvent.endDate = endDate;
                                });
                              }
                            },
                            locale: LocaleType.en,
                            theme: DatePickerTheme(
                              cancelStyle: TextStyle(
                                  fontFamily: Style.fontFamily,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: Style.foregroundColor
                              ),
                              doneStyle: TextStyle(
                                  fontFamily: Style.fontFamily,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: Style.foregroundColor
                              ),
                              itemStyle: TextStyle(
                                  fontFamily: Style.fontFamily,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                  color: Style.foregroundColor
                              ),
                              backgroundColor: Style.boxBackgroundColor,
                            ));
                      },
                      readOnly: true,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintStyle: TextStyle(
                            color: _currentEvent.endDate == null
                                ? Colors.grey[600]
                                : Colors.white,
                            fontFamily: 'Montserrat',
                            fontSize: 16.0,
                            fontWeight: _currentEvent.endDate == null
                                ? FontWeight.w500
                                : FontWeight.w600,
                          ),
                          hintText:
                              DateFormat('EEEE, dd-MM-yyyy')
                                  .format(_currentEvent.endDate),
                              ),
                    ),
                    trailing: Icon(Icons.chevron_right, color: Colors.white54),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(70, 0, 0, 0),
                    child: Divider(
                      color: Colors.white24,
                      height: 1,
                      thickness: 0.2,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                    },
                    dense: true,
                    leading: Icon(Icons.monetization_on,
                        size: 30.0, color: Colors.white54),
                    title: Text(currencySymbol,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0)),
                    trailing: Icon(Icons.lock,
                        size: 20.0, color: Colors.white54),
                  ),
                  Divider(
                    thickness: 0.05,
                    color: Colors.white,
                  ),
                  ListTile(
                    dense: true,
                    onTap: () async {
                      var res = await showCupertinoModalBottomSheet(
                          isDismissible: true,
                          backgroundColor: Colors.grey[900],
                          context: context,
                          builder: (context) =>
                              SelectWalletAccountScreen(wallet: _eventWallet));
                      if (res != null)
                        setState(() {
                          _eventWallet = res;
                        });
                    },
                    leading: _eventWallet == null
                        ? SuperIcon(iconPath: 'assets/icons/wallet_2.svg', size: 28.0)
                        : SuperIcon(iconPath: _eventWallet.iconID, size: 28.0),
                    title: TextFormField(
                      initialValue: _eventWallet.name,
                      readOnly: true,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintStyle: TextStyle(
                            color: _eventWallet == null
                                ? Colors.grey[600]
                                : Colors.white,
                            fontFamily: 'Montserrat',
                            fontSize: 16.0,
                            fontWeight: _eventWallet == null
                                ? FontWeight.w500
                                : FontWeight.w600,
                          ),
                          hintText: _eventWallet == null
                              ? 'Select wallet'
                              : _eventWallet.name),
                      onTap: () async {
                      },
                    ),
                    trailing: Icon(Icons.lock, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  Future<void> _showAlertDialog(String content) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return CustomAlert(content: content);
      },
    );
  }
}
