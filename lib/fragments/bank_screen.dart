import 'package:awesome_select/awesome_select.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/widget/button.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../common/menu_drawer.dart';
import '../common/bottom_navigation.dart';
import '../common/floating_button.dart';
import '../service/bank_service.dart';
import '../form_components/numberInput.dart';
import '../form_components/textInput.dart';
import '../model/bank.dart';
import '../model/mobile_bank.dart';
import '../constants.dart' as Constents;

class BankScreen extends StatefulWidget {
  static const String routeName = '/bankPage';

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController accountBranchController = TextEditingController();
  static const MOBILE_BANK = Constents.BankAccountType.MOBILE;
  static const BANK = Constents.BankAccountType.NORMAL;
  int bankType = -1;
  int bankId = -1;
  bool bankListLoadingDone = false;
  List<S2Choice<int>> banks = [];
  Map<int, int> mobileBanksHashTable = {};
  int mobileBankAccountType = 0;
  Bank bank = new Bank(0, '', '', '', BANK);
  MobileBank mobileBank = new MobileBank(0, '', 0, MOBILE_BANK);

  void initState() {
    super.initState();
    BankService().getBankList(context).then((_bankList) {
      for (var i = 0; i < _bankList.length; i++) {
        int id = _bankList[i]['id'];
        String name = _bankList[i]['name'];
        int type = _bankList[i]['type'];
        setState(() {
          banks.add(S2Choice<int>(value: id, title: name));
          mobileBanksHashTable[id] = type;
          bankListLoadingDone = true;
        });
      }
    });
    BankService().getBank(context).then((response) {
      setState(() {
        if (response != null) {
          bankId = response.bankId;
          bankType = response.bankType;
          switch (bankType) {
            case MOBILE_BANK:
              mobileBank = response;
              mobileNumberController.text = mobileBank.mobileNumber;
              mobileBankAccountType = mobileBank.accountType;
              break;
            case BANK:
              bank = response;
              accountNameController.text = bank.accountName;
              accountNumberController.text = bank.accountNumber;
              accountBranchController.text = bank.branch;
              break;
          }
        } else {
          bankId = 0;
        }
        // bankType = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    if (banks.length == 0) {
      return Scaffold(
        drawer: MenuDrawer(),
        appBar: AppBar(
          title: Text("Bank"),
        ),
        body: Center(
          // Aligns the container to center
          child: Container(
              // A simplified version of dialog.
              width: 100.0,
              height: 56.0,
              color: Colors.transparent,
              child: SpinKitThreeInOut(
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: EdgeInsets.only(right: 3),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: index.isEven
                            ? Color.fromARGB(255, 20, 17, 17)
                            : Colors.green,
                      ),
                    ),
                  );
                },
              )),
        ),
      );
    } else {
      return new Scaffold(
        appBar: AppBar(
          title: Text("Bank"),
        ),
        drawer: MenuDrawer(),
        body: SingleChildScrollView(
          child: new Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    bankListLoadingDone && bankId >= 0
                        ? selectBank()
                        : Container(),
                    bankType != -1 ? showDetail() : Container(),
                    bankType != -1
                        ? CustumButtom(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _saveBank(context);
                              }
                            },
                            text: 'Save',
                          )
                        : Container()
                  ],
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigation(),
        floatingActionButton: Visibility(
          visible: !keyboardIsOpen,
          child: floating(context),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      );
    }
  }

  Padding selectBank() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
      child: SmartSelect<int>.single(
        placeholder: "???????????????????????? ????????????",
        modalFilter: true,
        modalFilterAuto: true,
        tileBuilder: (context, state) => S2Tile<dynamic>(
          //https://github.com/akbarpulatov/flutter_awesome_select/blob/master/example/lib/features_single/single_chips.dart
          title: const Text(
            '????????? ?????????????????? ??? ???????????? ???????????? ??????????',
          ),
          value: state.selected?.toWidget() ?? Container(),
          onTap: state.showModal,
        ),
        title: '????????? ?????????????????? ??? ???????????? ???????????? ??????????',
        choiceItems: banks,
        onChange: (state) async {
          setState(() {
            bankId = state.value!;
            bankType = mobileBanksHashTable[bankId] as int;
          });
        },
        selectedValue: bankId,
      ),
    );
  }

  dynamic showDetail() {
    return bankType == MOBILE_BANK ? mobileBanking() : normalBanking();
  }

  Container mobileBanking() {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20.0,
            ),
            child: numberInput(
              label: "?????????????????? ?????????????????????",
              inputController: mobileNumberController,
              inputIcon: Icon(Icons.phone),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Radio(
                        value: MobileBank.PEROSANL,
                        groupValue: mobileBankAccountType,
                        onChanged: (value) {
                          setState(() {
                            mobileBankAccountType = value as int;
                          });
                        },
                      ),
                      Expanded(
                        child: Text('Personal'),
                      )
                    ],
                  ),
                  flex: 1,
                ),
                Expanded(
                  child: Row(
                    children: [
                      Radio(
                        value: MobileBank.MERCHANT,
                        groupValue: mobileBankAccountType,
                        onChanged: (value) {
                          setState(() {
                            mobileBankAccountType = value as int;
                          });
                        },
                      ),
                      Expanded(
                        child: Text('Merchant'),
                      )
                    ],
                  ),
                  flex: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container normalBanking() {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
            child: textInput(
              label: "????????????????????? ?????? ?????????",
              inputController: accountNameController,
              inputIcon: Icon(Icons.verified_user),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
            child: numberInput(
              label: "????????????????????? ?????????????????????",
              inputController: accountNumberController,
              inputIcon: Icon(Icons.cases_sharp),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
            child: textInput(
              label: "????????????????????? ?????? ?????????",
              inputController: accountBranchController,
              inputIcon: Icon(Icons.anchor),
            ),
          ),
        ],
      ),
    );
  }

  void _saveBank(BuildContext context) {
    var data = {};
    switch (bankType) {
      case MOBILE_BANK:
        data['bank'] = {
          'bankId': bankId,
          'bankType': bankType,
          'mobileNumber': mobileNumberController.text,
          'accountType': mobileBankAccountType,
        };
        break;
      case BANK:
        data['bank'] = {
          'bankId': bankId,
          'bankType': bankType,
          'accountName': accountNameController.text,
          'accountNumber': accountNumberController.text,
          'branchName': accountBranchController.text,
        };
        break;
    }
    //print(data);
    BankService().saveBank(data, context);
  }
}
