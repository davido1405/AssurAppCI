import 'package:assurappci/Models/AbonnementPharmacie.dart';
import 'package:assurappci/Repositories/AbonnementPharmacieRepository.dart';
import 'package:flutter/foundation.dart';

class Abonnementpharmacieviewmodel extends ChangeNotifier {
  final Abonnementpharmacierepository _abonnementpharmacie;
  Abonnementpharmacieviewmodel(this._abonnementpharmacie);

}