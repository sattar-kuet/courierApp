import 'package:awesome_select/awesome_select.dart';
import 'package:flutter/material.dart';
import '../common/menu_drawer.dart';
import '../common/bottom_navigation.dart';
import '../common/floating_button.dart';
import '../data/service.dart';
import '../form_components/numberInput.dart';
import '../form_components/textInput.dart';
import '../model/bank.dart';

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
  int bankId = 0;
  int bankType = -1;
  List<S2Choice<int>> banks = [];
  Map<int, int> mobileBanksHashTable = {};
  int mobileBankAccountType = 0;
  void initState() {
    super.initState();
    updateBankList();
  }

  updateBankList() async {
    var _bankList = await Service().getBankList();
    for (var i = 0; i < _bankList.length; i++) {
      int id = _bankList[i]['id'];
      String name = _bankList[i]['name'];
      int type = _bankList[i]['type'];
      setState(() {
        banks.add(S2Choice<int>(value: id, title: name));
        mobileBanksHashTable[id] = type;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20.0),
                    child: SmartSelect<int>.single(
                      placeholder: "নির্বাচন করুন",
                      modalFilter: true,
                      modalFilterAuto: true,
                      tileBuilder: (context, state) => S2Tile<dynamic>(
                        //https://github.com/akbarpulatov/flutter_awesome_select/blob/master/example/lib/features_single/single_chips.dart
                        title: const Text(
                          'কোন ব্যাংক এ টাকা নিতে চান?',
                        ),
                        value: state.selected?.toWidget() ?? Container(),
                        onTap: state.showModal,
                      ),
                      title: 'কোন ব্যাংক এ টাকা নিতে চান?',
                      choiceItems: banks,
                      onChange: (state) async {
                        setState(() {
                          bankId = state.value!;
                          bankType = mobileBanksHashTable[bankId] as int;
                          //updateAreaList();
                        });
                      },
                      selectedValue: bankId,
                    ),
                  ),
                  bankType == Bank.MOBILE_BANK
                      ? mobileBanking()
                      : normalBanking(),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveBank(context);
                      }
                    },
                    child: Text('Save'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
      floatingActionButton: floating,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
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
              label: "মোবাইল নাম্বার",
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
                        value: Bank.PEROSANL,
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
                        value: Bank.MERCHANT,
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

  void _saveBank(BuildContext context) {
    print('bankId {$bankId}');

    print('type {$bankType}');
  }

  Container normalBanking() {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
            child: textInput(
              label: "একাউন্ট এর নাম",
              inputController: accountNameController,
              inputIcon: Icon(Icons.verified_user),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
            child: numberInput(
              label: "একাউন্ট নাম্বার",
              inputController: accountNumberController,
              inputIcon: Icon(Icons.cases_sharp),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
            child: textInput(
              label: "ব্রাঞ্চ এর নাম",
              inputController: accountBranchController,
              inputIcon: Icon(Icons.anchor),
            ),
          ),
        ],
      ),
    );
  }
}
