import 'package:assurappci/Models/Pharmacie.dart';
import 'package:assurappci/Repositories/PharmacieRespository.dart';
import 'package:flutter/foundation.dart';

class PharmacieViewModel extends ChangeNotifier {

  //1-Dependances
  final Pharmacierespository _pharmacierespository;
  PharmacieViewModel(this._pharmacierespository);

  //2-Etat
  List<Pharmacie> _pharmacies=[];
  Pharmacie? _pharmacie;
  bool _chargementEnCours=false;
  String? _errorMessage;
  //3-Getters
  List<Pharmacie> get pharmacies=>_pharmacies;
  bool get chargementEnCours=>_chargementEnCours;
  String? get errorMessage=>_errorMessage;
  //4-Initialisation
  Future<List<Pharmacie>>init()async{
    _chargementEnCours=true;
    notifyListeners();
    try{
      _pharmacies= await _pharmacierespository.recupererPharmacie()??[];
    } catch (e) {
      _errorMessage = 'Impossible de charger les assurances.';
    } finally {
      _chargementEnCours = false;
      notifyListeners();
    }

    return _pharmacies;
  }

  Future<Pharmacie?>recupererProfilPharmacie(String codePharmacie) async{
    _chargementEnCours=true;
    _errorMessage=null;
    notifyListeners();

    //Récupérer maintenant
    try{
       _pharmacie=await _pharmacierespository.recupererProfilPharmacie(codePharmacie) as Pharmacie;
    }catch(e){
      _errorMessage="Impossible de récupérer le profil de la pharmacie";
    }finally{
      _chargementEnCours=false;
      notifyListeners();
    }

    return _pharmacie;
  }
}