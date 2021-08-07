import 'dart:math';

String convertTokenAmount(String _tokenAmount, String _decimals) {
  print(double.parse(_tokenAmount));
  print(double.parse(_decimals));
  String convertedAmount =
      (int.parse(_tokenAmount) / pow(10, int.parse(_decimals))).toString();
  print(convertedAmount);
  return convertedAmount;
}
