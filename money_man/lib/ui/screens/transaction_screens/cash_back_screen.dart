import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:money_man/core/models/category_model.dart';
import 'package:money_man/core/models/super_icon_model.dart';
import 'package:money_man/core/models/transaction_model.dart';
import 'package:money_man/core/models/wallet_model.dart';
import 'package:intl/intl.dart';
import 'package:money_man/core/services/firebase_firestore_services.dart';
import 'package:money_man/ui/screens/shared_screens/enter_amount_screen.dart';
import 'package:money_man/ui/screens/shared_screens/note_srcreen.dart';
import 'package:money_man/ui/screens/wallet_selection_screens/wallet_account_screen.dart';
import 'package:money_man/ui/style.dart';
import 'package:money_man/ui/widgets/custom_alert.dart';
import 'package:money_man/ui/widgets/money_symbol_formatter.dart';
import 'package:provider/provider.dart';

class CashBackScreen extends StatefulWidget {
  final MyTransaction transaction;
  final Wallet wallet;
  const CashBackScreen({
    Key key,
    @required this.transaction,
    @required this.wallet,
  }) : super(key: key);

  @override
  _CashBackScreenState createState() => _CashBackScreenState();
}

class _CashBackScreenState extends State<CashBackScreen> {
  MyTransaction extraTransaction;
  DateTime pickDate;
  double amount;
  MyCategory cate;
  Wallet selectedWallet;
  String note;
  String currencySymbol;
  String contact;
  String hintTextConact;
  bool isDebt;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    extraTransaction = widget.transaction;
    amount = extraTransaction.extraAmountInfo;
    contact = extraTransaction.contact;
    isDebt = extraTransaction.category.name == 'Debt';
    note = isDebt ? 'Debt paid to ' : 'Payment received  from ';
    pickDate = DateTime.parse(DateFormat("yyyy-MM-dd").format(DateTime.now()));
    selectedWallet = widget.wallet;
    currencySymbol =
        CurrencyService().findByCode(selectedWallet.currencyID).symbol;
    hintTextConact = 'With';
  }

  @override
  Widget build(BuildContext context) {
    final _firestore =
        Provider.of<FirebaseFireStoreService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cash back'),
        actions: [
          TextButton(
              onPressed: () async {
                if (selectedWallet == null) {
                  _showAlertDialog('Please pick your wallet!');
                } else if (amount == null) {
                  _showAlertDialog('Please enter amount!');
                } else {
                  if (isDebt) {
                    cate = await _firestore
                        .getCategoryByID('gi4CfNNlUoPSQlluCvS1');
                  } else {
                    cate = await _firestore
                        .getCategoryByID('ZPltfjSWha3HvmIX5fgr');
                  }

                  MyTransaction trans = MyTransaction(
                    id: 'id',
                    amount: amount,
                    note: contact == null ? note + 'someone' : note + contact,
                    date: pickDate,
                    currencyID: selectedWallet.currencyID,
                    category: cate,
                    contact: contact,
                  );

                  if (extraTransaction != null) {
                    if (trans.amount > extraTransaction.extraAmountInfo) {
                      await _showAlertDialog(
                          'Inputted amount must be <= unpaid amount. Unpaid amount is ${extraTransaction.extraAmountInfo}');
                      return;
                    }

                    MyTransaction newTrans =
                        await _firestore.addTransaction(selectedWallet, trans);

                    await _firestore.updateDebtLoanTransationAfterAdd(
                        extraTransaction, newTrans, selectedWallet);
                  }

                  Navigator.pop(context);
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 35.0),
        decoration: BoxDecoration(
            color: Colors.grey[900],
            border: Border(
                top: BorderSide(
                  color: Colors.white12,
                  width: 0.5,
                ),
                bottom: BorderSide(
                  color: Colors.white12,
                  width: 0.5,
                ))),
        child: ListView(shrinkWrap: true, children: [
          Text('PAID FROM'),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(10, 0, 20, 0),
            minVerticalPadding: 10.0,
            onTap: () async {
              final resultAmount = await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => EnterAmountScreen()));
              if (resultAmount != null)
                setState(() {
                  print(resultAmount);
                  amount = double.parse(resultAmount);
                });
            },
            leading: Icon(Icons.money, color: Colors.white54, size: 45.0),
            title: TextFormField(
              readOnly: true,
              onTap: () async {
                final resultAmount = await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => EnterAmountScreen()));
                if (resultAmount != null)
                  setState(() {
                    print(resultAmount);
                    amount = double.parse(resultAmount);
                  });
              },
              // onChanged: (value) => amount = double.tryParse(value),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintStyle: TextStyle(
                  color: amount == null ? Colors.grey[600] : Colors.white,
                  fontSize: amount == null ? 22 : 30.0,
                  fontFamily: 'Montserrat',
                  fontWeight:
                      amount == null ? FontWeight.w500 : FontWeight.w600,
                ),
                hintText: amount == null
                    ? 'Enter amount'
                    : MoneySymbolFormatter(
                            text: amount, currencyId: selectedWallet.currencyID)
                        .formatText,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(70, 0, 0, 0),
            child: Divider(
              color: Colors.white24,
              height: 1,
              thickness: 0.2,
            ),
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
            dense: true,
            leading:
                Icon(Icons.calendar_today, color: Colors.white54, size: 28.0),
            title: TextFormField(
              onTap: () async {
                DatePicker.showDatePicker(context,
                    currentTime: pickDate == null
                        ? DateTime(DateTime.now().year, DateTime.now().month,
                            DateTime.now().day)
                        : pickDate,
                    showTitleActions: true, onConfirm: (date) {
                  if (date != null) {
                    setState(() {
                      pickDate = date;
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
                    color: pickDate == null ? Colors.grey[600] : Colors.white,
                    fontFamily: 'Montserrat',
                    fontSize: 16.0,
                    fontWeight:
                        pickDate == null ? FontWeight.w500 : FontWeight.w600,
                  ),
                  hintText: pickDate ==
                          DateTime.parse(
                              DateFormat("yyyy-MM-dd").format(DateTime.now()))
                      ? 'Today'
                      : pickDate ==
                              DateTime.parse(DateFormat("yyyy-MM-dd").format(
                                  DateTime.now().add(Duration(days: 1))))
                          ? 'Tomorrow'
                          : pickDate ==
                                  DateTime.parse(DateFormat("yyyy-MM-dd")
                                      .format(DateTime.now()
                                          .subtract(Duration(days: 1))))
                              ? 'Yesterday'
                              : DateFormat('EEEE, dd-MM-yyyy')
                                  .format(pickDate)),
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
            dense: true,
            onTap: () async {
              var res = await showCupertinoModalBottomSheet(
                  isDismissible: true,
                  backgroundColor: Colors.grey[900],
                  context: context,
                  builder: (context) =>
                      SelectWalletAccountScreen(wallet: selectedWallet));
              if (res != null)
                setState(() {
                  selectedWallet = res;
                  currencySymbol = CurrencyService()
                      .findByCode(selectedWallet.currencyID)
                      .symbol;
                });
            },
            leading: selectedWallet == null
                ? SuperIcon(iconPath: 'assets/icons/wallet_2.svg', size: 28.0)
                : SuperIcon(iconPath: selectedWallet.iconID, size: 28.0),
            title: TextFormField(
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
                    color: selectedWallet == null
                        ? Colors.grey[600]
                        : Colors.white,
                    fontFamily: 'Montserrat',
                    fontSize: 16.0,
                    fontWeight: selectedWallet == null
                        ? FontWeight.w500
                        : FontWeight.w600,
                  ),
                  hintText: selectedWallet == null
                      ? 'Select wallet'
                      : selectedWallet.name),
              onTap: () async {
                var res = await showCupertinoModalBottomSheet(
                    isDismissible: true,
                    backgroundColor: Colors.grey[900],
                    context: context,
                    builder: (context) =>
                        SelectWalletAccountScreen(wallet: selectedWallet));
                if (res != null)
                  setState(() {
                    selectedWallet = res;
                    currencySymbol = CurrencyService()
                        .findByCode(selectedWallet.currencyID)
                        .symbol;
                    // event = null;
                  });
              },
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
            dense: true,
            leading: Icon(Icons.note, color: Colors.white54, size: 28.0),
            title: TextFormField(
              onTap: () async {
                final noteContent = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => NoteScreen(
                              content: note ?? '',
                            )));
                print(noteContent);
                if (noteContent != null) {
                  setState(() {
                    note = noteContent;
                  });
                }
              },
              readOnly: true,
              autocorrect: false,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500),
                  hintText: note == '' || note == null
                      ? 'Write note'
                      : contact != null
                          ? note + contact
                          : note + 'someone'),
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.white54),
          ),
          ListTile(
            dense: true,
            leading: Icon(Icons.account_balance_outlined,
                color: Colors.white54, size: 28.0),
            title: TextFormField(
              onTap: () async {
                final PhoneContact phoneContact =
                    await FlutterContactPicker.pickPhoneContact();
                if (phoneContact != null) {
                  print(phoneContact.fullName);
                  setState(() {
                    contact = phoneContact.fullName;
                  });
                }
              },
              readOnly: true,
              autocorrect: false,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintStyle: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Montserrat',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500),
                  hintText: contact ?? hintTextConact),
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600),
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
        ]),
      ),
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
