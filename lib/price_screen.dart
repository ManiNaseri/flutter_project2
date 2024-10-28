import 'dart:convert';

import 'package:cointracker/models/coin_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cointracker/constants.dart';
import 'package:intl/intl.dart';
import 'package:cointracker/utilities/coin_data.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class PriceScreen extends StatefulWidget {
  const PriceScreen({super.key});

  @override
  State<PriceScreen> createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = 'USD';

  List<CoinModel> coinList = [];

  List<Image> imageList = [
    Image(image: AssetImage("images.BTC.png"),),
    Image(image: AssetImage("images.ETH.png"),),
    Image(image: AssetImage("images.TON.png"),)
  ];

  List<DropdownMenuItem<String>> dropdownItems = [];

  InputDecorator getInputDecoration() {
    dropdownItems = [];
    for (String currency in currenciesList) {
      var newItem = DropdownMenuItem(child: Text(currency), value: currency);
      dropdownItems.add(newItem);
    }
    return InputDecorator(
      decoration: const InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          isExpanded: true,
          value: selectedCurrency,
          items: dropdownItems,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedCurrency = value;
                getCoinData(selectedCurrency);
              });
            }
          },
          dropdownColor: Color(0xFF303030),
        ),
      ),
    );
  }

  CupertinoPicker getCupertino() {
    List<Text> cupertinoItems = [];
    for (String currency in currenciesList) {
      cupertinoItems.add(Text(currency));
    }
    return CupertinoPicker(
      itemExtent: 32,
      onSelectedItemChanged: (itemIndex) {
        setState(() {
          selectedCurrency = currenciesList[itemIndex];
          getCoinData(selectedCurrency);
        });
      },
      children: cupertinoItems,
    );
  }

  void getCoinData(String currency) async {
    coinList = [];
    for (String crypto in cryptoList) {
      try {
        http.Response response = await http.get(Uri.parse(
            "https://rest.coinapi.io/v1/exchangerate/$crypto/$currency?apikey=8EA1DC7B-4730-4C20-8EA7-9EE006E9B776"));
        if (response.statusCode == 200) {
          var alldata = response.body;
          var decodeddata = jsonDecode(alldata);
          coinList.add(CoinModel(
              icon: crypto,
              name: crypto,
              price: decodeddata['rate']));
        } else {
          print(response.statusCode);
        }
      } catch (e) {
        print(e);
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getCoinData(selectedCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF303030),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage("images/coin.png"),
                    width: 100,
                  ),
                  SizedBox(width: 16),
                  Text(
                    "Coin Tracker",
                    style: kCoinTrackerTextStyle,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: ListView.separated(
                itemCount: coinList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.currency_bitcoin_rounded , size: 50,),
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            const Text(
                              "1",
                              style: TextStyle(fontSize: 18, color: Colors.white30),
                            ),
                            Text(
                              coinList[index].name!,
                              style: TextStyle(color: Colors.white30, fontSize: 15),
                            )
                          ],
                        )
                      ],
                    ),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat("#,###.0##").format(coinList[index].price),
                          style: TextStyle(fontSize: 18, color: Colors.white30),
                        ),
                        Text(selectedCurrency),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: Platform.isIOS ? 0 : 16),
              child: Platform.isIOS ? getCupertino() : getInputDecoration(),
            ),
          ],
        ),
      ),
    );
  } 
}